unit game;

{$mode objfpc}{$H+}
{$R *.lfm}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, windows;
type

  { TFgame }

  TFgame = class(TForm)
    livesCounter: TLabel;
    pad: TImage;
    ball: TImage;
    score: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure go();
    procedure movePad(o: integer);
    procedure genj();
    procedure Timer1Timer(Sender: TObject);
    function upravSmer(lastL, lastT: integer) : integer;
    function odraz(lastL, lastT, odkial : integer) : integer;
    procedure addScore(kolko : integer);
    procedure addToGrid(var what : TImage; typ, id : integer);
    procedure removeFromGrid(var what : TImage);
    procedure clearGrid();
    procedure respawnPad();
    procedure resetAll();
    function normalize360(smer : integer) : integer;
    procedure win();
    procedure lose();
    procedure modLife(kolko : integer);
    procedure despawnBricks();
    procedure despawnBrick(index : integer);
  private
    { private declarations }
  public
    { public declarations }
  end;
type
  gridPoint = record
    typ : integer;
    id : integer;
  end;

var
  Fgame: TFgame;
  grid: array[0..2000,0..2000] of gridPoint;
  things: array[0..5,0..5000] of TImage;
  left : array[0..5] of integer;
  rem : array[0..5] of integer;
  // 0 bricks
  // 1 pad placeholder, nothing is added
  pause, finished: boolean;
  pi: real;
  xleft, yleft: real;
  smer, PADspeed, lives, BALLspeed, fillPercent: integer;

implementation

uses mainmenu;

procedure TFgame.resetAll();
begin
  clearGrid();
  BALLspeed := 5;
  PADspeed := 20;
  finished := false;
  lives := 5;
  fillPercent := 20;
  modLife(0);
  genj();
  respawnPad();
end;

procedure TFgame.respawnPad();
begin
  pause := true;
  xleft := 0;
  yleft := 0;
  removeFromGrid(pad);
  pad.Left:= 232;
  pad.Top:= 456;
  ball.Left:= 232;
  ball.Top:= 372;
  addToGrid(pad, 1, 0);
  smer := normalize360(290 + random(140));
end;

procedure TFgame.genj();
var i, j : integer;
begin
  despawnBricks();
  rem[0] := 0;
  for i := 1 to (width div 20) - (width div (20 * 20)) - 1 do
    for j := 1 to ((height - 100) div 10) - ((height - 100) div (10 * 10)) - 1 do
      if (random(100 div 20) = 1) then begin
        things[0][rem[0]] := TImage.Create(self);
        things[0][rem[0]].Parent := Self;
        things[0][rem[0]].Left:= i * 20 + i;
        things[0][rem[0]].top:= j * 10 + j;
        things[0][rem[0]].Width := 18;
        things[0][rem[0]].Height := 8;
        things[0][rem[0]].Canvas.Brush.Color := rgbtocolor(random(255),random(255),random(255));
        things[0][rem[0]].Canvas.FillRect(clientrect);
        addToGrid(things[0][rem[0]], 0, rem[0]);
        inc(rem[0]);
      end;
  dec(rem[0]);
end;

procedure TFgame.FormCreate(Sender: TObject);
var i, j : integer;
begin
   pi := 3.1459;
   for i := 0 to 5 do
     for j := 0 to 5000 do
       things[i][j] := NIL;
end;

procedure TFgame.FormKeyPress(Sender: TObject; var Key: char);
begin
  case Key of
  'a': movePad(-1);
  'd': movePad(1);
  'p': pause := true;
  end;
end;

function _round(num : real; var rem : real) : integer;
var tmp : real;
begin
  tmp := num + rem;
  num := round(tmp);
  rem := tmp - num;
  _round := round(num);
end;

procedure TFgame.go();
var lastT, lastL, i : integer;
begin
  lastT := ball.Top;
  lastL := ball.Left;
  for i := 1 to BALLspeed do begin
    ball.left:= ball.left + _round(sin(smer / 180 * pi), xleft);
    ball.top:= ball.top - _round(cos(smer / 180 * pi), yleft);
    smer := upravSmer(lastL, lastT);
  end;
end;

procedure TFgame.movePad(o: integer);
begin
  if (pause) then pause := false; // unpause on pad moving
  removeFromGrid(pad);
  pad.Left:= pad.Left + o * PADspeed;
  // prevent going out of window
  if pad.Left <= 0 then pad.Left:= 1;
  if pad.Left + pad.Width > width then pad.Left:= width - pad.Width;
  addToGrid(pad, 1, 0);
end;

procedure TFgame.Timer1Timer(Sender: TObject);
begin
  if (pause = false) and (finished = false) then
    go();
end;

procedure TFgame.win();
begin
  finished := true;
  Fgame.Hide;
  Fmenu.Show;
end;

procedure TFgame.lose();
begin
  finished := true;
  Fgame.Hide;
  Fmenu.Show;
end;

function TFgame.upravSmer(lastL, lastT: integer) : integer;
var i, j, radius, sx, sy : integer;
begin
// Kraje hracieho pola
  // vrch
  if (ball.Top <= 0)  then begin
    upravSmer := odraz(lastL, lastT, 4);
    ball.Top:= 1;
    exit;
  end;

  // lava stena
  if (ball.left <= 0) then begin
    upravSmer := odraz(lastL, lastT, 1); exit;
  end;

  // prava stena
  if (ball.left + ball.Width >= width) then begin
    upravSmer := odraz(lastL, lastT, 2); exit;
  end;

  // spodok -> prehra
  if (ball.Top {+ (ball.Height div 2)} >= height) then begin
    modLife(-1);
    respawnPad;
  end;

  // ostatne
  sx := (2 * ball.Left + ball.Width) div 2 ;
  sy := (2 * ball.Top + ball.Height) div 2 ;
  radius := sy - ball.Top;

  for i := ball.Left to ball.Left + ball.Width do
    for j := ball.Top to ball.Top + ball.Height do
      begin
        // is not within ball
        if ((i - sx) * (i - sx) + (j - sy) * (j - sy) > radius * radius) then
          continue;

        // empty grid point
        if grid[i][j].typ = -1 then
          continue;

        case grid[i][j].typ of
          1 : begin // pad
            upravSmer := odraz(lastL, lastT, 3);
            ball.Top:= pad.Top - ball.Height - 1; // HACK proti odrazaniu lopty od krajov padu
            addScore(1);
            exit;
          end;
          0 : begin // tehla
            despawnBrick(grid[i][j].id);
            addScore(10);
            // vypocitaj odraz
            //upravSmer := odraz(lastL, lastT, random(3) + 1);
            //exit;
          end;
        end;
      end;
  upravSmer := smer;
end;

procedure TFgame.despawnBrick(index : integer);
begin
  if things[0][index] <> NIL then begin
    removeFromGrid(things[0][index]);
    things[0][index].Destroy;
    things[0][index] := NIL;
    dec(rem[0]);
    if rem[0] = -1 then win();
  end;
end;

procedure TFgame.despawnBricks();
var i : integer;
begin
  for i := 0 to 5000 do
    if things[0][i] <> NIL then begin
      removeFromGrid(things[0][i]);
      things[0][i].Destroy;
      things[0][i] := NIL;
    end;
end;

procedure TFgame.modlife(kolko : integer);
begin
  lives := lives + kolko;
  livesCounter.Caption:= IntToStr(lives);
  if (lives < 1) then lose();
end;

function TFgame.normalize360(smer : integer) : integer;
begin
  while (smer > 360) do smer := smer - 360;
  while (smer < 0 ) do smer := smer + 360;
  normalize360 := smer;
end;

function TFgame.odraz(lastL, lastT, odkial : integer) : integer;
begin
  case odkial of
    1, 2 : begin // lava, prava
      odraz := 360 - smer;
      exit;
    end;
    3 : begin // spodna
      if (lastL < ball.left) then
        begin odraz := 180 - smer; exit; end
      else
        begin odraz := 540 - smer; exit; end;
    end;
    4 : begin // horna
      if (lastL < ball.left) then
        begin odraz := abs(smer - 90) + 90; exit; end
      else
        begin odraz := 540 - smer; exit; end;
    end;
  end;
end;

procedure TFgame.addScore(kolko : integer);
var i : integer;
begin
  Val(score.Caption, i);
  score.Caption := IntToStr(i + kolko);
end;

procedure TFgame.removeFromGrid(var what : TImage);
var i, j : integer;
begin
  for i := what.Left to what.Left + what.Width do
    for j := what.Top to what.Top + what.Height do
      grid[i][j].typ := -1;
end;

procedure TFgame.addToGrid(var what : TImage; typ, id : integer);
var i, j : integer;
begin
  for i := what.Left to what.Left + what.Width do
    for j := what.Top to what.Top + what.Height do
      begin
        grid[i][j].typ := typ;
        grid[i][j].id := id;
    end;
end;

procedure TFgame.clearGrid();
var i, j : integer;
begin
  for i := 0 to 2000 do
    for j := 0 to 2000 do
      grid[i][j].typ := -1;
end;

end.


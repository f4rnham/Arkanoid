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
    procedure addToGrid(var what : TImage);
    procedure removeFromGrid(var what : TImage);
    procedure clearGrid();
    procedure respawnPad();
    procedure resetAll();
    function normalize360(smer : integer) : integer;
    procedure win();
    procedure lose();
    procedure modLife(kolko : integer);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Fgame: TFgame;
  grid: array[0..2000,0..2000] of pointer;
  bricks: array[0..5000] of TImage;
  pause, finished: boolean;
  pi: real;
  xleft, yleft: real;
  smer, PADspeed, bricksLeft, lives, BALLspeed, fillPercent: integer;

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
  addToGrid(pad);
  smer := normalize360(290 + random(140));
end;

procedure TFgame.genj();
var i, j : integer;
begin
  bricksLeft := 0;
  for i := 1 to (width div 20) - (width div (20 * 20)) - 1 do
    for j := 1 to ((height - 100) div 10) - ((height - 100) div (10 * 10)) - 1 do
      if (random(100 div 20) = 1) then begin
        bricks[bricksLeft] := TImage.Create(self);
        bricks[bricksLeft].Parent := Self;
        bricks[bricksLeft].Left:= i * 20 + i;
        bricks[bricksLeft].top:= j * 10 + j;
        bricks[bricksLeft].Width := 18;
        bricks[bricksLeft].Height := 8;
        bricks[bricksLeft].Canvas.Brush.Color := rgbtocolor(random(255),random(255),random(255));
        bricks[bricksLeft].Canvas.FillRect(clientrect);
        addToGrid(bricks[bricksLeft]);
        inc(bricksLeft);
      end;
end;

procedure TFgame.FormCreate(Sender: TObject);
begin
   randomize;
   pi := 3.1459;
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
  _round := round (num);
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
  // normalize
  if pad.Left <= 0 then pad.Left:= 1;
  if pad.Left + pad.Width > width then pad.Left:= width - pad.Width;
  addToGrid(pad);
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
var temp : TImage;
  i, j : integer;
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
  for i := ball.Left to ball.Left + ball.Width do
    for j := ball.Top to ball.Top + ball.Height do
      if grid[i][j] <> NIL then begin
        // pad
        if grid[i][j] = @pad then begin
          upravSmer := odraz(lastL, lastT, 3);
          ball.Top:= pad.Top - ball.Height - 1; // HACK proti odrazaniu lopty od krajov padu
          addScore(1);
          exit;
        end;
        // tehla
        temp := TImage(grid[i][j]^);
        removeFromGrid(temp);
        addScore(10);
        // vypocitaj odraz
        // odraz
        temp.Destroy;
        dec(bricksLeft);
        if (bricksLeft = 0) then win;

      end;



  upravSmer := smer;
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
    1 : begin // lava
      if lastT < ball.Top then
        begin odraz := 360 - smer; exit; end
      else
        begin odraz := 360 - smer; exit; end;
    end;
    2 : begin // prava
      if lastT < ball.Top then
        begin odraz := 360 - smer; exit; end
      else
        begin odraz := 360 - smer; exit; end;
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
      grid[i][j] := NIL;
end;

procedure TFgame.addToGrid(var what : TImage);
var i, j : integer;
begin
  for i := what.Left to what.Left + what.Width do
    for j := what.Top to what.Top + what.Height do
      grid[i][j] := @what;
end;

procedure TFgame.clearGrid();
var i, j : integer;
begin
  for i := 0 to 2000 do
    for j := 0 to 2000 do
      grid[i][j] := NIL;
end;

end.


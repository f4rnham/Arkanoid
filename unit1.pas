unit Unit1;

{$mode objfpc}{$H+}
{$R *.lfm}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, windows;
type

  { TMAIN }

  TMAIN = class(TForm)
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
    procedure resetALl();
    function normalize180(smer : integer) : integer;
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
  MAIN: TMAIN;
  grid: array[0..2000,0..2000] of pointer;
  bricks: array[0..500] of TImage;
  pause, finished: boolean;
  pi: real;
  i, j : integer;
  smer, BALLspeed, PADspeed, bricksLeft, lives: integer;

implementation

procedure TMAIN.resetAll();
begin
  clearGrid();
  BALLspeed := 5;
  PADspeed := 20;
  bricksLeft := 20;
  finished := false;
  lives := 5;
  modLife(0);
  genj();
  respawnPad();
end;

procedure TMAIN.respawnPad();
begin
  pause := true;
  removeFromGrid(pad);
  pad.Left:= 232;
  pad.Top:= 456;
  ball.Left:= 232;
  ball.Top:= 372;
  addToGrid(pad);
  smer := normalize360(290 + random(140));
end;

procedure TMAIN.genj();
var i : integer;
begin
   for i := 1 to bricksLeft do begin
     bricks[i] := TImage.Create(self);
     bricks[i].Parent := Self;
     bricks[i].Left:= random(Width - 10) + 5;
     bricks[i].top:= random(height) - (height - pad.Top - 20);
     bricks[i].Width:=10;
     bricks[i].Height:=10;
     bricks[i].Canvas.Brush.Color := rgbtocolor(random(255),random(255),random(255));
     bricks[i].Canvas.FillRect(clientrect);
     addToGrid(bricks[i]);
   end;
end;

procedure TMAIN.FormCreate(Sender: TObject);
begin
   randomize;
   pi := 3.1459;
   resetAll();
end;

procedure TMAIN.FormKeyPress(Sender: TObject; var Key: char);
begin
  case Key of
  'a': movePad(-1);
  'd': movePad(1);
  'p': pause := true;
  end;
end;

procedure TMAIN.go();
var lastT, lastL : integer;
begin
  lastT := ball.Top;
  lastL := ball.Left;
  ball.left:= ball.left + round(BALLspeed * sin(smer / 180 * pi));
  ball.top:= ball.top - round(BALLspeed * cos(smer / 180 * pi));

  smer := upravSmer(lastL, lastT);
end;

procedure TMAIN.movePad(o: integer);
begin
  if (pause) then pause := false; // unpause on pad moving
  removeFromGrid(pad);
  pad.Left:= pad.Left + o * PADspeed;
  // normalize
  if pad.Left <= 0 then pad.Left:= 1;
  if pad.Left + pad.Width > width then pad.Left:= width - pad.Width;
  addToGrid(pad);
end;

procedure TMAIN.Timer1Timer(Sender: TObject);
begin
  if (pause = false) and (finished = false) then
    go();
end;

procedure TMAIN.win();
begin
  finished := true;
end;

procedure TMAIN.lose();
begin
  finished := true;
end;

function TMAIN.upravSmer(lastL, lastT: integer) : integer;
var temp : TImage;
begin
// Kraje hracieho pola
  // vrch
  if (ball.Top <= 0)  then begin
    upravSmer := odraz(lastL, lastT, 4); exit;
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
  if (ball.Top + ball.Height >= height) then begin
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

procedure TMAIN.modlife(kolko : integer);
begin
  lives := lives + kolko;
  livesCounter.Caption:= IntToStr(lives);
  if (lives < 1) then lose();
end;

function TMAIN.normalize180(smer : integer) : integer;
begin
  while (smer > 360) do smer := smer - 180;
  while (smer < 0 ) do smer := smer + 180;
  normalize180 := smer;
end;

function TMAIN.normalize360(smer : integer) : integer;
begin
  while (smer > 360) do smer := smer - 360;
  while (smer < 0 ) do smer := smer + 360;
  normalize360 := smer;
end;

function TMAIN.odraz(lastL, lastT, odkial : integer) : integer;
begin
  case odkial of
    1 : begin // lava
      if lastT < ball.Top then
        begin odraz := normalize180(180 - smer); exit; end
      else
        begin odraz := normalize180(90 - (smer - 90)); exit; end;
    end;
    2 : begin // prava
      if lastT < ball.Top then
        begin odraz := normalize180(270 - (smer - 270)); exit; end
      else
        begin odraz := normalize180(360 - (smer - 180)); exit; end;
    end;
    3 : begin // spodna
      if (lastL < ball.left) then
        begin odraz := normalize180(90 - (smer - 90)); exit; end
      else
        begin odraz := normalize180(360 - (smer - 180)); exit; end;
    end;
    4 : begin // horna
      if (lastL < ball.left) then
        begin odraz := normalize180(-smer); exit; end
      else
        begin odraz := normalize180(270 - (smer - 270)); exit; end;
    end;
  end;
end;

procedure TMAIN.addScore(kolko : integer);
begin
  Val(score.Caption, i);
  score.Caption := IntToStr(i + kolko);
end;

procedure TMAIN.removeFromGrid(var what : TImage);
begin
  for i := what.Left to what.Left + what.Width do
    for j := what.Top to what.Top + what.Height do
      grid[i][j] := NIL;
end;

procedure TMAIN.addToGrid(var what : TImage);
begin
  for i := what.Left to what.Left + what.Width do
    for j := what.Top to what.Top + what.Height do
      grid[i][j] := @what;
end;

procedure TMAIN.clearGrid();
begin
  for i := 0 to 2000 do
    for j := 0 to 2000 do
      grid[i][j] := NIL;
end;

end.


unit Unit1;

{$mode objfpc}{$H+}
{$R *.lfm}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls;
type

  { TMAIN }

  TMAIN = class(TForm)
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
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MAIN: TMAIN;
  grid: array[0..2000,0..2000] of pointer;
  hit: array[0..500] of TImage;
  pi: real;
  i, j : integer;
  smer, BALLspeed, PADspeed : integer;

implementation

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

procedure TMAIN.genj();
begin
   for i := 0 to 20 do begin
     hit[i] := timage.Create(self);
     hit[i].Parent := Self;
     hit[i].Left:= random(Width - 10) + 5;
     hit[i].top:= random(height) - (height - pad.Top - 20);
     hit[i].Width:=10;
     hit[i].Height:=10;
     hit[i].Canvas.Brush.Color := rgbtocolor(random(255),random(255),random(255));
     hit[i].Canvas.FillRect(clientrect);

   end;
end;

procedure TMAIN.FormCreate(Sender: TObject);
begin
   // grid to NIL
   for i := 0 to 2000 do
     for j := 0 to 2000 do
       grid[i][j] := NIL;
   randomize;
   // config
   pi := 3.1459;
   smer := 10;
   BALLspeed := 5;
   PADspeed := 20;
   // init grid
   genj();
   addToGrid(pad);
end;

procedure TMAIN.FormKeyPress(Sender: TObject; var Key: char);
begin
  case Key of
  'a': movePad(-1);
  'd': movePad(1);
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
  removeFromGrid(pad);
  pad.Left:= pad.Left + o * PADspeed;
  // normalize
  if pad.Left <= 0 then pad.Left:= 1;
  if pad.Left + pad.Width > width then pad.Left:= width - pad.Width;
  addToGrid(pad);
end;

procedure TMAIN.Timer1Timer(Sender: TObject);
begin
    go();
end;

function normalize(smer : integer) : integer;
begin
  while (smer > 360) do smer := smer - 180;
  while (smer < 0 ) do smer := smer + 180;
  normalize := smer;
end;

function TMAIN.odraz(lastL, lastT, odkial : integer) : integer;
begin
  case odkial of
    1 : begin // lava
      if lastT < ball.Top then
        begin odraz := normalize(180 - smer); exit; end
      else
        begin odraz := normalize(90 - (smer - 90)); exit; end;
    end;
    2 : begin // prava
      if lastT < ball.Top then
        begin odraz := normalize(270 - (smer - 270)); exit; end
      else
        begin odraz := normalize(360 - (smer - 180)); exit; end;
    end;
    3 : begin // spodna
      if (lastL < ball.left) then
        begin odraz := normalize(90 - (smer - 90)); exit; end
      else
        begin odraz := normalize(360 - (smer - 180)); exit; end;
    end;
    4 : begin // horna
      if (lastL < ball.left) then
        begin odraz := normalize(-smer); exit; end
      else
        begin odraz := normalize(270 - (smer - 270)); exit; end;
    end;
  end;
end;

function TMAIN.upravSmer(lastL, lastT: integer) : integer;
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

  // spodok -> prehra??
  if (ball.Top + ball.Height >= height) then begin
    upravSmer := odraz(lastL, lastT, 3); exit;
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
        //TImage(@grid[i][j]);



      end;



  upravSmer := smer;
end;

end.


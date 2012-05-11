unit game;

{$mode objfpc}{$H+}
{$R *.lfm}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, windows, highscore, helpers, ballhandler;
type

  { TFgame }

  TFgame = class(TForm)
    livesCounter: TLabel;
    pad: TImage;
    score: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure movePad(o: integer);
    procedure genj();
    procedure Timer1Timer(Sender: TObject);
    procedure addScore(kolko : integer);
    procedure addToGrid(var what : TImage; typ, id : integer);
    procedure removeFromGrid(var what : TImage);
    procedure clearGrid();
    procedure respawnPad();
    procedure win();
    procedure lose();
    procedure modLife(kolko : integer);
    procedure despawnBricks();
    procedure despawnBrick(index : integer);
    procedure init(nejm: string; fillP, l : integer);
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
  rem : array[0..5] of integer;
  // 0 bricks
  // 1 pad placeholder, nothing is added
  balls : array[0..500] of Tball;
  ballCnt: integer;
  pause, finished: boolean;
  pi: real;
  PADspeed, lives, fillPercent: integer;
  Pname : string;

implementation

uses mainmenu;

procedure TFgame.init(nejm : string; fillP, l : integer);
begin
  clearGrid();
  Pname := nejm;
  fillPercent := fillP;
  lives := l;

  // default
  ballCnt := 0;
  PADspeed := 40;
  finished := false;
  modLife(0);
  genj();
  respawnPad();
end;

procedure TFgame.respawnPad();
var i : integer;
begin
  pause := true;

  // balls
  for i := 0 to ballCnt do
    if balls[i].created then begin
      balls[i].ball.Destroy();
      balls[i].created:= false;
    end;
  ballCnt := 0;
  balls[0].init(372, 232, normalize360(290 + random(140)), 5);
  Fgame.SetChildZPosition(balls[0].ball, 0);

  // pad
  removeFromGrid(pad);
  pad.Left:= 232;
  pad.Top:= 456;
  addToGrid(pad, 1, 0);
end;

procedure TFgame.genj();
var i, j : integer;
begin
  despawnBricks();
  rem[0] := 0;
  for i := 1 to (width div 20) - (width div (20 * 20)) - 1 do
    for j := 1 to ((height - 100) div 10) - ((height - 100) div (10 * 10)) - 1 do
      if (random(100) < fillPercent) then begin
        things[0][rem[0]] := TImage.Create(self);
        things[0][rem[0]].Parent := Self;
        things[0][rem[0]].Left:= i * 20 + i;
        things[0][rem[0]].top:= j * 10 + j;
        things[0][rem[0]].Width := 18;
        things[0][rem[0]].Height := 8;
        things[0][rem[0]].Canvas.Brush.Color := randomColor(Fgame.Color);
        things[0][rem[0]].Canvas.FillRect(clientrect);
        addToGrid(things[0][rem[0]], 0, rem[0]);
        inc(rem[0]);
      end;
  dec(rem[0]);
end;

procedure TFgame.FormCreate(Sender: TObject);
var i, j : integer;
begin
  Fgame.DoubleBuffered:= true;
  pause := true;
  pi := 3.1415926535897932384626433832795;
  for i := 0 to 500 do
    balls[i] := Tball.Create;
  for i := 0 to 5 do
    for j := 0 to 5000 do
      things[i][j] := NIL;
end;

procedure TFgame.FormKeyPress(Sender: TObject; var Key: char);
begin
  case Key of
  'a': movePad(-1);
  'd': movePad(1);
  'p': pause := not pause;
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
var i : integer;
begin
  if (pause = false) and (finished = false) then
    for i := 0 to ballCnt do
      balls[i].update();
end;

procedure TFgame.win();
begin
  finished := true;
  FhighScore.updateHS(Pname, _Val(score.Caption));
  Fgame.Hide;
  FhighScore.showHS();
  Fmenu.Show;
end;

procedure TFgame.lose();
begin
  finished := true;
  Fgame.Hide;
  Fmenu.Show;
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
  if lives = -1 then exit;
  lives := lives + kolko;
  livesCounter.Caption:= IntToStr(lives);
  if (lives < 1) then lose();
end;

procedure TFgame.addScore(kolko : integer);
begin
  score.Caption := IntToStr(_Val(score.Caption) + kolko);
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


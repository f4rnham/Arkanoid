unit game;

{$mode objfpc}{$H+}
{$R *.lfm}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, highscore, helpers, ballhandler, bonushandler;
type

  { TFgame }

  TFgame = class(TForm)
    livesCounter: TLabel;
    pad: TImage;
    score: TLabel;
    Timer1: TTimer;
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure movePad(where: integer);
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
    procedure addBrick(x, y : integer; farba : TColor);
    procedure despawnBricks();
    procedure despawnBrick(index : integer);
    procedure init(nejm: string; fillP, l : integer; checked : boolean);
    procedure spawnBall(x, y : integer);
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
  bonuses : array[0..2000] of Tbonus;
  balls : array[0..500] of Tball;
  ballCnt: integer;
  pause, finished: boolean;
  pi: real;
  lives, fillPercent: integer;
  Pname : string;
  roll : integer;

implementation

uses mainmenu;

procedure TFgame.spawnBall(x, y : integer);
begin
  inc(ballCnt);
  balls[ballCnt].init(y, x, random(360), 5);
end;

procedure TFgame.init(nejm : string; fillP, l : integer; checked : boolean);
begin
  clearGrid();
  Pname := nejm;
  fillPercent := fillP;
  lives := l;


  if checked then roll := 2
  else roll := 100;
  // default
  rem[2] := -1; // 0 bonuses falling
  ballCnt := 0;
  finished := false;
  modLife(0);
  genj();
  respawnPad();
end;

procedure TFgame.respawnPad();
var i : integer;
begin
  pause := true;

  // balls cleanup
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

  // destroy bonuses
  for i := 0 to rem[2] do
    if bonuses[i].created then begin
      bonuses[i].bonus.Destroy();
      bonuses[i].created:= false;
    end;
  rem[2] := -1;
end;

procedure TFgame.genj();
var i, j, pol : integer;
  tmpColor : TColor;
begin
  pol := ((width div 20) - (width div (20 * 20)) - 1) div 2;
  despawnBricks();
  rem[0] := 0;
  for i := 1 to pol - 1 do
    for j := 1 to ((height - 100) div 10) - ((height - 100) div (10 * 10)) - 1 do
      if (random(100) < fillPercent) then begin
        tmpColor := randomColor(Fgame.Color);
        addBrick(i * 20 + i, j * 10 + j, tmpColor);
        addBrick((2 * pol - i) * 20 +  2 * pol - i, j * 10 + j, tmpColor);
      end;
  dec(rem[0]);
end;

procedure TFgame.addBrick(x, y : integer; farba : TColor);
begin
  things[0][rem[0]] := TImage.Create(self);
  things[0][rem[0]].Parent := Self;
  things[0][rem[0]].Left:= x;
  things[0][rem[0]].top:= y;
  things[0][rem[0]].Width := 18;
  things[0][rem[0]].Height := 8;
  things[0][rem[0]].Canvas.Brush.Color := farba;
  things[0][rem[0]].Canvas.FillRect(clientrect);
  addToGrid(things[0][rem[0]], 0, rem[0]);
  inc(rem[0]);
end;

procedure TFgame.FormCreate(Sender: TObject);
var i, j : integer;
begin
  Fgame.DoubleBuffered:= true;
  pause := true;
  pi := 3.1415926535897932384626433832795;
  for i := 0 to 500 do begin
    balls[i] := Tball.Create;
    bonuses[i] := Tbonus.Create;
  end;
  for i := 0 to 5 do
    for j := 0 to 5000 do
      things[i][j] := NIL;
end;

procedure TFgame.FormClick(Sender: TObject);
begin
  pause := false;
end;

procedure TFgame.FormKeyPress(Sender: TObject; var Key: char);
begin
  case ord(Key) of
  ord('p'): pause := not pause;
  27: lose();
  end;
end;

procedure TFgame.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  movePad(x);
end;

procedure TFgame.movePad(where: integer);
begin
  removeFromGrid(pad);
  pad.Left:= where;
  // prevent going out of window
  if pad.Left <= 0 then pad.Left:= 1;
  if pad.Left + pad.Width > width then pad.Left:= width - pad.Width;
  addToGrid(pad, 1, 0);
end;

procedure TFgame.Timer1Timer(Sender: TObject);
var i : integer;
begin
  if (pause = false) and (finished = false) then begin
    // update balls
    i := 0;
    while i <= ballCnt do begin
      if balls[i].update() then
        inc(i)
      else begin
        if ballcnt = 0 then begin
          modLife(-1);
          respawnPad;
          exit;
        end;
        balls[i].ball.Destroy;
        balls[i].created:= false;
        if ballCnt <> 0 then begin
          balls[i] := balls[ballCnt];
          balls[ballCnt] := Tball.Create;
        end;
        dec(ballCnt);
      end;
    end;

    // update bonuses
    i := 0;
    while i <= rem[2] do begin
      if not bonuses[i].update() then begin
        bonuses[i].bonus.Destroy;
        bonuses[i].created:= false;
        if rem[2] <> 0 then begin
          bonuses[i] := bonuses[rem[2]];
          bonuses[rem[2]] := Tbonus.Create;
          //bonuses[rem[2]].created:= false;
          //bonuses[rem[2]].bonus.Destroy;
          end;
        dec(rem[2]);
      end
      else
        inc(i);
    end;
  end;
end;

procedure TFgame.win();
begin
  finished := true;
  respawnPad(); // cleanup
  if (FhighScore.updateHS(Pname, _Val(score.Caption))) then
    FhighScore.showHS();
  Fgame.Hide;
  Fmenu.Show;
end;

procedure TFgame.lose();
begin
  finished := true;
  respawnPad(); // cleanup
  if (FhighScore.updateHS(Pname, _Val(score.Caption))) then
    FhighScore.showHS();
  score.Caption:= IntToStr(0);
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


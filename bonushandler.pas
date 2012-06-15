unit bonushandler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, helpers, math;

type
  Tbonus = class
    bonus : TImage;
    speed : integer;
    what : integer;
    procedure init(t, l : integer);
    function update() : boolean;
  end;
implementation

uses game;

procedure Tbonus.init(t, l : integer);
begin
  bonus := TImage.Create(Fgame);
  bonus.Parent := Fgame;
  bonus.Width := 20 + random(10);
  bonus.Height := bonus.Width;
  bonus.Canvas.Brush.Color:= Fgame.Color;
  bonus.Canvas.FillRect(bonus.ClientRect);
  bonus.Canvas.Brush.Color := randomColor(Fgame.Color);
  bonus.Proportional:= true;
  what := random(11)+1;
  case what of
    1 : begin
      bonus.Canvas.Pen.Color:= clRed;
      bonus.Canvas.Pen.Width:= 3;
      bonus.Canvas.Line(0, bonus.Height div 2, bonus.Width, bonus.Height div 2);
      bonus.Canvas.Line(bonus.Width div 2, 0, bonus.Width div 2, bonus.Height);
    end;
    2 : begin
      bonus.Canvas.Pen.Color:= clLime;
      bonus.Canvas.Pen.Width:= 3;
      bonus.Canvas.Line(0, bonus.Height div 2, bonus.Width, bonus.Height div 2);
      bonus.Canvas.Line(bonus.Width div 2, 0, bonus.Width div 2, bonus.Height);
    end;
    3 : begin
      bonus.Canvas.Ellipse(0, 0, bonus.Width, bonus.Height);
    end;
    4 : begin
      bonus.Picture := Fgame.three_balls.Picture;
    end;
    5 : begin
      bonus.Canvas.MoveTo(bonus.Width div 2, 0);
      bonus.Canvas.LineTo(bonus.Width div 2 + bonus.Width div 3, bonus.Height);
      bonus.Canvas.LineTo(0, bonus.Height div 3);
      bonus.Canvas.LineTo(bonus.Width, bonus.Height div 3);
      bonus.Canvas.LineTo(bonus.Width div 2 - bonus.Width div 3, bonus.Height);
      bonus.Canvas.LineTo(bonus.Width div 2, 0);
    end;
    6 : begin
      bonus.Picture := Fgame.enlarge.Picture;
    end;
    7 : begin
      bonus.Picture := Fgame.small.Picture;
    end;
    8 : begin
      bonus.Picture := Fgame.speedup.Picture;
    end;
    9 : begin
      bonus.Picture := Fgame.slow.Picture;
    end;
    10 : begin
      bonus.Picture := Fgame.bigger.Picture;
    end;
    11 : begin
      bonus.Picture := Fgame.smaller.Picture;
    end;


    end;
  //1 score + 100
  //2 score + 1000
  //3 1 ball
  //4 3 ball
  //5
  //6 + pad size
  //7 - pad size
  //8 + ball speed
  //9 - ball speed
  //10 + ball size
  //11 - ball size
  bonus.Visible:= true;
  bonus.Left:= l;
  bonus.Top:= t;
  speed := 1 + random(2);
end;

function Tbonus.update() : boolean;
var i : integer;
begin
  update := true;
  bonus.Top := bonus.Top + speed;
  // too high
  if bonus.Top + bonus.Height < Fgame.pad.Top then
    exit;

  // too low
  if bonus.Top + bonus.Height > Fgame.pad.Top + Fgame.pad.Height then begin
    update := false;
    exit;
  end;

  // miss
  if (bonus.Left + bonus.Width < Fgame.pad.Left) or (bonus.Left > Fgame.pad.Left + Fgame.pad.Width) then
    exit;

  // hit
  update := false;
  // do something
  case what of
    1 : begin
      Fgame.addScore(100);
    end;
    2 : begin
      Fgame.addScore(1000);
    end;
    3 : begin
      Fgame.spawnBall(balls[0].ball.Left, balls[0].ball.Top);
    end;
    4 : begin
      for i := 0 to 2 do
        Fgame.spawnBall(balls[0].ball.Left, balls[0].ball.Top);
    end;
    5 : begin
    end;
    6 : begin
      Fgame.resizePad(Fgame.pad.Width + 20);
    end;
    7 : begin
      Fgame.resizePad(Fgame.pad.Width - 20);
    end;
    8 : begin
      for i := 0 to ballCnt do
        balls[i].speed := balls[i].speed + 3;
    end;
    9 : begin
      for i := 0 to ballCnt do
        balls[i].speed := max(1, balls[i].speed - 3);
    end;
    10 : begin
      for i := 0 to ballCnt do
        balls[i].resize(5);
    end;
    11 : begin
      for i := 0 to ballCnt do
        balls[i].resize(-5);
    end;
  end;



end;

end.


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
    created : boolean;
    what : integer;
    procedure init(t, l, i, sp : integer);
    function update() : boolean;
  end;
implementation

uses game;

procedure Tbonus.init(t, l, i, sp : integer);
begin
  bonus := TImage.Create(Fgame);
  created := true;
  bonus.Parent := Fgame;
  bonus.Width := 10 + random(10);
  bonus.Height := bonus.Width;
  bonus.Canvas.Brush.Color:= Fgame.Color;
  bonus.Canvas.FillRect(bonus.ClientRect);
  bonus.Canvas.Brush.Color := randomColor(Fgame.Color);
  what := random(4)+1;
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
      bonus.Canvas.MoveTo(bonus.Width div 2, 0);
      bonus.Canvas.LineTo(bonus.Width div 2 + bonus.Width div 3, bonus.Height);
      bonus.Canvas.LineTo(0, bonus.Height div 3);
      bonus.Canvas.LineTo(bonus.Width, bonus.Height div 3);
      bonus.Canvas.LineTo(bonus.Width div 2 - bonus.Width div 3, bonus.Height);
      bonus.Canvas.LineTo(bonus.Width div 2, 0);
    end;

  end;
  //1 score + 100
  //2 score + 1000
  //3 1 ball
  //4 3 ball

  bonus.Visible:= true;
  bonus.Left:= l;
  bonus.Top:= t;
  speed := sp;
  //what := i;
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
  end;



end;

end.


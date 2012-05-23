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
  bonus.Width := 10;
  bonus.Height := 10;
  bonus.Canvas.Brush.Color:= Fgame.Color;
  bonus.Canvas.FillRect(bonus.ClientRect);
  bonus.Canvas.Brush.Color := randomColor(Fgame.Color);
  bonus.Canvas.Ellipse(0, 0, bonus.Width, bonus.Height);
  bonus.Visible:= true;
  bonus.Left:= l;
  bonus.Top:= t;
  speed := sp;
  what := i;
end;

function Tbonus.update() : boolean;
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
  Fgame.addScore(100);
  Fgame.spawnBall(balls[0].ball.Left, balls[0].ball.Top);

end;

end.


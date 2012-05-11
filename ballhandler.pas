unit ballhandler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, helpers, math;

type
  Tball = class
    ball : TImage;
    smer : integer;
    xleft, yleft : real;
    speed : integer;
    created : boolean;
    procedure init(t, l, s, sp : integer);
    procedure update();
    function upravSmer(lastL, lastT: integer) : integer;
    function odraz(lastL, odkial : integer) : integer;
  end;
implementation

uses game;

procedure Tball.update();
var lastT, lastL, i : integer;
begin
  lastT := ball.Top;
  lastL := ball.Left;
  for i := 1 to speed do begin
    ball.left:= ball.left + _round(sin(smer / 180 * pi), xleft);
    ball.top:= ball.top - _round(cos(smer / 180 * pi), yleft);
    smer := upravSmer(lastL, lastT);
    lastT := ball.Top;
    lastL := ball.Left;
  end;
end;

function Tball.upravSmer(lastL, lastT: integer) : integer;
var i, j, radius, sx, sy, kam : integer;
  uhol : real;
begin
// Kraje hracieho pola
  // vrch
  if (ball.Top <= 0)  then begin
    upravSmer := odraz(lastL, 4);
    ball.Top:= 1;
    exit;
  end;

  //      lava stena  or                     prava stena
  if (ball.left <= 0) or (ball.left + ball.Width >= Fgame.width) then begin
    upravSmer := odraz(lastL, 1); exit;
  end;

  // spodok -> prehra
  if (ball.Top {+ (ball.Height div 2)} >= Fgame.height) then begin
    Fgame.modLife(-1);
    Fgame.respawnPad;
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
            upravSmer := odraz(lastL, 3);
            ball.Top:= Fgame.pad.Top - ball.Height - 1; // HACK proti odrazaniu lopty od krajov padu
            Fgame.addScore(1);
            exit;
          end;
          0 : begin // tehla
            Fgame.despawnBrick(grid[i][j].id);
            Fgame.addScore(10);
            uhol := arccos(abs(j - sy) / sqrt((i - sx) * (i - sx) + (j - sy) * (j - sy))) * (180 / pi);
            kam := 3; // spodna
            if (uhol < 91) then
              kam := 1; // lava / prava
            if (uhol < 46) then
              kam := 4; // horna
            upravSmer := odraz(lastL, kam);
            exit;
          end;
        end;
      end;
  upravSmer := smer;
end;

function Tball.odraz(lastL, odkial : integer) : integer;
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

procedure Tball.init(t, l, s, sp : integer);
begin
  ball := TImage.Create(Fgame);
  created := true;
  ball.Parent := Fgame;
  ball.Width := 10;
  ball.Height := 10;
  ball.Canvas.Brush.Color:= Fgame.Color;
  ball.Canvas.FillRect(ball.ClientRect);
  ball.Canvas.Brush.Color := randomColor(Fgame.Color);
  ball.Canvas.Ellipse(0, 0, ball.Width, ball.Height);
  ball.Visible:= true;
  ball.Left:= l;
  ball.Top:= t;
  smer := s;
  speed := sp;
  xleft := 0;
  yleft := 0;
end;

end.


unit ballhandler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, helpers, math, log;

type
  Tball = class
    ball : TImage;
    smer : integer;
    xleft, yleft : real;
    speed : integer;
    created : boolean;
    procedure init(t, l, s, sp : integer);
    function update() : boolean;
    function upravSmer(lastL, lastT: integer) : boolean;
    function odraz(lastL, odkial : integer) : integer;
  end;
implementation

uses game, mainmenu;

function Tball.update() : boolean;
var lastT, lastL, i : integer;
begin
  lastT := ball.Top;
  lastL := ball.Left;
  for i := 1 to speed do begin
    ball.left:= ball.left + _round(sin(smer / 180 * pi), xleft);
    ball.top:= ball.top - _round(cos(smer / 180 * pi), yleft);
    //outLog.outText(intToStr(ball.Left - lastL));
    //outLog.outText(intToStr(ball.Top - lastT));
    if (not upravSmer(lastL, lastT)) then begin
      update:= false;
      exit;
    end;
    lastT := ball.Top;
    lastL := ball.Left;
  end;
  update := true;
end;

function Tball.upravSmer(lastL, lastT: integer) : boolean;
var i, j, radius, sx, sy, kam : integer;
begin
  upravSmer := true;
// Kraje hracieho pola
  // vrch
  if (ball.Top <= 0)  then begin
    smer := odraz(lastL, 4);
    ball.Top:= 1;
    exit;
  end;

  //      lava stena  or                     prava stena
  if (ball.left <= 0) or (ball.left + ball.Width >= Fgame.width) then begin
    smer := odraz(lastL, 1);
    exit;
  end;

  // spodok -> prehra
  if (ball.Top {+ (ball.Height div 2)} >= Fgame.height) then begin
    upravSmer := false;
    exit();
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
            //smer := odraz(lastL, 3);
            if i - Fgame.pad.Left < Fgame.pad.Width div 2 then
              smer := 290 + (70 div (Fgame.pad.Width div 2)) * (i - Fgame.pad.Left)
            else
              smer := (70 div (Fgame.pad.Width div 2)) * (i - Fgame.pad.Left - Fgame.pad.Width div 2);

            ball.Top:= Fgame.pad.Top - ball.Height - 1; // HACK proti odrazaniu lopty od krajov padu
            Fgame.addScore(1);
            exit;
          end;
          0 : begin // tehla
            Fgame.despawnBrick(grid[i][j].id);
            Fgame.addScore(10);

            // drop bonus
            if random(roll) = 1 then begin
              inc(rem[2]);
              bonuses[rem[2]].init(j, i, 1, 2);
            end;

            // up and down -> side
            if (grid[i][j + 1].typ <> -1) and (grid[i][j - 1].typ <> -1) then
               kam := 1
            else
              if grid[i][j + 1].typ <> -1 then // horna stena
                kam := 4
              else // spodna
                kam := 3;

            smer := odraz(lastL, kam);
            exit;
          end;
        end;
      end;
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
  ball.Width := 10 + random(10);
  ball.Height := ball.Width;
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


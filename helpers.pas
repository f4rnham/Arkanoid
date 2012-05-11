unit helpers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics;

function _Val(s : string) : int64;
function normalize360(smer : integer) : integer;
function _round(num : real; var rem : real) : integer;
function randomColor(noo : TColor) : TColor;

implementation

function _Val(s : string) : int64;
var tmp : int64;
  e : integer;
begin
  Val(s, tmp, e);
  if e = 0 then
    _Val := tmp
  else
    _Val := -1;
end;

function normalize360(smer : integer) : integer;
begin
  while (smer > 360) do smer := smer - 360;
  while (smer < 0 ) do smer := smer + 360;
  normalize360 := smer;
end;

function _round(num : real; var rem : real) : integer;
var tmp : real;
begin
  tmp := num + rem;
  num := round(tmp);
  rem := tmp - num;
  _round := round(num);
end;

function randomColor(noo : TColor) : TColor;
var c : TColor;
begin
  c := noo;
  while c = noo do
    c := rgbtocolor(random(255),random(255),random(255));
  randomColor := c;
end;

end.


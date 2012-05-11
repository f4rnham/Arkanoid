unit helpers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

function _Val(s : string) : int64;
function normalize360(smer : integer) : integer;
function _round(num : real; var rem : real) : integer;

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

end.


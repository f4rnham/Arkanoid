unit log;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls;

type
  Tlog = class
    f : text;
    enabled : boolean;
    outFile : string;
    procedure outText(s : string);
    procedure init(s : string);
  end;

implementation

uses game, mainmenu;

procedure Tlog.outText(s : string);
begin
  if not enabled then exit;

  writeln(f, s);
  flush(f);
end;

procedure Tlog.init(s : string);
begin
  enabled := true;
  outFile := s;
  AssignFile(f, outFile);
  append(f);
end;

end.


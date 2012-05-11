unit input;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, errorreporting;

type

  { Tinput }

  Tinput = class(TForm)
    ok: TButton;
    inp: TEdit;
    nadpis: TStaticText;
    procedure okClick(Sender: TObject);
    procedure init(cap, def : string; var ret : string);
    function pass(c : char) : boolean;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Finput: Tinput;
  returning : ^string;
implementation

{$R *.lfm}

{ Tinput }

procedure Tinput.init(cap, def : string; var ret : string);
begin
  returning := @ret;
  nadpis.Caption:= cap;
  inp.Caption:= def;
  ShowModal;
end;

procedure Tinput.okClick(Sender: TObject);
var i : integer;
begin
  if length(inp.Caption) > 10 then begin
    Error.sendError('Prilis dlhe meno. Maximum 10 znakov');
    exit;
  end;

  for i := 1 to length(inp.Caption) do
    if (not pass(inp.Caption[i])) then begin
      Error.sendError('Meno moze obsahovat iba velke/male pislena anglickej abecedy + cisla');
      exit;
    end;
  returning^ := inp.Caption;
  Hide;
end;

function Tinput.pass(c : char) : boolean;
begin
  //              cisla                                 uppercase                          lowercase
  if (((ord(c) > 47) and (ord(c) < 58)) or ((ord(c) > 64) and (ord(c) < 91)) or ((ord(c) > 96) and (ord(c) < 123))) then
    pass := true
  else
    pass := false;
end;

end.


unit errorreporting;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TError }

  TError = class(TForm)
    ok: TButton;
    errText: TStaticText;
    procedure okClick(Sender: TObject);
    procedure sendError(err : string);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Error: TError;

implementation

{$R *.lfm}

procedure TError.sendError(err : string);
begin
  errText.Caption:= err;
  ShowModal;
end;

procedure TError.okClick(Sender: TObject);
begin
  Hide;
end;

end.


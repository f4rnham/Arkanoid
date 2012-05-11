unit highscore;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, errorreporting, process;

type

  { ThighScore }

  ThighScore = class(TForm)
    cont: TButton;
    status: TStaticText;
    table: TImage;
    procedure contClick(Sender: TObject);
    function requestHS() : boolean;
    procedure showHS();
    function loadHS() : boolean;
    function updateHS(nejm : string; score : int64) : boolean;
    function runProcess(args : string) : boolean;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FhighScore: ThighScore;
  f : Text;
  names : array[0..15] of string;
  scores : array[0..15] of longint;

implementation

{$R *.lfm}

function ThighScore.requestHS() : boolean;
begin
  if (not runProcess('-r')) then begin
    Error.sendError('subor hs.exe sa nepodarilo najst alebo spustit, overte ci sa nachadza v priecinku s hrou alebo ci mate dostatocne prava na jeho spustenie');
    requestHS := false;
    exit;
  end;
  requestHS := true;
end;

function ThighScore.runProcess(args : string) : boolean;
var tmp : file of byte;
  p : TProcess;
begin
  AssignFile(tmp, 'hs.exe');
  {$I-}
  Reset(tmp);
  {$I+}
  if (IOResult = 0) then begin
    CloseFile(tmp);
    runProcess := true;
  end else begin
    runProcess := false;
    exit;
  end;

  p := TProcess.Create(nil);
  p.CommandLine := 'hs.exe ' + args;
  p.Options := p.Options + [poWaitOnExit];
  p.Execute;
  p.Free;
end;

procedure ThighScore.showHS();
var i : integer;
begin
  status.Caption:= 'nacitavanie skore';
  Show;
  if (not requestHS()) then begin
    Hide;
    exit;
  end;

  if loadHS() then begin
    status.Caption:= 'hotovo';
    for i := 0 to 14 do begin
      table.Canvas.TextOut(10, 10 + i * 20, names[i]);
      table.Canvas.TextOut(150, 10 + i * 20, IntToStr(scores[i]));
    end;
  end
  else
    Hide;
end;

function ThighScore.updateHS(nejm: string; score: int64) : boolean;
begin
  if (not runProcess('-u ' + IntToStr(score) + ' ' + nejm)) then begin
    Error.sendError('subor hs.exe sa nepodarilo najst alebo spustit, overte ci sa nachadza v priecinku s hrou alebo ci mate dostatocne prava na jeho spustenie');
    Error.sendError('skore NEBOLO zapisane');
    updateHS := false;
    exit
  end;
  updateHS := true;
end;

function ThighScore.loadHS() : boolean;
var i, err : integer;
begin
  {$I-}
  AssignFile(f,'hs.txt');
  reset(f);

  readln(f, err); // first line, error report
  if err = 1 then begin
    Error.sendError('problem with HS');
    loadHS := false;
    exit;
  end;

  for i := 0 to 14 do
    readln(f, scores[i], names[i]);

  CloseFile(f);
  {$I-}
  if IOresult <> 0 then begin
    Error.sendError('problem with HS');
    loadHS := false;
    exit;
  end;
  loadHS := true;
end;

procedure ThighScore.contClick(Sender: TObject);
begin
  Hide;
end;

end.


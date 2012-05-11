unit highscore;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { ThighScore }

  ThighScore = class(TForm)
    cont: TButton;
    procedure contClick(Sender: TObject);
    procedure requestHS();
    procedure showHS();
    procedure updateHS(nejm : string; score : int64);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FhighScore: ThighScore;

implementation

{$R *.lfm}

procedure ThighScore.requestHS();
begin

end;

procedure ThighScore.showHS();
begin
  ShowModal;
end;

procedure ThighScore.updateHS(nejm: string; score: int64);
begin

end;

procedure ThighScore.contClick(Sender: TObject);
begin
  Hide;
end;

end.


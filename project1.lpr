program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, game, mainmenu;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmenu, Fmenu);
  Application.CreateForm(TFgame, Fgame);
  Application.Run;
end.


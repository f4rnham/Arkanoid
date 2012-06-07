program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, game, mainmenu, errorreporting, input, highscore, helpers, ballhandler,
  bonushandler, log, MyThreads;

{$R *.res}

begin
  Application.Initialize;
  randomize;
  Application.CreateForm(TFmenu, Fmenu);
  Application.CreateForm(TFgame, Fgame);
  Application.CreateForm(TError, Error);
  Application.CreateForm(Tinput, Finput);
  Application.CreateForm(ThighScore, FhighScore);
  Application.Run;
end.


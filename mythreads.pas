unit MyThreads;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

 Type
    TMyThread = class(TThread)
      procedure Execute; override;
      property Terminated;
      Constructor Create(CreateSuspended : boolean);
    public
      balls: boolean;
    end;

implementation

uses game;

constructor TMyThread.Create(CreateSuspended : boolean);
  begin
    FreeOnTerminate := True;
    inherited Create(CreateSuspended);
  end;

procedure TMyThread.Execute();
begin
  if balls then
    Fgame.updateBalls()
  else
    Fgame.updateBonus();
  Terminate;
end;

end.

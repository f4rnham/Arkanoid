unit mainmenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, game;

type

  { TFmenu }

  TFmenu = class(TForm)
    start: TButton;
    procedure startClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Fmenu: TFmenu;

implementation

{$R *.lfm}

{ TFmenu }

procedure TFmenu.startClick(Sender: TObject);
begin
   Hide;
   Fgame.resetAll();
   Fgame.Show;
end;

end.


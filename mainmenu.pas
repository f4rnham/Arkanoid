unit mainmenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, Buttons, game, errorreporting, input, highscore, log;

type

  { TFmenu }

  TFmenu = class(TForm)
    bonus: TCheckBox;
    hs: TButton;
    randomB: TCheckBox;
    infiLives: TCheckBox;
    lives: TEdit;
    startCustom: TButton;
    fillPercentH: TStaticText;
    fillPercent: TTrackBar;
    livesH: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure hsClick(Sender: TObject);
    procedure infiLivesChange(Sender: TObject);
    procedure randomBChange(Sender: TObject);
    procedure startCustomClick(Sender: TObject);
    function validate(co : TEdit; var kam : integer; err : string) : boolean;
    procedure startGame(a, b : integer);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Fmenu: TFmenu;
  nejm : string;
  score : int64;
  outLog : Tlog;
implementation

{$R *.lfm}

{ TFmenu }

procedure TFmenu.startCustomClick(Sender: TObject);
var life : integer;
begin
  // random
  if randomB.Checked then begin
    life := random(100) - 1;
    if life = 0 then life := 5; // a hotovo
    startGame(random(99) + 1, life);
    exit;
  end;
  // custom, eval values
  if infilives.Checked then
    life := -1
  else
    if (not validate(lives, life, 'Neplatny pocet zivotov. Maximum je 99, minimum 1.')) then
      exit;

  startGame(fillPercent.Position, life);
end;

procedure TFmenu.startGame(a, b : integer);
begin
  Finput.init('Zadajte meno', nejm, nejm);
  Fgame.init(nejm, a, b, bonus.Checked);
  Hide;
  Fgame.Show;
end;

procedure TFmenu.infiLivesChange(Sender: TObject);
begin
  lives.Enabled:= not infilives.Checked;
end;

procedure TFmenu.randomBChange(Sender: TObject);
begin
  fillPercent.Enabled:= not randomB.Checked;
  infiLives.Enabled:= not randomB.Checked;
  lives.Enabled:= not randomB.Checked;
end;

function TFmenu.validate(co : TEdit; var kam : integer; err : string) : boolean;
var e : integer;
begin
  Val(co.Caption, kam, e);
  if (e = 0) and (kam < 100) and (kam > 0) then begin
    validate := true;
    exit;
  end;

  validate := false;
  Error.sendError(err);
end;

procedure TFmenu.FormCreate(Sender: TObject);
begin
  nejm := 'MrSmith';
  outLog := Tlog.Create;
  //outLog.init('debug.txt');
end;

procedure TFmenu.hsClick(Sender: TObject);
begin
  FhighScore.showHS();
end;

end.


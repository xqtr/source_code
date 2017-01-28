unit tswitchbutton;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Graphics, Controls,gtk;

  type

  { TTSwitchButton }

  TTSwitchButton = class(TImage)
  private
    { Private declarations }
    DBDownPict: TPicture;
    DBUpPict:   TPicture;
    DBDisPict:  TPicture;
    DBEnabled: Boolean;
    FUp: Boolean;

    procedure SetDownPict(Value: TPicture);
    procedure SetUpPict(Value: TPicture);
    procedure SetDisPict(Value: TPicture);

  public
    { Public declarations }
    procedure SetEnabled(Value: Boolean);  override;
    Procedure SetOnOff(value:boolean);
    Function ReadOnOff:boolean;
    constructor Create(AOwner: TComponent); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    Procedure Click; override;
    destructor Destroy; override;
  published
    { Published declarations }
    property OnPict: TPicture read DBUpPict write SetUpPict;
    property DownPict: TPicture read DBDownPict write SetDownPict;
    property DisabledPict: TPicture read DBDisPict write SetDisPict;
    property Enabled: Boolean read DBEnabled write SetEnabled;
    Property Up:boolean read readonoff write setonoff;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Touch', [TTSwitchButton]);
end;

procedure TTSwitchButton.SetEnabled(Value: Boolean);
begin
 if Value = True then
    Picture:=DBUpPict
 else Picture:=DBDisPict;
      DBEnabled:=Value;
      fup:=value;
end;

procedure TTSwitchButton.SetOnOff(value: boolean);
begin
  fup:=value;
end;

function TTSwitchButton.ReadOnOff: boolean;
begin
  result:=fup;
end;

constructor TTSwitchButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DBDownPict:= TPicture.Create;
  DBUpPict := TPicture.Create;
  DBDisPict := TPicture.Create;
  Picture:= DBUpPict;
  fup:=true;
  SetEnabled(true);
end;

procedure TTSwitchButton.SetUpPict(Value: TPicture);
begin
  DBUpPict.Assign(Value);
end;

procedure TTSwitchButton.SetDownPict(Value: TPicture);
begin
  DBDownPict.Assign(Value);
end;

procedure TTSwitchButton.SetDisPict(Value: TPicture);
begin
  DBDisPict.Assign(Value);
end;

procedure TTSwitchButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
 inherited;
 if DBEnabled=True then
 if fUp then
  if (X<0)or(X>Width)or(Y<0)or(Y>Height) then
  begin
    SetCaptureControl(Self);
    if fup then Picture:=DBUpPict else picture:=dbdownpict;
   end;
end;

procedure TTSwitchButton.Click;
begin
if Enabled=True then
  begin
    fup:=not fup;
    if fup then picture:=dbuppict else picture:=dbdownpict;
  end;
  inherited Click;
end;

destructor TTSwitchButton.Destroy;
begin
  DBDownPict.Free;
  DBUpPict.Free;
  DBDisPict.Free;
  inherited Destroy;
end;

end.


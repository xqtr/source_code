unit timagebutton;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Graphics, Controls;

  type
  TTImageButton = class(TImage)
  private
    { Private declarations }
    DBOverPict: TPicture;
    DBDownPict: TPicture;
    DBUpPict:   TPicture;
    DBDisPict:  TPicture;
    DBEnabled: Boolean;
    Down: Boolean;
    Up: Boolean;

    procedure SetDownPict(Value: TPicture);
    procedure SetUpPict(Value: TPicture);
    procedure SetDisPict(Value: TPicture);

  public
    { Public declarations }
    procedure SetEnabled(Value: Boolean);  override;
    constructor Create(AOwner: TComponent); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
                      override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
                        X, Y: Integer); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property UpPict: TPicture read DBUpPict write SetUpPict;
    property DownPict: TPicture read DBDownPict write SetDownPict;
    property DisPict: TPicture read DBDisPict write SetDisPict;
    property Enabled: Boolean read DBEnabled write SetEnabled;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Touch', [TTImageButton]);
end;

procedure TTImageButton.SetEnabled(Value: Boolean);
begin
 if Value = True then
    Picture:=DBUpPict
 else Picture:=DBDisPict;
      DBEnabled:=Value;
end;

constructor TTImageButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DBOverPict:= TPicture.Create;
  DBDownPict:= TPicture.Create;
  DBUpPict := TPicture.Create;
  DBDisPict := TPicture.Create;
  Picture:= DBUpPict;
  Down:= False;
  SetEnabled(Enabled);
end;

procedure TTImageButton.SetUpPict(Value: TPicture);
begin
  DBUpPict.Assign(Value);
end;

procedure TTImageButton.SetDownPict(Value: TPicture);
begin
  DBDownPict.Assign(Value);
end;

procedure TTImageButton.SetDisPict(Value: TPicture);
begin
  DBDisPict.Assign(Value);
end;

procedure TTImageButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
 inherited;
 if DBEnabled=True then
 if Up then
  if (X<0)or(X>Width)or(Y<0)or(Y>Height) then
  begin
    SetCaptureControl(Self);
    Picture:=DBUpPict;
   end;
end;

procedure TTImageButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
                                 X, Y: Integer);
begin
 if (Button=mbLeft)and(DBEnabled=True) then
  begin
   Picture:=DownPict;
   Down:=True;
  end;
 inherited MouseDown(Button, Shift, X, Y);
end;

procedure TTImageButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
     X, Y: Integer);
begin
 if (Button=mbLeft)and(Enabled=True) then
  begin
   Picture:=UpPict;
   SetCaptureControl(nil);
  end;
 inherited  MouseUp(Button, Shift, X, Y);
 Down:=False;
end;

destructor TTImageButton.Destroy;
begin
  DBDownPict.Free;
  DBUpPict.Free;
  DBDisPict.Free;
  inherited Destroy;
end;

end.


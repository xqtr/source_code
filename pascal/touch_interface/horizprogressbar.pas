unit HorizProgressBar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type
  THorizProgressBar = class(TImage)
  private
    fbackpic:tpicture;
    fthumbpic:tpicture;
    fposition:integer;
    fmin,
    fmax:integer;
    fdown:boolean;
    FOnChange: TNotifyEvent;
    procedure setbackround(Value: tpicture);
    procedure setposition(Value: integer);
    procedure setthumb(Value: tpicture);
  protected

  public
    constructor Create(AOwner: TComponent); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    Procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    destructor Destroy; override;
    procedure Paint; override;
  published
    Property Background:tpicture read fbackpic write setbackround;
    Property Foreground:tpicture read fthumbpic write setthumb;
    Property Position:integer read fposition write setposition default 0;
    Property Maximum:integer read fmax write fmax default 100;
    Property Minimum:integer read fmin write fmin default 0;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Touch',[THorizProgressBar]);
end;

{ TButtonSlider }

procedure THorizProgressBar.setbackround(Value: tpicture);
begin
  fbackpic.assign(value);
  picture.assign(value);
  if assigned(fbackpic) then begin
  width:=fbackpic.Width;
  height:=fbackpic.Height;
  end;
end;

procedure THorizProgressBar.setposition(Value: integer);
begin
  fposition:=value;
  if fposition<fmin then fposition:=fmin;
  if fposition>fmax then fposition:=fmax;
  invalidate;
end;

procedure THorizProgressBar.setthumb(Value: tpicture);
begin
  fthumbpic.assign(value);
end;

constructor THorizProgressBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Fbackpic:= TPicture.Create;
  fthumbpic:= TPicture.Create;
  fposition:=0;
  fmin:=0;
  fmax:=100;
  fdown:=false;
end;

procedure THorizProgressBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if (X<0)or(X>Width)or(Y<0)or(Y>Height) then fdown:=false;
  if fdown=false then exit;
  fposition:=(x*fmax) div width;
  inherited MouseMove(Shift, X, Y);
  invalidate;
  if assigned(fonchange) then fonchange(nil);
end;

procedure THorizProgressBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if (Button=mbLeft) then fdown:=false;
  inherited MouseUp(Button, Shift, X, Y);
  invalidate;
end;

procedure THorizProgressBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if (Button=mbLeft) then fdown:=true;
  inherited MouseDown(Button, Shift, X, Y);
end;

destructor THorizProgressBar.Destroy;
begin
  fthumbpic.free;
  fbackpic.free;
  inherited Destroy;
end;

procedure THorizProgressBar.Paint;
var
  tw,th,tx,ty,
  startx,endx:integer;
begin
  inherited Paint;
  tw:=fthumbpic.Width;
  th:=fthumbpic.height;
  tx:=(fposition * tw) div fmax;
  if assigned(fbackpic) then canvas.Draw(0,0,fbackpic.graphic);
  if assigned(fthumbpic) then
    canvas.CopyRect(rect(0,0,tx,th),fthumbpic.Bitmap.Canvas,rect(0,0,tx,th));
end;

end.

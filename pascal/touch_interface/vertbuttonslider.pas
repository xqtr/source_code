unit VertButtonSlider;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TButtonSlider }

  TVertButtonSlider = class(TImage)
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
    Property Thumb:tpicture read fthumbpic write setthumb;
    Property Position:integer read fposition write setposition default 0;
    Property Maximum:integer read fmax write fmax default 100;
    Property Minimum:integer read fmin write fmin default 0;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Touch',[TVertButtonSlider]);
end;

{ TVertButtonSlider }

procedure TVertButtonSlider.setbackround(Value: tpicture);
begin
  fbackpic.assign(value);
  picture.assign(value);
  if assigned(fbackpic) then begin
  width:=fbackpic.Width;
  height:=fbackpic.Height;
  end;
end;

procedure TVertButtonSlider.setposition(Value: integer);
begin
  fposition:=value;
  if fposition<fmin then fposition:=fmin;
  if fposition>fmax then fposition:=fmax;
  invalidate;
end;

procedure TVertButtonSlider.setthumb(Value: tpicture);
begin
  fthumbpic.assign(value);
end;

constructor TVertButtonSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Fbackpic:= TPicture.Create;
  fthumbpic:= TPicture.Create;
  fposition:=0;
  fmin:=0;
  fmax:=100;
  fdown:=false;
end;

procedure TVertButtonSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if (X<0)or(X>Width)or(Y<0)or(Y>Height) then fdown:=false;
  if fdown=false then exit;
  fposition:=(y*fmax) div height;
  inherited MouseMove(Shift, X, Y);
  invalidate;
  if assigned(fonchange) then fonchange(nil);
end;

procedure TVertButtonSlider.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if (Button=mbLeft) then fdown:=false;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TVertButtonSlider.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if (Button=mbLeft) then fdown:=true;
  inherited MouseDown(Button, Shift, X, Y);
end;

destructor TVertButtonSlider.Destroy;
begin
  fthumbpic.free;
  fbackpic.free;
  inherited Destroy;
end;

procedure TVertButtonSlider.Paint;
var
  tw,th,tx,ty,
  starty,endy:integer;
begin
  inherited Paint;
  tw:=fthumbpic.Width;
  th:=fthumbpic.height;
  tx:=(width div 2) - (tw div 2);
  starty:=th div 2;
  endy:=fbackpic.height - th;
  ty:=(fposition * endy) div fmax;
  if assigned(fbackpic) then canvas.Draw(0,0,fbackpic.graphic);
  if assigned(fthumbpic) then canvas.draw(tx,ty,fthumbpic.graphic);
end;

end.

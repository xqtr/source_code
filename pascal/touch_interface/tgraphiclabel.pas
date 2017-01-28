unit tgraphiclabel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Graphics, Controls;

  type

  { TTGraphicLabel }

  TTGraphicLabel = class(TImage)
  private
    { Private declarations }
    FAlignment: TAlignment;
    DBOverPict: TPicture;
    DBDownPict: TPicture;
    DBUpPict:   TPicture;
    DBDisPict:  TPicture;
    DBEnabled: Boolean;
    Down: Boolean;
    Up: Boolean;
    Ftext:String;
    ffont:tfont;
    fdfont:tfont;

    procedure SetAlignment(Value: TAlignment);
    procedure Setdfont(Value: tfont);
    procedure SetDownPict(Value: TPicture);
    procedure Setfont(Value: tfont);
    procedure SetUpPict(Value: TPicture);
    procedure SetDisPict(Value: TPicture);
    Procedure SetText(value:string);
    function  GetAlignment: TAlignment;

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
    procedure Paint; override;
  published
    { Published declarations }
    property Alignment: TAlignment read GetAlignment write SetAlignment default taLeftJustify;
    property UpPict: TPicture read DBUpPict write SetUpPict;
    property DownPict: TPicture read DBDownPict write SetDownPict;
    property DisPict: TPicture read DBDisPict write SetDisPict;
    property Enabled: Boolean read DBEnabled write SetEnabled default true;
    Property Text:string read ftext write settext;
    Property Font:tfont read ffont write Setfont;
    Property DisabledFont:tfont read ffont write Setdfont;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Touch', [TTGraphicLabel]);
end;

procedure TTGraphicLabel.SetEnabled(Value: Boolean);
begin
 if Value = True then
    Picture:=DBUpPict
 else Picture:=DBDisPict;
      DBEnabled:=Value;
end;

constructor TTGraphicLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DBOverPict:= TPicture.Create;
  DBDownPict:= TPicture.Create;
  DBUpPict := TPicture.Create;
  DBDisPict := TPicture.Create;
  Picture:= DBUpPict;
  ffont:=tfont.create;
  fdfont:=tfont.create;
  Down:= False;
  SetEnabled(true);
end;

procedure TTGraphicLabel.SetUpPict(Value: TPicture);
begin
  DBUpPict.Assign(Value);
end;

procedure TTGraphicLabel.SetDownPict(Value: TPicture);
begin
  DBDownPict.Assign(Value);
end;

procedure TTGraphicLabel.Setfont(Value: tfont);
begin
  ffont.assign(value);
  invalidate;
end;

procedure TTGraphicLabel.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Invalidate;
  end;
end;

procedure TTGraphicLabel.Setdfont(Value: tfont);
begin
  fdfont.assign(value);
  invalidate;
end;

procedure TTGraphicLabel.SetDisPict(Value: TPicture);
begin
  DBDisPict.Assign(Value);
end;

procedure TTGraphicLabel.SetText(value: string);
begin
  ftext:=value;
  invalidate;
end;

function TTGraphicLabel.GetAlignment: TAlignment;
begin
  Result := FAlignment;
end;

procedure TTGraphicLabel.MouseMove(Shift: TShiftState; X, Y: Integer);
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

procedure TTGraphicLabel.MouseDown(Button: TMouseButton; Shift: TShiftState;
                                 X, Y: Integer);
begin
 if (Button=mbLeft)and(DBEnabled=True) then
  begin
   Picture:=DownPict;
   Down:=True;
  end;
 inherited MouseDown(Button, Shift, X, Y);
end;

procedure TTGraphicLabel.MouseUp(Button: TMouseButton; Shift: TShiftState;
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

destructor TTGraphicLabel.Destroy;
begin
  DBDownPict.Free;
  DBUpPict.Free;
  DBDisPict.Free;
  ffont.free;
  fdfont.destroy;
  inherited Destroy;
end;

procedure TTGraphicLabel.Paint;
var
  w,h,y,x:integer;
begin
  inherited Paint;
  canvas.GetTextSize(ftext,w,h);
  x:=(Width div 2) - (w div 2);
  y:=(height div 2) - (h div 2);
  if DBEnabled then canvas.font.Assign(ffont) else canvas.font.assign(fdfont);
  if FAlignment=taLeftJustify then canvas.TextOut(0,y,ftext);
  if FAlignment=taRightJustify then canvas.TextOut(canvas.width-w,y,ftext);
  if FAlignment=taCenter then canvas.TextOut(x,y,ftext);
end;

end.


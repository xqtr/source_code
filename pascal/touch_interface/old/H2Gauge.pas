Unit H2Gauge;

Interface

Uses
  Messages,Windows, Classes,Controls, ExtCtrls, SysUtils,GR32_Image,GR32,
  gr32_layers,Graphics,JvThreadTimer,GR32_transforms;

Type

  TH2Gauge = Class(TControl)
  Private
    fx,
    fy,
    fwidth,
    fheight:Integer;
    fvisible:Boolean;
    fpos:Integer;
    fbitmap:tbitmaplayer;
    fdrawmode:tdrawmode;
    falpha:Cardinal;
    fbmp:tbitmap32;
    fneedle:tbitmap32;
    fmin:Integer;
    fmax:Integer;
    fposition:Integer;
    Procedure Setvisible(value:Boolean);
    Procedure SetAlpha(value:Cardinal);
    Procedure SetDrawmode(value:tdrawmode);
    Procedure Setx(value:Integer);
    Procedure Sety(value:Integer);
    Procedure SetPosition(value:Integer);
    Procedure rotate(b:tbitmap32;Var dest:tbitmap32;angle:Single);
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
  Published
    Procedure LoadBackGround(filename:String);
    Procedure LoadNeedle(filename:String);
    Property Min:Integer Read fmin Write fmin;
    Property Max:Integer Read fmax Write fmax;
    Property Position:Integer Read fposition Write setposition;
    Property Alpha:Cardinal Read falpha Write setalpha;
    Property DrawMode:tdrawmode Read fdrawmode Write setdrawmode;
    Property X:Integer Read fx Write setx;
    Property Y:Integer Read fy Write sety;
    Property Bitmap:tbitmaplayer Read fbitmap Write fbitmap;
    Property Visible:Boolean Read fvisible Write setvisible;
  End;


Implementation

Uses Unit1;

Constructor TH2Gauge.Create(AOwner: TComponent);
Var
  L: TFloatRect;
  alayer:tbitmaplayer;
Begin
  Inherited Create(AOwner);
  fbitmap:=TBitmapLayer.Create((aowner As timage32).Layers);
  fdrawmode:=dmblend;
  falpha:=255;
  fvisible:=True;
  fmin:=0;
  fmax:=100;
  fposition:=0;
  fx:=0;
  fpos:=0;
  fy:=0;
  fwidth:=150;
  fheight:=150;
  fbmp:=tbitmap32.Create;
  fbitmap.Bitmap.Width:=fwidth;
  fbitmap.Bitmap.Height:=fheight;
  l.Left:=fx;
  l.Top:=fy;
  l.Right:=fx+fwidth;
  l.Bottom:=fy+fheight;
  fbitmap.Location:=l;
  fbitmap.Tag:=0;
  fbitmap.Bitmap.DrawMode:=fdrawmode;
  fbitmap.Bitmap.MasterAlpha:=falpha;
  fvisible:=True;
  fneedle:=tbitmap32.Create;
  fneedle.DrawMode:=dmblend;
  fneedle.MasterAlpha:=255;
End;

Destructor TH2Gauge.Destroy;
Begin
//here
  fbitmap.Free;
  fbmp.Free;
  fneedle.free;
  Inherited Destroy;
End;

Procedure TH2Gauge.LoadBackGround(filename: String);
Var au:Boolean;
  L: TFloatRect;
Begin
  If fileexists(filename) Then
    Begin
    Try
      LoadPNGintoBitmap32(fbmp,filename,au);
      fwidth:=fbmp.Width;
      fheight:=fbmp.Height;
      fneedle.Width:=fwidth;
      fneedle.Height:=fheight;
      fbitmap.Bitmap.width:=fwidth;
      fbitmap.Bitmap.Height:=fheight;

      l.Left:=fx;
      l.Top :=fy;
      l.Right:=fx+fwidth;
      l.Bottom:=fy+fheight;
      fbitmap.Location:=l;
    Except
      End;
    End;
End;

Procedure TH2Gauge.LoadNeedle(filename: String);
Var au:Boolean;
Begin
  If fileexists(filename) Then
    Begin
    Try
      LoadPNGintoBitmap32(fneedle,filename,au);
    Except
      End;
    End;
End;

Procedure TH2Gauge.rotate(b: tbitmap32; Var dest: tbitmap32;
  angle: Single);
Var
  T: TAffineTransformation;
Begin
  T := TAffineTransformation.Create;
  T.Clear;
  T.SrcRect := FloatRect(0, 0, b.Width + 1, B.height + 1);
  T.Translate(-b.width / 2, -b.height / 2);
  T.Rotate(0, 0, angle);
  T.Translate(b.width / 2, b.height / 2);
  transform(dest,b,t);
  t.Free;
End;

Procedure TH2Gauge.SetAlpha(value: Cardinal);
Begin
  falpha:=value;
  fbitmap.Bitmap.MasterAlpha:=falpha;
  fbmp.MasterAlpha:=falpha;
  fneedle.MasterAlpha:=falpha;
End;

Procedure TH2Gauge.SetDrawmode(value: tdrawmode);
Begin
  fdrawmode:=value;
  fbitmap.Bitmap.DrawMode:=fdrawmode;
  fbmp.DrawMode:=fdrawmode;
  fneedle.DrawMode:=fdrawmode;
End;

Procedure TH2Gauge.SetPosition(value: Integer);
Var
  deg:Single;
  mb: tbitmap32;
Begin
  fposition:=value;
  deg:=360 / fmax;
  mb :=tbitmap32.Create;
  mb.DrawMode:=dmblend;
  mb.MasterAlpha:=falpha;
  mb.Width:=fbmp.Width;
  mb.height:=fbmp.Height;
  rotate(fneedle,mb,-fposition*deg);
  fbmp.DrawTo(fbitmap.Bitmap,0,0);
  mb.DrawTo(fbitmap.Bitmap,0,0);
  mb.free;
End;

Procedure TH2Gauge.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

Procedure TH2Gauge.Setx(value: Integer);
Var
  L: TFloatRect;
Begin
  fx:=value;
  l.Left:=fx;
  l.Top:=fy;
  l.Right:=fx+fwidth;
  l.Bottom:=fy+fheight;
  fbitmap.Location:=l;
End;

Procedure TH2Gauge.Sety(value: Integer);
Var
  L: TFloatRect;
Begin
  fy:=value;
  l.Left:=fx;
  l.Top:=fy;
  l.Right:=fx+fwidth;
  l.Bottom:=fy+fheight;
  fbitmap.Location:=l;
End;

End.

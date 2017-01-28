Unit h2AnalogClock;

Interface

Uses
  Messages,Windows, Classes,Controls, ExtCtrls, SysUtils,GR32_Image,GR32,
  gr32_layers,Graphics,JvThreadTimer,GR32_transforms;

Type

  TH2AnalogClock = Class(TControl)
  Private
    ftimer:tjvthreadtimer;
    finterval:Cardinal;
    fx,
    fy,
    fwidth,
    fheight:Integer;
    fvisible:Boolean;
    fbitmap:tbitmaplayer;
    fdrawmode:tdrawmode;
    falpha:Cardinal;
    fbmp:tbitmap32;
    fmin:tbitmap32;
    fhour:tbitmap32;
    Procedure Setvisible(value:Boolean);
    Procedure Ontimer(Sender:Tobject);Virtual;
    Procedure SetAlpha(value:Cardinal);
    Procedure SetDrawmode(value:tdrawmode);
    Procedure Setx(value:Integer);
    Procedure Sety(value:Integer);
    Procedure SetWidth(value:Integer);
    Procedure SetHeight(value:Integer);
    Procedure rotate(b:tbitmap32;Var dest:tbitmap32;angle:Single);
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
  Published
    Procedure Start;
    Procedure Stop;
    Procedure LoadBackGround(filename:String);
    Procedure LoadMinute(filename:String);
    Procedure LoadHour(filename:String);
    Property Interval:Cardinal Read finterval Write finterval;
    Property Alpha:Cardinal Read falpha Write setalpha;
    Property DrawMode:tdrawmode Read fdrawmode Write setdrawmode;
    Property X:Integer Read fx Write setx;
    Property Y:Integer Read fy Write sety;
    Property Width:Integer Read fwidth Write setwidth;
    Property Height:Integer Read fheight Write setheight;
    Property Bitmap:tbitmaplayer Read fbitmap Write fbitmap;
    Property Visible:Boolean Read fvisible Write setvisible;
  End;


Implementation

Uses Unit1;

Constructor TH2AnalogClock.Create(AOwner: TComponent);
Var
  L: TFloatRect;
  alayer:tbitmaplayer;
Begin
  Inherited Create(AOwner);
  fbitmap:=TBitmapLayer.Create((aowner As timage32).Layers);
  ftimer:=tjvthreadtimer.Create(aowner);
  ftimer.Enabled:=False;
  ftimer.Interval:=1000;
  ftimer.Priority:=tpnormal;
  ftimer.OnTimer:=ontimer;
  finterval:=500;
  fdrawmode:=dmblend;
  falpha:=255;
  fvisible:=True;
  fx:=0;
  fy:=0;
  fwidth:=100;
  fheight:=100;
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
  fmin:=tbitmap32.Create;
  fmin.DrawMode:=dmblend;
  fmin.MasterAlpha:=255;
  fhour:=tbitmap32.Create;
  fhour.DrawMode:=dmblend;
  fhour.MasterAlpha:=255;
End;

Destructor TH2AnalogClock.Destroy;
Begin
//here
  fbitmap.Free;
  ftimer.Free;
  fbmp.Free;
  fmin.free;
  fhour.free;
  Inherited Destroy;
End;

Procedure TH2AnalogClock.LoadBackGround(filename: String);
Var au:Boolean;
Begin
  If fileexists(filename) Then
    Begin
    Try
      LoadPNGintoBitmap32(fbmp,filename,au);
      width:=fbmp.Width;
      height:=fbmp.Height;
    Except
      End;
    End;
End;

Procedure TH2AnalogClock.LoadHour(filename: String);
Var au:Boolean;
Begin
  If fileexists(filename) Then
    Begin
    Try
      LoadPNGintoBitmap32(fhour,filename,au);
    Except
      End;
    End;
End;

Procedure TH2AnalogClock.LoadMinute(filename: String);
Var au:Boolean;
Begin
  If fileexists(filename) Then
    Begin
    Try
      LoadPNGintoBitmap32(fmin,filename,au);
    Except
      End;
    End;
End;

Procedure TH2AnalogClock.Ontimer(Sender: Tobject);
Var
  h,m,s,ms:Word;
  hb,mb:tbitmap32;
Begin
  hb:=tbitmap32.Create;
  hb.DrawMode:=dmblend;
  mb:=tbitmap32.Create;
  mb.DrawMode:=dmblend;
  hb.MasterAlpha:=falpha;
  mb.MasterAlpha:=falpha;
  hb.Width:=fWidth;
  mb.Width:=fWidth;
  hb.height:=fheight;
  mb.height:=fheight;
  decodetime(time,h,m,s,ms);
  If h>12 Then h:=h-12;
  rotate(fmin,mb,-m*6);
  rotate(fhour,hb,-h*30);
  fbmp.DrawTo(fbitmap.Bitmap,0,0);
  hb.DrawTo(fbitmap.Bitmap,0,0);
  mb.DrawTo(fbitmap.Bitmap,0,0);
  hb.free ;
  mb.free;
End;

Procedure TH2AnalogClock.rotate(b: tbitmap32; Var dest: tbitmap32;
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

Procedure TH2AnalogClock.SetAlpha(value: Cardinal);
Begin
  falpha:=value;
  fbitmap.Bitmap.MasterAlpha:=falpha;
  fbmp.MasterAlpha:=falpha;
  fmin.MasterAlpha:=falpha;
  fhour.MasterAlpha:=falpha;
End;

Procedure TH2AnalogClock.SetDrawmode(value: tdrawmode);
Begin
  fdrawmode:=value;
  fbitmap.Bitmap.DrawMode:=fdrawmode;
  fbmp.DrawMode:=fdrawmode;
  fmin.DrawMode:=fdrawmode;
  fhour.DrawMode:=fdrawmode;
End;


Procedure TH2AnalogClock.SetHeight(value: Integer);
Var
  L: TFloatRect;
Begin
  fheight:=value;
  l.Left:=fx;
  l.Top:=fy;
  l.Right:=fx+fwidth;
  l.Bottom:=fy+fheight;
  fbitmap.Location:=l;
  fbmp.Height:=fheight;
  fmin.Height:=fheight;
  fhour.Height:=fheight;
End;

Procedure TH2AnalogClock.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

Procedure TH2AnalogClock.SetWidth(value: Integer);
Var
  L: TFloatRect;
Begin
  fwidth:=value;
  l.Left:=fx;
  l.Top :=fy;
  l.Right:=fx+fwidth;
  l.Bottom:=fy+fheight;
  fbitmap.Location:=l;
  fbmp.width:=fwidth;
  fmin.width:=fwidth;
  fhour.width:=fwidth;
End;

Procedure TH2AnalogClock.Setx(value: Integer);
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

Procedure TH2AnalogClock.Sety(value: Integer);
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

Procedure TH2AnalogClock.Start;
Var
  L: TFloatRect;
Begin
  fbitmap.bitmap.width:=fwidth;
  fbitmap.bitmap.height:=fheight;
  l.Left:=fx;
  l.Right:=fx+fbitmap.Bitmap.Width;
  l.Top :=fy;
  l.Bottom:=fy+fbitmap.Bitmap.height;
  fbitmap.Location:=l;
  ftimer.Enabled:=True;
End;

Procedure TH2AnalogClock.Stop;
Begin
  ftimer.Enabled:=False;
End;

End.

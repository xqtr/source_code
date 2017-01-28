Unit H2TrackBar;

Interface

Uses
  Messages,Windows, Classes,Controls, ExtCtrls, SysUtils,GR32_Image,GR32,
  gr32_layers,Graphics;

Type

  TH2TrackBar = Class(TControl)
  Private
    fx,
    fy,
    fwidth,
    fheight:Integer;
    fvisible:Boolean;
    fpos:Integer;
    fvolume:Boolean;
    fbitmap:tbitmaplayer;
    fdrawmode:tdrawmode;
    falpha:Cardinal;
    fback:tbitmap32;
    ffont:tfont;
    ffront:tbitmap32;
    fmin:Cardinal;
    fshowtext:Boolean;
    fthumb:Boolean;
    fs:String;
    fmax:Cardinal;
    fborder:Byte;
    fposition:Cardinal;
    Procedure SetFont(font:tfont);
    Procedure Setvisible(value:Boolean);
    Procedure SetAlpha(value:Cardinal);
    Procedure SetDrawmode(value:tdrawmode);
    Procedure Setx(value:Integer);
    Procedure Sety(value:Integer);
    Procedure SetPosition(value:Cardinal);
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
  Published
    Procedure LoadBackGround(filename:String);
    Procedure LoadForeGround(filename:String);
    Property Thumb:Boolean Read fthumb Write fthumb;
    Property Min:Cardinal Read fmin Write fmin;
    Property Max:Cardinal Read fmax Write fmax;
    Property Width:Integer Read fwidth;
    Property Text:String Read fs Write fs;
    Property Volume:Boolean Read fvolume Write fvolume;
    Property Position:Cardinal Read fposition Write setposition;
    Property Alpha:Cardinal Read falpha Write setalpha;
    Property Font:tfont Read ffont Write setfont;
    Property DrawMode:tdrawmode Read fdrawmode Write setdrawmode;
    Property Border:Byte Read fborder Write fborder;
    Property Showtext:Boolean Read fshowtext Write fshowtext;
    Property X:Integer Read fx Write setx;
    Property Y:Integer Read fy Write sety;
    Property Bitmap:tbitmaplayer Read fbitmap Write fbitmap;
    Property Visible:Boolean Read fvisible Write setvisible;
  End;


Implementation

Uses Unit1;

Constructor TH2TrackBar.Create(AOwner: TComponent);
Var
  L: TFloatRect;
  alayer:tbitmaplayer;
Begin
  Inherited Create(AOwner);
  fbitmap:=TBitmapLayer.Create((aowner As timage32).Layers);
  fdrawmode:=dmblend;
  ffont:=tfont.Create;
  fvolume:=False;
  fthumb:=False;  
  falpha:=255;
  fvisible:=True;
  fs:='';
  fshowtext:=True;
  fmin:=0;
  fmax:=100;
  fposition:=0;
  fx:=0;
  fpos:=0;
  fy:=0;
  fwidth:=150;
  fheight:=150;
  fback:=tbitmap32.Create;
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
  ffront:=tbitmap32.Create;
  ffront.DrawMode:=dmblend;
  ffront.MasterAlpha:=255;
End;

Destructor TH2TrackBar.Destroy;
Begin
//here
  fbitmap.Free;
  fback.Free;
  ffront.free;
  ffont.Free;
  Inherited Destroy;
End;

Procedure TH2TrackBar.LoadBackGround(filename: String);
Var au:Boolean;
  L: TFloatRect;
Begin
  If fileexists(filename) Then
    Begin
    Try
      LoadPNGintoBitmap32(fback,filename,au);
      fwidth:=fback.Width;
      fheight:=fback.Height;
      ffront.Width:=fwidth;
      ffront.Height:=fheight;
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

Procedure TH2TrackBar.LoadForeground(filename: String);
Var au:Boolean;
Begin
  If fileexists(filename) Then
    Begin
    Try
      LoadPNGintoBitmap32(ffront,filename,au);
    Except
      End;
    End;
End;

Procedure TH2TrackBar.SetAlpha(value: Cardinal);
Begin
  falpha:=value;
  fbitmap.Bitmap.MasterAlpha:=falpha;
  fback.MasterAlpha:=falpha;
  ffront.MasterAlpha:=falpha;
End;

Procedure TH2TrackBar.SetDrawmode(value: tdrawmode);
Begin
  fdrawmode:=value;
  fbitmap.Bitmap.DrawMode:=fdrawmode;
  fback.DrawMode:=fdrawmode;
  ffront.DrawMode:=fdrawmode;
End;

Procedure TH2TrackBar.SetFont(font: tfont);
Begin
  ffont.Assign(font);
End;

Procedure TH2TrackBar.SetPosition(value: Cardinal);
Var
  Color: Longint;
  r, g, b: Byte;
  w,h:Integer;
Begin
  fbitmap.Bitmap.Clear($000000);
  fbitmap.Bitmap.Font.Assign(ffont);
  Color := ColorToRGB(ffont.Color);
  r     := Color;
  g     := Color Shr 8;
  b     := Color Shr 16;
  fposition:=value;
  fback.DrawTo(fbitmap.Bitmap,0,0);
  If fthumb=False Then
    ffront.DrawTo(fbitmap.Bitmap,fborder,fborder,rect(fborder,fborder,(fPosition * (fWidth-(fborder*2)))Div fmax,fheight-fborder))
  Else
    ffront.DrawTo(fbitmap.Bitmap,fborder+((fPosition * (fWidth-(fborder*2)))Div fmax)-(ffront.Width Div 2),fborder);
  If showtext Then
    Begin
    w:=fbitmap.Bitmap.TextWidth(fs);
    h:=fbitmap.Bitmap.Textheight(fs);
    fBitmap.bitmap.RenderText((fwidth Div 2)-(w Div 2),(fheight Div 2) - (h Div 2),fs,0,color32(r,g,b,falpha));
    End;
End;

Procedure TH2TrackBar.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

Procedure TH2TrackBar.Setx(value: Integer);
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

Procedure TH2TrackBar.Sety(value: Integer);
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

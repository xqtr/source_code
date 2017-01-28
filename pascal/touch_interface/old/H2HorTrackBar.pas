Unit H2HorTrackBar;

Interface

Uses
  Messages,Windows, Classes,Controls, ExtCtrls, SysUtils,GR32_Image,GR32,
  gr32_layers,Graphics;

Type

  TH2HorTrackBar = Class(TControl)
  Private
    fx,
    fy,
    fwidth,
    fheight:Integer;
    fid:Byte;
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
    fs: String;
    fmax:Cardinal;
    fborder:Byte;
    fposition:Integer;
    Procedure SetFont(font:tfont);
    Procedure Setvisible(value:Boolean);
    Procedure SetAlpha(value:Cardinal);
    Procedure SetDrawmode(value:tdrawmode);
    Procedure Setx(value:Integer);
    Procedure Sety(value:Integer);
    Procedure SetPosition(value:Integer);
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
    Property Height:Integer Read fheight;
    Property Text:String Read fs Write fs;
    Property Volume:Boolean Read fvolume Write fvolume;
    Property Position:Integer Read fposition Write setposition;
    Property Alpha:Cardinal Read falpha Write setalpha;
    Property Font:tfont Read ffont Write setfont;
    Property DrawMode:tdrawmode Read fdrawmode Write setdrawmode;
    Property Border:Byte Read fborder Write fborder;
    Property Showtext:Boolean Read fshowtext Write fshowtext;
    Property X:Integer Read fx Write setx;
    Property Y:Integer Read fy Write sety;
    Property Bitmap:tbitmaplayer Read fbitmap Write fbitmap;
    Property Visible:Boolean Read fvisible Write setvisible;
    Property ID:Byte Read fid Write fid;
  End;


Implementation

Uses Unit1;

Constructor TH2HorTrackBar.Create(AOwner: TComponent);
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
  fid:=0;
  fvisible:=True;
  fs :='';
  fshowtext:=True;
  fmin:=0;
  fmax:=100;
  fposition:=0;
  fx :=0;
  fpos:=0;
  fy :=0;
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

Destructor TH2HorTrackBar.Destroy;
Begin
//here
  fbitmap.Free;
  fback.Free;
  ffront.free;
  ffont.Free;
  Inherited Destroy;
End;

Procedure TH2HorTrackBar.LoadBackGround(filename: String);
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

Procedure TH2HorTrackBar.LoadForeground(filename: String);
Var au:Boolean;
  L: TFloatRect;
Begin
  If fileexists(filename) Then
    Begin
    Try
      LoadPNGintoBitmap32(ffront,filename,au);
      If ffront.Width>fback.Width Then
        Begin
        fwidth:=ffront.Width;
        fheight:=ffront.Height;
        fbitmap.Bitmap.width:=fwidth;
        fbitmap.Bitmap.Height:=fheight;
        l.Left:=fx;
        l.Top :=fy;
        l.Right:=fx+fwidth;
        l.Bottom:=fy+fheight;
        fbitmap.Location:=l;
        End;

    Except
      End;
    End;
End;


Procedure TH2HorTrackBar.SetAlpha(value: Cardinal);
Begin
  falpha:=value;
  fbitmap.Bitmap.MasterAlpha:=falpha;
  fback.MasterAlpha:=falpha;
  ffront.MasterAlpha:=falpha;
End;

Procedure TH2HorTrackBar.SetDrawmode(value: tdrawmode);
Begin
  fdrawmode:=value;
  fbitmap.Bitmap.DrawMode:=fdrawmode;
  fback.DrawMode:=fdrawmode;
  ffront.DrawMode:=fdrawmode;
End;

Procedure TH2HorTrackBar.SetFont(font: tfont);
Begin
  ffont.Assign(font);
End;

Procedure TH2HorTrackBar.SetPosition(value: Integer);
Var
  x,y:Integer;
Begin
//  fposition:=fmax-value;
  fposition:=value;
  If value>fmax Then fposition:=fmax;
  If value<fmin Then fposition:=fmin;
  fbitmap.Bitmap.Clear($000000);
  x:=(fbitmap.Bitmap.Width Div 2)-(fback.Width Div 2);
  y:=(fbitmap.Bitmap.height Div 2)-(fback.height Div 2);
  fback.DrawTo(fbitmap.Bitmap,x,y);
  If fthumb=False Then
    Begin
    ffront.DrawTo(fbitmap.Bitmap,fborder,fborder,rect(fborder,fborder,fwidth-fborder,fheight-((fPosition * (fheight-(fborder*2)))Div fmax)))
    End Else
    Begin
    x:=fborder+(fwidth Div 2)-(ffront.Width Div 2);
    y:=fheight-(fborder+((fPosition * (fheight-(fborder*2)))Div fmax))-(ffront.height Div 2);
    If y<0 Then y:=0;
    If y+ffront.Height>fheight Then y:=fheight-ffront.Height;
    ffront.DrawTo(fbitmap.Bitmap,x,y);
    End;
End;

Procedure TH2HorTrackBar.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

Procedure TH2HorTrackBar.Setx(value: Integer);
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

Procedure TH2HorTrackBar.Sety(value: Integer);
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

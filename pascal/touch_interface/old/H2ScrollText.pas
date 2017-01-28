Unit H2ScrollText;

Interface

Uses
  Messages,Windows, Classes,Controls, ExtCtrls, SysUtils,GR32_Image,GR32,
  gr32_layers,Graphics;

Type

  TH2Scrolltext = Class(TControl)
  Private
    fNewstr:String;
    fanimate:Boolean;
    ftimer:tTimer;
    finterval:Cardinal;
    fsep:String;
    fx,
    fy,
    fwidth,
    fheight:Integer;
    fvisible:Boolean;
    fitems:tstringlist;
    ffont:tfont;
    fpos: Integer;
    fbitmap:tbitmaplayer;
    fbmp: tbitmap32;
    fdrawmode:tdrawmode;
    falpha:Cardinal;
    Procedure SetFont(font:tfont);
    Procedure Setvisible(value:Boolean);
    Procedure SetAnimate(value:Boolean);
    Procedure SetNewStr(value:String);
    Procedure Ontimer(Sender:Tobject);Virtual;
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
  Published
    Procedure Clear;
    Procedure Start;
    Procedure Stop;
    Property Seperator:String Read fsep Write fsep;
    Property NewStr:String Write SetNewStr;
    Property Animate:Boolean Read fanimate Write setanimate;
    Property Interval:Cardinal Read finterval Write finterval;
    Property Font:tfont Read ffont Write setfont;
    Property Alpha:Cardinal Read falpha Write falpha;
    Property DrawMode:tdrawmode Read fdrawmode Write fdrawmode;
    Property X:Integer Read fx Write fx;
    Property Y:Integer Read fy Write fy;
    Property Width:Integer Read fwidth Write fwidth;
    Property Height:Integer Read fheight Write fheight;
    Property Bitmap:tbitmaplayer Read fbitmap Write fbitmap;
    Property Visible:Boolean Read fvisible Write setvisible;
    Property OnMouseDown;
    Property OnMouseMove;
    Property OnMouseUp;
    Property OnClick;
    Property OnDblClick;

  End;

Implementation

{ TH2Label }

Procedure TH2Scrolltext.Clear;
Begin
  fitems.Clear;
  fanimate:=False;
  ftimer.Enabled:=False;
End;

Constructor TH2Scrolltext.Create(AOwner: TComponent);
Var
  L: TFloatRect;
Begin
  Inherited Create(AOwner);
  fbitmap:=TBitmapLayer.Create((aowner As timage32).Layers);
  ffont:=tfont.Create;
  ftimer:=ttimer.Create(aowner);
  ftimer.Enabled:=False;
  ftimer.Interval:=500;
  fsep:=' # ';
  ftimer.OnTimer:=ontimer;
  fanimate:=False;
  finterval:=500;
  fitems:=tstringlist.Create;
  fnewstr:='';
  fdrawmode:=dmblend;
  falpha:=255;
  fvisible:=True;
  fx:=0;
  fpos:=0;
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

End;

Destructor TH2Scrolltext.Destroy;
Begin
//here
  stop;
  ffont.Free;
  fbitmap.Free;
  ftimer.Free;
  fitems.Free;
  fbmp.Free;
  Inherited Destroy;
End;

Procedure TH2Scrolltext.Ontimer(Sender: Tobject);
Begin
  ftimer.Enabled:=False;
  If fanimate Then
    Begin
    fpos:=fpos+1;
    fbmp.DrawTo(fBitmap.Bitmap,0,0,rect(fpos,0,fwidth+fpos,fHeight));
    If fpos>=fbmp.Width Then fpos:=0;
    End;
  ftimer.Enabled:=True;
End;

Procedure TH2Scrolltext.SetAnimate(value: Boolean);
Begin
  fanimate:=value;
  ftimer.Interval:=finterval;
  ftimer.Enabled:=fanimate;
End;

Procedure TH2Scrolltext.SetFont(font: tfont);
Begin
  ffont.Assign(font);
End;

Procedure TH2Scrolltext.SetNewStr(value: String);
Var
  w,i,j:Integer;
  Color: Longint;
  r, g, b: Byte;
Begin
  ftimer.Enabled:=False;
  fpos:=0;
  fitems.add(value+fsep);
  fbmp.Clear($000000);
  fbmp.Width:=0;
  fbmp.Height:=fheight;
  fbmp.Font.Assign(ffont);
  Color := ColorToRGB(ffont.Color);
  r     := Color;
  g     := Color Shr 8;
  b     := Color Shr 16;
  w:=0;
  For i:=0 To fitems.Count-1 Do
    Begin
    w:=fbmp.TextWidth(fitems[i])+w;
    End;
  fbmp.Width:=w+fwidth;
  j:=0;
  For i:=0 To fitems.Count-1 Do
    Begin
    fbmp.RenderText(fwidth+j,0,fitems[i],0,color32(r,g,b,falpha));
    j:=j+fbmp.TextWidth(fitems[i]);
    End;
  ftimer.Enabled:=True;
End;

Procedure TH2Scrolltext.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

Procedure TH2Scrolltext.Start;
Var
  L: TFloatRect;
Begin
  fbitmap.bitmap.width:=fwidth;
  fbitmap.bitmap.height:=fheight;
  l.Left:=fx;
  l.Right:=fx+fbitmap.Bitmap.Width;
  l.Top :=fy;
  l.Bottom:=fy+fbitmap.Bitmap.height;
  ftimer.Interval:=finterval;
  fbitmap.Location:=l;
  fanimate:=True;
  ftimer.Enabled:=True;
End;

Procedure TH2Scrolltext.Stop;
Begin
  fanimate:=False;
  ftimer.Enabled:=False;
End;

End.

Unit H2Edit;

Interface

Uses
  Messages,Windows, Classes,Controls, ExtCtrls, SysUtils,GR32_Image,GR32,gr32_layers,Graphics;

Type

  TH2Edit = Class(TControl)
  Private
    fcaption:String;
    fx,
    fy,
    fwidth,
    fheight:Integer;
    fvisible:Boolean;
    ffont:tfont;
    fbitmap:tbitmaplayer;
    fdrawmode:tdrawmode;
    falpha:Cardinal;
    Procedure SetCaption(NewCaption:String);
    Procedure SetFont(font:tfont);
    Procedure Setvisible(value:Boolean);
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
  Published
    Property Caption:String Read fcaption Write Setcaption;
    Property Font:tfont Read ffont Write setfont;
    Property Alpha:Cardinal Read falpha Write falpha;
    Property DrawMode:tdrawmode Read fdrawmode Write fdrawmode;
    Property X:Integer Read fx Write fx;
    Property Y:Integer Read fy Write fy;
    Property Bitmap:tbitmaplayer Read fbitmap Write fbitmap;
    Property Visible:Boolean Read fvisible Write setvisible;
    Property OnMouseDown;
    Property OnMouseMove;
    Property OnMouseUp;
    Property OnClick;
    Property OnDblClick;

  End;

Implementation

{ TH2Edit }

Constructor TH2Edit.Create(AOwner: TComponent);
Var
  L: TFloatRect;
  alayer:tbitmaplayer;
Begin
  Inherited Create(AOwner);
  fbitmap:=TBitmapLayer.Create((aowner As timage32).Layers);
  ffont:=tfont.Create;
  fcaption:='';
  fdrawmode:=dmblend;
  falpha:=255;
  fvisible:=True;
  fx:=0;
  fy:=0;
  fwidth:=100;
  fheight:=100;
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

Destructor TH2Edit.Destroy;
Begin
//here
  ffont.Free;
  fbitmap.Free;
  Inherited Destroy;
End;

Procedure TH2Edit.SetCaption(NewCaption: String);
Var
  Color: Longint;
  r, g, b: Byte;
  L: TFloatRect;
Begin
  //caption:=newcaption;
  fcaption:=newcaption;
  fbitmap.Bitmap.Clear($000000);
  fbitmap.Bitmap.Font.Assign(ffont);
  Color := ColorToRGB(ffont.Color);
  r     := Color;
  g     := Color Shr 8;
  b     := Color Shr 16;
  fbitmap.Bitmap.Width:=fbitmap.Bitmap.TextWidth(fcaption);
  fbitmap.Bitmap.height:=fbitmap.Bitmap.TextHeight(fcaption);
  fBitmap.bitmap.RenderText(0,0,fcaption,0,color32(r,g,b,falpha));
  l.Left:=fx;
  l.Right:=fx+fbitmap.Bitmap.Width;
  l.Top :=fy;
  l.Bottom:=fy+fbitmap.Bitmap.height;
  fbitmap.Location:=l;

End;


Procedure TH2Edit.SetFont(font: tfont);
Begin
  ffont.Assign(font);
End;

Procedure TH2Edit.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

End.

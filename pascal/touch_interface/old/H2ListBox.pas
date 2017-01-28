Unit H2ListBox;

Interface

Uses
  Messages,Windows, Classes,Controls, ExtCtrls, SysUtils,GR32_Image,GR32,gr32_layers,Graphics;

Type

  TH2ListBox = Class(TControl)
  Private
    fx,
    fy,
    fwidth,
    fheight,
    fcount,
    findent,
    ffirst,
    findex,
    fitemheight:Integer;
    fvisible:Boolean;
    ftitle:String;
    ffont: tfont;
    fbitmap:tbitmaplayer;
    fselect:tbitmap32;
    fdrawmode:tdrawmode;
    falpha:Cardinal;
    fitems:tstringlist;
    Procedure SetFont(value:tfont);
    Procedure SetItems(value:tstringlist);
    Procedure Setvisible(value:Boolean);
    Procedure SetItemindex(value:Integer);
    Procedure Setx(value:Integer);
    Procedure Sety(value:Integer);
    Procedure SetWidth(value:Integer);
    Procedure SetHeight(value:Integer);
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure MouseDown(Sender: TObject; Buttons: TMouseButton; Shift: TShiftState; X, Y: Integer);
  Published
    Procedure LoadSelection(Filename:String);
    Procedure ScrollDown;
    Procedure ScrollUp;
    Procedure Clear;
    Procedure UpdateLV;
    Property Font:tfont Read ffont Write setfont;
    Property Alpha:Cardinal Read falpha Write falpha;
    Property DrawMode:tdrawmode Read fdrawmode Write fdrawmode;
    Property X:Integer Read fx Write setx;
    Property Y:Integer Read fy Write sety;
    Property Width:Integer Read fwidth Write setwidth;
    Property Title:String Read ftitle Write ftitle;
    Property Height:Integer Read fheight Write setheight;
    Property Bitmap:tbitmaplayer Read fbitmap Write fbitmap;
    Property Items:tstringlist Read fitems Write Setitems;
    Property Visible:Boolean Read fvisible Write setvisible;
    Property ItemIndex:Integer Read findex Write setitemindex;
    Property Indent:Integer Read findent Write findent;
    Property ItemHeight:Integer Read fitemheight Write fitemheight;
    Property MaxItems:Integer Read fcount Write fcount;
    Property OnMouseDown;
    Property OnMouseMove;
    Property OnMouseUp;
    Property OnClick;
    Property OnDblClick;

  End;

Implementation

Uses unit1;
{ TH2ListBox }

Procedure TH2ListBox.Clear;
Begin
  fitems.Clear;
  ffirst:=0;
  findex:=-1;
  updatelv;
End;

Constructor TH2ListBox.Create(AOwner: TComponent);
Var
  L: TFloatRect;
  alayer:tbitmaplayer;
Begin
  Inherited Create(AOwner);
  fbitmap:=TBitmapLayer.Create((aowner As timage32).Layers);
  fbitmap.OnMouseUp:=mousedown;
  ffont:=tfont.Create;
  fdrawmode:=dmblend;
  falpha:=255;
  fvisible:=True;
  fitems:=tstringlist.Create;
  ftitle:='';
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
  fselect:=tbitmap32.Create;
  fselect.DrawMode:=fdrawmode;
  fselect.MasterAlpha:=falpha;
  fcount:=5;
  findent:=0;
  ffirst:=0;
  findex:=-1;
  fitemheight:=20;
End;

Destructor TH2ListBox.Destroy;
Begin
//here
  ffont.Free;
  fbitmap.Free;
  fitems.Destroy;
  fselect.Free;
  Inherited Destroy;
End;

Procedure TH2ListBox.LoadSelection(Filename: String);
Var au:Boolean;
  L: TFloatRect;
Begin
  If fileexists(filename) Then
    Begin
    Try
      LoadPNGintoBitmap32(fselect,filename,au);
    Except
      End;
    End;
End;

Procedure TH2ListBox.MouseDown(Sender: TObject; Buttons: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var i,c:Integer;
Begin
  If ffirst+fcount>fitems.Count-1 Then c:=fitems.Count-1 Else c:=ffirst+fcount;
  For i:=ffirst To c Do
    Begin
    If (x>=fx+findent) And (x<=fx+fwidth-findent) And (y>=fitemheight+fy+(fitemheight*(i-ffirst))) And (y<=fitemheight+fy+(fitemheight*(i-ffirst)+fitemheight)) Then
      findex:=i;
    End;
  updatelv;
End;

Procedure TH2ListBox.ScrollDown;
Begin
  If ffirst+fcount>fitems.Count-1 Then exit;
  ffirst:=ffirst+fcount;
  updatelv;
End;

Procedure TH2ListBox.ScrollUp;
Begin
  If ffirst-fcount<=0 Then ffirst:=0 Else ffirst:=ffirst-fcount;
  updatelv;
End;

Procedure TH2ListBox.SetFont(value: tfont);
Var
  Color: Longint;
  r, g, b: Byte;
Begin
  ffont.Assign(value);
  Color := ColorToRGB(ffont.Color);
  r     := Color;
  g     := Color Shr 8;
  b     := Color Shr 16;
  fbitmap.Bitmap.Font.assign(ffont);
End;

Procedure TH2ListBox.SetHeight(value: Integer);
Var
  L: TFloatRect;
Begin
  fheight:=value;
  l.Left:=fx;
  l.Top:=fy;
  l.Right:=fx+fwidth;
  l.Bottom:=fy+fheight;
  fbitmap.Location:=l;
  fbitmap.Bitmap.Height:=fheight;
End;

Procedure TH2ListBox.SetItemindex(value: Integer);
Begin
  findex:=value;
  updatelv;
End;

Procedure TH2ListBox.SetItems(value: tstringlist);
Begin
  fitems.Assign(value);
  findex:=fitems.Count-1;
  updatelv;
End;

Procedure TH2ListBox.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

Procedure TH2ListBox.SetWidth(value: Integer);
Var
  L: TFloatRect;
Begin
  fwidth:=value;
  l.Left:=fx;
  l.Top :=fy;
  l.Right:=fx+fwidth;
  l.Bottom:=fy+fheight;
  fbitmap.Location:=l;
  fbitmap.Bitmap.Width:=fwidth;
End;

Procedure TH2ListBox.Setx(value: Integer);
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

Procedure TH2ListBox.Sety(value: Integer);
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

Procedure TH2ListBox.UpdateLV;
Var i,c,h:Integer;
  Color:  Longint;
  r, g, b: Byte;
Begin
  fbitmap.Bitmap.Clear($000000);
  Color := ColorToRGB(ffont.Color);
  r     := Color;
  g     := Color Shr 8;
  b     := Color Shr 16;
  fbitmap.Bitmap.Font.Assign(ffont);
  h:=(fitemheight Div 2)-(fbitmap.bitmap.TextHeight(ftitle) Div 2);
  fbitmap.Bitmap.Rendertext(findent,h,ftitle,0,color32(r,g,b,falpha));
  h:=(fitemheight Div 2)-(fbitmap.bitmap.TextHeight(inttostr(findex+1)+'/'+inttostr(fitems.Count)) Div 2);
  c:=fbitmap.bitmap.Textwidth(inttostr(findex+1)+'/'+inttostr(fitems.Count));
  fbitmap.Bitmap.Rendertext(fwidth-c,h,inttostr(findex+1)+'/'+inttostr(fitems.Count),0,color32(r,g,b,falpha));

  If fitems.Count=0 Then exit;
  If ffirst+fcount>fitems.Count-1 Then c:=fitems.Count-1 Else c:=ffirst+fcount;
  For i:=ffirst To c Do
    Begin
    If i=findex Then
      Begin
      fselect.DrawTo(fbitmap.Bitmap,0,fitemheight+fitemheight*(i-ffirst));
      End;
    h:=(fitemheight Div 2)-(fbitmap.bitmap.TextHeight(fitems[i]) Div 2);
    fbitmap.Bitmap.Rendertext(findent,(fitemheight*(i-ffirst))+h+fitemheight,fitems[i],0,color32(r,g,b,falpha));
    End;


End;

End.

unit GraphicMemo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  LCLIntf;

type

  { TGraphicMemo }

  TGraphicMemo = class(TPanel)
  private
    fback:tpicture;
    fbuff:tbitmap;
    fcircle:tpicture;
    flines:Tstringlist;
    ffont:tfont;
    findex:integer;
    fx,fy,fx1,fy1,fident:integer;
    fdown:boolean;
    findent:integer;
    floaded:boolean;
    procedure setback(Value: tpicture);
    procedure setcircle(Value: tpicture);
    procedure setident(Value: integer);
    procedure setlines(value:tstringlist);
    procedure loadtextbuffer;
    procedure setfont(value:tfont);
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    Procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    destructor Destroy; override;
    procedure Paint; override;
  published
    Procedure LoadFromFile(s:string);
    Procedure Apply;
    Procedure ScrollBy(y:integer);
    Property Background:tpicture read fback write setback;
    Property Circle:tpicture read fcircle write setcircle;
    Property Indent:integer read findent write setident;
    Property Lines:tstringlist read flines write setlines;
    Property Font:tfont read ffont write setfont;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Touch',[TGraphicMemo]);
end;

{ TGraphicMemo }

procedure TGraphicMemo.setident(Value: integer);
begin
  findent:=value;
  invalidate;
end;

procedure TGraphicMemo.setback(Value: tpicture);
begin
  fback.assign(value);
end;

procedure TGraphicMemo.setcircle(Value: tpicture);
begin
  fcircle.assign(value);
end;

procedure TGraphicMemo.setlines(value: tstringlist);
begin
  lines.assign(value);
  loadtextbuffer;
  invalidate;
end;

procedure TGraphicMemo.loadtextbuffer;
var
  i,w:integer;
begin
  if flines.count<=0 then exit;
  findex:=0;
  w:=0;

  fbuff.height:=(flines.count*ffont.size)+(height div 2)+(flines.count);
  fbuff.width:=width-(findent*2);
  fbuff.Canvas.Font.Assign(ffont);
  fbuff.Canvas.AntialiasingMode:=amOff;
  fbuff.canvas.brush.style:=bsclear;
  with fbuff do begin
   transparentmode:=tmauto;
   transparent:=true;
  end;
  fbuff.canvas.Clear;
  for i:=0 to flines.count-1 do begin
    w:=fbuff.canvas.TextWidth(flines[i]);
    if alignment=tacenter then fbuff.Canvas.TextOut((fbuff.width div 2)-(w div 2),(i*(ffont.size+2)),flines[i]);;
    if alignment=taleftjustify then fbuff.Canvas.TextOut(0,(i*(ffont.size+2)),flines[i]);
    if alignment=tarightjustify then fbuff.Canvas.TextOut(fbuff.width-w,(i*(ffont.size+2)),flines[i]);
  end;
end;

procedure TGraphicMemo.setfont(value: tfont);
begin
  ffont.assign(value);
  fbuff.Canvas.Font.assign(value);
end;


constructor TGraphicMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fback:= tpicture.Create;
  Fbuff:= tbitmap.Create;
  fcircle:=tpicture.create;
  ffont:=tfont.create;
  flines:=tstringlist.create;
  fbuff.Width:=1;
  fbuff.height:=1;
  bevelinner:=bvnone;
  bevelouter:=bvnone;
  findex:=0;
  fx:=0;
  floaded:=false;
  fy:=0;
  findent:=0;
  fdown:=false;
end;

procedure TGraphicMemo.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if fdown then  scrollby(fy-y);
  fy:=y;
  fx1:=x;
  fy1:=y;
  inherited MouseMove(Shift, X, Y);
end;

procedure TGraphicMemo.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  fdown:=false;
  invalidate;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TGraphicMemo.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  fdown:=true;
  fx:=y;
  inherited MouseDown(Button, Shift, X, Y);
end;

destructor TGraphicMemo.Destroy;
begin
  fback.free;
  flines.Free;
  fbuff.free;
  fcircle.free;
  ffont.free;
  inherited Destroy;
end;

procedure TGraphicMemo.Paint;
begin
if assigned(fback) then canvas.draw(0,0,fback.graphic);
  canvas.Draw(findent,-findex+findent,fbuff);
  canvas.CopyRect(rect(0,0,width,findent),fback.Bitmap.canvas,rect(0,0,width,findent));
  canvas.CopyRect(rect(0,height-findent,width,height+20),fback.Bitmap.canvas,rect(0,height-findent,width,height+20));
if (fdown=true) and (assigned(fcircle)) then canvas.draw(fx1-(fcircle.width div 2),fy1-(fcircle.height div 2),fcircle.graphic);
end;

procedure TGraphicMemo.LoadFromFile(s: string);
begin
  lines.clear;
  floaded:=true;
  lines.LoadFromFile(s);
  loadtextbuffer;
  invalidate;
end;

procedure TGraphicMemo.Apply;
begin
  loadtextbuffer;
  invalidate;
end;

procedure TGraphicMemo.ScrollBy(y: integer);
begin
  findex:=findex+y;
  if (findex+height)>= fbuff.height then findex:=fbuff.height-height;
  if findex<=0 then findex:=0;
  invalidate;
end;

end.
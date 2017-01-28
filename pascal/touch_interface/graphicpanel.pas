unit GraphicPanel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TGraphicPanel }

  TGraphicPanel = class(TPanel)
  private
    fup:tpicture;
    fdown:tpicture;
    fleft:tpicture;
    fright:tpicture;
    fupperleft:tpicture;
    fupperright:tpicture;
    fdownleft:tpicture;
    fdownright:tpicture;
    rright: tpicture;
    procedure setdown(Value: tpicture);
    procedure setdownleft(Value: tpicture);
    procedure setdownright(Value: tpicture);
    procedure setleft(Value: tpicture);
    procedure setright(Value: tpicture);
    procedure setup(Value: tpicture);
    procedure setupperleft(Value: tpicture);
    procedure setupperright(Value: tpicture);
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
  published
    { Published declarations }
    Property ImgUp:tpicture read fup write setup;
    Property ImgDown:tpicture read fdown write setdown;
    Property ImgLeft:tpicture read fleft write setleft;
    Property ImgRight:tpicture read fright write setright;
    Property ImgUpperleft:tpicture read fupperleft write setupperleft;
    Property ImgUpperright:tpicture read fupperright write setupperright;
    Property ImgDownleft:tpicture read fdownleft write setdownleft;
    Property ImgDownright:tpicture read fdownright write setdownright;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Touch',[TGraphicPanel]);
end;

{ TGraphicPanel }

procedure TGraphicPanel.setdown(Value: tpicture);
begin
  fdown.assign(value);
end;

procedure TGraphicPanel.setdownleft(Value: tpicture);
begin
  fdownleft.assign(value);
end;

procedure TGraphicPanel.setdownright(Value: tpicture);
begin
  fdownright.assign(value);
end;

procedure TGraphicPanel.setleft(Value: tpicture);
begin
  fleft.assign(value);
end;

procedure TGraphicPanel.setright(Value: tpicture);
begin
  fright.assign(value);
end;

procedure TGraphicPanel.setup(Value: tpicture);
begin
  fup.assign(value);
end;

procedure TGraphicPanel.setupperleft(Value: tpicture);
begin
  fupperleft.assign(value);
end;

procedure TGraphicPanel.setupperright(Value: tpicture);
begin
  fupperright.assign(value);
end;

constructor TGraphicPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
    fup:=tpicture.create;
    fdown:=tpicture.create;
    fleft:=tpicture.create;
    fright:=tpicture.create;
    fupperleft:=tpicture.create;
    fupperright:=tpicture.create;
    fdownleft:=tpicture.create;
    fdownright:=tpicture.create;
    rright:=tpicture.create;
    caption:='';
    BevelInner:=bvnone;
    BevelOuter:=bvnone;
end;

destructor TGraphicPanel.Destroy;
begin
    fup.free;
    fdown.free;
    fleft.free;
    fright.free;
    fupperleft.free;
    fupperright.free;
    fdownleft.free;
    fdownright.free;
    rright.free;
  inherited Destroy;
end;

procedure TGraphicPanel.Paint;
var
  i,d:integer;
begin
  inherited Paint;
  i:=0;
  while i<width do begin
    i:=i+fup.width;
    canvas.Draw(i,0,fup.Graphic);
  end;
//  for i:=0 to width by fup.width do canvas.Draw(i,0,fup.Graphic);
  i:=0;
  while i<width do begin
    i:=i+fdown.width;
    canvas.Draw(i,height-fdown.height,fdown.Graphic);
  end;
//  for i:=0 to width do canvas.Draw(i,height-fdown.height,fdown.Graphic);
  i:=0;
  while i<height do begin
    i:=i+fleft.height;
    canvas.Draw(0,i,fleft.Graphic);
  end;
//  for i:=0 to height do canvas.Draw(0,i,fleft.Graphic);
 i:=0;
  while i<height do begin
    i:=i+fright.height;
    canvas.Draw(width-fright.width,i,fright.Graphic);
  end;
//  for i:=0 to height do canvas.Draw(width-fright.width,i,fright.Graphic);
  canvas.Draw(0,0,fupperleft.graphic);
  canvas.draw(0,height-fdownleft.height,fdownleft.graphic);
  canvas.draw(width-fupperright.width,0,fupperright.graphic);
  canvas.draw(width-fdownright.width,height-fdownright.height,fdownright.graphic);
end;

end.
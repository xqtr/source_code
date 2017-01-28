unit MultiStateButton;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TMultiStateButton }

  TMultiStateButton = class(TImage)
  private
    fastate:integer;
    fstates:integer;
    fpath,
    fimage,
    fext:string;
    Procedure setpath(value:string);
    Procedure Setstate(value:integer);
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    Procedure Click; override;
  published
    Property Path:string read fpath write setpath;
    Property ImageFile:string read fimage write fimage;
    Property Extension:string read fext write fext;
    Property StatesCount:integer read fstates write fstates default 2;
    Property State:integer read fastate write setstate;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Touch',[TMultiStateButton]);
end;

{ TMultiStateButton }

procedure TMultiStateButton.setpath(value: string);
begin
  fpath:=IncludeTrailingPathDelimiter(value);
end;

procedure TMultiStateButton.Setstate(value: integer);
begin
  if (fpath='') or (fext='') or (fimage='') then exit;
  if (value>=1) and (value<=fstates) then fastate:=value else fastate:=1;
  picture.LoadFromFile(fpath+fimage+'_'+inttostr(fastate)+fext);
end;

constructor TMultiStateButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fstates:=2;
  fastate:=1;
  fpath:='';
  fimage:='';
  fext:='.png';
end;

destructor TMultiStateButton.Destroy;
begin
  inherited Destroy;
end;

procedure TMultiStateButton.Click;
begin
  if (fpath='') or (fext='') or (fimage='') then exit;
  fastate:=fastate+1;
  if fastate>fstates then fastate:=1;
  picture.LoadFromFile(fpath+fimage+'_'+inttostr(fastate)+fext);
  inherited Click;
end;

end.

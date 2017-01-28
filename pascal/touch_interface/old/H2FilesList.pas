Unit H2FilesList;

Interface

Uses
  Windows, Classes,controls,  SysUtils,GR32_Image,GR32,
  gr32_layers,Graphics,generalprocedures,shellapi;

Type
  PIRecord=^TIrecord;
  TIRecord=Record
    dir:String;
    filename:String;
    size:Integer;
    folder:Boolean;
  End;

  TH2FilesList = Class(TControl)
  Private
    fsrx,
    fsry,
    fsrf,
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
    ftitle,
    fdir,
    ffile: String;
    ffont: tfont;
    ftitleheight:Integer;
    fbitmap:tbitmaplayer;
    fselect:tbitmap32;
    ffolder:tbitmap32;
    fdrawmode:tdrawmode;
    falpha:Cardinal;
    fitems:tlist;
    Procedure SetFont(value:tfont);
    Procedure SetItems(value:tlist);
    Procedure Setvisible(value:Boolean);
    Procedure SetItemindex(value:Integer);
    Procedure Setx(value:Integer);
    Procedure Sety(value:Integer);
    Procedure SetWidth(value:Integer);
    Procedure SetHeight(value:Integer);
    Procedure SetDir(value:String);
    Procedure Findfiles(FilesList: TList; StartDir, FileMask: String);
    Procedure FindDir(DirList:tlist;startdir,filemask:String);
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure MouseDown(Sender: TObject; Buttons: TMouseButton; Shift: TShiftState; X, Y: Integer);
  Published
    Procedure LoadSelection(Filename:String);
    Procedure LoadFolderICO(Filename:String);
    Procedure Files;
    Procedure Select;
    Procedure FolderUP;
    Procedure ScrollDown;
    Procedure Delete;
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
    Property Filename:String Read ffile Write ffile;
    Property Dir:String Read fdir Write setdir;
    Property Height:Integer Read fheight Write setheight;
    Property TitleHeight:Integer Read ftitleheight Write ftitleheight;
    Property Bitmap:tbitmaplayer Read fbitmap Write fbitmap;
    Property Items:tlist Read fitems Write Setitems;
    Property Visible:Boolean Read fvisible Write setvisible;
    Property ItemIndex:Integer Read findex Write setitemindex;
    Property Indent:Integer Read findent Write findent;
    Property ItemHeight:Integer Read fitemheight Write fitemheight;
    Property MaxItems:Integer Read fcount Write fcount;
    Property SizeRx:Integer Read fsrx Write fsrx;
    Property SizeRy:Integer Read fsry Write fsry;
    Property SizeRFont:Integer Read fsrf Write fsrf;
  End;

Implementation

Uses unit1;
{ TH2FilesList }

Procedure TH2FilesList.Select;
Begin
  If findex<0 Then exit;
  If pirecord(fitems[findex]).folder=False Then
    Begin
    shellexecute(0,'open',Pchar(pirecord(fitems[findex]).dir+pirecord(fitems[findex]).filename),'','',sw_show);
    updatelv;
    End Else
    Begin
    fdir:=fdir+pirecord(fitems[findex]).filename;
    fdir:=IncludeTrailingPathDelimiter(fdir);
    clear;

    finddir(fitems,fdir,'*.*');
    findfiles(fitems,fdir,'*.*');
    updatelv;
    End;
End;

Procedure TH2FilesList.Clear;
Var i:Integer;
Begin
  For i:=fitems.Count-1 Downto 0 Do dispose(pirecord(fitems[i]));
  fitems.Clear;
  ffirst:=0;
  findex:=-1;
  fbitmap.Bitmap.Clear($000000);
End;

Constructor TH2FilesList.Create(AOwner: TComponent);
Var
  L: TFloatRect;
  alayer:tbitmaplayer;
Begin
  Inherited Create(AOwner);
  fbitmap:=TBitmapLayer.Create((aowner As timage32).Layers);
  fbitmap.OnMouseUp:=mousedown;
  ftitleheight:=15;
  ffont:=tfont.Create;
  fdrawmode:=dmblend;
  falpha:=255;
  fvisible:=True;
  fitems:=tlist.Create;
  ftitle:='';
  fdir:='c:\';
  ffile:='';
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
  ffolder:=tbitmap32.create;
  ffolder.DrawMode:=fdrawmode;
  ffolder.MasterAlpha:=falpha;
  fcount:=5;
  findent:=0;
  ffirst:=0;
  findex:=-1;
  fitemheight:=20;
End;

Destructor TH2FilesList.Destroy;
Begin
//here
  ffont.Free;
  fbitmap.Free;
  ffolder.Free;
  fitems.Destroy;

  fselect.Free;
  Inherited Destroy;
End;

Procedure TH2FilesList.FindDir(DirList: tlist; startdir,
  filemask: String);
Var
  SR: TSearchRec;
  IsFound: Boolean;
  i: Integer;
  v:pirecord;
Begin
  // Build a list of subdirectories
  IsFound := FindFirst(StartDir+'*.*', faAnyFile, SR) = 0;
  While IsFound Do
    Begin
    If ((SR.Attr And faDirectory) <> 0) And
      (SR.Name[1] <> '.') Then
      Begin
      v:=new(pirecord);
      v.dir:=startdir;
      v.filename:=SR.Name;
      v.size:=sr.Size;
      v.folder:=True;
      DirList.Add(v);
      End;
    IsFound := FindNext(SR) = 0;
    End;
  FindClose(SR);
End;

Procedure TH2FilesList.Findfiles(FilesList: TList; StartDir,
  FileMask: String);
Var
  SR: TSearchRec;
  IsFound: Boolean;
  i: Integer;
  v:pirecord;
Begin
  If StartDir[length(StartDir)] <> '\' Then
    StartDir := StartDir + '\';

  { Build a list of the files in directory StartDir
     (not the directories!)                         }

  IsFound :=
    FindFirst(StartDir+FileMask, faAnyFile-faDirectory, SR) = 0;
  While IsFound Do
    Begin
    v:=new(pirecord);
    v.dir:=startdir;
    v.filename:=SR.Name;
    v.size:=sr.Size;
    v.folder:=False;
    FilesList.Add(v);
    IsFound := FindNext(SR) = 0;
    End;
  FindClose(SR);
End;

Procedure TH2FilesList.files;
Begin
  clear;
  finddir(fitems,fdir,'*.*');
  findfiles(fitems,fdir,'*.*');
  updatelv;
End;


Procedure TH2FilesList.LoadFolderICO(Filename: String);
Var au:Boolean;
Begin
  If fileexists(filename) Then
    Begin
    Try
      LoadPNGintoBitmap32(ffolder,filename,au);
    Except
      End;
    End;
End;

Procedure TH2FilesList.LoadSelection(Filename: String);
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

Procedure TH2FilesList.MouseDown(Sender: TObject; Buttons: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var i,c:Integer;
Begin
  If ffirst+fcount>fitems.Count-1 Then c:=fitems.Count-1 Else c:=ffirst+fcount;
  For i:=ffirst To c Do
    Begin
    If (x>=fx+findent) And (x<=fx+fwidth) And (y>=ftitleheight+fy+(fitemheight*(i-ffirst))) And (y<=ftitleheight+fy+(fitemheight*(i-ffirst)+fitemheight)) Then
      findex:=i;
    End;
  updatelv;
End;

Procedure TH2FilesList.ScrollDown;
Var i,d:Integer;
Begin
    If ffirst+fcount>fitems.Count-1 Then exit;
    ffirst:=ffirst+fcount;
    updatelv;
End;

Procedure TH2FilesList.ScrollUp;
Var i,d:Integer;
Begin
    If ffirst-fcount<=0 Then ffirst:=0 Else ffirst:=ffirst-fcount;
    updatelv;
End;

Procedure TH2FilesList.SetDir(value: String);
Var
  i:Integer;
Begin
  i:=fbitmap.Bitmap.TextWidth(inttostr(findex)+'/'+inttostr(fitems.count));
  fdir:=value;
  ftitle:=mince(value,fwidth-i,fbitmap.Bitmap);
End;

Procedure TH2FilesList.SetFont(value: tfont);
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

Procedure TH2FilesList.SetHeight(value: Integer);
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

Procedure TH2FilesList.SetItemindex(value: Integer);
Begin
  findex:=value;
  updatelv;
End;

Procedure TH2FilesList.SetItems(value: tlist);
Begin
  fitems.Assign(value);
  findex:=fitems.Count-1;
  updatelv;
End;

Procedure TH2FilesList.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

Procedure TH2FilesList.SetWidth(value: Integer);
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

Procedure TH2FilesList.Setx(value: Integer);
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

Procedure TH2FilesList.Sety(value: Integer);
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

Procedure TH2FilesList.UpdateLV;
Var i,c,h:Integer;
  a:Real;
  Color: Longint;
  r, g, b: Byte;
  s:String;
Begin
  fbitmap.Bitmap.Clear($000000);
  Color := ColorToRGB(ffont.Color);
  r     := Color;
  g     := Color Shr 8;
  b     := Color Shr 16;
  fbitmap.Bitmap.Font.Assign(ffont);

    h:=(ftitleheight Div 2)-(fbitmap.bitmap.TextHeight(inttostr(findex+1)+'/'+inttostr(fitems.Count)) Div 2);
    c:=fbitmap.bitmap.Textwidth(inttostr(findex+1)+'/'+inttostr(fitems.Count));
    fbitmap.Bitmap.Rendertext(fwidth-c,h,inttostr(findex+1)+'/'+inttostr(fitems.Count),0,color32(r,g,b,falpha));
    ftitle:=mince(fdir,fwidth-c,fbitmap.Bitmap);
    h:=(ftitleheight Div 2)-(fbitmap.bitmap.TextHeight(ftitle) Div 2);
    fbitmap.Bitmap.Rendertext(2,h,ftitle,0,color32(r,g,b,falpha));

    If fitems.Count=0 Then exit;
    If ffirst+fcount>fitems.Count-1 Then c:=fitems.Count-1 Else c:=ffirst+fcount;
    For i:=ffirst To c Do
      Begin
      If i=findex Then
        Begin
        fselect.DrawTo(fbitmap.Bitmap,0,ftitleheight+fitemheight*(i-ffirst));
        End;

      If pirecord(fitems[i]).folder=True Then
        Begin
        ffolder.DrawTo(fbitmap.Bitmap,0,2+ftitleheight+fitemheight*(i-ffirst));
        h:=2;
        fbitmap.Bitmap.Rendertext(findent,(fitemheight*(i-ffirst))+h+ftitleheight,pirecord(fitems[i]).filename,0,color32(r,g,b,falpha));
        fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size+fsrf;
        fbitmap.Bitmap.Rendertext(findent+fsrx,(fitemheight*(i-ffirst))+fsry+ftitleheight,'<Folder>',0,color32(r,g,b,falpha));
        fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size-fsrf;
        End Else
        Begin
        If fileexists(pirecord(fitems[i]).dir+pirecord(fitems[i]).filename) Then
          Begin
          h:=2;
          fbitmap.Bitmap.Rendertext(findent,(fitemheight*(i-ffirst))+h+ftitleheight,pirecord(fitems[i]).filename,0,color32(r,g,b,falpha));
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size+fsrf;
          s:=floattostrf(pirecord(fitems[i]).size / 1024,ffnumber,7,2)+' KB';
          fbitmap.Bitmap.Rendertext(findent+fsrx,(fitemheight*(i-ffirst))+fsry+ftitleheight,s,0,color32(r,g,b,falpha));
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size-fsrf;
          End;
        End;
      End;
End;

Procedure TH2FilesList.FolderUP;
Var
  s:String;
  MyStr: Pchar;
  i, Len: Integer;
  SectPerCls,
  BytesPerCls,
  FreeCls,
  TotCls      : DWord;
  v:pirecord;
Const
  Size: Integer = 200;
Begin
  s:=IncludeTrailingPathDelimiter(fdir);
  setcurrentdir(s);
  If length(s)=3 Then
    Begin
    clear;
    GetMem(MyStr, Size);
    Len:=GetLogicalDriveStrings(Size, MyStr);
    For i:=0 To Len-1 Do
      Begin
      If (ord(MyStr[i])>=65)And(ord(MyStr[i])<=90) Or (ord(MyStr[i])>=97)And(ord(MyStr[i])<=122) Then
        Begin
        v:=new(pirecord);
        v.dir:='';
        v.filename:=uppercase(MyStr[i]+':\');
        v.size:=0;
        v.folder:=True;
        fitems.Add(v);
        End;
      End;
    FreeMem(MyStr);
    fdir:='';
    updatelv;
    End Else
    Begin
    chdir('..');
    If IOResult <> 0 Then
      Begin
      End Else
      Begin s:=getcurrentdir;
      fdir:=IncludeTrailingPathDelimiter(s);
      files;
      End;
    End;
End;

procedure TH2FilesList.Delete;
begin
  If findex<0 Then exit;
  If pirecord(fitems[findex]).folder=False Then
    Begin
    deletefile(pirecord(fitems[findex]).dir+pirecord(fitems[findex]).filename);
    updatelv;
    End;
end;

End.

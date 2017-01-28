Unit H2ImageList;

Interface

Uses
  Windows, Classes,Controls,  SysUtils,GR32_Image,GR32,
  gr32_layers,Graphics,generalprocedures;

Type
  PIRecord=^TIrecord;
  TIRecord=Record
    dir:String;
    filename:String;
    size:Integer;
    folder:Boolean;
  End;

  TH2ImageList = Class(TControl)
  Private
    fsrx,
    fsry,
    fwrx,
    fwry,
    fsrf,
    fwrf,
    fx,
    fy,
    fwidth,
    fheight,
    fcount,
    findent,
    ffirst,
    findex,
    fitemheight,
    fthumbwidth,
    fthumbheight:Integer;
    fstate:Boolean;
    fvisible:Boolean;
    ftitle,
    fdir,
    ffile: String;
    ffont: tfont;
    ftitleheight:Integer;
    fbitmap:tbitmaplayer;
    fselect:tbitmap32;
    ffolder:tbitmap32;
    fimage:tbitmap32;
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
    Procedure FindImages(FilesList: TList; StartDir:String);
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
    Procedure ScrollUp;
    Procedure Clear;
    Procedure UpdateLV;
    Property State:Boolean Read fstate Write fstate;
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
    Property ThumbHeight:Integer Read fthumbheight Write fthumbheight;
    Property TitleHeight:Integer Read ftitleheight Write ftitleheight;
    Property Bitmap:tbitmaplayer Read fbitmap Write fbitmap;
    Property Items:tlist Read fitems Write Setitems;
    Property Visible:Boolean Read fvisible Write setvisible;
    Property ItemIndex:Integer Read findex Write setitemindex;
    Property ThumbWidth:Integer Read fthumbwidth Write fthumbwidth;
    Property Indent:Integer Read findent Write findent;
    Property ItemHeight:Integer Read fitemheight Write fitemheight;
    Property MaxItems:Integer Read fcount Write fcount;
    Property SizeRx:Integer Read fsrx Write fsrx;
    Property SizeRy:Integer Read fsry Write fsry;
    Property WidthRx:Integer Read fwrx Write fwrx;
    Property WidthRy:Integer Read fwry Write fwry;
    Property SizeRFont:Integer Read fsrf Write fsrf;
    Property WidthRFont:Integer Read fwrf Write fwrf;


  End;

Implementation

Uses unit1;
{ TH2ImageList }

Procedure TH2ImageList.Select;
Begin
  If findex<0 Then exit;
  If pirecord(fitems[findex]).folder=False Then
    Begin
    fstate:=Not fstate;
    updatelv;
    End Else
    Begin
    fdir:=fdir+pirecord(fitems[findex]).filename;
    fdir:=IncludeTrailingPathDelimiter(fdir);
    clear;
    fstate:=False;
    finddir(fitems,fdir,'*.*');
    findimages(fitems,fdir);
    updatelv;
    End;
End;

Procedure TH2ImageList.Clear;
Var i:Integer;
Begin
  For i:=fitems.Count-1 Downto 0 Do dispose(pirecord(fitems[i]));
  fitems.Clear;
  ffirst:=0;
  findex:=-1;
  fbitmap.Bitmap.Clear($000000);
End;

Constructor TH2ImageList.Create(AOwner: TComponent);
Var
  L: TFloatRect;
  alayer:tbitmaplayer;
Begin
  Inherited Create(AOwner);
  fbitmap:=TBitmapLayer.Create((aowner As timage32).Layers);
  fbitmap.OnMouseUp:=mousedown;
  fimage :=tbitmap32.Create;
  fimage.DrawMode:=fdrawmode;
  fimage.MasterAlpha:=falpha;

  ftitleheight:=15;
  fthumbwidth:=64;
  ffont:=tfont.Create;
  fstate:=False;
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

Destructor TH2ImageList.Destroy;
Begin
//here
  ffont.Free;
  fbitmap.Free;
  ffolder.Free;
  fitems.Destroy;
  fimage.Free;
  fselect.Free;
  Inherited Destroy;
End;

Procedure TH2ImageList.FindDir(DirList: tlist; startdir,
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

Procedure TH2ImageList.Findfiles(FilesList: TList; StartDir,
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

Procedure TH2ImageList.files;
Begin
  clear;
  finddir(fitems,fdir,'*.*');
  findimages(fitems,fdir);
  updatelv;
End;

Procedure TH2ImageList.FindImages(FilesList: TList; StartDir:String);
Begin
  findfiles(fileslist,fdir,'*.jpg');
  findfiles(fileslist,fdir,'*.jpeg');
  findfiles(fileslist,fdir,'*.pcx');
  findfiles(fileslist,fdir,'*.bmp');
  findfiles(fileslist,fdir,'*.ico');
  findfiles(fileslist,fdir,'*.png');
End;

Procedure TH2ImageList.LoadFolderICO(Filename: String);
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

Procedure TH2ImageList.LoadSelection(Filename: String);
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

Procedure TH2ImageList.MouseDown(Sender: TObject; Buttons: TMouseButton;
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

Procedure TH2ImageList.ScrollDown;
Var i,d:Integer;
Begin
  If fstate=False Then
    Begin
    If ffirst+fcount>fitems.Count-1 Then exit;
    ffirst:=ffirst+fcount;
    updatelv;
    End Else
    Begin
    If findex<0 Then
      Begin
      For i:=0 To fitems.Count-1 Do If pirecord(fitems[i]).folder Then findex:=i;
      End Else
      For i:=findex To fitems.Count-1 Do
        Begin
        If i+1>fitems.Count-1 Then d:=i Else d:=i+1;
        If pirecord(fitems[d]).folder=False Then
          Begin findex:=d;updatelv;break;End;
        End;
    End;
End;

Procedure TH2ImageList.ScrollUp;
Var i,d:Integer;
Begin
  If fstate=False Then
    Begin
    If ffirst-fcount<=0 Then ffirst:=0 Else ffirst:=ffirst-fcount;
    updatelv;
    End Else
    Begin
    If findex<0 Then
      Begin
      For i:=fitems.Count-1 Downto 0 Do If pirecord(fitems[i]).folder Then findex:=i;
      End Else
      For i:=findex Downto 0 Do
        Begin
        If i-1<0 Then d:=0 Else d:=i-1;
        If pirecord(fitems[d]).folder=False Then
          Begin findex:=d;updatelv;break End;
        End;
    End;
End;

Procedure TH2ImageList.SetDir(value: String);
Var
  i:Integer;
Begin
  i:=fbitmap.Bitmap.TextWidth(inttostr(findex)+'/'+inttostr(fitems.count));
  fdir:=value;
  ftitle:=mince(value,fwidth-i,fbitmap.Bitmap);
End;

Procedure TH2ImageList.SetFont(value: tfont);
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

Procedure TH2ImageList.SetHeight(value: Integer);
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

Procedure TH2ImageList.SetItemindex(value: Integer);
Begin
  findex:=value;
  updatelv;
End;

Procedure TH2ImageList.SetItems(value: tlist);
Begin
  fitems.Assign(value);
  findex:=fitems.Count-1;
  updatelv;
End;

Procedure TH2ImageList.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

Procedure TH2ImageList.SetWidth(value: Integer);
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

Procedure TH2ImageList.Setx(value: Integer);
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

Procedure TH2ImageList.Sety(value: Integer);
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

Procedure TH2ImageList.UpdateLV;
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
  If fstate=False Then
    Begin //Display Folder
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
        fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size+fwrf;
        fbitmap.Bitmap.Rendertext(findent+fwrx,(fitemheight*(i-ffirst))+fwry+ftitleheight,'<Folder>',0,color32(r,g,b,falpha));
        fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size-fwrf;
        End Else
        Begin
        If fileexists(pirecord(fitems[i]).dir+pirecord(fitems[i]).filename) Then
          Begin
          fimage.Clear;
          fimage.DrawMode:=dmopaque;
          fimage.masteralpha:=255;
          fimage.LoadFromFile(pirecord(fitems[i]).dir+pirecord(fitems[i]).filename);
          s:=inttostr(fimage.Width)+' x '+inttostr(fimage.Height);
   // fimage.Width:=fthumbwidth;
   // fimage.Height:=fthumbheight;
          fimage.DrawTo(fbitmap.Bitmap,
            rect(1,ftitleheight+fitemheight*(i-ffirst)+(fitemheight Div 2)-(fthumbheight Div 2),1+fthumbwidth,ftitleheight+fitemheight*(i-ffirst)+(fitemheight Div 2)-(fthumbheight Div 2)+fthumbheight));
          h:=2;
          fbitmap.Bitmap.Rendertext(findent,(fitemheight*(i-ffirst))+h+ftitleheight,pirecord(fitems[i]).filename,0,color32(r,g,b,falpha));
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size+fwrf;
          fbitmap.Bitmap.Rendertext(findent+fwrx,(fitemheight*(i-ffirst))+fwry+ftitleheight,s,0,color32(r,g,b,falpha));
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size-fwrf;
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size+fsrf;
          s:=floattostrf(pirecord(fitems[i]).size / 1024,ffnumber,7,2)+' KB';
          fbitmap.Bitmap.Rendertext(findent+fsrx,(fitemheight*(i-ffirst))+fsry+ftitleheight,s,0,color32(r,g,b,falpha));
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size-fsrf;
          End;
        End;
      End;
    End Else
  If findex>=0 Then
    Begin //Display Single Image
    fimage.LoadFromFile(pirecord(fitems[findex]).dir+pirecord(fitems[findex]).filename);
{for i:=0 to 1 do begin
if (fimage.Width>fwidth) and (fimage.height<fheight) then a:=fwidth / fimage.Width;
if (fimage.Width<fwidth) and (fimage.height<fheight) then a:=1;
if (fimage.Width<fwidth) and (fimage.height>fheight) then a:=fheight / fimage.height;
if (fimage.Width>fwidth) and (fimage.height>fheight) then a:=fwidth / fimage.Width;
fimage.Width:=trunc(fimage.Width*a);
fimage.Height:=trunc(fimage.Height*a);
end;
c:=(fwidth div 2) - (fimage.Width div 2);
h:=(fheight div 2) - (fimage.height div 2);
}
//fimage.DrawTo(fbitmap.Bitmap,c,h);
    fimage.DrawTo(fbitmap.Bitmap,rect(0,0,fwidth,fheight));
    End;
End;

Procedure TH2ImageList.FolderUP;
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
  fstate:=False;
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

End.

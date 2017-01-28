Unit H2MediaList;

Interface

Uses
  Windows, Classes,controls,  SysUtils,GR32_Image,GR32,
  gr32_layers,Graphics,generalprocedures;

Type
  PMediaFile=^TMediaFile;
  TMediaFile=Record
    Filename:String;
    name:string;
    ext:String[4];
    Size:Integer;
    Date:tdatetime;
    Directory:String;
    Duration:Int64;
    Time:string[8];
    Title,
    Artist,
    Album,
    Genre:string;
    hash:string;
    Year:string[4];
    Music:boolean;
    Video:Boolean;
    Folder:Boolean;
    Playlist:Boolean;
    Rate:Byte;
    Selected:Boolean;
  End;


  PIRecord=^TIrecord;
  TIRecord=Record
    dir:String;
    filename:String;
    size:Integer;
    folder:Boolean;
  End;

  TH2MediaList = Class(TControl)
  Private
    fsrx,
    fsry,
    fsrf,
    frrx,
    frry,
    frrf,
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
    ftype:byte;
    ftitle,
    ffile,
    fdir: String;
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
    Procedure MakeRootItems;
    Procedure MakeMusicFolders;
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure MouseDown(Sender: TObject; Buttons: TMouseButton; Shift: TShiftState; X, Y: Integer);
  Published
    Procedure RateUp(item:pmediafile);
    Procedure RateDown(item:pmediafile);
    Procedure Find(s:string);
    Procedure SortByName;
    Procedure SortByRate;
    Procedure AddItemstoPlaylist;
    Procedure AddItemtoPlaylist;
    Procedure AppendItemstoPlaylist;
    Procedure LoadSelection(Filename:String);
    Procedure LoadFolderICO(Filename:String);
    Procedure Root;
    Procedure Files;
    Procedure Select;
    Procedure FolderUP;
    Procedure ScrollDown;
    Procedure ScrollUp;
    Procedure Clear;
    Procedure UpdateLV;
    Property Font:tfont Read ffont Write setfont;
    Property Alpha:Cardinal Read falpha Write falpha;
    Property DrawMode:tdrawmode Read fdrawmode Write fdrawmode;
    Property X:Integer Read fx Write setx;
    Property Y:Integer Read fy Write sety;
    Property ListType:byte read ftype write ftype;
    Property Width:Integer Read fwidth Write setwidth;
    Property Title:String Read ftitle Write ftitle;
    Property Filename:String Read ffile Write ffile;
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
    Property RateRx:Integer Read frrx Write frrx;
    Property RateRy:Integer Read frry Write frry;
    Property RateRFont:Integer Read frrf Write frrf;
  End;

function CompareNames(Item1, Item2: Pointer): Integer;
function CompareRates(Item1, Item2: Pointer): Integer;

Implementation

Uses unit1,medialibrary;
{ TH2MediaList }

Procedure TH2MediaList.Select;
Begin
  If findex<0 Then exit;
  if fitems.count=0 then exit;
  if ftype=0 then begin
  If pmediafile(fitems[findex]).folder=False Then
    Begin
      if pmediafile(fitems[findex]).Playlist then
        if pos('ARTIST:',uppercase(pmediafile(fitems[findex]).hash))>0 then begin
         ftitle:=ftitle+': '+pmediafile(fitems[findex])^.name;
        unit1.MediaLibrary.ArtistPlaylist(pmediafile(fitems[findex])^.name);
        clear;

        fitems.Assign(unit1.MediaLibrary.Playlist);
        updatelv;
        exit;
        end
        else if pos('ALBUM:',uppercase(pmediafile(fitems[findex]).hash))>0 then begin
        ftitle:=ftitle+': '+pmediafile(fitems[findex])^.name;
        unit1.MediaLibrary.albumPlaylist(pmediafile(fitems[findex])^.name);
        clear;
        fitems.Assign(unit1.MediaLibrary.Playlist);
        updatelv;
        exit;
        end
        else if pos('YEAR:',uppercase(pmediafile(fitems[findex]).hash))>0 then begin
        ftitle:=ftitle+': '+pmediafile(fitems[findex])^.name;
        unit1.MediaLibrary.yearPlaylist(pmediafile(fitems[findex])^.name);
        clear;
        fitems.Assign(unit1.MediaLibrary.Playlist);
        updatelv;
        exit;
        end
        else if pos('GENRE:',uppercase(pmediafile(fitems[findex]).hash))>0 then begin
        ftitle:=ftitle+': '+pmediafile(fitems[findex])^.name;
        unit1.MediaLibrary.genrePlaylist(pmediafile(fitems[findex])^.name);
        clear;
        fitems.Assign(unit1.MediaLibrary.Playlist);
        updatelv;
        exit;
        end
        else if pos('RATE:',uppercase(pmediafile(fitems[findex]).hash))>0 then begin
        ftitle:=ftitle+': '+pmediafile(fitems[findex])^.name;
        unit1.MediaLibrary.ratePlaylist(strtoint(pmediafile(fitems[findex])^.name));
        clear;
        fitems.Assign(unit1.MediaLibrary.Playlist);
        updatelv;
        exit;
        end
        else begin
        ftitle:=ftitle+': '+pmediafile(fitems[findex])^.name;
        clear;
        fitems.Assign(unit1.MediaLibrary.LoadM3U(pmediafile(fitems[findex])^.filename));
        updatelv;
        exit;
      end;
      if pmediafile(fitems[findex])^.Music then begin
         form1.OpenStream(pmediafile(fitems[findex])^.Filename);
      end;
    End Else
    Begin
    ftitle:='Sort by '+pmediafile(fitems[findex])^.hash;
    if uppercase(pmediafile(fitems[findex]).hash)='ARTIST' then begin
      unit1.MediaLibrary.MakeArtistPlaylist(unit1.MediaLibrary.items);
      clear;
      fitems.Assign(unit1.MediaLibrary.Playlist);
      end
    else if uppercase(pmediafile(fitems[findex])^.hash)='ALBUM' then begin
      unit1.MediaLibrary.MakeAlbumPlaylist(unit1.MediaLibrary.items);
      clear;
      fitems.Assign(unit1.MediaLibrary.Playlist);
      end
    else if uppercase(pmediafile(fitems[findex])^.hash)='GENRE' then begin
      unit1.MediaLibrary.MakeGenrePlaylist(unit1.MediaLibrary.items);
      clear;
      fitems.Assign(unit1.MediaLibrary.Playlist);
      end
    else if uppercase(pmediafile(fitems[findex])^.hash)='YEAR' then begin
      unit1.MediaLibrary.MakeYearPlaylist(unit1.MediaLibrary.items);
      clear;
      fitems.Assign(unit1.MediaLibrary.Playlist);
      end
    else if uppercase(pmediafile(fitems[findex])^.hash)='FAVORITES' then begin
      unit1.MediaLibrary.MakeFavoritePlaylist(unit1.MediaLibrary.items);
      clear;
      fitems.Assign(unit1.MediaLibrary.Playlist);
      end
    else if uppercase(pmediafile(fitems[findex])^.hash)='MUSIC FOLDERS' then begin
    clear;
       makemusicfolders;
       end
    else if pos('FOLDER:',uppercase(pmediafile(fitems[findex])^.hash))>0 then begin
      ftype:=1;
      fdir:=IncludeTrailingPathDelimiter(pmediafile(fitems[findex])^.directory);
      files;
    end;
    updatelv;
    End;
    end else begin
    if pmediafile(fitems[findex])^.Folder=true then begin
    fdir:=fdir+pmediafile(fitems[findex]).filename;
    fdir:=IncludeTrailingPathDelimiter(fdir);
    files;
    end else if pmediafile(fitems[findex])^.Music=true then begin
      form1.OpenStream(pmediafile(fitems[findex])^.Filename);
    end;
    end;
End;

Procedure TH2MediaList.Clear;
Var i:Integer;
Begin
 // For i:=fitems.Count-1 Downto 0 Do dispose(pmediafile(fitems[i]));
  fitems.Clear;
  ffirst:=0;
  findex:=-1;
  fbitmap.Bitmap.Clear($000000);
End;

Constructor TH2MediaList.Create(AOwner: TComponent);
Var
  L: TFloatRect;
  alayer:tbitmaplayer;
  v:pmediafile;
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
  ftype:=0;
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
  makerootitems;
End;

Destructor TH2MediaList.Destroy;
Begin
//here
  ffont.Free;
  fbitmap.Free;
  ffolder.Free;
  fitems.Destroy;

  fselect.Free;
  Inherited Destroy;
End;

Procedure TH2MediaList.FindDir(DirList: tlist; startdir,
  filemask: String);
Var
  SR: TSearchRec;
  IsFound: Boolean;
  i: Integer;
  v:pmediafile;
Begin
  // Build a list of subdirectories
  IsFound := FindFirst(StartDir+'*.*', faAnyFile, SR) = 0;
  While IsFound Do
    Begin
    If ((SR.Attr And faDirectory) <> 0) And
      (SR.Name[1] <> '.') Then
      Begin
      new(v);
      v^.directory:=startdir;
      v^.name:=sr.name;
      v^.filename:=SR.Name;
      v^.size:=sr.Size;
      v^.folder:=True;
      v^.Music:=false;
      v^.Playlist:=false;
      v^.Time:='';
      v^.Video:=false;
      DirList.Add(v);
      End;
    IsFound := FindNext(SR) = 0;
    End;
  FindClose(SR);
End;

Procedure TH2MediaList.Findfiles(FilesList: TList; StartDir,FileMask: String);
Var
  SR: TSearchRec;
  IsFound: Boolean;
  i: Integer;
  v:pmediafile;
Begin
  If StartDir[length(StartDir)] <> '\' Then
    StartDir := StartDir + '\';

  { Build a list of the files in directory StartDir
     (not the directories!)                         }

  IsFound :=
    FindFirst(StartDir+FileMask, faAnyFile-faDirectory, SR) = 0;
  While IsFound Do
    Begin
    new(v);
    v^.Directory:=startdir;
    v^.name:=SR.Name;
    v^.Filename:=v^.Directory+v^.name;
    v^.Size:=sr.Size;
    v^.folder:=False;
    v^.Music:=true;
    v^.Time:='';
    FilesList.Add(v);
    IsFound := FindNext(SR) = 0;
    End;
  FindClose(SR);
End;

Procedure TH2MediaList.files;
Begin
  clear;
  finddir(fitems,fdir,'*.*');
  findfiles(fitems,fdir,'*.mp3');
  findfiles(fitems,fdir,'*.ogg');
  findfiles(fitems,fdir,'*.wma');
  findfiles(fitems,fdir,'*.wav');
  ftype:=1;
  updatelv;
End;


Procedure TH2MediaList.LoadFolderICO(Filename: String);
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

Procedure TH2MediaList.LoadSelection(Filename: String);
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

Procedure TH2MediaList.MouseDown(Sender: TObject; Buttons: TMouseButton;
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

Procedure TH2MediaList.ScrollDown;
Var i,d:Integer;
Begin
    If ffirst+fcount>fitems.Count-1 Then exit;
    ffirst:=ffirst+fcount;
    updatelv;
End;

Procedure TH2MediaList.ScrollUp;
Var i,d:Integer;
Begin
    If ffirst-fcount<=0 Then ffirst:=0 Else ffirst:=ffirst-fcount;
    updatelv;
End;

Procedure TH2MediaList.SetDir(value: String);
Var
  i:Integer;
Begin
  i:=fbitmap.Bitmap.TextWidth(inttostr(findex)+'/'+inttostr(fitems.count));
  fdir:=value;
  ftitle:=mince(value,fwidth-i,fbitmap.Bitmap);
End;

Procedure TH2MediaList.SetFont(value: tfont);
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

Procedure TH2MediaList.SetHeight(value: Integer);
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

Procedure TH2MediaList.SetItemindex(value: Integer);
Begin
  findex:=value;
  updatelv;
End;

Procedure TH2MediaList.SetItems(value: tlist);
Begin
  fitems.Assign(value);
  findex:=fitems.Count-1;
  updatelv;
End;

Procedure TH2MediaList.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

Procedure TH2MediaList.SetWidth(value: Integer);
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

Procedure TH2MediaList.Setx(value: Integer);
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

Procedure TH2MediaList.Sety(value: Integer);
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

Procedure TH2MediaList.UpdateLV;
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
    s:=mince(ftitle,fwidth-c,fbitmap.Bitmap);
    h:=(ftitleheight Div 2)-(fbitmap.bitmap.TextHeight(s) Div 2);
    fbitmap.Bitmap.Rendertext(2,h,S,0,color32(r,g,b,falpha));

    If fitems.Count=0 Then exit;
    If ffirst+fcount>fitems.Count-1 Then c:=fitems.Count-1 Else c:=ffirst+fcount;
    For i:=ffirst To c Do
      Begin
      If i=findex Then
        Begin
        fselect.DrawTo(fbitmap.Bitmap,0,ftitleheight+fitemheight*(i-ffirst));
        End;

      If pmediafile(fitems[i])^.folder=True Then
        Begin
        ffolder.DrawTo(fbitmap.Bitmap,0,2+ftitleheight+fitemheight*(i-ffirst));
        h:=2;
        fbitmap.Bitmap.Rendertext(findent,(fitemheight*(i-ffirst))+h+ftitleheight,pmediafile(fitems[i])^.name,0,color32(r,g,b,falpha));
        fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size+fsrf;
        fbitmap.Bitmap.Rendertext(fsrx,(fitemheight*(i-ffirst))+fsry+ftitleheight,'<Folder>',0,color32(r,g,b,falpha));
        fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size-fsrf;
        End Else
        If pmediafile(fitems[i])^.playlist=true Then
          Begin
          h:=2;
          fbitmap.Bitmap.Rendertext(findent,(fitemheight*(i-ffirst))+h+ftitleheight,pmediafile(fitems[i])^.name,0,color32(r,g,b,falpha));
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size+fsrf;
          s:='<Playlist>';
          fbitmap.Bitmap.Rendertext(fsrx,(fitemheight*(i-ffirst))+fsry+ftitleheight,s,0,color32(r,g,b,falpha));
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size-fsrf;
          End else
        if pmediafile(fitems[i])^.music=true Then
        If fileexists(pmediafile(fitems[i])^.filename) Then
          Begin
          h:=2;
          fbitmap.Bitmap.Rendertext(findent,(fitemheight*(i-ffirst))+h+ftitleheight,mince(pmediafile(fitems[i])^.name,fwidth-findent,fbitmap.Bitmap),0,color32(r,g,b,falpha));
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size+fsrf;
          if pmediafile(fitems[i])^.music then s:=pmediafile(fitems[i])^.time;
          fbitmap.Bitmap.Rendertext(findent+fsrx,(fitemheight*(i-ffirst))+fsry+ftitleheight,s,0,color32(r,g,b,falpha));
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size-fsrf;
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size+frrf;
          if pmediafile(fitems[i])^.music then s:=inttostr(pmediafile(fitems[i])^.rate)+'/5';
          fbitmap.Bitmap.Rendertext(findent+frrx,(fitemheight*(i-ffirst))+frry+ftitleheight,s,0,color32(r,g,b,falpha));
          fbitmap.Bitmap.Font.Size:=fbitmap.Bitmap.Font.Size-frrf;
          End;

      End;
End;

Procedure TH2MediaList.FolderUP;
Var
  s:String;
  MyStr: Pchar;
  i, Len: Integer;
  SectPerCls,
  BytesPerCls,
  FreeCls,
  TotCls      : DWord;
  v:pmediafile;
Const
  Size: Integer = 200;
Begin
  if ftype=1 then begin
  s:=IncludeTrailingPathDelimiter(fdir);
  ftitle:=s;
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
        new(v);
        v^.directory:='';
        v^.filename:=uppercase(MyStr[i]+':\');
        v^.name:=v^.filename;
        v^.time:='';
        v^.size:=0;
        v^.folder:=True;
        v^.music:=false;
        v^.playlist:=false;
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
      updatelv;
    End;
  end else
    if unit1.MediaLibrary.SortString='' then begin
      root;
    end else begin
      if unit1.MediaLibrary.Sorttype='ARTIST' then begin
        ftitle:=copy(ftitle,1,pos(':',ftitle)-1);
        unit1.MediaLibrary.MakeArtistPlaylist(unit1.MediaLibrary.items);
        clear;
        fitems.Assign(unit1.MediaLibrary.Playlist);
      end else if unit1.MediaLibrary.Sorttype='ALBUM' then begin
        ftitle:=copy(ftitle,1,pos(':',ftitle)-1);
              unit1.MediaLibrary.MakealbumPlaylist(unit1.MediaLibrary.items);
      clear;
      fitems.Assign(unit1.MediaLibrary.Playlist);

      end else if unit1.MediaLibrary.Sorttype='YEAR' then begin
        ftitle:=copy(ftitle,1,pos(':',ftitle)-1);
              unit1.MediaLibrary.MakeyearPlaylist(unit1.MediaLibrary.items);
      clear;
      fitems.Assign(unit1.MediaLibrary.Playlist);

      end else if unit1.MediaLibrary.Sorttype='RATE' then begin
        ftitle:=copy(ftitle,1,pos(':',ftitle)-1);
              unit1.MediaLibrary.MakefavoritePlaylist(unit1.MediaLibrary.items);
      clear;
      fitems.Assign(unit1.MediaLibrary.Playlist);

      end else if unit1.MediaLibrary.Sorttype='GENRE' then begin
        ftitle:=copy(ftitle,1,pos(':',ftitle)-1);
              unit1.MediaLibrary.MakegenrePlaylist(unit1.MediaLibrary.items);
      clear;
      fitems.Assign(unit1.MediaLibrary.Playlist);

      end;
      updatelv;
      unit1.MediaLibrary.SortString:='';
    end;
End;

procedure TH2MediaList.MakeRootitems;
var v:pmediafile;
begin
ftype:=0;
clear;
ftitle:='Sort by...';
new(v);
v^.name:='Album';
v^.hash:=v.name;
v^.Folder:=true;
v^.Music:=false;
v^.Playlist:=false;
fitems.Add(v);
new(v);
v^.name:='Artist';
v^.hash:=v.name;
v^.Folder:=true;
v^.Music:=false;
v^.Playlist:=false;
fitems.Add(v);
new(v);
v^.name:='Genre';
v^.hash:=v.name;
v^.Folder:=true;
v^.Music:=false;
v^.Playlist:=false;
fitems.Add(v);
new(v);
v^.name:='Year';
v^.hash:=v.name;
v^.Folder:=true;
v^.Music:=false;
v^.Playlist:=false;
fitems.Add(v);
new(v);
v^.name:='Favorites';
v^.hash:=v.name;
v^.Folder:=true;
v^.Music:=false;
v^.Playlist:=false;
fitems.Add(v);
new(v);
v^.name:='Music Folders';
v^.hash:=v.name;
v^.Folder:=true;
v^.Music:=false;
v^.Playlist:=false;
fitems.Add(v);
end;

procedure TH2MediaList.Root;
begin
makerootitems;
updatelv;
end;

procedure TH2MediaList.MakeMusicFolders;
var
i:integer;
v:pmediafile;
begin
ftype:=0;
clear;
if unit1.MediaLibrary.Paths.Count=0 then exit;
for i:=0 to unit1.MediaLibrary.Paths.Count-1 do
  begin
    new(v);
    v^.Directory:=unit1.MediaLibrary.Paths[i];
    v^.name:=getfoldernamefrompath(v^.Directory);
    v^.hash:='FOLDER: '+v^.name;
    v^.folder:=true;
    v^.Playlist:=false;
    v^.Video:=false;
    v^.Music:=false;
    fitems.Add(v);
  end;

end;

procedure TH2MediaList.AddItemstoPlaylist;
var i:integer;
begin
  if fitems.Count=0 then exit;
  unit1.MediaLibrary.Playlist.Clear;
  for i:=0 to fitems.count-1 do
    if pmediafile(fitems[i])^.music=true then unit1.MediaLibrary.playlist.add(fitems[i]);
end;

procedure TH2MediaList.AppendItemstoPlaylist;
var i:integer;
begin
  if fitems.Count=0 then exit;
  for i:=0 to fitems.count-1 do
    if pmediafile(fitems[i])^.music=true then unit1.MediaLibrary.playlist.add(fitems[i]);
end;

procedure TH2MediaList.RateUp(item: pmediafile);
begin
if item=nil then exit;
if item^.Music=false then exit;
if item^.Rate>=5 then exit;
item^.Rate:=item^.Rate+1;
end;

procedure TH2MediaList.RateDown(item: pmediafile);
begin
if item=nil then exit;
if item^.Music=false then exit;
if item^.Rate<=0 then exit;
item^.Rate:=item^.Rate-1;
end;

function CompareNames(Item1, Item2: Pointer): Integer;
begin
  Result := CompareText(pmediafile(item1)^.name, pmediafile(item2)^.Name);
end;

function CompareRates(Item1, Item2: Pointer): Integer;
begin
  Result := CompareText(inttostr(pmediafile(item1)^.rate), inttostr(pmediafile(item2)^.rate));
end;

procedure TH2MediaList.SortByName;
begin
  fitems.Sort(@comparenames);
  updatelv;
end;

procedure TH2MediaList.SortByRate;
begin
  fitems.Sort(@comparerates);
  updatelv;
end;

procedure TH2MediaList.AddItemtoPlaylist;
begin
if findex<0 then exit;
if pmediafile(fitems[findex])^.music=true then unit1.MediaLibrary.playlist.add(fitems[findex]);
end;

procedure TH2MediaList.Find(s: string);
var
i:integer;
begin
if s='' then exit;
if unit1.MediaLibrary.Items.count=0 then exit;
clear;
for i:=unit1.MediaLibrary.Items.Count-1 downto 0 do
  if pos(uppercase(s),uppercase(pmediafile(unit1.MediaLibrary.Items[i])^.name))>0 then
     fitems.Add(unit1.MediaLibrary.Items[i]);
updatelv;     
end;

End.

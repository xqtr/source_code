program SqliteTest;

//{$mode objfpc}
{$mode objfpc}
{$h+}
{$codepage utf-8}
{$codepage utf8}
uses

{$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}cwstring,{$ENDIF}{$ifdef windows}windows,ctypes,{$endif}
  Classes,crt,httpsend,md5, {$IFDEF linux}unix,unixutil,{$ENDIF}
  { you can add units after this }inifiles, db, sqlite3ds, SysUtils,fileutil,strutils,dateutils,regexpr,lazutf8,ccsv;

const
  yellow=14;
  red=12;
  cyan=11;
  white=15;
  green=10;
  blue=1;
  grey=7;
  version='0.10';
  {$IFDEF windows}
  screenheight=25;
  screenwidth=80;
  {$ENDIF}

type
  TStation=record
        id,
        location,
        name,
        link,
        tag,
        freq,
        tone,
        shift,
        wide,
        groupo:string;
        no:integer;
  end;

  tappcolor=record
        toplinetext:byte;
        toplineback:byte;
        baselinetext:byte;
        baselineback:byte;

        percenttext:byte;

        forumtext1:byte;
        forumtext2:byte;
        forumtext3:byte;

        titletext:byte;

        posttext:byte;
        postinfo:byte;
        postsep:byte;
  end;

var
  ds: TSQLite3Dataset;
  leave:boolean;
  greek:boolean;
  history:tstringlist;
  history_index:integer;
  database:string;
  kbbuf:string;
  ch:char;
  l:tstringlist;
  i,e,v:integer;
  s:string;
  d:integer;
  title:string;
  theme:tappcolor;
  viewer_x:integer;
  rtlfm:string = 'rtl_fm -f %s -M %s -A fast -E - | play -r 16k -t raw -e s -b 16 -c 1 -V1 -';
  {$ifdef windows}
  cp:cuint;
  {$endif}


 procedure command(str:string); forward;
 procedure topline(s:string); forward;
 procedure sqlexec(sql:string); forward;

function colortobyte(col: string): byte;
  var c:string;
begin
  c:=uppercase(col);
  if c='YELLOW' then result:=yellow;
  if c='RED' then result:=red;
  if c='GREEN' then result:=green;
  if c='WHITE' then result:=white;
  if c='BLUE' then result:=blue;
  if c='GREY' then result:=grey;
  if c='CYAN' then result:=cyan;
  if c='DARKGRAY' then result:=darkgray;
  if c='MAGENTA' then result:=magenta;
end;


procedure loadsettings;
var
  ini:tinifile;
begin
  with theme do begin
        toplinetext:=white;
        toplineback:=blue;
        baselinetext:=white;
        baselineback:=blue;

        percenttext:=white;

        forumtext1:=white;
        forumtext2:=cyan;
        forumtext3:=darkgray;

        titletext:=white;

        posttext:=darkgray;
        postinfo:=white;
        postsep:=darkgray;
  end;
  if not fileexists('theme.ini') then exit;
  ini:=tinifile.create('theme.ini');
  with theme do begin
    toplinetext:=colortobyte(ini.readstring('colors','top_line_text','white'));
    toplineback:=colortobyte(ini.readstring('colors','top_line_background','blue'));
    baselinetext:=colortobyte(ini.readstring('colors','base_line_text','white'));
    baselineback:=colortobyte(ini.readstring('colors','base_line_background','blue'));
    percenttext:=colortobyte(ini.readstring('colors','percent','white'));
    forumtext1:=colortobyte(ini.readstring('colors','forum_list_line1','white'));
    forumtext2:=colortobyte(ini.readstring('colors','forum_list_line2','cyan'));
    forumtext3:=colortobyte(ini.readstring('colors','forum_list_line3','darkgray'));
    titletext:=colortobyte(ini.readstring('colors','titles_text_color','white'));
    posttext:=colortobyte(ini.readstring('colors','normal_text_color','grey'));
    postinfo:=colortobyte(ini.readstring('colors','bold_text_color','white'));
    postsep:=colortobyte(ini.readstring('colors','line_seperator_color','darkgray'));
  end;
  ini.free;
end;

procedure load_rtlfm_settings;
var
  ini:tinifile;
begin
  if not fileexists('rtlfm.ini') then exit;
  ini:=tinifile.create('rtlfm.ini');
  rtlfm:=ini.readstring('rtlfm','command',rtlfm);
  ini.free;
end;


function pathdelimeter:char;
begin
result:='\';
{$IFDEF UNIX}result:='/';{$ENDIF}

end;

procedure WriteHelp;
begin
  writeln;
  textcolor(white);
  writeln(' Ham Radio Stations');
  writeln('         Version '+version);
  writeln;
  writeln('A simple program to manage your ham radio stations/repeaters');
  writeln;
  textcolor(grey);
  writeln(' Example for the rtlfm.ini file:');
  writeln(' [rtlfm]');
  writeln(' command=rtl_fm -f %s -M %s -A fast -E - | play -r 16k -t raw -e s -b 16 -c 1 -V1 -');
  writeln;
  writeln(' The -F %s and the -M %s must be present for rtl_fm to work correctly.');
  writeln;
  halt;
end;

function Center(AnyString: string;c:char; Width: byte): string;
begin
   repeat
      if length( AnyString ) < Width
         then AnyString:=AnyString+c;
      if length( AnyString ) < Width
         then AnyString:=c+AnyString;
   until length( AnyString ) >= Width;
   Center:=AnyString;
end;

PROCEDURE MaskedReadLn(VAR s : String; mask : String; fillCh : Char);
{ in 'mask', chars with A will only accept alpha input, and chars
  with 0 will only accept numeric input; spaces accept anything }
VAR ch : Char; sx, ox, oy : Byte;
BEGIN
  s := ''; ox := WhereX; oy := WhereY; sx := 0;
  REPEAT
    Inc(sx);
    IF (mask[sx] IN ['0', 'A']) THEN
      Write(fillCh)
    ELSE IF (mask[sx] = '_') THEN
      Write(' ')
    ELSE Write(mask[sx]);
  UNTIL (sx = Length(mask));
  sx := 0;
  WHILE (NOT (mask[sx + 1] IN [#32, '0', 'A']))
  AND (sx < Length(mask)) DO BEGIN
    Inc(sx);
    s := s + mask[sx];
  END;
  GotoXY(ox + sx, oy);
  REPEAT
    ch := ReadKey;
    IF (ch = #8) THEN BEGIN
      IF (Length(s) > sx) THEN BEGIN
        IF NOT (mask[Length(s)] IN [#32, '0', 'A']) THEN BEGIN
          REPEAT
            setlength(s,Length(s) - 1);
            GotoXY(WhereX - 1, WhereY);
          UNTIL (Length(s) <= sx) OR (mask[Length(s)] IN [#32, '0', 'A']);
        END;
        setlength(s,Length(s) - 1); 
        GotoXY(WhereX - 1, WhereY);
        Write(fillCh); GotoXY(WhereX - 1, WhereY);
      END ELSE BEGIN
        Sound(440);
        Delay(50);
        NoSound;
      END;
    END ELSE IF (Length(s) < Length(mask)) THEN BEGIN
      CASE mask[Length(s) + 1] OF
        '0' : IF (ch IN ['0'..'9']) THEN BEGIN
                Write(ch);
                s := s + ch;
              END;
        'A' : IF (UpCase(ch) IN ['A'..'Z']) THEN BEGIN
                Write(ch);
                s := s + ch;
              END;
        #32 : BEGIN
                Write(ch);
                s := s + ch;
              END;
      END;
      WHILE (Length(s) < Length(mask))
      AND (NOT (mask[Length(s) + 1] IN [#32, '0', 'A'])) DO BEGIN
        IF (mask[Length(s) + 1] = '_') THEN s := s + ' ' ELSE
          s := s + mask[Length(s) + 1];
        GotoXY(WhereX + 1, WhereY);
      END;
    END;
  UNTIL (ch IN [#13, #27]);
END;


procedure logo;
var
x:integer;
begin
x:=100;
textcolor(theme.postinfo);
  writeln;
  writeln;
  writeln;
  writeln(center(' _  _              ___         _ _     ',' ',screenwidth-1));sleep(x);
  writeln(center('| || |__ _ _ __   | _ \__ _ __| (_)___ ',' ',screenwidth-1));sleep(x);
  writeln(center('| __ / _` | ''  \  |   / _` / _` | / _ \',' ',screenwidth-1));sleep(x);
  writeln(center('|_||_\__,_|_|_|_| |_|_\__,_\__,_|_\___/',' ',screenwidth-1));sleep(x);
  writeln(center('    _        _   _             ',' ',screenwidth-1));sleep(x);
  writeln(center(' __| |_ __ _| |_(_)___ _ _  ___',' ',screenwidth-1));sleep(x);
  writeln(center('(_-<  _/ _` |  _| / _ \ '' \(_-<',' ',screenwidth-1));sleep(x);
  writeln(center('/__/\__\__,_|\__|_\___/_||_/__/',' ',screenwidth-1));     sleep(x);
  writeln(' ');  
  writeln;sleep(x);
  writeln(center('                          Version '+version,' ',screenwidth-1));sleep(x);
  writeln('');
  writeln('');
  textcolor(theme.postsep);
   writeln(center('CPU: '+{$i %FPCTARGETCPU%}+' - OS: '+{$i %FPCTARGETOS%},' ',screenwidth-1));;


  sleep(x*3);
end;

procedure defscreen;
begin
  //writehelp;
  //title:=database+' ';
  title:=' Using: '+database;
  clrscr;
  logo;
  //sleep(500);
  clrscr;
end;

function colortostr(col:byte):string;
begin
  case col of
  white: result:='%w%';
  yellow: result:='%y%';
  cyan: result:='%c%';
  blue: result:='%b%';
  green: result:='%g%';
  darkgray: result:='%d%';
  red: result:='%r%';
  end;
end;

procedure writeat(x, y: integer; str: string);
begin
  gotoxy(x,y);
  write(str);
end;

procedure helpline(s:string);
begin
  gotoxy(1,screenheight-1);
  textcolor(theme.baselinetext);
  textbackground(theme.baselineback);
  clreol;
  write(center(s,' ',screenwidth));
end;

function gr2en(text:string):string;
var q1,q2:integer;
  gr,en,new:string;
  n:char;
  cl:string;
begin
  result:=text;
  if greek=false then exit;
  new:=text;
  gr:='αβγδεζηθικλμνξοπρσςτυφχψωάέήίόύώΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩΆΈΉΊΌΎΏ';
  en:='abgdezh8iklmn3oprsstufxcwaehiouwABGDEZH8IKLMN3OPRSTYFXCWAEHIOYW';
  //helpline('Converting to Greek. Please wait...');
  for q1:=1 to utf8length(new) do begin
		for q2:=1 to utf8length(gr) do begin
		   if utf8copy(new,q1,1)=utf8copy(gr,q2,1) then begin
		       utf8delete(new,q1,1);
		       utf8insert(en[q2],new,q1);
		       break;
		     end;
		   end;
  end;
  result:=new;
  //helpline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.');
end;

function DownloadHTTP(URL, TargetFile: string): Boolean;
// Download file; retry if necessary.
// Could use Synapse HttpGetBinary, but that doesn't deal
// with result codes (i.e. it happily downloads a 404 error document)
const
  MaxRetries = 3;
var
  HTTPGetResult: Boolean;
  HTTPSender: THTTPSend;
  RetryAttempt: Integer;
begin
  Result := False;
  RetryAttempt := 1;
  HTTPSender := THTTPSend.Create;
  try
    try
      // Try to get the file
      HTTPGetResult := HTTPSender.HTTPMethod('GET', URL);
      while (HTTPGetResult = False) and (RetryAttempt < MaxRetries) do
      begin
        Sleep(500 * RetryAttempt);
        HTTPGetResult := HTTPSender.HTTPMethod('GET', URL);
        RetryAttempt := RetryAttempt + 1;
      end;
      // If we have an answer from the server, check if the file
      // was sent to us.
      case HTTPSender.Resultcode of
        100..299:
          begin
            HTTPSender.Document.SaveToFile(TargetFile);
            Result := True;
          end; //informational, success
        300..399: Result := False; // redirection. Not implemented, but could be.
        400..499: Result := False; // client error; 404 not found etc
        500..599: Result := False; // internal server error
        else Result := False; // unknown code
      end;
    except
      // We don't care for the reason for this error; the download failed.
      Result := False;
    end;
  finally
    HTTPSender.Free;
  end;
end;

procedure program_exit;
begin
  history.free;
  l.free;
  ds.free;
  textcolor(white);
  textbackground(black);
  clrscr;
  if fileexists('output.txt') then deletefile('output.txt');
  {$ifdef windows}
    setconsolecp(cp);
  {$endif}
  halt(0);
end;

procedure baseline(str:string);
begin
  textbackground(theme.baselineback);textcolor(theme.baselinetext);
  gotoxy(1,screenheight-1);
  clreol;
  write(center(str,' ',screenwidth));
  gotoxy(1,screenheight);
  textcolor(theme.titletext);textbackground(black);
  clreol;
  write('#> ');
  textcolor(theme.posttext);
end;

procedure inlinehelp;
var
  f:textfile;
begin
  assign(f,'output.txt');
  rewrite(f);
  writeln(f,colortostr(theme.titletext));
  writeln(f,'> Commands');
  writeln(f,colortostr(theme.posttext));
  writeln(f,'/exit, /x: exits the program');
  writeln(f,'/index, /i: Display all repeaters');
  writeln(f,'/save: Save current screen to textfile');
  writeln(f,'/version, /v: show current program version');
  writeln(f,'help, /help, /h: This screen ');
  writeln(f,'/update, /u: Update repeater database');
  writeln(f,'/dir: List files in current folder');
  writeln(f,' ');
  writeln(f,colortostr(theme.titletext));
  writeln(f,'> Database Commands');
  writeln(f,colortostr(theme.posttext));
  writeln(f,'/create <name>, /cr <name>: Create new database');
  writeln(f,'/open <name>, /o <name>: Open database');
  writeln(f,'/list, /l: List databases in current folder');
  writeln(f,'/remove <name>, /rm <name>: Delete database from disk');
  writeln(f,' ');
  writeln(f,colortostr(theme.titletext));
  writeln(f,'> Import/Export Commands');
  writeln(f,colortostr(theme.posttext));
  writeln(f,'/chirp export,/ce: Export database in .csv format compatible with CHIRP');
  writeln(f,'/chirp import,/ci: Import database from .csv format compatible with CHIRP');
  writeln(f,'/gqrx export, /ge: Export database in .csv format compatible with GQRX');
  writeln(f,'/gqrx import, /gi: Import database from .csv format compatible with GQRX');
  writeln(f,' ');
  writeln(f,colortostr(theme.titletext));
  writeln(f,'> Record Commands');
  writeln(f,colortostr(theme.posttext));
  writeln(f,'/edit <no>, /e <no>: Edit record number <no>');
  writeln(f,'/del <no>, /d <no>: Delete record number <no>');
  writeln(f,'/add, /a: Add new record');
  writeln(f,'/show <no>, /s <no>: Show details of record');
  {$IFDEF UNIX}
  writeln(f,'/audio <no>: Listen to specific station');
  {$ENDIF}
  writeln(f,' ');
  writeln(f,colortostr(theme.titletext));
  writeln(f,'> List Commands');
  writeln(f,colortostr(theme.posttext));
  writeln(f,'/repeaters, /r: show all repeaters ordered by id');
  writeln(f,'/repeaters id, /r id: Show repeaters ordered by ID');
  writeln(f,'/repeaters loc, /r loc: Show repeaters ordered by Location');
  writeln(f,'/repeaters tone, /r tone: Show repeaters ordered by Tone');
  writeln(f,'/repeaters freq, /r freq: Show repeaters ordered by Tone');
  writeln(f,'/repeaters group, /r group: Show repeaters ordered by Group');
  writeln(f,'/repeaters tag, /r tag: Show repeaters ordered by Tag');
  writeln(f,' ');
  writeln(f,colortostr(theme.titletext));
  writeln(f,'> Search Commands');
  writeln(f,colortostr(theme.posttext));
  writeln(f,'/searchloc <string>, /sl <string>: Search database in Location field');
  writeln(f,'/searchid <string>, /si <string>: Search database in ID field');
  writeln(f,'/searchtone <string>, /st <string>: Search database in Tone field');
  writeln(f,'/searchshift <string>, /ss <string>: Search database in Shift field');
  writeln(f,'/searchwide <string>, /sw <string>: Search database in Wide field');
  writeln(f,'/searchfreq <string>, /sf <string>: Search database in Frequency field');
  writeln(f,'/searchgroup <string>, /sg <string>: Search database in Group field');
  writeln(f,'/searchtag <string>, /stag <string>: Search database in Tag field');
    writeln(f,' ');
  writeln(f,colortostr(theme.titletext)+'> Keys and Shortcuts');
  writeln(f,colortostr(theme.posttext));
  writeln(f,'Up, Down, Left, Right, PgUp, PgDown: Text scroll');
  writeln(f,'[, ]: Browse command history');
  writeln(f,'Esc: Exits the program');
  closefile(f);
  topline('Available Commands and features...');
end;

function forumtime(t:integer):string;
begin
  result:=formatdatetime('hh:nn DD-MM-YYYY',unixtodatetime(t));
end;

procedure topline(s:string);
begin
  gotoxy(1,1);
  textcolor(theme.toplinetext);
  textbackground(theme.toplineback);
  clreol;
  write(stringofchar(' ',screenwidth));
  gotoxy(1,1);
  write(s);
end;

procedure viewer_pos;
var q:real;
begin
  q:=i+screenheight;
  q:=((l.count - q) / l.count) * 100;
  if q<0 then q:=0;
  if q>100 then q:=100;
  q:=100-q;
  gotoxy(screenwidth-5,screenheight);
  textcolor(theme.percenttext);
  write(inttostr(trunc(q))+'%');
end;

procedure clrscreen;
begin
  textbackground(black);
  clrscr;
  topline(title);
  baseline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.');
  
  gotoxy(1,2);
end;

procedure viewer(str: string);
var
  x,y:integer;
  p1:string;
begin
    clrscreen;
    x:=wherex;
    y:=2;
    //title:='Using: '+database+' [ '+str+' ]';
    if i+screenheight-3>l.count-1 then e:=l.count-1 else e:=i+screenheight-4;
    for d:=i to e do begin
      p1:=lowercase(l[d]);
      if pos('%g%',p1)>0 then begin textcolor(green);s:='%g%';end;
      if pos('%y%',p1)>0 then begin textcolor(yellow);s:='%y%';end;
      if pos('%r%',p1)>0 then begin textcolor(red);s:='%r%';end;
      if pos('%d%',p1)>0 then begin textcolor(grey);s:='%d%';end;
      if pos('%w%',p1)>0 then begin textcolor(white);s:='%w%';end;
      if pos('%b%',p1)>0 then begin textcolor(blue);s:='%b%';end;
      if pos('%c%',p1)>0 then begin textcolor(cyan);s:='%c%';end;
      if pos('%m%',p1)>0 then begin textcolor(magenta);s:='%m%';end;
      v:=pos(s,p1);
      s:=l[d];
      delete(s,v,3);
      gotoxy(1,y);
      y:=y+1;
      write(copy(s,viewer_x,screenwidth-1));
    end; //
    viewer_pos;
    gotoxy(4,screenheight);
end;

procedure clrlinefrom(x,y:integer);
var p:integer;
begin
gotoxy(x,y);
for p:=x to x+14 do write(' ');
end;

procedure deleterecord(s:string);
var
  c:char;
  confirm:string;
begin
//delete form repeaters where id=aaa;
  helpline('Are you sure you want to delete this record? [Y]es/[C]ancel:');
  textbackground(black);
  gotoxy(1,screenheight);
  write('#> ');
  gotoxy(4,screenheight);
  c:=readkey;
  confirm:=c;
  confirm:=uppercase(trim(confirm));
  baseline('Removing Record...');
  if confirm='Y' then begin
    //ds.execsql('delete from repeaters where id='''+ds.fields.fieldbyname('id').asstring+'''');
    ds.delete;
    ds.applyupdates;
    writeln('Deleted...');
  end else baseline('Returned to index...');
end;

procedure insertrecord(s:string);
var
  id,loc,freq,tone,wide,shift,groupo,link,tag,name,sign:string;
  id1,loc1,freq1,tone1,wide1,shift1,groupo1,link1,name1,tag1,sign1:string;
  ts,cs:tstation;

  confirm:string;
  c:char;
  valid:boolean;
  complete:boolean;
  fr,tn,shf:single;
  code:byte;
  tab1,tab2,tab3:byte;
begin
clrscreen;
title:='Using: '+database+' [ Inserting new Record ]';
topline(title);
textbackground(black);
tab1:=5;
tab2:=35;
tab3:=50;
writeat(tab1,4,'ID               (ex. R45)  : ');
writeat(tab1,5,'Name           (ex SV3SDD)  : ');
writeat(tab1,6,'Location                    : ');
writeat(tab1,7,'Frequency (ex. 144,500.00)  : ');
writeat(tab1,8,'Tone            (ex. 88.5)  : ');
writeat(tab1,9,'Wide/Narrow          (W/N)  : ');
writeat(tab1,10,'Sign                (+/-)  : ');
writeat(tab1,11,'Shift        (ex. 00.600)   : ');
writeat(tab1,12,'Group                       : ');
writeat(tab1,13,'Link                        : ');
writeat(tab1,14,'Tags                        : ');
valid:=false;
complete:=false;
cursoron;
repeat
textcolor(theme.postinfo);
repeat
writeat(tab2,4,'> ');readln(id1);
if id1='' then begin helpline('ERROR - You must specify an ID');valid:=true;end;
if id1<>'' then begin id:=id1;valid:=true;end;
clrlinefrom(tab2,4);
writeat(tab2,4,uppercase(id1));
until valid=true;

valid:=false;
repeat
writeat(tab2,5,'> ');readln(name1);
if name1='' then begin name:='#';valid:=true;end;
if name1<>'' then begin name:=name1;valid:=true;end;
clrlinefrom(tab2,5);
writeat(tab2,5,uppercase(name1));
until valid=true;

valid:=false;
repeat
writeat(tab2,6,'> ');readln(loc1);
if loc1='' then begin loc:='#';valid:=true;end;
if loc1<>'' then begin loc:=loc1;valid:=true;end;
clrlinefrom(tab2,6);
writeat(tab2,6,uppercase(loc1));
until valid=true;

valid:=false;
repeat
writeat(tab2,7,'> ');maskedreadln(freq1,'000,000.00','#');
clrlinefrom(tab2,7);
(*if trim(freq1)<>'' then begin
val(freq1,fr,code);
if code=0 then begin
  freq:=floattostr(fr);
  valid:=true;
  writeat(tab2,6,freq);
end;
end else begin
  helpline('ERROR - You must specify a frequency...');
  valid:=false;
end;           *)
if length(freq1)=10 then begin freq:=freq1;valid:=true;end;
writeat(tab2,7,freq);
until valid=true;

valid:=false;
repeat
writeat(tab2,8,'> ');maskedreadln(tone1,'000.00','#');
clrlinefrom(tab2,8);
(*if tone1<>'' then begin
val(tone1,tn,code);
if code=0 then begin
  tone:=floattostr(tn);
  valid:=true;
  writeat(tab2,7,tone);
end;
end else begin
  tone:='0.00';
  valid:=true;
end;*)
if length(tone1)=6 then begin tone:=tone1;valid:=true;end;
writeat(tab2,8,tone);
until valid=true;


valid:=false;
repeat
writeat(tab2,9,'> ');maskedreadln(wide1,'A',' ');
wide:=ds.fields.fieldbyname('wide').asstring;
if wide1='' then begin wide:='N';valid:=true;end;
if (uppercase(wide1)='N') or (uppercase(wide1)='W') then begin wide:=wide1;valid:=true;end;
//clrlinefrom(35+length(wide),8);
clrlinefrom(tab2,9);
writeat(tab2,9,uppercase(wide));
until valid=true;

valid:=false;
repeat
writeat(tab2,10,'> ');maskedreadln(sign1,' ',' ');
wide:=ds.fields.fieldbyname('sign').asstring;
if sign1='' then begin sign:='-';valid:=true;end;
if (uppercase(sign1)='-') or (uppercase(sign1)='+') then begin sign:=sign1;valid:=true;end;
//clrlinefrom(35+length(wide),8);
clrlinefrom(tab2,10);
writeat(tab2,10,uppercase(sign));
until valid=true;

valid:=false;
repeat
writeat(tab2,11,'> ');maskedreadln(shift1,'00.000','#');
clrlinefrom(tab2,11);
(*if shift1<>'' then begin
val(shift1,shf,code);
if code=0 then begin
  shift:=floattostr(shf);
  valid:=true;
  writeat(tab2,9,shift)
end;
end else begin
  shift:='SIMPLEX';
  valid:=true;
end;*)
  if length(shift1)=6 then begin shift:=shift1;valid:=true;end;
  writeat(tab2,11,shift1);
until valid=true;

valid:=false;
repeat
writeat(tab2,12,'> ');readln(groupo1);
if groupo1='' then begin groupo:='none';valid:=true;end;
if groupo1<>'' then begin groupo:=groupo1;valid:=true;end;
clrlinefrom(tab2,12);
writeat(tab2,12,uppercase(groupo1));
until valid=true;

valid:=false;
repeat
writeat(tab2,13,'> ');readln(link1);
if link1='' then begin link:='none';valid:=true;end;
if link1<>'' then begin link:=link1;valid:=true;end;
clrlinefrom(tab2,13);
writeat(tab2,13,uppercase(link1));
until valid=true;

valid:=false;
repeat
writeat(tab2,14,'> ');readln(tag1);
if tag1='' then begin tag:='#';valid:=true;end;
if tag1<>'' then begin tag:=tag1;valid:=true;end;
clrlinefrom(tab2,14);
writeat(tab2,14,uppercase(tag1));
until valid=true;


  helpline('Are you sure about the changes? [Y]es/[C]ancel:');
  textbackground(black);
  gotoxy(1,screenheight);
  write('#> ');
  gotoxy(4,screenheight);
  c:=readkey;
  confirm:=c;
  confirm:=uppercase(trim(confirm));
  baseline('Adding new Record.');
  if confirm='Y' then begin
    //if ds.active=false then ds.open;
    //ds.insert;
    //ds.fields.fieldbyname('id').asstring:=id;
    //ds.fields.fieldbyname('freq').asstring:=freq;
    //ds.post;
    
    //ds.sql:=
    ds.execsql('INSERT INTO repeaters VALUES('+
    				 ''''+uppercase(id)+''','+
                                 ''''+uppercase(loc)+''','+
                                 ''''+uppercase(name)+''','+
                                 ''''+uppercase(link)+''','+
                                 ''''+freq+''','+
                                 ''''+shift+''','+
                                 ''''+sign+''','+
                                 ''''+tone+''','+
                                 ''''+uppercase(groupo)+''','+
                                 ''''+uppercase(wide)+''','+
                                 '''FM'','+
                                 ''' '','+
                                 ''''+uppercase(tag)+''','+
                                 ''''+datetimetostr(today)+''','+
                                 ''''+datetimetostr(today)+''')');
                                 
                                 
    //ds.execsql;
    ds.applyupdates;
    complete:=true;
    writeln('Inserted...');
  end;
  if confirm = 'C' then complete:=true;
until complete=true;
end;

procedure showrecord;
var
  f:textfile;
begin
  assign(f,'output.txt');
  rewrite(f);
  writeln(f,'');
  writeln(f,'');writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     ID ');
  writeln(f,colortostr(theme.posttext)+'     '+gr2en(ds.fields.fieldbyname('id').asstring));
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Location');
  writeln(f,colortostr(theme.posttext)+'     '+gr2en(ds.fields.fieldbyname('location').asstring));
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Name');
  writeln(f,colortostr(theme.posttext)+'     '+ds.fields.fieldbyname('name1').asstring);
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Frequency');
  writeln(f,colortostr(theme.posttext)+'     '+ds.fields.fieldbyname('freq').asstring);
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Tone ');
  writeln(f,colortostr(theme.posttext)+'     '+ds.fields.fieldbyname('tone').asstring);
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Wide/Narrow ');
  writeln(f,colortostr(theme.posttext)+'     '+gr2en(ds.fields.fieldbyname('wide').asstring));
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Sign ');
  writeln(f,colortostr(theme.posttext)+'     '+gr2en(ds.fields.fieldbyname('sign').asstring));
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Shift ');
  writeln(f,colortostr(theme.posttext)+'     '+ds.fields.fieldbyname('shift').asstring);
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Group ');
  writeln(f,colortostr(theme.posttext)+'     '+gr2en(ds.fields.fieldbyname('groupo').asstring));
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Link ');
  writeln(f,colortostr(theme.posttext)+'     '+gr2en(ds.fields.fieldbyname('name2').asstring));
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Tags ');
  writeln(f,colortostr(theme.posttext)+'     '+gr2en(ds.fields.fieldbyname('tags').asstring));
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Created at (date)');
  writeln(f,colortostr(theme.posttext)+'     '+gr2en(ds.fields.fieldbyname('createdate').asstring));
  writeln(f,'');
  writeln(f,colortostr(theme.postinfo)+'     Last Access (date)');
  writeln(f,colortostr(theme.posttext)+'     '+gr2en(ds.fields.fieldbyname('lastdate').asstring));
  writeln(f,'');
  closefile(f);
end;


procedure updaterecord(s:string);
var
  id,loc,freq,tone,wide,shift,groupo,name,sign,link,tag:string;
  id1,loc1,freq1,tone1,wide1,shift1,groupo1,link1,name1,sign1,tag1:string;
  ts,cs:tstation;

  confirm:string;
  c:char;
  valid:boolean;
  complete:boolean;
  fr,tn,shf:single;
  code:byte;
  tab1,tab2,tab3:byte;
begin
clrscreen;
title:='Using: '+database+' [ Editing Record ]';
topline(title);
textbackground(black);
tab1:=5;
tab2:=35;
tab3:=54;
writeat(tab1,4,'ID               (ex. R45)  : ');writeat(tab3,4,gr2en(ds.fields.fieldbyname('id').asstring));
writeat(tab1,5,'Location                    : ');writeat(tab3,5,gr2en(ds.fields.fieldbyname('location').asstring));
writeat(tab1,6,'Name                        : ');writeat(tab3,6,ds.fields.fieldbyname('name1').asstring);
writeat(tab1,7,'Frequency (ex. 144.500000)  : ');writeat(tab3,7,ds.fields.fieldbyname('freq').asstring);
writeat(tab1,8,'Tone            (ex. 88.5)  : ');writeat(tab3,8,ds.fields.fieldbyname('tone').asstring);
writeat(tab1,9,'Wide/Narrow          (W/N)  : ');writeat(tab3,9,gr2en(ds.fields.fieldbyname('wide').asstring));
writeat(tab1,10,'Sign                 (+/-)  : ');writeat(tab3,10,ds.fields.fieldbyname('sign').asstring);
writeat(tab1,11,'Shift        (ex. 00.600)   : ');writeat(tab3,11,ds.fields.fieldbyname('shift').asstring);
writeat(tab1,12,'Group                       : ');writeat(tab3,12,gr2en(ds.fields.fieldbyname('groupo').asstring));
writeat(tab1,13,'Link                        : ');writeat(tab3,13,gr2en(ds.fields.fieldbyname('name2').asstring));
writeat(tab1,14,'Tags                        : ');writeat(tab3,14,gr2en(ds.fields.fieldbyname('tags').asstring));
valid:=false;
complete:=false;
cursoron;
repeat
textcolor(theme.postinfo);
repeat
writeat(tab2,4,'> ');readln(id1);
if id1='' then begin id:=ds.fields.fieldbyname('id').asstring;valid:=true;end;
if id1<>'' then begin id:=id1;valid:=true;end;
clrlinefrom(tab2,4);
writeat(tab2,4,uppercase(id1));
until valid=true;

valid:=false;
repeat
writeat(tab2,5,'> ');readln(loc1);
if loc1='' then begin loc:=ds.fields.fieldbyname('location').asstring;valid:=true;end;
if loc1<>'' then begin loc:=loc1;valid:=true;end;
clrlinefrom(tab2,5);
writeat(tab2,5,uppercase(loc1));
until valid=true;
valid:=false;
repeat
writeat(tab2,6,'> ');readln(name1);
if name1='' then begin name:=ds.fields.fieldbyname('name1').asstring;valid:=true;end;
if name1<>'' then begin name:=name1;valid:=true;end;
clrlinefrom(tab2,6);
writeat(tab2,6,uppercase(name1));
until valid=true;
valid:=false;
repeat
writeat(tab2,7,'> ');maskedreadln(freq1,'000.000,00','#');
clrlinefrom(tab2,7);
(*if trim(freq1)<>'' then begin
val(freq1,fr,code);
if code=0 then begin
  freq:=floattostr(fr);
  valid:=true;
  writeat(tab2,6,freq);
end;
end else begin
  freq:=ds.fields.fieldbyname('freq').asstring;
  valid:=true;
end;*)
  if length(freq1)=10 then begin freq:=freq1;valid:=true;end else
    if length(freq1)=0 then begin freq:=ds.fields.fieldbyname('freq').asstring;valid:=true;end;
  writeat(tab2,7,freq1);
until valid=true;

valid:=false;
repeat
writeat(tab2,8,'> ');maskedreadln(tone1,'000.00','#');
clrlinefrom(tab2,8);
(*if tone1<>'' then begin
val(tone1,tn,code);
if code=0 then begin
  tone:=floattostr(tn);
  valid:=true;
  writeat(tab2,7,tone);
end;
end else begin
  tone:=ds.fields.fieldbyname('tone').asstring;
  valid:=true;
end;*)
  if length(tone1)=6 then begin tone:=tone1;valid:=true;end else
    if length(tone1)=0 then begin tone:=ds.fields.fieldbyname('tone').asstring;valid:=true;end;
  writeat(tab2,8,tone1);
until valid=true;


valid:=false;
repeat
writeat(tab2,9,'> ');maskedreadln(wide1,'A','#');
wide:=ds.fields.fieldbyname('wide').asstring;
if wide1='' then begin wide:=ds.fields.fieldbyname('wide').asstring;valid:=true;end;
if (uppercase(wide1)='N') or (uppercase(wide1)='W') then begin wide:=wide1;valid:=true;end;
//clrlinefrom(35+length(wide),8);
clrlinefrom(tab2,9);
writeat(tab2,9,uppercase(wide));
until valid=true;
valid:=false;
repeat
writeat(tab2,10,'> ');maskedreadln(sign1,' ','#');
sign:=ds.fields.fieldbyname('sign').asstring;
if sign1='' then begin sign:=ds.fields.fieldbyname('sign').asstring;valid:=true;end;
if (uppercase(sign1)='-') or (uppercase(sign1)='+') then begin sign:=sign1;valid:=true;end;
//clrlinefrom(35+length(wide),8);
clrlinefrom(tab2,10);
writeat(tab2,10,uppercase(sign));
until valid=true;

valid:=false;
repeat
writeat(tab2,11,'> ');maskedreadln(shift1,'00.000','#');
clrlinefrom(tab2,11);
(*if shift1<>'' then begin
val(shift1,shf,code);
if code=0 then begin
  shift:=floattostr(shf);
  valid:=true;
  writeat(tab2,9,shift)
end;
end else begin
  shift:=ds.fields.fieldbyname('shift').asstring;
  valid:=true;
end;*)
  if length(shift1)=6 then begin shift:=shift1;valid:=true;end else
    if length(shift1)=0 then begin shift:=ds.fields.fieldbyname('shift').asstring;valid:=true;end;
  writeat(tab2,11,shift1);
until valid=true;

valid:=false;
repeat
writeat(tab2,12,'> ');readln(groupo1);
if groupo1='' then begin groupo:=ds.fields.fieldbyname('groupo').asstring;valid:=true;end;
if groupo1<>'' then begin groupo:=groupo1;valid:=true;end;
clrlinefrom(tab2,12);
writeat(tab2,12,uppercase(groupo1));
until valid=true;

valid:=false;
repeat
writeat(tab2,13,'> ');readln(link1);
if link1='' then begin link:=ds.fields.fieldbyname('name2').asstring;valid:=true;end;
if link1<>'' then begin link:=link1;valid:=true;end;
clrlinefrom(tab2,13);
writeat(tab2,13,uppercase(link1));
until valid=true;

valid:=false;
repeat
writeat(tab2,14,'> ');readln(tag1);
if tag1='' then begin tag:=ds.fields.fieldbyname('tags').asstring;valid:=true;end;
if tag1<>'' then begin tag:=tag1;valid:=true;end;
clrlinefrom(tab2,14);
writeat(tab2,14,uppercase(tag1));
until valid=true;


  helpline('Are you sure about the changes? [Y]es/[C]ancel:');
  textbackground(black);
  gotoxy(1,screenheight);
  write('#> ');
  gotoxy(4,screenheight);
  c:=readkey;
  confirm:=c;
  confirm:=uppercase(trim(confirm));
  baseline('Edit of current station is continuing.');
  if confirm='Y' then begin
    if ds.active=false then ds.open;
    //ds.insert;
    //ds.fields.fieldbyname('id').asstring:=id;
    //ds.fields.fieldbyname('freq').asstring:=freq;
    //ds.post;
    
    //ds.sql:=
    sqlexec('UPDATE repeaters SET id='''+uppercase(id)+''', '+
    				 'freq='''+freq+''', '+
                                 'name1='''+name+''', '+
                                 'tone='''+tone+''', '+
                                 'wide='''+uppercase(wide)+''', '+
                                 'location='''+uppercase(loc)+''', '+
                                 'sign='''+sign+''', '+
                                 'shift='''+shift+''', '+
                                 'tags='''+uppercase(tag)+''', '+
                                 'groupo='''+uppercase(groupo)+''', '+
                                 'name1='''+name+''', '+
                                 'band=''FM'', '+
                                 'name2='''+uppercase(link)+''''+
                                 ' WHERE id='''+ds.fields.fieldbyname('id').asstring+'''');
    //ds.execsql;
    ds.applyupdates;
    complete:=true;
    writeln('Saved...');
  end;
  if confirm = 'C' then complete:=true;
until complete=true;
end;

function togqrxfreq(s:string):string;
var
  p:string;
begin
  p:=trimright(trimleft(s));
  p:=stringreplace(p,',','',[rfreplaceall]);
  p:=stringreplace(p,'.','',[rfreplaceall]);
  p:=stringreplace(p,' ','',[rfreplaceall]);
  p:=stringreplace(uppercase(p),'MHZ','',[rfreplaceall]);
  if length(p)<9 then
        repeat
          p:=p+'0';
        until length(p)=9;
  result:=p;
end;

function fromgqrxfreq(s:string):string;
var p:string;
begin
  p:=trimleft(trimright(s));
  insert('.',p,4);
  insert(',',p,8);
  result:=p;
end;


procedure sqlexec(sql:string);
begin
if ds.active=true then ds.close;
   ds.Sql := sql;
   ds.Open;
end;

procedure rowid(d:integer);
var i:integer;
begin
  case d of
    0: ds.first;
    1: ds.first;
    else begin
       ds.first;
       for i:=1 to d-1 do ds.next;
       end;
  end;
end;

procedure listenrecord(s:string);
var
  band:string[8];
  freq:string[15];
  comm:string;
  res:longint;
begin
  clrscr;
  textcolor(white);
  textbackground(black);
  if ds.fields.fieldbyname('wide').asstring='W' then band:='wbfm' else band:='fm';
  freq:=ds.fields.fieldbyname('freq').asstring;
  freq:=togqrxfreq(freq);
  ds.fields.fieldbyname('lastdate').asstring:=datetimetostr(today);
  //comm:=format('rtl_fm -f %s -M %s -A fast -E - | play -r 16k -t raw -e s -b 16 -c 1 -V1 -',[ freq, band]);
  comm:=format(rtlfm,[ freq, band]);
  {$IFDEF linux}res:=shell(comm);{$ENDIF}
end;

function formatfreq(s:string):string;
var ss:string;
begin
  ss:=uppercase(s);
  if pos(ss,'MHZ')>0 then stringreplace(ss,'MHZ','',[rfreplaceall]);
  if ss[3]='.' then ss[3]:=',';
  if length(ss)=7 then ss:=ss+'.00';
  if length(ss)<10 then begin
    repeat
      ss:=ss+'0';
    until length(ss)=10;
    ss[8]:='.';
    ss[3]:=',';
  end;
  result:=ss;
end;

function formatid(st:string):string;
var ss:string;
begin
ss:=st;
ss:=uppercase(ss);
ss:=stringreplace(trimright(ss),' ','',[rfreplaceall]);
ss:=stringreplace(trimright(ss),'MHZ','',[rfreplaceall]);
if (trim(ss)='') or (trim(ss)=' ') then ss:='empty';
result:=ss;
end;

procedure gqrxexport;
var
  f:textfile;
  line:string;
  sp:string;
  q:integer;
begin
   try
   sqlexec('select * from repeaters');
       ds.first;
       assign(f,'output.txt');
       rewrite(f);
       q:=0;
       writeln(f,'# Tag name          ;  color');
       writeln(f,'Untagged            ; #c0c0c0');
       writeln(f,'');
       writeln(f,'# Frequency ; Name                     ; Modulation          ;  Bandwidth; Tags');
       while not ds.eof do begin
       q:=q+1;
       line:='';
       line:=line+togqrxfreq(ds.fields.fieldbyname('freq').asstring)+';';
       if gr2en(ds.fields.fieldbyname('id').asstring)<>'' then line:=line+ds.fields.fieldbyname('id').asstring+';'
         else if gr2en(ds.fields.fieldbyname('name2').asstring)<>'' then line:=line+ds.fields.fieldbyname('name2').asstring+';'
         else if gr2en(ds.fields.fieldbyname('name1').asstring)<>'' then line:=line+ds.fields.fieldbyname('name1').asstring+';'
         else line:=line+'unknown';
       if ds.fields.fieldbyname('wide').asstring='N' then line:=line+' Narrow FM ; 10000 ; Untagged' else
         if ds.fields.fieldbyname('wide').asstring='W' then line:=line+'Wide FM ; 10000 ; Untagged' else
         if trim(ds.fields.fieldbyname('wide').asstring)='' then line:=line+'Narrow FM ; 10000 ; Untagged' else
            line:=line+'Narrow FM ; 10000 ; Untagged';
       //line:=line+' '+format('%-25s',[gr2en(rsp2(ds.fields.fieldbyname('location').asstring))]);
       //line:=line+' '+format('%-10s',[gr2en(rsp2(ds.fields.fieldbyname('name1').asstring))]);
       //line:=line+' '+format('%-30s',[gr2en(rsp2(ds.fields.fieldbyname('name2').asstring))]);
       
       //line:=line+' '+format('%10s',[rsp2(ds.fields.fieldbyname('shift').asstring)]);
       //line:=line+' '+format('%-3s',[rsp(ds.fields.fieldbyname('wide').asstring)]);
       //line:=line+' '+format('%-20s',[gr2en(rsp2(ds.fields.fieldbyname('groupo').asstring))]);
       writeln(f,line);
       ds.next;
     end;
     closefile(f);
   except
     helpline('Error... Repeater table maybe missing. Press any key to continue...');readkey;
   end;
end;


function tochirpfreq(s:string):string;
var
  p:string;
begin
  p:=trimright(trimleft(s));
  p:=stringreplace(p,',','',[rfreplaceall]);
  p:=stringreplace(p,'.','',[rfreplaceall]);
  p:=stringreplace(p,' ','',[rfreplaceall]);
  p:=stringreplace(uppercase(p),'MHZ','',[rfreplaceall]);
  if length(p)<9 then
        repeat
          p:=p+'0';
        until length(p)=9;
  insert('.',p,4);
  result:=p;
end;

function fromchirpfreq(s:string):string;
var
  p:string;
begin
  p:=s;
  insert(',',p,8);
  delete(p,length(p),1);
  result:=p;
end;


function commatodot(s:String):string;
var 
  m:string;
begin
  m:=stringreplace(s,',','.',[rfreplaceall]);
  result:=m;
end;

procedure gqrximport;
var
	chirp:tcsv;
	expfile:textfile;
        tmpfile:textfile;
        dd:integer;
	filename:string;
        line:string;
        f:boolean;
begin
  line:='';
  filename:='';
  command('/DIR');
  helpline('Enter filename. Leave empty to cancel.');
  textbackground(black);
  gotoxy(1,screenheight);
  write('#> Filename (ex: gqrx.csv): ');
  gotoxy(30,screenheight);
  readln(filename);
  if trim(filename)='' then baseline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.') else
    if fileexists('.'+pathdelimeter+filename) then begin
  f:=false;
  assignfile(tmpfile,'tmp.tmp');
  assignfile(expfile,filename);
  reset(expfile);
  rewrite(tmpfile);
  repeat
    readln(expfile,line);
    if f=true then writeln(tmpfile,line);
    if pos('Freq',line)>0 then f:=true;
  until eof(expfile);
  closefile(expfile);
  closefile(tmpfile);
  line:='';
  //writeln(expfile,'Location,Name,Frequency,Duplex,Offset,Tone,rToneFreq,cToneFreq,DtcsCode,DtcsPolarity,Mode,TStep,Skip,Comment,URCALL,RPT1CALL,RPT2CALL');
  chirp := TCsv.Create('tmp.tmp');

  with chirp do
  begin
    
    OpenCsv();
    Delimiter := ';';
    writeat(1,screenheight,'Importing...');
    if recordcount>0 then 
      for dd:=0 to recordcount-1 do begin
                 write('.');
                 line:='';
		 line:=line+'INSERT INTO repeaters VALUES(';
    				line:=line+ ''''+inttostr(dd+1)+''',';
                                line:=line+ '''#'',';
                                line:=line+ ''''+uppercase(trimleft(trimright(getfieldvalue(dd,1))))+''',';
                                line:=line+ '''#'',';
                                line:=line+ ''''+fromgqrxfreq(getfieldvalue(dd,0))+''',';
                                line:=line+ '''00.000'',';
                                line:=line+ '''-'',';
                                line:=line+ '''000.00'',';
                                line:=line+ '''#'',';
                                if getfieldvalue(dd,2)='Narrow FM' then line:=line+ '''N'',' else
                                  if getfieldvalue(dd,2)='Wide FM' then line:=line+ '''W'',' else
                                    if getfieldvalue(dd,2)='NFM' then line:=line+ '''N'',' else
                                      line:=line+ '''N'',';
                                if getfieldvalue(dd,2)='Narrow FM' then line:=line+ '''FM'',' else
                                  if getfieldvalue(dd,2)='Wide FM' then line:=line+ '''WFM'',' else
                                    if getfieldvalue(dd,2)='LSB' then line:=line+ '''LSB'',' else
                                      if getfieldvalue(dd,2)='CW-L' then line:=line+ '''CWL'',' else
                                      line:=line+ '''FM'',';
                                line:=line+ ''' '',';
                                line:=line+ '''GQRX, '+trimleft(trimright(getfieldvalue(dd,4)))+''',';
                                line:=line+ ''''+datetimetostr(today)+''',';
                                line:=line+ ''''+datetimetostr(today)+''')';
                                 
                ds.execsql(line);
    //ds.execsql;
    
    end;
    ds.applyupdates;
  end;
  end;
  if fileexists('tmp.tmp') then deletefile('tmp.tmp');
end;

procedure chirpimport;
var
	chirp:tcsv;
	expfile:textfile;
	dd:integer;
	filename:string;
        line:string;
begin
  filename:='';
  command('/DIR');
  helpline('Enter filename. Leave empty to cancel.');
  textbackground(black);
  gotoxy(1,screenheight);
  write('#> Filename (ex: chirp.csv): ');
  gotoxy(30,screenheight);
  readln(filename);
  if trim(filename)='' then baseline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.') else
    if fileexists('.'+pathdelimeter+filename) then begin
  //assignfile(expfile,filename);
  //reset(expfile);
  //writeln(expfile,'Location,Name,Frequency,Duplex,Offset,Tone,rToneFreq,cToneFreq,DtcsCode,DtcsPolarity,Mode,TStep,Skip,Comment,URCALL,RPT1CALL,RPT2CALL');
  chirp := TCsv.Create(filename);

  with chirp do
  begin
    Delimiter := ',';
    OpenCsv();
    writeat(1,screenheight,'Importing...');
    if recordcount>0 then 
      for dd:=0 to recordcount-1 do begin
                 write('.');
                 line:='';
		 line:=line+'INSERT INTO repeaters VALUES(';
    				line:=line+ ''''+uppercase(getfieldvalue(dd,0))+''',';
                                line:=line+ '''#'',';
                                line:=line+ ''''+uppercase(getfieldvalue(dd,1))+''',';
                                line:=line+ '''#'',';
                                line:=line+ ''''+fromchirpfreq(getfieldvalue(dd,2))+''',';
                                line:=line+ ''''+getfieldvalue(dd,4)+''',';
                                line:=line+ ''''+getfieldvalue(dd,3)+''',';
                                line:=line+ ''''+getfieldvalue(dd,6)+''',';
                                line:=line+ '''#'',';
                                if getfieldvalue(dd,10)='FM' then line:=line+ '''W'',' else
                                  if getfieldvalue(dd,10)='WFM' then line:=line+ '''W'',' else
                                    if getfieldvalue(dd,10)='NFM' then line:=line+ '''N'',' else
                                      line:=line+ '''N'',';
                                if getfieldvalue(dd,10)='FM' then line:=line+ '''FM'',' else
                                  if getfieldvalue(dd,10)='WFM' then line:=line+ '''WFM'',' else
                                    if getfieldvalue(dd,10)='NFM' then line:=line+ '''NFM'',' else
                                      line:=line+ '''FM'',';
                                line:=line+ ''' '',';
                                line:=line+ '''CHIRP'',';
                                line:=line+ ''''+datetimetostr(today)+''',';
                                line:=line+ ''''+datetimetostr(today)+''')';
                                 
                ds.execsql(line);
    //ds.execsql;
    
    end;
    ds.applyupdates;
  end;
  end;
end;

procedure chirpexport;
var
  f:textfile;
  line:string;
  sh:string;
  q:integer;
begin
   try
   sqlexec('select * from repeaters');
       ds.first;
       assign(f,'output.txt');
       rewrite(f);
       q:=0;
       writeln(f,'Location,Name,Frequency,Duplex,Offset,Tone,rToneFreq,cToneFreq,DtcsCode,DtcsPolarity,Mode,TStep,Skip,Comment,URCALL,RPT1CALL,RPT2CALL');
       
       while not ds.eof do begin
       q:=q+1;
       line:=inttostr(q)+',';
       if gr2en(ds.fields.fieldbyname('id').asstring)<>'' then line:=line+ds.fields.fieldbyname('id').asstring+','
         else if gr2en(ds.fields.fieldbyname('name2').asstring)<>'' then line:=line+ds.fields.fieldbyname('name2').asstring+','
         else if gr2en(ds.fields.fieldbyname('name1').asstring)<>'' then line:=line+ds.fields.fieldbyname('name1').asstring+',';
       line:=line+tochirpfreq(ds.fields.fieldbyname('freq').asstring)+',,';
       sh:=ds.fields.fieldbyname('shift').asstring;
       if sh='simplex' then line:=line+'0.000000,' else line:=line+commatodot(sh)+',';
       sh:=trim(ds.fields.fieldbyname('tone').asstring);
       if sh='' then line:=line+',' else line:=line+'Tone,';
       if sh<>'' then line:=line+commatodot(sh)+','
         else line:=line+'88.5,';
       if sh<>'' then line:=line+commatodot(sh)+','
         else line:=line+'88.5,';
       line:=line+'023,NN,';
       if ds.fields.fieldbyname('wide').asstring='N' then line:=line+'NFM,' else
         if ds.fields.fieldbyname('wide').asstring='W' then line:=line+'FM,' else
         line:=line+'NFM,';
       line:=line+'5.00,,';
       if gr2en(ds.fields.fieldbyname('name2').asstring)<>'###' then line:=line+gr2en(ds.fields.fieldbyname('name2').asstring)+',,,,' else
         line:=line+',,,,,';
       //line:=line+' '+format('%-25s',[gr2en(rsp2(ds.fields.fieldbyname('location').asstring))]);
       //line:=line+' '+format('%-10s',[gr2en(rsp2(ds.fields.fieldbyname('name1').asstring))]);
       //line:=line+' '+format('%-30s',[gr2en(rsp2(ds.fields.fieldbyname('name2').asstring))]);
       
       //line:=line+' '+format('%10s',[rsp2(ds.fields.fieldbyname('shift').asstring)]);
       //line:=line+' '+format('%-3s',[rsp(ds.fields.fieldbyname('wide').asstring)]);
       //line:=line+' '+format('%-20s',[gr2en(rsp2(ds.fields.fieldbyname('groupo').asstring))]);
       writeln(f,line);
       ds.next;
     end;
     closefile(f);
   except
     helpline('Error... Repeater table maybe missing. Press any key to continue...');readkey;
   end;
end;

procedure showrepeaters(typo:string);
var
  f:textfile;
  line:string;
  no:integer;
begin
   try
   no:=0;
   sqlexec('select * from repeaters order by '+typo+' asc');
       ds.first;
       assign(f,'output.txt');
       rewrite(f);
       writeln(f,colortostr(theme.titletext));
    writeln(f,center('    _        _   _             ',' ',screenwidth-1));
	writeln(f,center(' __| |_ __ _| |_(_)___ _ _  ___',' ',screenwidth-1));
	writeln(f,center('(_-<  _/ _` |  _| / _ \ '' \(_-<',' ',screenwidth-1));
	writeln(f,center('/__/\__\__,_|\__|_\___/_||_/__/',' ',screenwidth-1));     
	writeln(f,' ');
       writeln(f,colortostr(theme.postinfo)+
       format(' %-4s %10s %-25s %-20s %-30s %-12s %11s %2s %11s %-11s %-10s %-20s',['No','CallSign','Location','Name','Link','Frequency','Tone','+-','Shift','Wide','Group','Tags']));
       while not ds.eof do begin
       no:=no+1;
       line:=' '+format('%-4s',[inttostr(no)]);
       line:=line+' '+format('%10s',[ds.fields.fieldbyname('id').asstring]);
       line:=line+' '+format('%-25s',[gr2en(ds.fields.fieldbyname('location').asstring)]);
       line:=line+' '+format('%-20s',[gr2en(ds.fields.fieldbyname('name1').asstring)]);
       line:=line+' '+format('%-30s',[gr2en(ds.fields.fieldbyname('name2').asstring)]);
       line:=line+' '+format('%-12s',[ds.fields.fieldbyname('freq').asstring]);
       line:=line+' '+format('%11s',[ds.fields.fieldbyname('tone').asstring]);
       line:=line+' '+format('%2s',[ds.fields.fieldbyname('sign').asstring]);
       line:=line+' '+format('%11s',[ds.fields.fieldbyname('shift').asstring]);
       line:=line+' '+format('%-11s',[ds.fields.fieldbyname('wide').asstring]);
       line:=line+' '+format('%-10s',[gr2en(ds.fields.fieldbyname('groupo').asstring)]);
       line:=line+' '+format('%-20s',[gr2en(ds.fields.fieldbyname('tags').asstring)]);
       //writeln(f,));
        writeln(f,colortostr(theme.posttext)+line);
       //result:='Post: #'+ds.fields.fieldbyname('post_id').asstring+'- Subject: '+ds.fields.fieldbyname('post_subject').asstring;

       ds.next;
     //end;
     end;
     writeln(f,' ');
     {$IFDEF unix}writeln(f,center('Listen to a station with the /audio command',' ',screenwidth-1));{$ENDIF}
     writeln(f,center('Type /help for the help screen',' ',screenwidth-1));
     writeln(f,' ');
     closefile(f);
   except
     helpline('Error... Repeater table maybe missing. Press any key to continue...');readkey;
   end;
end;

procedure searchrepeaters(col,str:string);
var
  f:textfile;
  line:string;
  no:integer;
 begin
  sqlexec('select * from repeaters where '+col+' like "%'+str+'%"');
  no:=0;
  try
     ds.first;
       assign(f,'output.txt');
       rewrite(f);
       writeln(f,colortostr(theme.titletext));
	writeln(f,center('    _        _   _             ',' ',screenwidth-1));
	writeln(f,center(' __| |_ __ _| |_(_)___ _ _  ___',' ',screenwidth-1));
	writeln(f,center('(_-<  _/ _` |  _| / _ \ '' \(_-<',' ',screenwidth-1));
	writeln(f,center('/__/\__\__,_|\__|_\___/_||_/__/',' ',screenwidth-1));     
	writeln(f,' ');
       writeln(f,center('Results for search term: "'+str+'"',' ',screenwidth-1));
       writeln(f,colortostr(theme.postinfo));
       //writeln(f,format('%-10s %-25s %-10s %-30s %11s %10s %10s %-3s %-20s %-20s ',['ID','Location','Name','Link','Freq','Tone','Shift','Wide','Group','Tags']));
       writeln(f,format(' %-4s %10s %-25s %-20s %-30s %-12s %11s %11s %-11s %-10s %-20s',['No','CallSign','Location','Name','Link','Frequency','Tone','Shift','Wide','Group','Tags']));
       while not ds.eof do begin
       no:=no+1;
       line:=' '+format('%-4s',[inttostr(no)]);
       line:=line+' '+format('%10s',[ds.fields.fieldbyname('id').asstring]);
       line:=line+' '+format('%-25s',[gr2en(ds.fields.fieldbyname('location').asstring)]);
       line:=line+' '+format('%-20s',[gr2en(ds.fields.fieldbyname('name1').asstring)]);
       line:=line+' '+format('%-30s',[gr2en(ds.fields.fieldbyname('name2').asstring)]);
       line:=line+' '+format('%-12s',[ds.fields.fieldbyname('freq').asstring]);
       line:=line+' '+format('%11s',[ds.fields.fieldbyname('tone').asstring]);
       line:=line+' '+format('%11s',[ds.fields.fieldbyname('shift').asstring]);
       line:=line+' '+format('%-11s',[ds.fields.fieldbyname('wide').asstring]);
       line:=line+' '+format('%-10s',[gr2en(ds.fields.fieldbyname('groupo').asstring)]);
       line:=line+' '+format('%-20s',[gr2en(ds.fields.fieldbyname('tags').asstring)]);
       writeln(f,colortostr(theme.posttext)+line);
       ds.next;
     //end;
     end;
     writeln(f,' ');
     {$IFDEF unix}writeln(f,center('Listen to a station with the /audio command',' ',screenwidth-1));{$ENDIF}
     writeln(f,center('Type /help for the help screen',' ',screenwidth-1));
     writeln(f,' ');
     closefile(f);
   except
     helpline('Repeater not found... Press any key...');readkey;
   end;
end;

procedure index;
begin
  title:='Using: '+database+' [ Index ]';
  showrepeaters('id');
  l.clear;
  l.loadfromfile('output.txt');
  i:=0;
  viewer(title);
  //topline('[] Greek Repeaters');
end;


procedure savetofile;
var filename:string;
begin
  filename:='';
  helpline('Enter filename. Leave empty to cancel.');
  textbackground(black);
  gotoxy(1,screenheight);
  write('#> Filename: ');
  gotoxy(14,screenheight);
  readln(filename);
  if trim(filename)='' then baseline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.') else begin
    copyfile('output.txt',filename);
  end;
  index;
end;

procedure deletedatabase(s:string);
var
  c:char;
  confirm:string;
begin
//delete form repeaters where id=aaa;
  helpline('Are you sure you want to delete the Database? [Y]es/[C]ancel:');
  textbackground(black);
  gotoxy(1,screenheight);
  write('#> ');
  gotoxy(4,screenheight);
  c:=readkey;
  confirm:=c;
  confirm:=uppercase(trim(confirm));
  baseline('Removing Database...');
  if confirm='Y' then begin
    //ds.execsql('delete from repeaters where id='''+ds.fields.fieldbyname('id').asstring+'''');
    deletefile('./'+lowercase(s)+'.sqlite');
    writeln('Database Removed...');
  end else baseline('Returned to index...');
end;


procedure createdatabase(s:string);
var
  ss:string;
begin
  ss:=trimleft(trimright(lowercase(s)));
  if fileexists(ss+'.sqlite')=false then begin
    with ds do begin
      ds.close;
      ds.filename:=ss+'.sqlite';
      tablename:='repeaters';
      try
      ds.execsql('CREATE TABLE repeaters (id varchar(255) DEFAULT (null) ,location varchar(255) DEFAULT (null) ,'+
      'name1 varchar(255) DEFAULT (null) ,name2 varchar(255) DEFAULT (null) ,freq varchar(255) DEFAULT (''000,000.00'') ,'+
      'shift varchar(255) DEFAULT (''00.000''),sign varchar(1) default(''-'') ,tone varchar(255) DEFAULT (''000.00'') ,groupo varchar(255) DEFAULT (null) ,'+
      'wide VARCHAR(5) default (''N''),band VARCHAR(5) default (''FM''),nomos VARCHAR(255) default (null),tags varchar(255) default(null), lastdate varchar(20) default (00/00/00) ,'+
      'createdate varchar(20) default (00/00/00))');
      except
        helpline('[e102] Could not create Database. Press any key to continue...');
	readkey;
      end;
      try
      primarykey:='id';
      sql:='pragma encoding = "el.utf8"';
      execsql;
      sql:='select * from repeaters order by location asc';
      open;
      except
        helpline('[e104] Could not create Database. Press any key to continue...');
	readkey;
      end;
    end;
  end else begin
    helpline('Database allready exists. Cannot create it. Remove file first.');
  end;
end;

function ExtractFileNameEX(const AFileName:String): String;
 var
   I: integer;
 begin
    I := LastDelimiter('.'+PathDelim+DriveDelim,AFileName);
        if (I=0)  or  (AFileName[I] <> '.')
            then
                 I := MaxInt;
          Result := ExtractFileName(Copy(AFileName,1,I-1));
 end;

procedure listfiles;
var
  files:tstringlist;
  f:textfile;
  pp:integer;
begin
  try
  files:=FindAllFiles('.', '*.*', true);
  assign(f,'output.txt');
  rewrite(f);
  writeln(f,colortostr(theme.titletext));
  writeln(f,center('  __ _ _        ',' ',screenwidth-1));
  writeln(f,center(' / _(_) |___ ___',' ',screenwidth-1));
  writeln(f,center('|  _| | / -_|_-<',' ',screenwidth-1));
  writeln(f,center('|_| |_|_\___/__/',' ',screenwidth-1));
  writeln(f,' ');
  writeln(f,colortostr(theme.postinfo));
  writeln(f,center('Found '+inttostr(files.count)+' Files.',' ',screenwidth-1));
  writeln(f,' ');
  writeln(f,colortostr(theme.posttext));
  if files.count>0 then begin
      for pp:=0 to files.count-1 do writeln(f,'  '+inttostr(pp+1)+'.  '+files[pp]);
      writeln(f,colortostr(theme.postsep));
      writeln(f,center('Import CHIRP or GQRX .csv files with /import command. Type /help for more information.',' ',screenwidth-1));
    end else begin
      writeln(f,colortostr(theme.postsep));
      writeln(f,center('No files found. Type /help for the help screen.',' ',screenwidth-1));
    end;
  closefile(f);
  except
    helpline('[e120] Error while listing files. Press any key to continue...');
    readkey;
  end;
end;

procedure listdatabases;
var
  files:tstringlist;
  f:textfile;
  pp:integer;
begin
  try
  files:=FindAllFiles('.', '*.sqlite', true);
  assign(f,'output.txt');
  rewrite(f);
  writeln(f,colortostr(theme.titletext));
  writeln(f,center('    _      _        _                     ',' ',screenwidth-1));
  writeln(f,center(' __| |__ _| |_ __ _| |__  __ _ ___ ___ ___',' ',screenwidth-1));
  writeln(f,center('/ _` / _` |  _/ _` | ''_ \/ _` (_-</ -_|_-<',' ',screenwidth-1));
  writeln(f,center('\__,_\__,_|\__\__,_|_.__/\__,_/__/\___/__/',' ',screenwidth-1));
  writeln(f,' ');
  writeln(f,colortostr(theme.postinfo));
  writeln(f,center('Found '+inttostr(files.count)+' Databases.',' ',screenwidth-1));
  writeln(f,' ');
  writeln(f,colortostr(theme.posttext));
  if files.count>0 then begin
      for pp:=0 to files.count-1 do writeln(f,'  '+inttostr(pp+1)+'.  '+ExtractFileNameEx(files[pp]));
      writeln(f,colortostr(theme.postsep));
      writeln(f,center('Change Database with the /open command.',' ',screenwidth-1));
      writeln(f,center('Remove Database with the /remove command.',' ',screenwidth-1));
      writeln(f,center('Type /help for the help screen',' ',screenwidth-1));
    end else begin
      writeln(f,colortostr(theme.postsep));
      writeln(f,center('No databases found. Create one, with the /create command.',' ',screenwidth-1));
    end;
  closefile(f);
  except
    helpline('[e110] Error while listing databases. Press any key to continue...');
    readkey;
  end;
end;

procedure opendatabase(s:string);
var
  ss:string;
begin
  if ds.active=true then ds.close;
  if fileexists(trimleft(trimright(lowercase(s)))+'.sqlite')=false then begin
        helpline('[e101] Database does not exist. Press any key to continue...');
	readkey;
  end else begin
  try
  with ds do
    begin
     FileName := lowercase(s)+'.sqlite';
     database:= uppercase(s);
     TableName := 'repeaters';

     PrimaryKey := 'Id';
     sql:='PRAGMA encoding = "el.utf8"';
     execsql;
     //sql:='SET names utf8';
     //execsql;
     Sql := 'select * from repeaters order by location asc';
     Open;
     end;
 except
     helpline('Error opening database. Press any key to continue...');
     readkey;
 end;
 end;
end;


procedure updatedatabase;
var c:char;
begin
  if DownloadHTTP('http://fugazigr.com/repeaters/repeaters.sqlite','repeaters.upd')=false then begin
    helpline('Error while downloading database. Press any key to continue.');
    c:=readkey;
       index;
  end else begin
     if  MD5Print(MD5File('repeaters.sqlite'))= MD5Print(MD5File('repeaters.upd')) then begin
       helpline('No updates available. Press any key to continue.');
       c:=readkey;
       index;
       deletefile('repeaters.upd');
     end else begin
       helpline('Database updated... Please restart program. Press any key to continue.');
       deletefile('repeaters.sqlite');
       copyfile('repeaters.upd','repeaters.sqlite');
       deletefile('repeaters.upd');
       c:=readkey;
       index;
     end;
  end;
end;

procedure updateprogram;
var
   c:char;
   filec:string;
begin
{$IFDEF UNIX}
  filec:='repeaters';
{$ENDIF}
{$IFDEF WIN}
  filec:='repeaters.exe';
{$ENDIF}

  if DownloadHTTP('http://fugazigr.com/repeaters/'+filec,filec+'.upd')=false then begin
    helpline('Error while downloading program. Press any key to continue.');
    c:=readkey;
       index;
  end else begin
     if  MD5Print(MD5File(filec))= MD5Print(MD5File(filec+'.upd')) then begin
       helpline('No updates available. Press any key to continue.');
       c:=readkey;
       index;
       deletefile(filec+'.upd');
     end else begin
       helpline('Program updated... Please restart program. Press any key to continue.');
       deletefile(filec);
       copyfile(filec+'.upd',filec);
       deletefile(filec+'.upd');
       c:=readkey;
       index;
     end;
  end;
end;

procedure command(str:string);
var
  s:string;
  c:char;
  i1:integer;
  found:boolean;
  id,error:integer;
begin
  found:=false;
  s:=uppercase(str);
  if (pos('HELP',s)>0) or (pos('/H',s)>0) then begin
    inlinehelp;
    title:='Using: '+database+' [ Help ]';
    l.clear;
    i:=0;
    l.loadfromfile('output.txt');
    viewer(title);
    found:=true;
  end;
  if (pos('/SAVE',s)>0) then begin
    savetofile;
    found:=true;
  end;
  if (pos('/VERSION',s)>0) or (pos('/V',s)>0) then begin
     for i1:=2 to screenheight-2 do begin
       gotoxy(1,i1);clreol;
     end;
     gotoxy(1,2);
     logo;
     helpline('Press any key to continue...');
     readkey;
     //showcurrent;
     found:=true;
  end;
  if (pos('/INDEX',s)>0) or (pos('/I',s)>0) then begin
        index;
        found:=true;
        gotoxy(4,screenheight);
        end;
  if (pos('/DIR',s)>0) then begin
        found:=true;
        try
          listfiles;
          title:='Using: '+database+' [ List of files ]';
     	  l.clear;
	      l.loadfromfile('output.txt');
	      i:=0;
	      viewer(title);
	except
	  helpline('[e122] Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;
  if (pos('/AUDIO',s)>0) then begin
        found:=true;
        delete(s,pos('/AUDIO',s),6);
  	trim(s);
        val(s,id,error);
        if error=0 then begin
        try
			//rowid(id);
			ds.recno:=id;
			listenrecord(s);
			index;
		except
			helpline('[542] Error on command. Make sure you typed it correct. Any key to continue...');
			readkey;
        end;
    end;
  end;

  if (pos('/LIST',s)>0) or (pos('/L',s)>0)then begin
        found:=true;
        try
          listdatabases;
          title:='Using: '+database+' [ List of Databases ]';
     	  l.clear;
	      l.loadfromfile('output.txt');
	      i:=0;
	      viewer(title);
	except
	  helpline('[e112] Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;      
  if (pos('/OPEN',s)>0) or (pos('/O',s)>0)then begin
        found:=true;
        delete(s,pos('/OPEN',s),5);
        delete(s,pos('/O',s),2);
        s:=trim(s);
        try
          opendatabase(s);
          database:=uppercase(s);
          title:='Using: '+database+' [ Search Results ]';
          index;
	  l.clear;
	  l.loadfromfile('output.txt');
	  i:=0;
	  viewer(title);
	except
	  helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;
  if (pos('/CREATE',s)>0) or (pos('/CR',s)>0)then begin
        found:=true;
        delete(s,pos('/CREATE',s),7);
        delete(s,pos('/CR',s),3);
	s:=trimleft(trimright((s)));
        try
          createdatabase(s);
          database:=uppercase(s);
        except
	  helpline('[e103] Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
        title:='Using: '+database+' [ Search Results ]';
        index;
  end;
  if (pos('/REMOVE',s)>0) or (pos('/RM',s)>0)then begin
        found:=true;
        delete(s,pos('/REMOVE',s),7);
        delete(s,pos('/RM',s),3);
	s:=trimleft(trimright((s)));
        try
          deletedatabase(s);
          //database:=uppercase(s);
        except
	  helpline('[e109] Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
        title:='Using: '+database+' [ Search Results ]';
        index;
  end;
  if (pos('/CHIRP EXPORT',s)>0) or (pos('/CE',s)>0) then begin
    if found=true then exit else found:=true;
    title:='Using: '+database+' [ Export in CHIRP mode ]';
    chirpexport;
    l.clear;
    l.loadfromfile('output.txt');
    i:=0;
    viewer(title);
    end;
  if (pos('/CHIRP IMPORT',s)>0) or (pos('/CI',s)>0) then begin
    if found=true then exit else found:=true;
    title:='Using: '+database+' [ Import from CHIRP mode ]';
    chirpimport;
    index;
    end;
  if (pos('/GQRX EXPORT',s)>0) or (pos('/GE',s)>0) then begin
    if found=true then exit else found:=true;
    title:='Using: '+database+' [ Export in GQRX mode ]';
    gqrxexport;
    l.clear;
    l.loadfromfile('output.txt');
    i:=0;
    viewer(title);
    end;
  if (pos('/GQRX IMPORT',s)>0) or (pos('/GI',s)>0) then begin
    if found=true then exit else found:=true;
    title:='Using: '+database+' [ Import from GQRX mode ]';
    gqrximport;
    index;
    end;
  if (pos('/UPDATE',s)>0) or (pos('/U',s)>0) then begin
    if found=true then exit else found:=true;
    //title:='CHIRP export file as .csv';
    updatedatabase;
    updateprogram;
    //l.clear;
    //l.loadfromfile('output.txt');
    //i:=0;
    //viewer(title);
    end;        
  if (pos('/SEARCHLOC',s)>0) or (pos('/SL',s)>0) then begin
        found:=true;
        delete(s,pos('/SEARCHLOC',s),10);
        delete(s,pos('/SL',s),3);
	s:=trim(s);
        try
          title:='Using: '+database+' [ Search Results ]';
          searchrepeaters('location',s);
	  l.clear;
	  l.loadfromfile('output.txt');
	  i:=0;
	  viewer(title);
	except
	  helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;
  if (pos('/SEARCHID',s)>0) or (pos('/SI',s)>0) then begin
        found:=true;
        delete(s,pos('/SEARCHID',s),9);
        delete(s,pos('/SI',s),3);
	s:=trim(s);
        try
          title:='Using: '+database+' [ Search Results ]';
          searchrepeaters('id',s);
	  l.clear;
	  l.loadfromfile('output.txt');
	  i:=0;
	  viewer(title);
	except
	  helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;
  if (pos('/SEARCHTAG',s)>0) or (pos('/STAG',s)>0) then begin
        found:=true;
        delete(s,pos('/SEARCHTAG',s),10);
        delete(s,pos('/STAG',s),5);
	s:=trim(s);
        try
          title:='Using: '+database+' [ Search Results ]';
          searchrepeaters('tags',s);
	  l.clear;
	  l.loadfromfile('output.txt');
	  i:=0;
	  viewer(title);
	except
	  helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;
  if (pos('/SEARCHGROUP',s)>0) or (pos('/SG',s)>0) then begin
        found:=true;
        delete(s,pos('/SEARCHGROUP',s),12);
        delete(s,pos('/SG',s),3);
	s:=trim(s);
        try
          title:='Using: '+database+' [ Search Results ]';
          searchrepeaters('groupo',s);
	  l.clear;
	  l.loadfromfile('output.txt');
	  i:=0;
	  viewer(title);
	except
	  helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;
  if (pos('/EDIT',s)>0) or (pos('/E',s)>0) then begin
        found:=true;
        delete(s,pos('/EDIT',s),5);
        delete(s,pos('/E',s),2);
	    trim(s);
        val(s,id,error);
        if error=0 then begin
        try
			//rowid(id);
			ds.recno:=id;
			updaterecord(s);
			index;
		except
			helpline('Error on command. Make sure you typed it correct. Any key to continue...');
			readkey;
        end;
    end;
  end;
  if (pos('/ADD',s)>0) or (pos('/A',s)>0) then begin
        found:=true;
        delete(s,pos('/ADD',s),4);
        delete(s,pos('/A',s),2);
	insertrecord('s');
        index;
  end;
  if (pos('/DEL',s)>0) or (pos('/D',s)>0) then begin
        found:=true;
        delete(s,pos('/DEL',s),4);
        delete(s,pos('/D',s),2);
        trim(s);
        val(s,id,error);
        if error=0 then begin
        try
			//rowid(id);
			ds.recno:=id;
			deleterecord(s);
			index;
		except
			helpline('Error on command. Make sure you typed it correct. Any key to continue...');
			readkey;
        end;
    end;
  end;
  if (pos('/SEARCHTONE',s)>0) or (pos('/ST',s)>0) then begin
        found:=true;
        delete(s,pos('/SEARCHTONE',s),11);
        delete(s,pos('/ST',s),3);
	s:=trim(s);
        try
          title:='Using: '+database+' [ Search Results ]';
          searchrepeaters('tone',s);
	  l.clear;
	  l.loadfromfile('output.txt');
	  i:=0;
	  viewer(title);
	except
	  helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;
  if (pos('/SEARCHSHIFT',s)>0) or (pos('/SS',s)>0) then begin
        found:=true;
        delete(s,pos('/SEARCHSHIFT',s),12);
        delete(s,pos('/SS',s),3);
	s:=trim(s);
        try
          title:='Using: '+database+' [ Search Results ]';
          searchrepeaters('shift',s);
	  l.clear;
	  l.loadfromfile('output.txt');
	  i:=0;
	  viewer(title);
	except
	  helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;
  if (pos('/SEARCHWIDE',s)>0) or (pos('/SW',s)>0) then begin
        found:=true;
        delete(s,pos('/SEARCHWIDE',s),11);
        delete(s,pos('/SW',s),3);
	s:=trim(s);
        try
          title:='Using: '+database+' [ Search Results ]';
          searchrepeaters('wide',s);
	  l.clear;
	  l.loadfromfile('output.txt');
	  i:=0;
	  viewer(title);
	except
	  helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;
  if (pos('/SEARCHFREQ',s)>0) or (pos('/SF',s)>0) then begin
        found:=true;
        delete(s,pos('/SEARCHFREQ',s),11);
        delete(s,pos('/SF',s),3);
	s:=trim(s);
        try
          title:='Using: '+database+' [ Search Results ]';
          searchrepeaters('freq',s);
	  l.clear;
	  l.loadfromfile('output.txt');
	  i:=0;
	  viewer(title);
	except
	  helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
  end;
  (*
  if (pos('/TOPIC',s)>0) or (pos('/T',s)>0) then begin
        found:=true;
        delete(s,pos('/TOPIC',s),6);
        delete(s,pos('/T',s),2);
	trim(s);
        val(s,id,error);
        if error=0 then begin
	try
	  title:=database+ '> '+gettopictitle(id);
          showtopic(id);
	  l.clear;
	  l.loadfromfile('output.txt');
	  i:=0;
	  viewer(title);
	except
	  helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
        end;
  end;
  *)
  if (pos('/SHOW',s)>0) or (pos('/S',s)>0) then begin
        found:=true;
        delete(s,pos('/SHOW',s),5);
        delete(s,pos('/S',s),2);
	s:=trim(s);
        val(s,id,error);
        if error=0 then begin
        try
          title:='Using: '+database+' [ Record Details ]';
          ds.recno:=id;
          topline(title);
          showrecord;
          l.clear;
       	  l.loadfromfile('output.txt');
          i:=0;
	  viewer(title);
        except
          helpline('Error on command. Make sure you typed it correct. Any key to continue...');
	  readkey;
        end;
       end;
  end;
  if (pos('/REPEATERS ID',s)>0) or (pos('/R ID',s)>0) then begin
    found:=true;
    title:='Using: '+database+' [ Index Ordered by Callsign ]';
    showrepeaters('id');
    l.clear;
    l.loadfromfile('output.txt');
    i:=0;
    viewer(title);
  end;
  if (pos('/REPEATERS TAG',s)>0) or (pos('/R TAG',s)>0) then begin
    found:=true;
    title:='Using: '+database+' [ Index Ordered by Tags ]';
    showrepeaters('tags');
    l.clear;
    l.loadfromfile('output.txt');
    i:=0;
    viewer(title);
  end;
  if (pos('/REPEATERS GROUP',s)>0) or (pos('/R GROUP',s)>0) then begin
    found:=true;
    title:='Using: '+database+' [ Index Ordered by Group ]';
    showrepeaters('groupo');
    l.clear;
    l.loadfromfile('output.txt');
    i:=0;
    viewer(title);
  end;
  if (pos('/REPEATERS LOC',s)>0) or (pos('/R LOC',s)>0) then begin
    found:=true;
    title:='Using: '+database+' [ Index Ordered by Location ]';
    showrepeaters('location');
    l.clear;
    l.loadfromfile('output.txt');
    i:=0;
    viewer(title);
  end;
  if (pos('/REPEATERS TONE',s)>0) or (pos('/R TONE',s)>0) then begin
    found:=true;
    title:='Using: '+database+' [ Index Ordered by Tone ]';
    showrepeaters('tone');
    l.clear;
    l.loadfromfile('output.txt');
    i:=0;
    viewer(title);
  end;
  if (pos('/REPEATERS FREQ',s)>0) or (pos('/R FREQ',s)>0) then begin
    found:=true;
    title:='Using: '+database+' [ Index Ordered by Frequency ]';
    showrepeaters('freq');
    l.clear;
    l.loadfromfile('output.txt');
    i:=0;
    viewer_x:=1;
    viewer(title);
  end;

  if (pos('/REPEATERS',s)>0) or (pos('/R',s)>0) then begin
    if found=true then exit else found:=true;
    title:='Using: '+database+' [ Index ]';
    showrepeaters('name');
    l.clear;
    l.loadfromfile('output.txt');
    i:=0;
    viewer(title);

  end;

  if (pos('/EXIT',s)>0) or (pos('/X',s)>0) then begin
    found:=true;
    helpline('Are you sure? (y/n)');gotoxy(4,screenheight);c:=readkey;if uppercase(c)='Y' then
    	begin
          program_exit;
        end;
    helpline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.');
    textcolor(theme.posttext);
  end;
  if found=false then baseline('Command not found...');

  textcolor(theme.posttext);
  textbackground(black);
  gotoxy(4,screenheight);

end;

begin
  if (uppercase(paramstr(1))='--HELP') or (uppercase(paramstr(1))='-H') or (uppercase(paramstr(1))='/?') or (uppercase(paramstr(1))='/H')then writehelp;
  {$ifdef windows}
  cp:=getconsoleoutputcp;
  setconsoleoutputcp(cp_utf8);
  {$endif}

  loadsettings;
  defscreen;
  kbbuf:='';
  leave:=false;
  ds := TSqlite3Dataset.Create(nil);
  history:=tstringlist.create;
  history_index:=0;
  l:=tstringlist.create;
  greek:=true;
  opendatabase('repeaters');
  i:=0;
  d:=0;
  //writeln(screenwidth,' ',screenheight);
  //l.loadfromfile('phpbb2sqlite.pas');
  //viewer('asd');
  index;
  //viewer('Viewing forum #'+s);
  topline('[] Repeaters');
  viewer('[] Repeaters');
  baseline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.');
  repeat
    ch:=readkey;
    //writeln(ord(ch));
    case ch of
    '[': begin
    		if (history_index>0) and (history.count>0) then begin
                history_index:=history_index-1;
                baseline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.');
                write(history[history_index]);
                kbbuf:=history[history_index];
                end;
        end;
    ']': begin
    		if (history_index<history.count-1) and (history.count>0) then begin
                history_index:=history_index+1;
                baseline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.');
                write(history[history_index]);
                kbbuf:=history[history_index];
                end;
        end;
    #77: begin //right
			viewer_x:=viewer_x+1;
            viewer(title);
		end;    
	#75: begin //left
			viewer_x:=viewer_x-1;
			if viewer_x<1 then viewer_x:=1;
            viewer(title);
			end;
    #8:  begin
			gotoxy(4,screenheight);
			write(stringofchar(' ',length(kbbuf)));
           		delete(kbbuf,length(kbbuf),1);
           		gotoxy(4,screenheight);
           		write(kbbuf);
		 end;
    #72: begin
			if i-1<0 then i:=0 else i:=i-1;
                        viewer_pos;
                        viewer(title);
		 end;  //Up key
    #80: begin
			if i+screenheight-2>l.count-1 then i:=i else i:=i+1;  //Down Key
                        viewer_pos;
                        viewer(title);
		 end;
    #81: begin
			if i+((screenheight-2)*2)>l.count-1 then i:=l.count-screenheight-3 else i:=i+((screenheight-2)*2);  //Page Down
                        if l.count<screenheight-3 then i:=0;
                        viewer_pos;
                        viewer(title);
		 end;
    #73: begin
			if i-screenheight-2<0 then i:=0 else i:=i-screenheight-2;  //Page Up
                        viewer_pos;
                        viewer(title);
		 end;
    #27: begin //esc
			helpline('Are you sure? (y/n)');gotoxy(4,screenheight);if uppercase(readkey)='Y' then
    	begin
          program_exit;
        end;
    helpline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.');
    textcolor(theme.posttext);
		 end;
    #13: begin
           //process command
           baseline('Use Up,Down Arrow keys, Page Up/Down. Type ''help'' for available commands.');
           command(kbbuf);
           history.add(kbbuf);
           history_index:=history.count;
           kbbuf:='';
           end;
    #32,#47,#48,#49,#50,#51,#52,#53,#54,#55,#56,#57: begin
           write(ch);
           kbbuf:=kbbuf+ch;
           end;
    #97,#98,#99,#100,#101,#102,#103,#104,#105,#106,#107,#108,#109,#110,#111,#112,#113,#114,#115,#116,#117,#118,#119,#120,#121,#122:begin
    	 write(ch);
         kbbuf:=kbbuf+ch;
         end;
    //#65,#66,#67,#68,#69,#70,#71,#74,#76,#78,#79,#82,#83,#84,#85,#86,#87,#88,#89,#90:begin
    //	 write(ch);
    //     kbbuf:=kbbuf+ch;
    //     end;
    end;
    until leave=true;
    clrscr;
end.

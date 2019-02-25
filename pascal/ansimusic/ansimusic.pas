{
        __  _                        __ _                           _  __
  ______\ \_\\_______________________\///__________________________//_/ /______
  \___\                                                                   /___/
   | .__                                 __                                  |
   | |                   ___  __________/  |________                         |
   |                     \  \/  / ____/\   __\_  __ \                        |
   ;                      >    < <_|  | |  |  |  | \/                        ;
   :                     /__/\_ \__   | |__|  |__|                           :
   .                           \/  |__|                                      .
   .                                                                         .
   .                             xqtr@gmx.com                                .   
   :        https://github.com/xqtr   ::   https://paypal.me/xqtr            :
   ;                                                                         ;
   + --- --  -   .     -        ---    ---    ---        -     .    - -- --- +
   
    This is a test program to play the old style, ansi music, with the help of
    SOX in linux machines. It doesn't work 100% but its too close, cause there
    are some undocumented areas in the ansi music format, like the < > chars.
    and the Txxx command. Whats the Tempo in ansi music, anyway?
   
    If someone knows more about, let me know. Also... i don't know shit about
    music, so the notes maybe different than the original. 
     
    The idea is to translate the ANSI music notes, to a SOX frequency that can
    play. While playing the music, you will hear a noise from SOX when it
    starts and exits. I had the same idea to use SOX, as in this link:
    https://stackoverflow.com/questions/13760504/generate-tones-of-specific-
    frequency-on-mac-command-line 
    Which i used to make the Playtone procedure, cause as i said... i ain't 
    know shit about music.. :)
  
}

program ansimusic;

uses
  crt,
  math,
  unix,
  sysutils;

var
  f   : text;
  b   : byte;
  c   : char;
  st  : string;
  
  Octave        : Byte = 4;
  ConstDuration : Real = 0.5;
  Duration      : Real =0;
  LDur          : Byte;

Function Real2Str (R : Real; D:Byte) : String;
  Var S : String;
begin
 Str (R:10:d,S);
 
 Real2Str:=S;
end;    
    
procedure playtone(n:string; dur:real; oct:byte);
const
  temp = 1.0594630943592952646;
  A4   = 440;
var
  note_int:byte;
  A0 : Real;
  C0 : Real;
  HZ : Real;
  i:byte;
begin
  for i:=1 to Length(n) Do
    n[i]:=Upcase(n[i]);
  case n of
    'A'  :  note_int:=10;
    'A#' :  note_int:=11;
    'A-' :  note_int:=9;
    'B'  :  note_int:=12;
    'B#' :  note_int:=13;
    'B-' :  note_int:=11;
    'C'  :  note_int:=0;
    'C#' :  note_int:=1;
    'C-' :  note_int:=13;
    'D'  :  note_int:=2;
    'D#' :  note_int:=3;
    'D-' :  note_int:=1;
    'E'  :  note_int:=4;
    'E#' :  note_int:=5;
    'E-' :  note_int:=3;
    'F'  :  note_int:=6;
    'F#' :  note_int:=7;
    'F-' :  note_int:=5;
    'G'  :  note_int:=8;
    'G#' :  note_int:=9;
    'G-' :  note_int:=7;
  end;
  A0 := A4 / 16;
  C0 := A0 * ( 1 / temp)**9;
  HZ := C0*Power(2,oct+1) * Power(temp,note_int);
  //HZ:=$( bc -l <<< "$C0_HZ * 2^$OCTAVE * $EQL_TEMPERAMENT ^ $NOTE_INT" )
  fpsystem('play -n synth '+Real2Str(dur,8)+' sin '+Real2Str(hz,8)+' 2>/dev/null');
end;    
  
Procedure ProcessMusic(Music:string);
Var
  snum:string;
  Count:Word;
  TCount:Word;
  Note:String;
Begin
  Count:=1;
  While Count <= Length(Music) Do Begin
  
    if keypressed then begin
      halt;
    end;
  
  
    Write(Music[Count]);
    if (Music[Count]=#27) and (Music[Count+1]='F') Then Count:=Count+2;
    Case Music[Count] Of
      #27 : Count:=Count+1;
      '[' : Count:=Count+1;
      'L' : Begin
              TCount:=Count+1;
              SNum:='';
              While (Music[TCount] in ['0'..'9']) and (TCount<=Length(Music)) Do Begin
                snum:=snum+Music[TCount];
                TCount:=TCount+1;  
              End;
              If snum='' Then LDur:=1 Else Begin
                Count:=TCount;
                LDur := StrToInt(snum);
                Duration := ConstDuration / LDur;
              End;
            End;
      'T' : Begin
              TCount:=Count+1;
              SNum:='';
              While (Music[TCount] in ['0'..'9']) and (TCount<=Length(Music)) Do Begin
                snum:=snum+Music[TCount];
                TCount:=TCount+1;  
              End;
              If snum='' Then LDur:=1 Else Begin
                Count:=TCount;
                LDur := StrToInt(snum);
                Duration := ConstDuration / LDur;
              End;
            End;
      'O' : Begin
              Count:=Count+1;
              Octave:=StrToInt(Music[Count]);
              //Count:=Count+1;
            End;
      'M' : bEGIN
              Count:=Count+1;
              Case Music[Count+1] Of
                'L' : Begin
                        LDur:=1;
                        Duration := ConstDuration / LDur;
                      End;
                'F' : ;
                'B' : ;
                'N' : Duration := (ConstDuration / LDur) * (7/8);
                'S' : Duration := (ConstDuration / LDur) * (3/4);
              End;
              
              Count:=Count+1;
            End;
      'P' : Begin
              TCount:=Count+1;
              SNum:='';
              While (Music[TCount] in ['0'..'9']) and (TCount<=Length(Music)) Do Begin
                snum:=snum+Music[TCount];
                TCount:=TCount+1;  
              End;
              Count:=TCount-1;
              Duration := ConstDuration / StrToInt(snum);
              Delay(Trunc(Duration));
            End;
      'N' : Begin
              Duration := (ConstDuration / LDur) * (7/8);
              COunt:=COunt+1;
            End;
      'S' : Begin
              Duration := (ConstDuration / LDur) * (3/4);
              COunt:=COunt+1;
            End;
      'A'..'G' 
          : Begin
              Note:=Music[Count];
              If Count+1<=Length(Music) Then Begin
                if Music[Count+1] in ['#','+','-','.'] Then
                  Case Music[Count+1] Of
                    '+' : Begin 
                            Note:=Note+'#';
                            COunt:=COunt+1;
                            PlayTone(Note,Duration,Octave);
                          End;
                    '#' : Begin 
                            Note:=Note+'#';
                            COunt:=COunt+1;
                            PlayTone(Note,Duration,Octave);
                          End;
                    '-' : Begin 
                            Note:=Note+'-';
                            COunt:=COunt+1;
                            PlayTone(Note,Duration,Octave);
                          End;
                    '.' : Begin 
                            COunt:=COunt+1;
                            PlayTone(Note,Duration+(Duration/2),Octave);
                          End;
                  End
                else PlayTone(Note,Duration+(Duration/2),Octave);
              
              End;
              COunt:=COunt+1;
            End;
  Else
      Count:=Count+1;
    End;
    
  
  
  End;
End;  
  
procedure demo;  
begin
  ProcessMusic('MFT225O3L8GL8GL8GL2E-P8L8FL8FL8FML2DL2DP8');
  ProcessMusic('MFO3L8GL8GL8GL8E-L8A-L8A-L8A-L8GO4L8E-L8E-L8E-MLL2C');
  ProcessMusic('MFL8CMNO3L8GL8GL8GL8DL8A-L8A-L8A-L8GO4L8FL8FL8FMLL2DL2DMN');
  ProcessMusic('MFO4L8GL8GL8FL8E-O3L8E-L8E-L8FL8GO4L8GL8GL8FL8E-O3L8E-L8E-');
  ProcessMusic('MFL8FL8GO4L8GL8GL8FL8E-P4L8CP4L1GO3L8A-L8A-L8A-MLL2FL2FMN');
  ProcessMusic('MFP8O3L8A-L8A-L8A-L8FL8DL8DL8DO2L8BL8A-L8A-L8A-L8GO1L8GL8');
  ProcessMusic('MFGL8GL8CO3L8A-L8A-L8A-L8FL8DL8DL8DO2L8B-L8A-L8A-L8A-L8GO1');
  ProcessMusic('MFL8GL8GL8GL8CO3L8GO4L8CL8CL2CO3L8BL8BL8BO4L8DL2DL8DL8DL8D');
  ProcessMusic('MFL8E-L8E-L8DL8DL8FL8FL8EL8E-L8GT50O4L8GL8FL8FL8A-L8A-L8G');
  ProcessMusic('MFL8GL8B-L8B-L8A-L8A-L8CL8CL8BL8B-L8DL8CL8E-L8E-L8E-L8CL8');
  ProcessMusic('MFGL8GL8GL8E-L8CO3L8GL8GL8E-L8CL8CL8CO2L8B-O4L8FL8E-L8E-L8');
  ProcessMusic('MFBL8GL8FL8FL8DO3L8BL8GL8FL8DO2L8BO3L8CL8CL8CO4L8E-L8E-');
end;  
  
begin
  if (paramstr(1)='DEMO') or (paramstr(1)='demo') then begin
    demo;
    exit;
  end;  
  if not fileexists(paramstr(1)) then begin
    writeln;
    writeln('File doesn''t exist. Aborting...');
    writeln('execute like this to hear a demo:');
    writeln('#> ./ansimus demo');
    writeln;
    exit;
  end;
  writeln('Get more songs here: http://artscene.textfiles.com/ansimusic/songs/');  
  writeln('Press key to abort...');
  assign(f,paramstr(1));
  reset(f);
  While not eof(f) do begin
    readln(f,st);
    if st[1]=#27 then processmusic(st);
    writeln;
  end;
  close(f);
end.

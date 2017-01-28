program fppower;


{
Rtl_power produces a compact CSV file with minimal redundancy. The columns are:

date, time, Hz low, Hz high, Hz step, samples, dB, dB, dB, ...

Date and time apply across the entire row. The exact frequency of a dB value can be found by (hz_low + N * hz_step). The samples column indicated how many points went into each average.
}

{$GOTO ON}  

{$mode objfpc}{$H+}
{$IFDEF Linux}
  {$DEFINE Unix}
  {$ENDIF}

uses
  sysutils,math,strutils,ccsv;
  
  var
	mycsv : tcsv;
	r,c:integer;
	v:float;
	freq,vs,s:string;
	i:integer;
	format,evaluate:string;
	tmptime:string;
	log:boolean;
	
//Logvalue freq,first_date,first_time,last_date,last_time,last_db,peak,occurances

procedure logvalues(filename:string; freq,stime,sdate,db:string);
var
	logcsv:tcsv;
	i,f:integer;
	p:float;
	found:boolean;
	S : AnsiString;
begin
  //Create csv object
  logcsv := TCsv.Create(filename);

  with logcsv do
  begin
    Delimiter := ';';
    OpenCsv();
    //Check if open
    if MyCsv.IsOpen then
    begin
		found:=false;
		for i:=0 to recordcount-1 do begin
			if GetFieldValue(i,0)=freq then begin
				found:=true;
				f:=i;
				break;
			end;
		end;
		if found=true then begin //found
			SetFieldValue(f,3,sdate);
			SetFieldValue(f,4,stime);
			if strtofloat(getfieldvalue(f,6))<strtofloat(db) then setfieldvalue(f,6,db);
			SetFieldValue(f,5,db);
			p:=strtofloat(getfieldvalue(f,7))+1;
			setfieldvalue(f,7,floattostr(p));
		end else begin //not found
			DateTimeToString(s,'YYYY-MM-DD',Date);
			AddRecord(freq+';'+s+';'+timetostr(time)+';'+sdate+';'+stime+';'+db+';'+db+';1;');
		end;
		UpdateCsv;
		savecsv(filename);
    end;
  end;

end;	
  
procedure writecsvdata(filename:string; str:string);
  var
    filevar:textfile;
  begin
    assignfile(filevar,filename);
    {$I+}
    try
      rewrite(filevar);
      writeln(filevar,str);
      closefile(filevar);
    except
      on E: EInOutError do
        begin
          writeln('File error');
        end;
      end;
    end;
  
  procedure checkvalues(cvsfile:string);
  begin
  //Create csv object
  MyCsv := TCsv.Create(cvsfile);

  with mycsv do
  begin
    Delimiter := ',';
    OpenCsv();
    //Check if open
    if MyCsv.IsOpen then
    begin
      for r := 0 to RecordCount - 1 do begin
      if format='SPECTRUM' then begin 
		if tmptime<>GetFieldValue(r, 1) then begin
			writeln('Time: ',GetFieldValue(r, 1));
			tmptime:=GetFieldValue(r, 1);
		end;
	  end;
		for c := 6 to fieldcount -1 do 
		begin
			//Show first name.
			try
				v:=strtofloat(GetFieldValue(r,c));
				case evaluate of
					'MORE' : begin
						if v > strtofloat(paramstr(1)) then begin
						freq:=FormatFloat('#,##0.00;;Zero',strtofloat(GetFieldValue(r, 2)) + strtofloat(GetFieldValue(r, 4)) * c);
						vs:=FormatFloat('#,##0.00;;Zero',v);
						case format of
							'NORMAL': begin
								writeln('[',GetFieldValue(r, 0),' / ',GetFieldValue(r, 1),'] Freq: ',freq,' Hz, Value: ', vs);
							end;
							'CSV' : begin
								writeln(GetFieldValue(r, 0),';',GetFieldValue(r, 1),';',freq,';', vs);
							end;
							'SPECTRUM' : begin
								writeln(freq,'| ',dupestring('#',round(30+(v*40/30))),vs);
							end;
						end;
						end;	
						if log then logvalues('./fppower_log.csv',freq,GetFieldValue(r, 1),GetFieldValue(r, 0),vs);
						
					end;
					'LESS' : begin
						if v < strtofloat(paramstr(1)) then begin
						freq:=FormatFloat('#,##0.00;;Zero',strtofloat(GetFieldValue(r, 2)) + strtofloat(GetFieldValue(r, 4)) * c);
						vs:=FormatFloat('#,##0.00;;Zero',v);
						case format of
							'NORMAL': begin
								writeln('[',GetFieldValue(r, 0),' / ',GetFieldValue(r, 1),'] Freq: ',freq,' Hz, Value: ', vs);
							end;
							'CSV' : begin
								writeln(GetFieldValue(r, 0),';',GetFieldValue(r, 1),';',freq,';', vs);
							end;
							'SPECTRUM' : begin
								writeln(freq,'| ',dupestring('#',round(30+(v*40/30))),vs);
							end;
						end;
						end;	
						if log then logvalues('./fppower_log.csv',freq,GetFieldValue(r, 1),GetFieldValue(r, 0),vs);
					end;
				end;
				
			except
				writeln('Conversion error [021]');
			end;
		end;
	  end;	
    end;
  end;
  end;
  
  procedure helpscreen;
  begin
	writeln;
	writeln('Filter rtl_power results to get active frequencies.');
	writeln;
	writeln('[] Usage:');
	writeln('      fppower <value> [filename] [options]');
	writeln;
	writeln('      <value>    : float number, indicates strength of signal from rtl_power');
	writeln('      [filename] : file to get values from. Leave empty to get values from stdin');
	writeln;
	writeln('[] Options');
	writeln('      -csv       : Format output as CSV');
	writeln('      -spectrum  : Display results like a spectrum analyzer');
	writeln('      -more      : Value is over, target value [default]');
	writeln('      -less      : Value is under, target value');
	writeln('      -log       : keeps a log file, with found results');
	writeln;
	writeln('[] Example:');
	writeln('      fppower -40 rtlpower.csv');
	writeln('      rtl_power -f 146M:175M:5k | ./fppower -40');
	writeln('      fppower -40 rtlpower.csv -csv -less');
	writeln('      rtl_power -f 119M:175M:2k | ./fppower 1 -more -csv | cut -d '';'' -f3');
	writeln('      rtl_power -f 119M:175M:2k | ./fppower 2 -log');
	writeln;
	writeln('[] Log file');
	writeln('       The log file (fppower_log.csv) is a CSV file with the results that match');
	writeln('       the criteria. This file is for searches, so if you want a different file');
	writeln('       for each search, you must copy the existing one');
	writeln;
  end;
  
begin
	format:='NORMAL';
	evaluate:='MORE';
	tmptime:='';
	log:=false;
	
	
	if paramcount<1 then begin
		helpscreen;
		exit;
		end;
		
	try
		strtofloat(paramstr(1));
	except
		helpscreen;
		exit;
	end;

	if paramcount>=2 then begin
		for i:=2 to paramcount do begin
			if uppercase(paramstr(i))='-CSV' then format:='CSV';
			if uppercase(paramstr(i))='-SPECTRUM' then format:='SPECTRUM';
			if uppercase(paramstr(i))='-LESS' then evaluate:='LESS';
			if uppercase(paramstr(i))='-MORE' then evaluate:='MORE';
			if uppercase(paramstr(i))='-LOG' then log:=true;
		end;
	end;
	
	
	if not fileexists(paramstr(2)) then begin
		while not EOF do begin
			ReadLn(s);
			writecsvdata('./tmp.csv',s);
			checkvalues('./tmp.csv');
		end;
	end else begin
		checkvalues(paramstr(2));
	end;
end.

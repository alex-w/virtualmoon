unit dbutil;
{
  This file is to be maintened in datlun
  and copied to virtualmoon if changed
}
{
Copyright (C) 2006 Patrick Chevalley

http://www.ap-i.net
pch@ap-i.net

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}
{$MODE objfpc}
{$H+}

interface

Uses Forms, Dialogs, Classes, SysUtils, passql, passqlite;

const
    DBversion=900;
    DBnotesversion=800;
    DBname='dbmoon9';
    DBnamenotes='dbnotes';
    MaxDB=99;
    MaxDBN=200;
    UserDBN=100;
    ConnectDBN=500;
    MaxConnectDBN=100;
    NumMoonDBFields = 52;
    MoonDBFields : array[1..NumMoonDBFields,1..2] of string = (
      ('NAME','text'),
      ('LUN','text'),
      ('NAME_TYPE','text'),
      ('IAU_TYPE','text'),
      ('TYPE','text'),
      ('SUBTYPE','text'),
      ('PROCESS','text'),
      ('PERIOD','text'),
      ('PERIOD_SOURCE','text'),
      ('GEOLOGY','text'),
      ('NAME_DETAIL','text'),
      ('NAME_ORIGIN','text'),
      ('IAU_APPROVAL','text'),
      ('LANGRENUS','text'),
      ('HEVELIUS','text'),
      ('RICCIOLI','text'),
      ('WORK','text'),
      ('COUNTRY','text'),
      ('NATIONLITY','text'),
      ('CENTURY_N','float'),
      ('CENTURY_C','text'),
      ('BIRTH_PLACE','text'),
      ('BIRTH_DATE','text'),
      ('DEATH_PLACE','text'),
      ('DEATH_DATE','text'),
      ('FACTS','text'),
      ('LONGI_N','float'),
      ('LONGI_N_360','float'),
      ('LONGI_C','text'),
      ('LATI_N','float'),
      ('LATI_C','text'),
      ('FACE','text'),
      ('QUADRANT','text'),
      ('AREA','text'),
      ('LENGTH_KM','float'),
      ('WIDE_KM','float'),
      ('LENGTH_ARCSEC','float'),
      ('HEIGHT_M','float'),
      ('RAPPORT','float'),
      ('GENERAL_1','text'),
      ('GENERAL_2','text'),
      ('SLOPES','text'),
      ('WALLS','text'),
      ('FLOOR','text'),
      ('INTEREST_N','integer'),
      ('INTEREST_C','text'),
      ('LUNATION','integer'),
      ('MOONDAY_S','text'),
      ('MOONDAY_M','text'),
      ('DIAM_INST','integer'),
      ('TH_INSTRU','text'),
      ('PR_INSTRU','text')
      );
    FDBN=1;
    FNAME=2;
    FLONGIN=28;
    FLATIN=31;
    FWIDEKM=37;
    FGENERAL1=41;
    SimplifiedDBN=100;

var
    sidelist: string;
    database : array[1..MaxDB] of string;
    usedatabase :array[1..MaxDBN] of boolean;
    connectdatabase : array[1..MaxConnectDBN] of string;
    useconnectdatabase : array[1..MaxConnectDBN] of boolean;
    ConnectDBCols: array[1..MaxConnectDBN] of TStringList;

Procedure ListDB;
Procedure LoadDB(dbm: TLiteDB);
Procedure LoadConnectDB(dbm: TLiteDB);
procedure LoadConnectDBcols;
Procedure CreateDB(dbm: TLiteDB);
Procedure ConvertDB(dbm: TLiteDB; fn,side:string);
procedure DBjournal(dbname,txt:string);
Procedure LoadLopamIdx(fn,path:string; dbm: TLiteDB);
function LoadNotelunDB(db: TLiteDB): integer;

implementation

Uses  u_constant, u_util, fmsg;

Procedure CreateDB(dbm: TLiteDB);
var i,dbv: integer;
    cmd,buf: string;
    ok:boolean;
begin
ok:=dbm.query('select name from moon order by name LIMIT 1;');  // try to detect corrupt database file
buf:=dbm.QueryOne('select version from dbversion;');
dbv:=StrToIntDef(buf,0);
if (dbv<DBversion)or(not ok) then begin
 buf:=dbm.DataBase;
 dbm.Close;
 if FileExists(buf) then DeleteFile(buf);
 dbm.DataBase:=buf;
 cmd:='create table moon ( '+
    'ID INTEGER PRIMARY KEY,'+
    'DBN integer';
 for i:=1 to NumMoonDBFields do begin
   cmd:=cmd+','+MoonDBFields[i,1]+' '+MoonDBFields[i,2];
 end;
 cmd:=cmd+');';
 dbm.Query(cmd);
 if dbm.LastError<>0 then dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
 dbm.Query('create index moon_pos on moon (long_in,lat_in);');
 dbm.Query('create index moon_name on moon (dbn,name);');
 dbjournal(extractfilename(dbm.database),'CREATE TABLE MOON');

 cmd:='create table file_date ( '+
    'DBN integer,'+
    'FDATE integer'+
    ');';
 dbm.Query(cmd);
 if dbm.LastError<>0 then dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
 dbjournal(extractfilename(dbm.database),'CREATE TABLE FILE_DATE');

 cmd:='create table user_database ( '+
    'DBN integer,'+
    'NAME text'+
    ');';
 dbm.Query(cmd);
 if dbm.LastError<>0 then dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
 dbjournal(extractfilename(dbm.database),'CREATE TABLE USER_DATABASE');

 cmd:='create table dbversion ( '+
    'version integer'+
    ');';
 dbm.Query(cmd);
 cmd:='insert into dbversion values('+inttostr(DBversion)+');';
 dbm.Query(cmd);
 if dbm.LastError<>0 then dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
 dbjournal(extractfilename(dbm.database),'CREATE TABLE DBVERSION');
end;
end;

Procedure ConvertDB(dbm: TLiteDB; fn,side:string);
var cmd,v,buf,fnn,dbv: string;
    i,imax,ii,j,n:integer;
    hdr,row: TStringList;
    f: TextFile;
    idx: array[0..NumMoonDBFields] of integer;
begin
if MsgForm=nil then Application.CreateForm(TMsgForm, MsgForm);
MsgForm.Label1.caption:=ExtractFileName(fn)+crlf+'Preparing Database. Please Wait ...';
msgform.show;
msgform.Refresh;
application.ProcessMessages;
hdr:=TStringList.Create;
row:=TStringList.Create;
dbv:=dbm.QueryOne('select version from dbversion;');
dbm.Query('update dbversion set version=0;');
try
AssignFile(f,fn);
Reset(f);
ReadLn(f,buf);
SplitRec2(buf,';',hdr);
dbm.Query('PRAGMA journal_mode = MEMORY');
dbm.Query('PRAGMA synchronous = OFF');
dbm.StartTransaction;
dbm.Query('delete from moon where DBN='+side+';');
dbm.Commit;
dbjournal(extractfilename(dbm.database),'DELETE ALL DBN='+side);
v:='';
for i:=1 to NumMoonDBFields do begin
  ii:=hdr.IndexOf(MoonDBFields[i,1]);
  idx[i]:=ii;
  if ii<0 then v:=v+MoonDBFields[i,1]+'; ';
end;
if v>'' then dbjournal(extractfilename(dbm.database), fn+' missing fields: '+v);
dbm.StartTransaction;
n:=0;   // single file
j:=0;
fnn:=fn;
repeat
  repeat
    ReadLn(f,buf);
    SplitRec2(buf,';',row);
    if row.Count<>hdr.Count then begin
      dbjournal(extractfilename(fnn), ' skip bad record: '+copy(buf,1,20)+' fields='+inttostr(row.Count)+' expected='+inttostr(hdr.Count));
      continue;
    end;
    cmd:='insert into moon values(NULL,'+side+',';
    for i:=1 to NumMoonDBFields do begin
      if idx[i]>=0 then
        v:=row[idx[i]]
      else
        v:='';
      v:=stringreplace(v,',','.',[rfreplaceall]);
      v:=stringreplace(v,'""','''',[rfreplaceall]);
      v:=stringreplace(v,'"','',[rfreplaceall]);
      cmd:=cmd+'"'+v+'",';
    end;
    cmd:=copy(cmd,1,length(cmd)-1)+');';
    dbm.Query(cmd);
    if dbm.LastError<>0 then dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
  until EOF(f);
  CloseFile(f);
  inc(j);
  if j<=n then begin
    fnn:=StringReplace(fn,'-0','-'+inttostr(j),[]);
    dbjournal(extractfilename(dbm.database),'Process file: '+fnn);
    MsgForm.Label1.caption:=ExtractFileName(fnn)+crlf+'Preparing Database. Please Wait ...';
    MsgForm.Refresh;
    application.ProcessMessages;
    AssignFile(f,fnn);
    Reset(f);
  end;
until j>n;
imax:=dbm.GetLastInsertID;
dbm.Query('update moon set wide_km=0 where wide_km="";');
dbm.Query('update moon set wide_km=0 where wide_km="?";');
dbm.Query('update moon set length_km=0 where length_km="";');
dbm.Query('update moon set length_km=0 where length_km="?";');
dbm.Query('delete from file_date where dbn='+side+';');
dbm.Query('insert into file_date values ('+side+','+inttostr(fileage(fn))+');');
dbm.Query('update dbversion set version='+dbv+';');
dbm.Commit;
dbjournal(extractfilename(dbm.database),'INSERT DBN='+side+' MAX ID='+inttostr(imax));
finally
hdr.Free;
row.Free;
dbm.Query('PRAGMA journal_mode = DELETE');
dbm.Query('PRAGMA synchronous = NORMAL');
end;
end;

Procedure ListDB;
var f:    Tsearchrec;
    i,j,n,p: integer;
    dben: TStringList;
    cdben: TStringList;
    buf,nb: string;
begin
{ Mandatory database file pattern:
  - number between 01 and 99
  - underscore character _
  - name of the database to show in list. Can be translated. _ replaced by space in list.
  - underscore character _
  - uppercase language code, two character
  - .csv

  Example:
    01_Nearside_Named_EN.csv
    07_Historical_EN.csv
    07_Historique_FR.csv

  Connected database start at 500_
}
  DatabaseList.Clear;
  DatabaseList.Sorted:=true;
  dben:=TStringList.Create;
  dben.Sorted:=true;
  ConnectDatabaseList.Clear;
  ConnectDatabaseList.Sorted:=true;
  cdben:=TStringList.Create;
  cdben.Sorted:=true;
  i:=findfirst(Slash(appdir)+Slash('Database')+'*_*_EN.csv', faNormal, f);
  while (i=0) do begin
    p:=pos('_',f.Name);
    n:=StrToIntDef(copy(f.Name,1,p-1),-1);
    if n<0 then continue;
    if n<100 then
      dben.Add(f.Name)
    else if (n>=500)and(n<600) then
      cdben.Add(f.Name);
    i:=FindNext(f);
  end;
  findclose(f);
  if uplanguage='EN' then begin
    DatabaseList.Assign(dben);
    ConnectDatabaseList.Assign(cdben);
  end
  else begin
    for i:=0 to dben.Count-1 do begin
       p:=pos('_',dben[i]);
       nb:=copy(dben[i],1,p-1);
       j:=findfirst(Slash(appdir)+Slash('Database')+nb+'_*_'+uplanguage+'.csv', faNormal, f);
       if j=0 then
         DatabaseList.add(f.Name)
       else
         DatabaseList.add(dben[i]);
       FindClose(f);
    end;
    for i:=0 to cdben.Count-1 do begin
       p:=pos('_',cdben[i]);
       nb:=copy(cdben[i],1,p-1);
       j:=findfirst(Slash(appdir)+Slash('Database')+nb+'_*_'+uplanguage+'.csv', faNormal, f);
       if j=0 then
         ConnectDatabaseList.add(f.Name)
       else
         ConnectDatabaseList.add(cdben[i]);
       FindClose(f);
    end;
  end;
  DatabaseList.Sorted:=false;
  ConnectDatabaseList.Sorted:=false;
  for i:=1 to MaxDB do
    database[i]:='';
  for i:=0 to DatabaseList.Count-1 do begin
    buf:=DatabaseList[i];
    database[i+1]:=Slash(appdir)+Slash('Database')+buf;
    p:=pos('_',buf);
    Delete(buf,1,p);
    Delete(buf,Length(buf)-6,7);
    buf:=StringReplace(buf,'_',' ',[rfReplaceAll]);
    DatabaseList[i]:=buf;
  end;
  for i:=1 to MaxConnectDBN do
    connectdatabase[i]:='';
  for i:=0 to ConnectDatabaseList.Count-1 do begin
    buf:=ConnectDatabaseList[i];
    connectdatabase[i+1]:=Slash(appdir)+Slash('Database')+buf;
    p:=pos('_',buf);
    Delete(buf,1,p);
    Delete(buf,Length(buf)-6,7);
    buf:=StringReplace(buf,'_',' ',[rfReplaceAll]);
    ConnectDatabaseList[i]:=buf;
  end;
  dben.Free;
  cdben.Free;
end;

Procedure LoadDB(dbm: TLiteDB);
var i,db_age : integer;
    buf,missingf:string;
    needvacuum: boolean;
begin
missingf:='';
needvacuum:=false;
buf:=Slash(DBdir)+DBname+uplanguage+'.dbl';
dbm.Use(utf8encode(buf));
try
ListDB;
CreateDB(dbm);
sidelist:='';
for i:=1 to maxdbn do if usedatabase[i] and ((i>MaxDB)or(database[i]<>'')) then sidelist:=sidelist+','+inttostr(i);
if copy(sidelist,1,1)=',' then delete(sidelist,1,1);
for i:=1 to MaxDB do begin
  if usedatabase[i] and (database[i]<>'') then begin
     if (pos('_Satellite_',database[i])>0) then
       UnnamedList:=UnnamedList+' '+inttostr(i)+' ';
     buf:=dbm.QueryOne('select fdate from file_date where dbn='+inttostr(i)+';');
     if buf='' then db_age:=0 else db_age:=strtoint(buf);
     if fileexists(database[i]) then begin
     if (db_age<fileage(database[i])) then begin
        dbjournal(extractfilename(dbm.database),'LOAD DATABASE DBN='+inttostr(i)+' FROM FILE: '+database[i]+' FILE DATE: '+ DateTimeToStr(FileDateToDateTime(fileage(database[i]))) );
        convertDB(dbm,database[i],inttostr(i));
        needvacuum:=true;
     end;
     end
     else begin
       usedatabase[i]:=false;
       if i<>5 then missingf:=missingf+database[i]+blank;
     end;
  end
  else usedatabase[i]:=false;
end;
if needvacuum then dbm.Query('Vacuum;');
LoadConnectDBcols;
LoadConnectDB(dbm);
finally
if MsgForm<>nil then MsgForm.Close;
if missingf>'' then
   MessageDlg('Some database files are missing, the program may not work correctly.'+crlf+missingf,mtError,[mbClose],0);
end;
end;

Procedure LoadConnectDB(dbm: TLiteDB);
var fn,tname,buf,cols,cmd,buf1,v: string;
    i,j,colcount:integer;
    col,val: TStringList;
    f: textfile;
begin
for j:=1 to ConnectDatabaseList.Count do begin
  fn:=connectdatabase[j];
  tname:='connected_'+lowercase(stringreplace(ConnectDatabaseList[j-1],' ','',[rfReplaceAll]));
  colcount:=ConnectDBCols[j].Count;
  if FileExists(fn) then begin
    cmd:='select * from '+tname+' limit 1';
    dbm.Query(cmd);
    if dbm.RowCount<=0 then begin
      if MsgForm=nil then Application.CreateForm(TMsgForm, MsgForm);
      MsgForm.Label1.caption:=ExtractFileName(fn)+crlf+'Preparing Database. Please Wait ...';
      msgform.show;
      msgform.Refresh;
      application.ProcessMessages;
      col:=TStringList.Create;
      val:=TStringList.Create;
      try
      AssignFile(f,fn);
      Reset(f);
      ReadLn(f,cols);
      SplitRec2(cols,';',col);
      if col.Count<colcount then exit;
      dbjournal(extractfilename(dbm.database),'CREATE TABLE '+tname);
      cmd:='drop table '+tname+';';
      dbm.Query(cmd);
      cmd:='create table '+tname+' ( ';
      for i:=0 to colcount-1 do begin
        cmd:=cmd+ConnectDBCols[j][i]+' text,';
      end;
      cmd:=copy(cmd,1,length(cmd)-1);
      cmd:=cmd+');';
      dbm.Query(cmd);
      if dbm.LastError<>0 then begin
        dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
        exit;
      end;
      cmd:='create index '+tname+'_idx on '+tname+'(NAME);';
      dbm.Query(cmd);
      if dbm.LastError<>0 then begin
        dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
        exit;
      end;
      cmd:='insert into '+tname+' values (';
      while not eof(f) do begin
        ReadLn(f,buf);
        SplitRec2(buf,';',val);
        if val.Count<colcount then continue;
        buf1:='';
        for i:=0 to colcount-1 do begin
          v:=val[i];
          v:=stringreplace(v,'""','''',[rfreplaceall]);
          v:=stringreplace(v,'"','',[rfreplaceall]);
          buf1:=buf1+'"'+v+'",';
        end;
        buf1:=copy(buf1,1,length(buf1)-1);
        cmd:=cmd+buf1+'),(';
      end;
      i:=length(cmd);
      delete(cmd,Length(cmd)-1,2);
      dbm.Query(cmd);
      if dbm.LastError<>0 then begin
         dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
       end;
      CloseFile(f);
      finally
       if MsgForm<>nil then MsgForm.Close;
       col.Free;
       val.Free;
      end;
    end;
  end;
end;
end;

procedure LoadConnectDBcols;
var i: integer;
    fn,fname,buf:string;
    f:TextFile;
begin
  for i:=1 to ConnectDatabaseList.Count do begin
     if ConnectDBCols[i]=nil then  ConnectDBCols[i]:=TStringList.Create;
     fn:=connectdatabase[i];
     fname:=ChangeFileExt(fn,'.txt');
     if not FileExists(fname) then
       fname:=fn;
     if FileExists(fname) then begin
       AssignFile(f,fname);
       Reset(f);
       ReadLn(f,buf);
       CloseFile(f);
       SplitRec2(buf,';',ConnectDBCols[i]);
     end;
  end;
end;

procedure DBjournal(dbname,txt:string);
var f : textfile;
    fn: string;
const dbj='database_journal.txt';
begin
fn:=Slash(DBdir)+dbj;
if fileexists(fn) then begin
  assignfile(f,fn);
  append(f);
end else begin
  assignfile(f,fn);
  rewrite(f);
end;
writeln(f,FormatDateTime('yyyy"-"mm"-"dd" "hh":"nn":"ss',Now),' DB=',dbname,' ',txt);
closefile(f);
end;

Procedure LoadLopamIdx(fn,path:string; dbm: TLiteDB);
var buf,cmd,v: string;
    i:integer;
    val: TStringList;
    f: textfile;
const colcount=80;
begin
 if FileExists(slash(path)+fn+'.csv') then begin
    cmd:='select * from lopamidx limit 1';
    dbm.Query(cmd);
    if dbm.LastError<>0 then begin
      val:=TStringList.Create;
      try
      dbjournal(extractfilename(dbm.database),'CREATE TABLE LOPAMIDX');
      cmd:='create table lopamidx ( '+
         'NAME TEXT,'+
         'F_LATIN FLOAT,'+
         'F_LONGIN FLOAT,'+
         'PLATE TEXT,'+
         'IMAGE TEXT,'+
         'LATIN FLOAT,'+
         'LONGIN FLOAT'+
         ');';
      dbm.Query(cmd);
      if dbm.LastError<>0 then dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
      cmd:='create index lopamidx_idx on lopamidx(NAME);';
      dbm.Query(cmd);
      if dbm.LastError<>0 then begin
        dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
        exit;
      end;
      AssignFile(f,slash(path)+fn+'.csv');
      Reset(f);
      ReadLn(f,buf);

      cmd:='insert into lopamidx values ';
      while not eof(f) do begin
        ReadLn(f,buf);
        SplitRec2(buf,';',val);
        cmd:=cmd+'(';
        for i:=0 to 6 do begin
          v:=val[i];
          v:=stringreplace(v,'""','''',[rfreplaceall]);
          v:=stringreplace(v,'"','',[rfreplaceall]);
          cmd:=cmd+'"'+v+'",';
        end;
        cmd:=copy(cmd,1,length(cmd)-1);
        cmd:=cmd+'),';
      end;
      CloseFile(f);
      cmd:=copy(cmd,1,length(cmd)-1);
      dbm.Query(cmd);
      if dbm.LastError<>0 then begin
         dbjournal(extractfilename(dbm.database),copy(cmd,1,60)+'...  Error: '+dbm.ErrorMessage);
      end;
      finally
       val.Free;
      end;
    end;
 end;
end;

function LoadNotelunDB(db: TLiteDB): integer;
var cmd,buf,txt,user: string;
    row: TStringList;
    f: TextFile;
    dt:double;
    n: integer;
begin
  n:=0;
  db.Use(Slash(DBdir)+DBnamenotes+'.dbl');
  buf:=db.QueryOne('select version from dbversion;');
  // next version will eventually look for upgrade
  if buf='' then begin
    // create new database

    dbjournal(extractfilename(db.database),'CREATE TABLE obsnotes');
    cmd:='create table obsnotes ( '+
         'ID INTEGER PRIMARY KEY,'+
         'FORMATION TEXT,'+
         'DATESTART FLOAT,'+
         'DATEEND FLOAT,'+
         'LOCATION INTEGER,'+
         'OBSERVER INTEGER,'+
         'METEO TEXT,'+
         'SEEING TEXT,'+
         'INSTRUMENT INTEGER,'+
         'BARLOW INTEGER,'+
         'EYEPIECE INTEGER,'+
         'CAMERA INTEGER,'+
         'NOTE TEXT,'+
         'FILES TEXT'+
         ');';
    db.Query(cmd);
    if db.LastError<>0 then dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage);
    db.Query('create index ix1_formation on obsnotes(FORMATION);');

    dbjournal(extractfilename(db.database),'CREATE TABLE infonotes');
    cmd:='create table infonotes ( '+
         'ID INTEGER PRIMARY KEY,'+
         'FORMATION TEXT,'+
         'DATE FLOAT,'+
         'AUTHOR TEXT,'+
         'NOTE TEXT,'+
         'FILES TEXT'+
         ');';
    db.Query(cmd);
    if db.LastError<>0 then dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage);
    db.Query('create index ix2_formation on infonotes(FORMATION);');

    dbjournal(extractfilename(db.database),'CREATE TABLE location');
    cmd:='create table location ( '+
         'ID INTEGER PRIMARY KEY,'+
         'NAME TEXT,'+
         'LONGITUDE FLOAT,'+
         'LATITUDE FLOAT,'+
         'ELEVATION FLOAT,'+
         'TIMEZONE TEXT'+
         ');';
    db.Query(cmd);
    if db.LastError<>0 then dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage);
    db.Query('create index ix_location on location(NAME);');

    dbjournal(extractfilename(db.database),'CREATE TABLE observer');
    cmd:='create table observer ( '+
         'ID INTEGER PRIMARY KEY,'+
         'NAME TEXT,'+
         'FIRSTNAME TEXT,'+
         'PSEUDO TEXT,'+
         'CONTACT TEXT'+
         ');';
    db.Query(cmd);
    if db.LastError<>0 then dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage);
    db.Query('create index ix_observer on observer(NAME);');

    dbjournal(extractfilename(db.database),'CREATE TABLE instrument');
    cmd:='create table instrument ( '+
         'ID INTEGER PRIMARY KEY,'+
         'NAME TEXT,'+
         'TYPE TEXT,'+
         'DIAMETER FLOAT,'+
         'FOCAL FLOAT,'+
         'FD FLOAT'+
         ');';
    db.Query(cmd);
    if db.LastError<>0 then dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage);
    db.Query('create index ix_instrument on instrument(NAME);');

    dbjournal(extractfilename(db.database),'CREATE TABLE barlow');
    cmd:='create table barlow ( '+
         'ID INTEGER PRIMARY KEY,'+
         'NAME TEXT,'+
         'POWER FLOAT'+
         ');';
    db.Query(cmd);
    if db.LastError<>0 then dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage);
    db.Query('create index ix_barlow on barlow(NAME);');

    dbjournal(extractfilename(db.database),'CREATE TABLE eyepiece');
    cmd:='create table eyepiece ( '+
         'ID INTEGER PRIMARY KEY,'+
         'NAME TEXT,'+
         'FOCAL FLOAT,'+
         'FIELD FLOAT'+
         ');';
    db.Query(cmd);
    if db.LastError<>0 then dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage);
    db.Query('create index ix_eyepiece on eyepiece(NAME);');

    dbjournal(extractfilename(db.database),'CREATE TABLE camera');
    cmd:='create table camera ( '+
         'ID INTEGER PRIMARY KEY,'+
         'NAME TEXT,'+
         'PIXELX FLOAT,'+
         'PIXELY FLOAT,'+
         'PIXELSIZE FLOAT'+
         ');';
    db.Query(cmd);
    if db.LastError<>0 then dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage);
    db.Query('create index ix_camera on camera(NAME);');

    dbjournal(extractfilename(db.database),'CREATE VIEW flatobs');
    cmd:='create view flatobs as '+
         'select formation,datestart,dateend,location.name as LOCATION,observer.name || " " || observer.firstname as OBSERVER, '+
         'meteo,seeing,instrument.name as INSTRUMENT,barlow.name as BARLOW,eyepiece.name as EYEPIECE,camera.name as CAMERA, '+
         'note,files '+
         'from obsnotes '+
         'left outer join location on location.id = location '+
         'left outer join observer on observer.id = observer '+
         'left outer join instrument on instrument.id = instrument '+
         'left outer join barlow on barlow.id = barlow '+
         'left outer join eyepiece on eyepiece.id = eyepiece '+
         'left outer join camera on camera.id = camera '+
         '; ';
    db.Query(cmd);
    if db.LastError<>0 then dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage);

    dbjournal(extractfilename(db.database),'CREATE TABLE dbversion');
    cmd:='create table dbversion ( '+
        'version integer'+
        ');';
    db.Query(cmd);
    cmd:='insert into dbversion values('+inttostr(DBversion)+');';
    db.Query(cmd);
    if db.LastError<>0 then dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage);

    if fileexists(Slash(DBdir) + 'notes.csv') then begin
      dbjournal(extractfilename(db.database),'IMPORT notes.csv');
      row:=TStringList.Create;
      AssignFile(f,Slash(DBdir) + 'notes.csv');
      Reset(f);
      ReadLn(f,buf);
      SplitRec2(buf,';',row);
      if (row[0]<>'NAME')or(row[1]<>'NOTES') then dbjournal(extractfilename(db.database),'Wrong header '+buf);
      dt:=trunc(now);
      user:=CurrentUserName;
      repeat
        ReadLn(f,buf);
        SplitRec2(buf,';',row);
        txt:=StringReplace(row[1],'||',#10,[rfReplaceAll]);
        cmd:='insert into infonotes values(NULL,"'+row[0]+'","'+formatfloat(f5,dt)+'","'+user+'","'+txt+'","");';
        db.Query(cmd);
        if db.LastError<>0 then
          dbjournal(extractfilename(db.database),copy(cmd,1,60)+'...  Error: '+db.ErrorMessage)
        else
          inc(n);
      until EOF(f);
      CloseFile(f);
      row.Free;
    end;
end;
result:=n;
end;

end.

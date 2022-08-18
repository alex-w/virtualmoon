unit notelun_main;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef mswindows}
    Windows, ShlObj,
  {$endif}
  dbutil, u_constant, u_util, libsql, cu_tz, passql, passqlite, UniqueInstance, notelun_setup,
  LCLVersion, IniFiles, u_translation, pu_search, pu_date, LazUTF8,
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus, Grids, ComCtrls, StdCtrls, Buttons, EditBtn, ExtDlgs;

type

  { Tf_notelun }

  Tf_notelun = class(TForm)
    BtnChangeInfoDate: TSpeedButton;
    BtnEdit: TSpeedButton;
    BtnDelete: TSpeedButton;
    BtnSearchFormation1: TSpeedButton;
    CalendarDialog1: TCalendarDialog;
    ObsFiles: TStringGrid;
    ObsEyepiece: TComboBox;
    InfoFiles: TStringGrid;
    Label21: TLabel;
    MenuItemSetupBarlow: TMenuItem;
    ObsInstrument: TComboBox;
    ObsBarlow: TComboBox;
    ObsCamera: TComboBox;
    ObsMeteo: TEdit;
    ObsSeeing: TEdit;
    ObsPower: TEdit;
    ObsEnd: TEdit;
    ObsStart: TEdit;
    Label20: TLabel;
    MenuItemHelp: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemSetupLocation: TMenuItem;
    MenuItemSetupLastFormation: TMenuItem;
    MenuItemSetupObserver: TMenuItem;
    MenuItemSetupInstrument: TMenuItem;
    MenuItemSetupEyepiece: TMenuItem;
    MenuItemSetupCamera: TMenuItem;
    MenuItemSetupEphemeris: TMenuItem;
    MenuItemSetupFont: TMenuItem;
    MenuItemSetupList: TMenuItem;
    MenuItemSetupPrint: TMenuItem;
    MenuItemSortFormation: TMenuItem;
    MenuItemSortDate: TMenuItem;
    MenuItemSortType: TMenuItem;
    MenuItemSortPlace: TMenuItem;
    MenuItemSortObserver: TMenuItem;
    MenuItemSortInstrument: TMenuItem;
    MenuItemSortEyepiece: TMenuItem;
    MenuItemSortFileFormat: TMenuItem;
    MenuItemNewObs: TMenuItem;
    MenuItemNewInfo: TMenuItem;
    MenuItemEditNote: TMenuItem;
    MenuItemDeleteNote: TMenuItem;
    MenuItemPrintNote: TMenuItem;
    MenuItemPrintList: TMenuItem;
    MenuItemExport: TMenuItem;
    Quit: TMenuItem;
    ObsAltitude: TLabel;
    ObsAzimut: TLabel;
    ObsLibrLat: TLabel;
    ObsLibrLon: TLabel;
    ObsColongitude: TLabel;
    ObsLunation: TLabel;
    ObsDiam: TLabel;
    ObsDec: TLabel;
    ObsRA: TLabel;
    ObsObserver: TComboBox;
    ObsLocation: TComboBox;
    ObsFilesBox: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ObsText: TMemo;
    ObsNote: TGroupBox;
    ObsEph: TGroupBox;
    ObsGear: TGroupBox;
    ObsCircumstance: TGroupBox;
    ObsDate: TEdit;
    InfoFilesBox: TGroupBox;
    ObsFormation: TEdit;
    InfoNote: TGroupBox;
    InfoAuthor: TEdit;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    InfoText: TMemo;
    MenuFile: TMenuItem;
    MenuSetup: TMenuItem;
    MenuHelp: TMenuItem;
    MenuManage: TMenuItem;
    InfoFormation: TEdit;
    InfoDate: TEdit;
    PageControl1: TPageControl;
    PanelObsTop: TPanel;
    PanelTopRight: TPanel;
    PanelTopLeft: TPanel;
    PanelInfoTop: TPanel;
    PanelStatus: TPanel;
    PanelList: TPanel;
    PanelListBottom: TPanel;
    PanelRight: TPanel;
    PanelLeft: TPanel;
    PanelTop: TPanel;
    BtnSave: TSpeedButton;
    ListNotes: TStringGrid;
    ButtonAtlun: TSpeedButton;
    ButtonPhotlun: TSpeedButton;
    ButtonDatlun: TSpeedButton;
    ButtonWeblun: TSpeedButton;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    BtnSearchFormation: TSpeedButton;
    BtnChangeObsDate: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Splitter1: TSplitter;
    TabSheetObservation: TTabSheet;
    TabSheetInformation: TTabSheet;
    UniqueInstance1: TUniqueInstance;
    procedure BtnChangeInfoDateClick(Sender: TObject);
    procedure BtnChangeObsDateClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnSearchFormationClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InfoFilesValidateEntry(sender: TObject; aCol, aRow: Integer; const OldValue: string; var NewValue: String);
    procedure InfoNoteChange(Sender: TObject);
    procedure ListNotesSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
    procedure MenuItemNewInfoClick(Sender: TObject);
    procedure MenuItemNewObsClick(Sender: TObject);
    procedure MenuSetupObservation(Sender: TObject);
    procedure UniqueInstance1OtherInstance(Sender: TObject; ParamCount: Integer; const Parameters: array of String);

  private
    tz: TCdCTimeZone;
    Finfodate,Fobsdate: double;
    param : Tstringlist;
    StartVMA,CanCloseVMA: boolean;
    EditingObservation,EditingInformation,ModifiedObservation,ModifiedInformation,NewInformation,NewObservation: boolean;
    CurrentInfoId, CurrentObsId: integer;
    CurrentFormation: string;
    procedure SetLang;
    procedure GetAppDir;
    Procedure ReadParam(first:boolean=true);
    function  FormatDate(val:string):string;
    procedure SetInfoDate(val:string);
    procedure ClearList;
    procedure NotesList(formation:string='';prefix:char=' ';fid:integer=0);
    procedure ClearObsBox(box:TComboBox);
    procedure LoadObsBox(table: string;box:TComboBox;  name2:string='');
    procedure LoadObsBoxes;

    procedure ClearInfoNote;
    procedure ShowInfoNote(id: integer);
    procedure SetEditInformation(onoff: boolean);
    procedure SaveInformationNote;
    procedure NewInformationNote(formation:string='');
    procedure DeleteInformation(id: integer);

    procedure ClearObsNote;
    procedure ShowObsNote(id: integer);
    procedure SetEditObservation(onoff: boolean);
    procedure SaveObservationNote;
    procedure NewObservationNote(formation:string='');
    procedure DeleteObservation(id: integer);

  public

  end;

var
  f_notelun: Tf_notelun;

implementation

{$R *.lfm}

{ Tf_notelun }


procedure Tf_notelun.FormCreate(Sender: TObject);
var inifile:Tmeminifile;
    i: integer;
begin
  DefaultFormatSettings.DateSeparator:='/';
  DefaultFormatSettings.TimeSeparator:=':';
  DefaultFormatSettings.DecimalSeparator:='.';
  compile_time := {$I %DATE%}+' '+{$I %TIME%};
  compile_version := 'Lazarus '+lcl_version+' Free Pascal '+{$I %FPCVERSION%}+' '+{$I %FPCTARGETOS%}+'-'+{$I %FPCTARGETCPU%};
  StartVMA:=false;
  CanCloseVMA:=true;

  GetAppDir;
  inifile := Tmeminifile.Create(ConfigFile);
  language:= inifile.ReadString('default', 'lang_po_file', '');
  inifile.Free;
  language:=u_translation.translate(language,'en');
  uplanguage:=UpperCase(language);
  SetLang;
  tz:=TCdCTimeZone.Create;
  tz.LoadZoneTab(ZoneDir+'zone.tab');
  dbm:=TLiteDB.Create(self);
  dbnotes:=TLiteDB.Create(self);
  param:=Tstringlist.Create;
  param.clear;
  if paramcount>0 then begin
   for i:=1 to paramcount do begin
      param.Add(paramstr(i));
   end;
  end;
end;

procedure Tf_notelun.FormDestroy(Sender: TObject);
begin
  ClearList;
  ClearObsBox(ObsLocation);
  ClearObsBox(ObsObserver);
  ClearObsBox(ObsInstrument);
  ClearObsBox(ObsBarlow);
  ClearObsBox(ObsEyepiece);
  ClearObsBox(ObsCamera);
  dbm.free;
  dbnotes.free;
  tz.Free;
  DatabaseList.free;
  param.free;
end;

procedure Tf_notelun.FormShow(Sender: TObject);
var i: integer;
begin
  for i:=1 to maxdbn do usedatabase[i]:=false;
  usedatabase[1]:=true;
  DatabaseList:=Tstringlist.Create;
  LoadDB(dbm);
  LoadNotelunDB(dbnotes);
  f_search.dbm:=dbm;
  ClearObsNote;
  ClearInfoNote;
  PageControl1.ActivePageIndex:=0;
  CurrentFormation:='';
  LoadObsBoxes;
  ReadParam;
  if CurrentFormation='' then NotesList;
end;

procedure Tf_notelun.SetLang;
begin
  MenuItemSetupLocation.Caption:='Location';
  MenuItemSetupObserver.Caption:='Observer';
  MenuItemSetupInstrument.Caption:='Instrument';
  MenuItemSetupBarlow.Caption:='Barlow';
  MenuItemSetupEyepiece.Caption:='Eyepiece';
  MenuItemSetupCamera.Caption:='Camera';
end;

procedure Tf_notelun.GetAppDir;
var
  buf: string;
  inif: TMeminifile;
{$ifdef darwin}
  i:      integer;
{$endif}
{$ifdef mswindows}
  PIDL:   PItemIDList;
  Folder: array[0..MAX_PATH] of char;
{$endif}
begin
{$ifdef darwin}
  appdir := getcurrentdir;
  if (not directoryexists(slash(appdir) + slash('Textures'))) then
  begin
    appdir := ExtractFilePath(ParamStr(0));
    i      := pos('.app/', appdir);
    if i > 0 then
    begin
      appdir := ExtractFilePath(copy(appdir, 1, i));
    end;
  end;
{$else}
  appdir     := getcurrentdir;
  if not DirectoryExists(slash(appdir)+slash('Textures')) then begin
     appdir:=ExtractFilePath(ParamStr(0));
  end;
{$endif}
  privatedir := DefaultPrivateDir;
{$ifdef unix}
  appdir     := expandfilename(appdir);
  bindir     := slash(appdir);
  privatedir := expandfilename(PrivateDir);
  configfile := expandfilename(Defaultconfigfile);
  CdCconfig  := ExpandFileName(DefaultCdCconfig);
{$endif}
{$ifdef mswindows}
  buf:='';
  SHGetSpecialFolderLocation(0, CSIDL_LOCAL_APPDATA, PIDL);
  SHGetPathFromIDList(PIDL, Folder);
  buf:=systoutf8(Folder);
  buf:=trim(buf);
  buf:=SafeUTF8ToSys(buf);
  if buf='' then begin  // old windows version
     SHGetSpecialFolderLocation(0, CSIDL_APPDATA, PIDL);
     SHGetPathFromIDList(PIDL, Folder);
     buf:=trim(Folder);
  end;
  if buf='' then begin
     MessageDlg('Unable to create '+privatedir,
               mtError, [mbAbort], 0);
     Halt;
  end;
  privatedir := slash(buf) + privatedir;
  configfile := slash(privatedir) + Defaultconfigfile;
  CdCconfig  := slash(buf) + DefaultCdCconfig;
  bindir:=slash(appdir);
{$endif}

  if fileexists(configfile) then begin
    inif:=TMeminifile.create(configfile);
    try
    buf:=inif.ReadString('default','Install_Dir',appdir);
    if Directoryexists(slash(buf)+slash('Textures')) then appdir:=noslash(buf);
    finally
     inif.Free;
    end;
  end;
  if not directoryexists(privatedir) then
    CreateDir(privatedir);
  if not directoryexists(privatedir) then
    forcedirectories(privatedir);
  if not directoryexists(privatedir) then
  begin
    privatedir := appdir;
  end;
  Tempdir := slash(privatedir) + DefaultTmpDir;
  if not directoryexists(TempDir) then
    CreateDir(TempDir);
  if not directoryexists(TempDir) then
    forcedirectories(TempDir);
  DBdir := Slash(privatedir) + 'database';
  if not directoryexists(DBdir) then
    CreateDir(DBdir);
  if not directoryexists(DBdir) then
    forcedirectories(DBdir);
  // Be sur the Textures directory exists
  if (not directoryexists(slash(appdir) + slash('Textures'))) then
  begin
    // try under the current directory
    buf := GetCurrentDir;
    if (directoryexists(slash(buf) + slash('Textures'))) then
      appdir := buf
    else
    begin
      // try under the program directory
      buf := ExtractFilePath(ParamStr(0));
      if (directoryexists(slash(buf) + slash('Textures'))) then
        appdir := buf
      else
      begin
        // try share directory under current location
        buf := ExpandFileName(slash(GetCurrentDir) + SharedDir);
        if (directoryexists(slash(buf) + slash('Textures'))) then
          appdir := buf
        else
        begin
          // try share directory at the same location as the program
          buf := ExpandFileName(slash(ExtractFilePath(ParamStr(0))) + SharedDir);
          if (directoryexists(slash(buf) + slash('Textures'))) then
            appdir := buf
          else
          begin
            MessageDlg('Could not found the application Textures directory.' +
              crlf + 'Please try to reinstall the program at a standard location.',
              mtError, [mbAbort], 0);
            Halt;
          end;
        end;
      end;
    end;
  end;
 {$ifndef darwin}
  if not FileExists(slash(bindir)+ExtractFileName(ParamStr(0))) then begin
     bindir := slash(ExtractFilePath(ParamStr(0)));
     if not FileExists(slash(bindir)+ExtractFileName(ParamStr(0))) then begin
        bindir := slash(ExpandFileName(slash(appdir) + slash('..')+slash('..')+'bin'));
        if not FileExists(slash(bindir)+ExtractFileName(ParamStr(0))) then begin
           bindir:='';
        end;
     end;
  end;
  {$endif}
  Maplun  := '"'+bindir + DefaultMaplun+'"';
  Photlun := '"'+bindir + DefaultPhotlun+'"';     // Photlun normally at same location as vma
  Datlun  := '"'+bindir + DefaultDatlun+'"';
  Weblun  := '"'+bindir + DefaultWeblun+'"';
  helpdir := slash(appdir) + slash('doc');
  jpldir  := slash(appdir)+slash('data')+'jpleph';
  // Be sure zoneinfo exists in standard location or in vma directory
  ZoneDir  := slash(appdir) + slash('data') + slash('zoneinfo');
  buf      := slash('') + slash('usr') + slash('share') + slash('zoneinfo');
  if (FileExists(slash(buf) + 'zone.tab')) then
    ZoneDir := slash(buf)
  else
  begin
    buf := slash('') + slash('usr') + slash('lib') + slash('zoneinfo');
    if (FileExists(slash(buf) + 'zone.tab')) then
      ZoneDir := slash(buf)
    else
    begin
      if (not FileExists(slash(ZoneDir) + 'zone.tab')) then
      begin
        MessageDlg('zoneinfo directory not found!' + crlf +
          'Please install the tzdata package.' + crlf +
          'If it is not installed at a standard location create a logical link zoneinfo in virtualmoon data directory.',
          mtError, [mbAbort], 0);
        Halt;
      end;
    end;
  end;
end;

procedure Tf_notelun.UniqueInstance1OtherInstance(Sender: TObject; ParamCount: Integer; const Parameters: array of String);
var i: integer;
begin
  application.Restore;
  application.BringToFront;
  if ParamCount > 0 then begin
     param.Clear;
     for i:=0 to ParamCount-1 do begin
        param.add(Parameters[i]);
     end;
     ReadParam(false);
  end;
end;

Procedure Tf_notelun.ReadParam(first:boolean=true);
var i,id : integer;
    nam,txt: string;
    prefix: char;
begin
nam:='';
prefix:=' ';
id:=0;
i:=0;
while i <= param.count-1 do begin
  if (param[i]='-nx')and first then begin       // when started by vma do not close vma on exit!
     CanCloseVMA:=false;
  end
  else if param[i]='-n' then begin   // set formation name to search
     inc(i);
     if i <= param.count-1 then
        nam:=param[i];
  end
  else if param[i]='-p' then begin   // set note type to search
     inc(i);
     if i <= param.count-1 then
        prefix:=param[i].Chars[0];
  end
  else if param[i]='-i' then begin   //set note id to search
     inc(i);
     if i <= param.count-1 then
        id:=StrToIntDef(param[i],0);
  end
  else if param[i]='-newi' then begin   // create new information note
     inc(i);
     if i <= param.count-1 then
        txt:=param[i]
     else
        txt:='';
     CurrentFormation:=txt;
     NewInformationNote(txt);
  end
  else if param[i]='-newo' then begin   // create new observation note
     inc(i);
     if i <= param.count-1 then
        txt:=param[i]
     else
        txt:='';
     CurrentFormation:=txt;
     NewObservationNote(txt);
  end
  else if param[i]='-quit' then begin  // close current instance
     Close;
  end
  else if param[i]='--' then begin   // last parameter
       break;
  end;
  inc(i);
end;
if (nam<>'')or(id<>0) then begin
  CurrentFormation:=nam;
  NotesList(nam,prefix,id);
end;
end;

procedure Tf_notelun.BtnSearchFormationClick(Sender: TObject);
var p: tpoint;
    ed:tedit;
begin
  case TSpeedButton(sender).tag of
    0: ed:=ObsFormation;
    1: ed:=InfoFormation;
  end;
  p.x:=ed.Left;
  p.y:=ed.Top+ed.Height;
  p:=ed.Parent.ClientToScreen(p);
  f_search.SetFormation(ed.Text);
  f_search.Left:=p.x;
  f_search.Top:=p.y;
  if f_search.ShowModal=mrOK then begin
    ed.Text:=f_search.ListBox1.GetSelectedText;
  end;
end;

procedure Tf_notelun.BtnChangeObsDateClick(Sender: TObject);
var p: tpoint;
begin
  p.x:=ObsDate.Left;
  p.y:=ObsDate.Top+ObsDate.Height;
  p:=ObsDate.Parent.ClientToScreen(p);
  f_date.Left:=p.x;
  f_date.Top:=p.y;
  if Fobsdate=0 then
    f_date.Date:=now
  else
    f_date.Date:=Fobsdate;
  if f_date.ShowModal=mrOK then begin
    Fobsdate:=f_date.Date;
    ObsDate.Text:=FormatDateTime(datetimedisplay,Fobsdate);
  end;
end;

procedure Tf_notelun.BtnChangeInfoDateClick(Sender: TObject);
var p: tpoint;
begin
  p.x:=InfoDate.Left;
  p.y:=InfoDate.Top+InfoDate.Height;
  p:=InfoDate.Parent.ClientToScreen(p);
  if Finfodate=0 then
    CalendarDialog1.Date:=now
  else
    CalendarDialog1.Date:=Finfodate;
  CalendarDialog1.Left:=p.x;
  CalendarDialog1.Top:=p.y;
  if CalendarDialog1.Execute then begin
    Finfodate:=trunc(CalendarDialog1.Date);
    InfoDate.Text:=FormatDateTime(datedisplay,Finfodate);
  end;
end;

function Tf_notelun.FormatDate(val:string):string;
var dt: double;
begin
  dt:=StrToFloatDef(val,0);
  if dt=0 then
    result:=''
  else
    result:=FormatDateTime(datedisplay,dt);
end;

procedure Tf_notelun.SetInfoDate(val:string);
begin
  Finfodate:=StrToFloatDef(val,0);
  if Finfodate=0 then
    InfoDate.Text:=''
  else
    InfoDate.Text:=FormatDateTime(datedisplay,Finfodate);
end;

procedure Tf_notelun.NotesList(formation:string='';prefix:char=' ';fid:integer=0);
var sortcol,cmd: string;
    i,n,k: integer;
    id:TNoteID;
    ok: boolean;
begin
  if formation='' then
    formation:=CurrentFormation
  else
    CurrentFormation:=formation;
  ClearList;
  k:=1;
  n:=1;
  sortcol:='FORMATION';
  cmd:='select ID,FORMATION,DATE from infonotes';
  if formation<>'' then cmd:=cmd+' where FORMATION="'+formation+'"';
  cmd:=cmd+' order by '+sortcol;
  dbnotes.Query(cmd);
  ListNotes.RowCount:=ListNotes.RowCount+dbnotes.RowCount;
  for i:=0 to dbnotes.RowCount-1 do begin
    id:=TNoteID.Create;
    id.prefix:='I';
    id.id:=dbnotes.Results[i].Format[0].AsInteger;
    if (fid<>0)and(prefix='I')and(id.id=fid) then k:=n;
    ListNotes.Objects[0,n]:=id;
    ListNotes.Cells[0,n]:=dbnotes.Results[i][1];
    ListNotes.Cells[1,n]:=FormatDate(dbnotes.Results[i][2]);
    ListNotes.Cells[2,n]:='I';
    inc(n);
  end;
  cmd:='select ID,FORMATION,DATESTART from obsnotes';
  if formation<>'' then cmd:=cmd+' where FORMATION="'+formation+'"';
  dbnotes.Query(cmd);
  ListNotes.RowCount:=ListNotes.RowCount+dbnotes.RowCount;
  for i:=0 to dbnotes.RowCount-1 do begin
    id:=TNoteID.Create;
    id.prefix:='O';
    id.id:=dbnotes.Results[i].Format[0].AsInteger;
    if (fid<>0)and(prefix='O')and(id.id=fid) then k:=n;
    ListNotes.Objects[0,n]:=id;
    ListNotes.Cells[0,n]:=dbnotes.Results[i][1];
    ListNotes.Cells[1,n]:=FormatDate(dbnotes.Results[i][2]);
    ListNotes.Cells[2,n]:='O';
    inc(n);
  end;
  ListNotesSelectCell(ListNotes,0,k,ok);
end;

procedure Tf_notelun.ClearList;
var i: integer;
begin
  for i:=1 to ListNotes.RowCount-1 do begin
    if ListNotes.Objects[0,i]<>nil then begin
      ListNotes.Objects[0,i].Free;
      ListNotes.Objects[0,i]:=nil;
    end;
  end;
  ListNotes.RowCount:=1;
end;

procedure Tf_notelun.ClearInfoNote;
begin
  Finfodate:=0;
  InfoFormation.Text:='';
  InfoDate.Text:='';
  InfoAuthor.Text:='';
  InfoText.Text:='';
  InfoFiles.Clear;
  ModifiedInformation:=false;
end;

procedure Tf_notelun.ClearObsNote;
begin
  Fobsdate:=0;
  ObsFormation.Text:='';
  ObsDate.Text:='';
  ObsLocation.Text:='';
  ObsObserver.Text:='';
  ObsStart.Text:='';
  ObsEnd.Text:='';
  ObsMeteo.Text:='';
  ObsSeeing.Text:='';
  ObsInstrument.Text:='';
  ObsBarlow.Text:='';
  ObsPower.Text:='';
  ObsCamera.Text:='';
  ObsText.Text:='';
  ObsFiles.Clear;
  ObsRA.Caption:=' ';
  ObsDec.Caption:=' ';
  ObsDiam.Caption:=' ';
  ObsLunation.Caption:=' ';
  ObsColongitude.Caption:=' ';
  ObsLibrLon.Caption:=' ';
  ObsLibrLat.Caption:=' ';
  ObsAzimut.Caption:=' ';
  ObsAltitude.Caption:=' ';
  ModifiedObservation:=false;
end;

procedure Tf_notelun.ListNotesSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
var i: LongWord;
    id: TNoteID;
begin
  id:=TNoteID(ListNotes.Objects[0,aRow]);
  if id<>nil then begin
    i:=id.id;
    if id.prefix='O' then begin
      ShowObsNote(i);
    end
    else if id.prefix='I' then begin
      ShowInfoNote(i);
    end;
    CanSelect:=true;
  end
  else begin
    CanSelect:=false;
  end;
end;

procedure Tf_notelun.MenuSetupObservation(Sender: TObject);
begin
  FSetup.PageControl1.ActivePageIndex:=TMenuItem(Sender).tag;
  FSetup.ShowModal;
  if FSetup.ModalResult=mrOK then
    LoadObsBoxes;
end;

procedure Tf_notelun.ClearObsBox(box:TComboBox);
var i: integer;
begin
  for i:=0 to box.items.Count-1 do begin
    if box.items.Objects[i]<>nil then begin
      box.items.Objects[i].Free;
      box.items.Objects[i]:=nil;
    end;
  end;
  box.clear;
end;

procedure Tf_notelun.LoadObsBox(table: string;box:TComboBox; name2:string='');
var cmd: string;
    i: integer;
    id: TNoteID;
begin
  ClearObsBox(box);
  if name2='' then
    cmd:='select id,name from '+table+' order by name'
  else
    cmd:='select id,name,'+name2+' from '+table+' order by name';
  dbnotes.Query(cmd);
  for i:=0 to dbnotes.RowCount-1 do begin
    id:=TNoteID.Create;
    id.id:=dbnotes.Results[i].Format[0].AsInteger;
    if name2='' then
      box.Items.AddObject(dbnotes.Results[i][1],id)
    else
      box.Items.AddObject(dbnotes.Results[i][1]+' '+dbnotes.Results[i][2],id);
  end;
  if box.Items.Count>0 then box.ItemIndex:=0;
end;

procedure Tf_notelun.LoadObsBoxes;
begin
  LoadObsBox('location',ObsLocation);
  LoadObsBox('observer',ObsObserver,'firstname');
  LoadObsBox('instrument',ObsInstrument);
  LoadObsBox('barlow',ObsBarlow);
  LoadObsBox('eyepiece',ObsEyepiece,'focal');
  LoadObsBox('camera',ObsCamera);
end;

procedure Tf_notelun.ShowInfoNote(id: integer);
var cmd: string;
begin
  PageControl1.ActivePageIndex:=1;
  SetEditInformation(false);
  ClearInfoNote;
  cmd:='select ID,FORMATION,DATE,AUTHOR,NOTE,FILES from infonotes where ID='+inttostr(id);
  dbnotes.Query(cmd);
  if dbnotes.RowCount>0 then begin
    CurrentInfoId:=dbnotes.Results[0].Format[0].AsInteger;
    InfoFormation.Text:=dbnotes.Results[0][1];
    SetInfoDate(dbnotes.Results[0][2]);
    InfoAuthor.Text:=dbnotes.Results[0][3];
    InfoText.Text:=dbnotes.Results[0][4];
    InfoFiles.RowCount:=1;
    InfoFiles.Cells[0,0]:=dbnotes.Results[0][5];
  end
  else
    CurrentInfoId:=-1;
  ModifiedInformation:=false;
end;

procedure Tf_notelun.BtnEditClick(Sender: TObject);
begin
  case PageControl1.ActivePageIndex of
    0 : SetEditObservation(true);
    1 : SetEditInformation(true);
  end;
end;

procedure Tf_notelun.BtnSaveClick(Sender: TObject);
begin
  case PageControl1.ActivePageIndex of
    0 : SaveObservationNote;
    1 : SaveInformationNote;
  end;
end;

procedure Tf_notelun.BtnDeleteClick(Sender: TObject);
begin
  case PageControl1.ActivePageIndex of
    0 : DeleteObservation(CurrentInfoId);
    1 : DeleteInformation(CurrentInfoId);
  end;
  NotesList;
end;



procedure Tf_notelun.SetEditInformation(onoff: boolean);
var b:TBorderStyle;
begin

  if (not onoff) and ModifiedInformation then begin
    if MessageDlg('Note is modified do you want to save the modification?',mtConfirmation,mbYesNo,0)=mrYes then
      SaveInformationNote
    else begin
      if NewInformation then DeleteInformation(CurrentInfoId);
    end;
  end;
  EditingInformation:=onoff;
  if EditingInformation then
    b:=bsSingle
  else
    b:=bsNone;
  InfoFormation.BorderStyle:=b;
  BtnSearchFormation1.Visible:=EditingInformation;
  InfoDate.BorderStyle:=b;
  BtnChangeInfoDate.Visible:=EditingInformation;
  InfoAuthor.BorderStyle:=b;
  InfoAuthor.ReadOnly:=not EditingInformation;
  InfoText.BorderStyle:=b;
  InfoText.ReadOnly:=not EditingInformation;
  InfoFiles.BorderStyle:=b;
  if (EditingInformation)and(not (goEditing in InfoFiles.Options)) then
    InfoFiles.Options:=InfoFiles.Options+[goEditing];
  if (not EditingInformation)and(goEditing in InfoFiles.Options) then
     InfoFiles.Options:=InfoFiles.Options-[goEditing];
end;

procedure Tf_notelun.InfoNoteChange(Sender: TObject);
begin
 ModifiedInformation:=true;
end;

procedure Tf_notelun.InfoFilesValidateEntry(sender: TObject; aCol, aRow: Integer; const OldValue: string; var NewValue: String);
begin
 if OldValue<>NewValue then InfoNoteChange(sender);
end;

procedure Tf_notelun.SaveInformationNote;
var cmd: string;
    id: integer;
begin
 if CurrentInfoId>0 then begin
   id:=CurrentInfoId;
   cmd:='replace into infonotes (ID,FORMATION,DATE,AUTHOR,NOTE,FILES) values ('+
        IntToStr(CurrentInfoId)+',"'+
        SafeSqlText(InfoFormation.Text)+'",'+
        FormatFloat(f5,Finfodate)+',"'+
        SafeSqlText(InfoAuthor.Text)+'","'+
        SafeSqlText(InfoText.Text)+'","'+
        SafeSqlText(InfoFiles.Cells[0,0])+'")';
   dbnotes.Query(cmd);
   if dbnotes.LastError=0 then begin
     ModifiedInformation:=false;
     if NewInformation then
       NotesList(InfoFormation.Text,'I');
     ShowInfoNote(id);
     NewInformation:=false;
   end
   else
     ShowMessage('Error: '+dbnotes.ErrorMessage)
 end;
end;

procedure Tf_notelun.MenuItemNewInfoClick(Sender: TObject);
begin
  NewInformationNote;
end;

procedure Tf_notelun.MenuItemNewObsClick(Sender: TObject);
begin
  PageControl1.ActivePageIndex:=0;
end;

procedure Tf_notelun.NewInformationNote(formation:string='');
var cmd: string;
begin
  SetEditInformation(false);
  cmd:='insert into infonotes (ID,FORMATION,DATE,AUTHOR,NOTE,FILES) values ('+'null,"'+
       SafeSqlText(formation)+'",'+FormatFloat(f5,trunc(now))+',"","","")';
  dbnotes.Query(cmd);
 if dbnotes.LastError=0 then begin
   NewInformation:=true;
   CurrentInfoId:=dbnotes.LastInsertID;
   ModifiedInformation:=false;
   ShowInfoNote(CurrentInfoId);
   SetEditInformation(true);
   ModifiedInformation:=true;
 end
 else
   ShowMessage('Error: '+dbnotes.ErrorMessage)
end;

procedure Tf_notelun.DeleteInformation(id: integer);
var cmd: string;
begin
  NewInformation:=false;
  if id>0 then begin
    cmd:='delete from infonotes where ID='+inttostr(id);
    dbnotes.Query(cmd);
  end;
end;

procedure Tf_notelun.ShowObsNote(id: integer);
var cmd: string;
begin
  PageControl1.ActivePageIndex:=0;
  ClearObsNote;
end;

procedure Tf_notelun.SetEditObservation(onoff: boolean);
begin
  EditingObservation:=onoff;

end;

procedure Tf_notelun.SaveObservationNote;
begin

end;

procedure Tf_notelun.NewObservationNote(formation:string='');
begin

end;

procedure Tf_notelun.DeleteObservation(id: integer);
begin

end;


end.


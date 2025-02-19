unit BdlForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, NoDaveComponent, ExtCtrls, ComCtrls, DBXpress, DB,
  SqlExpr, IniFiles;

type

  TPLC20 = class(TNoDave)
  private
    PressureArray: array [1..50] of integer;
    PressureCount: integer;
  public
    function ReadPressure: Boolean;
    function WritePressure(SemiproductCodeNo: integer): boolean;
    procedure Reconnect;
    procedure Setup(Rack, Slot: integer; Ip: string);
  end;

  TPLC10 = class(TNoDave)
  public
    PhotoSatate: boolean;
    function ReadPhoto: Boolean;
    procedure Reconnect;
    procedure Setup(Rack, Slot: integer; Ip: string);
  end;

  TMainForm = class(TForm)
    Console: TMemo;
    Timer: TTimer;
    StatusBar: TStatusBar;
    DB: TSQLConnection;
    procedure TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
  public
    procedure Connecting(Sender: TObject);
  end;

var
  IniFile: TIniFile;
  MainForm: TMainForm;
  PLC20: TPLC20;
  PLC10: TPLC10;

implementation

{$R *.dfm}

function TPLC20.ReadPressure: Boolean;
var
  Buf: integer;
begin
  Result := False;
  if Active then
  begin
    ReadBytes(daveDB, 220, 840, 2, @Buf); //�������� ����������
    Buf:= hi(buf)+lo(buf)*256;
    inc(PressureCount);
    PressureArray[PressureCount]:=Buf;
    MainForm.Console.Lines.Add(DateTimeToStr(now)+'  ��������: '+IntToStr(Buf));
  end
  else
    Reconnect;
end;

function TPLC20.WritePressure(SemiproductCodeNo: integer): boolean;
var
  i: integer;
begin
  MainForm.Console.Lines.Add(DateTimeToStr(now)+'  ���������� � ����. ��������� '+IntToStr(SemiproductCodeNo));
  for i:=1 to PressureCount do begin
    MainForm.DB.ExecuteDirect('insert into rml2_outlet_water (semiproduct_code_no,seq_no,signal_name,signal_value,revision) values ('+IntToStr(SemiproductCodeNo)+','+IntToStr(i)+',''WATER_PRESSURE'','+IntToStr(PressureArray[i])+',sysdate)');
  end;
  PressureCount:=0;
end;

procedure TPLC20.Reconnect;
begin
  if Active then
    Disconnect;
  Connect(True);
end;

procedure TPLC20.Setup(Rack, Slot: integer; Ip: string);
begin
  CPURack := Rack;
  CPUSlot := Slot;
  IPAddress := Ip;
  Protocol := daveProtoISOTCP;
  onConnect := MainForm.Connecting;
  onDisconnect := MainForm.Connecting;
end;

function TPLC10.ReadPhoto: Boolean;
var
  Buf: integer;
  CodeBuf: integer;
begin
  Result := False;
  if Active then
  begin
    ReadBytes(daveDB, 215, 812, 1, @Buf); //����������� ����� �����������
    Buf:= (Buf and 2)div 2;
    MainForm.Console.Lines.Add(DateTimeToStr(now)+'  �����������: '+IntToStr(Buf));

    //����������� ����������
    if (Buf=1) and (MainForm.Timer.Interval=1000) then begin
      MainForm.Timer.Enabled:=False;
      MainForm.Timer.Interval:=6000;
      MainForm.Timer.Enabled:=True;
      Exit;
    end;
    //����� ����� � ���������������
    if (Buf=1) and (MainForm.Timer.Interval=6000) then begin
      PLC20.ReadPressure;
      MainForm.Timer.Enabled:=False;
      MainForm.Timer.Interval:=3000;
      MainForm.Timer.Enabled:=True;
      Exit;
    end;
    //����� ���� ����� ���������������
    if (Buf=1) and (MainForm.Timer.Interval=3000) then begin
      PLC20.ReadPressure;
      Exit;
    end;
    //����� ����� �� �����������
    if (Buf=0) and (MainForm.Timer.Interval=3000) then begin
      PLC20.ReadPressure;
      MainForm.Timer.Enabled:=False;
      MainForm.Timer.Interval:=3001;
      MainForm.Timer.Enabled:=True;
      Exit;
    end;
    //����� ����� �� ���������������
    if (Buf=0) and (MainForm.Timer.Interval=3001) then begin
      PLC20.ReadPressure;

      ReadBytes(daveDB, 239, 26, 2, @CodeBuf); //SemiproductCodeNo �� ����� � ������ �����
      CodeBuf:= hi(codebuf)+lo(codebuf)*256;
      PLC20.WritePressure(CodeBuf);

      MainForm.Timer.Enabled:=False;
      MainForm.Timer.Interval:=1000;
      MainForm.Timer.Enabled:=True;
      Exit;
    end;
  end
  else
    Reconnect;
end;

procedure TPLC10.Reconnect;
begin
  if Active then
    Disconnect;
  Connect(True);
end;

procedure TPLC10.Setup(Rack, Slot: integer; Ip: string);
begin
  CPURack := Rack;
  CPUSlot := Slot;
  IPAddress := Ip;
  Protocol := daveProtoISOTCP;
  onConnect := MainForm.Connecting;
  onDisconnect := MainForm.Connecting;
end;

procedure TMainForm.Connecting(Sender: TObject);
begin
  if PLC20.Active then
    StatusBar.Panels[0].Text := 'PLC20.���������� �����������     '
  else
    StatusBar.Panels[0].Text := 'PLC20.������� ����������     ';

  if PLC10.Active then
    StatusBar.Panels[0].Text := StatusBar.Panels[0].Text+'PLC10.���������� �����������     '
  else
    StatusBar.Panels[0].Text := StatusBar.Panels[0].Text+'PLC10.������� ����������     ';
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  PLC10.ReadPhoto;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if PLC20.Active then
    PLC20.Disconnect;
  if PLC10.Active then
    PLC10.Disconnect;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  IniFile:= TIniFile.Create(ExtractFilePath(Application.ExeName)+'level2.ini');

  DB.Params.Values['DataBase']:=IniFile.ReadString('database','alias','');
  DB.Params.Values['User_Name']:=IniFile.ReadString('database','login','');
  DB.Params.Values['Password']:=IniFile.ReadString('database','password','');
  PLC20:= TPLC20.Create(MainForm);
  PLC20.Setup(IniFile.ReadInteger('plc20','rack',0),IniFile.ReadInteger('plc20','slot',0),IniFile.ReadString('plc20','ip',''));
  PLC10:= TPLC10.Create(MainForm);
  PLC10.Setup(IniFile.ReadInteger('plc10','rack',0),IniFile.ReadInteger('plc10','slot',0),IniFile.ReadString('plc10','ip',''));;
  DB.Connected:=True;

  Connecting(Self);
end;

end.

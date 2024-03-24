object MainForm: TMainForm
  Left = 361
  Top = 260
  Width = 698
  Height = 570
  Caption = 'WaterPressure'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Console: TMemo
    Left = 0
    Top = 0
    Width = 690
    Height = 524
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 524
    Width = 690
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 32
    Top = 16
  end
  object DB: TSQLConnection
    ConnectionName = 'OracleConnection'
    DriverName = 'Oracle'
    GetDriverFunc = 'getSQLDriverORACLE'
    LibraryName = 'dbexpora.dll'
    LoginPrompt = False
    Params.Strings = (
      'DriverName=Oracle'
      'DataBase=lev2'
      'User_Name=mmk3rmrt'
      'Password=mmk3rmrt'
      'RowsetSize=20'
      'BlobSize=-1'
      'ErrorResourceFile='
      'LocaleCode=0000'
      'Oracle TransIsolation=ReadCommited'
      'OS Authentication=False'
      'Multiple Transaction=True'
      'Trim Char=False')
    VendorLib = 'oci.dll'
    Left = 72
    Top = 16
  end
end

program WaterPressure;

uses
  Forms,
  BdlForm in 'BdlForm.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

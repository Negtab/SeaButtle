program SeaBattle;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  WinUnitUser1 in 'WinUnitUser1.pas' {WinFormUser1},
  WinUnitUser2 in 'WinUnitUser2.pas' {WinFormUser2},
  InstructionUnit in 'InstructionUnit.pas' {InstructionForm},
  DevUnit in 'DevUnit.pas' {DevForm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Cyan Night');
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TWinFormUser1, WinFormUser1);
  Application.CreateForm(TWinFormUser2, WinFormUser2);
  Application.CreateForm(TInstructionForm, InstructionForm);
  Application.CreateForm(TDevForm, DevForm);
  Application.Run;
end.

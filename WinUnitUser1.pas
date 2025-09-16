unit WinUnitUser1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage;

type
  TWinFormUser1 = class(TForm)
    WinImageUser1: TImage;
    WinLabelUser1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WinFormUser1: TWinFormUser1;

implementation

{$R *.dfm}

procedure TWinFormUser1.FormCreate(Sender: TObject);
begin
    WinLabelUser1.Caption :='!Выиграл игрок 1!';
    WinImageUser1.Center := True;
end;

end.

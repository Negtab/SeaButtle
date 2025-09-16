unit WinUnitUser2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TWinFormUser2 = class(TForm)
    WinImageUser2: TImage;
    WinLabelUser2: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WinFormUser2: TWinFormUser2;

implementation

{$R *.dfm}

procedure TWinFormUser2.FormCreate(Sender: TObject);
begin
    WinLabelUser2.Caption :='!Выиграл игрок 2!';
    WinImageUser2.Center := True;
end;

end.

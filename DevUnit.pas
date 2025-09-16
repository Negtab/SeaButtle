unit DevUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TDevForm = class(TForm)
    AboutUsLabel: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DevForm: TDevForm;

implementation

{$R *.dfm}

end.

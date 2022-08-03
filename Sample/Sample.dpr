program Sample;

uses
  Vcl.Forms,
  uExample in 'uExample.pas' {fExample},
  uMinOpenGL in 'uMinOpenGL.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfExample, fExample);
  Application.Run;
end.

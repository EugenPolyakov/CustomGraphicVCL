unit uExample;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GraphicVCLExtension, GraphicVCLControls,
  GraphicVCLCommonControls, GraphicVCLBase, uMinOpenGL, OpenGL;

type
  TfExample = class(TForm)
    CGScene1: TCGScene;
    CGImage1: TCGImage;
    CGLabel1: TCGLabel;
    CGFontGenerator1: TCGFontGenerator;
    CGLabel2: TCGLabel;
    CGTextureLibrary1: TCGTextureLibrary;
    CGScrollBarTemplate1: TCGScrollBarTemplate;
    CGEdit1: TCGEdit;
    CGSpinEdit1: TCGSpinEdit;
    CGScrollBox1: TCGScrollBox;
    UpDownTemplate1: TUpDownTemplate;
    CGSpinEdit2: TCGSpinEdit;
    CGBorderTemplateWhite: TCGBorderTemplate;
    CGBorderTemplateRed: TCGBorderTemplate;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fExample: TfExample;

implementation

{$R *.dfm}

procedure TfExample.FormCreate(Sender: TObject);
begin
  CGTextureLibrary1.BilboardClass:= TBilboardObject;
  CGTextureLibrary1.TiledBilboardClass:= TTiledBilboardObject;

  UpDownTemplate1.ButtonUp:= CGTextureLibrary1.LoadTexture('up.bmp');
  UpDownTemplate1.ButtonDown:= CGTextureLibrary1.LoadTexture('down.bmp');
  CGScrollBarTemplate1.ButtonUp:= CGTextureLibrary1.LoadTexture('up.bmp');
  CGScrollBarTemplate1.ButtonDown:= CGTextureLibrary1.LoadTexture('down.bmp');
  CGScrollBarTemplate1.ButtonPage:= CGTextureLibrary1.LoadTexture('btn.bmp');

  CGImage1.Picture:= CGTextureLibrary1.LoadTexture('up.bmp');

  CGScene1.ClearMask:= GL_COLOR_BUFFER_BIT;

  CGBorderTemplateWhite.TopBorderImage:= TSolidBrush.Create(clWhite, 1);
  CGBorderTemplateWhite.BottomBorderImage:= CGBorderTemplateWhite.TopBorderImage;
  CGBorderTemplateWhite.LeftBorderImage:= CGBorderTemplateWhite.TopBorderImage;
  CGBorderTemplateWhite.RightBorderImage:= CGBorderTemplateWhite.TopBorderImage;
  CGBorderTemplateWhite.TopLeftCornerImage:= CGBorderTemplateWhite.TopBorderImage;
  CGBorderTemplateWhite.TopRightCornerImage:= CGBorderTemplateWhite.TopBorderImage;
  CGBorderTemplateWhite.BottomLeftCornerImage:= CGBorderTemplateWhite.TopBorderImage;
  CGBorderTemplateWhite.BottomRightCornerImage:= CGBorderTemplateWhite.TopBorderImage;

  CGBorderTemplateRed.TopBorderImage:= TSolidBrush.Create(clRed, 1);
  CGBorderTemplateRed.BottomBorderImage:= CGBorderTemplateRed.TopBorderImage;
  CGBorderTemplateRed.LeftBorderImage:= CGBorderTemplateRed.TopBorderImage;
  CGBorderTemplateRed.RightBorderImage:= CGBorderTemplateRed.TopBorderImage;
  CGBorderTemplateRed.TopLeftCornerImage:= CGBorderTemplateRed.TopBorderImage;
  CGBorderTemplateRed.TopRightCornerImage:= CGBorderTemplateRed.TopBorderImage;
  CGBorderTemplateRed.BottomLeftCornerImage:= CGBorderTemplateRed.TopBorderImage;
  CGBorderTemplateRed.BottomRightCornerImage:= CGBorderTemplateRed.TopBorderImage;
end;

end.

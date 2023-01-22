unit uMinOpenGL;

interface

uses
  System.UITypes, System.Types, WinApi.Windows, GraphicVCLBase, System.SysUtils,
  System.Classes, Vcl.Graphics, OpenGL;

type
  TCustomContext = class (TCGContextBase)
  private
    FGLRC: HGLRC;
    FPS: TPaintStruct;
    FPF: TPixelFormatDescriptor;
    FDC: HDC;
  protected
    procedure DoScissorActive(IsActive: Boolean); override;
    procedure SetScissor(const R: TRect); override;
  public
    constructor Create; override;
    procedure CreateContext(DC: HDC); override;
    procedure Deactivate; override;
    procedure Activate; override;
    procedure DestroyContext; override;
    procedure SetViewPort(const R: TRect); override;
    procedure PrepareNewFrame(ClearBits: LongWord; const Color: TColor4f); override;
    function IsContextCreated: Boolean; override;
  end;

  TTextObject = class (TSimple2DText)
  private
    FOffset: Integer;
    FText: TTextData;
  protected
    procedure SetColor(const Value: TColor); override;
    function GetColor: TColor; override;
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
    procedure InnerInitContext; override;
    procedure InnerFreeContext(AContext: TCGContextBase); override;
  public
    constructor Create(FOffset: Integer; const AInfo: TTextData);
    procedure Draw(X: Integer; Y: Integer); override;
    procedure DrawWithSize(const Pos: TPoint; const Size: TPoint); override;
    procedure ActualizeContext; override;
  end;

  TCustomFontGenerator = class (TCGFontGeneratorBase)
  private
    FFont: TFont;
    FIsGenerated: Boolean;
  protected
    procedure SetNeedRefresh(const Value: TNotifyEvent); override;
    function GetLineHeight: Integer; override;
  public
    constructor Create(AFont: TFont; const CharPages: string); override;
    destructor Destroy; override;
    function GenerateText(const AInfo: TTextData): TSimple2DText; override;
    procedure FreeContext(AContext: TCGContextBase); override;
    function GetCursorPosition(const AInfo: TTextData; X, Y: Integer): TTextPosition; overload; override;
    function GetCursorPosition(const AInfo: TTextData; Index: Integer): TTextPosition; overload; override;
    function GetSizes(const AInfo: TTextData; var ASize: TPoint): Boolean; override;
  end;

  TBilboardObject = class (TCGBilboard)
  private
    FGraphic: TBitmap;
    FTexture: GLUInt;
  protected
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
    procedure InnerFreeContext(AContext: TCGContextBase); override;
    procedure InnerInitContext; override;
  public
    procedure ActualizeContext; override;
    procedure DrawBilboard(const Bilboard: TRect; const TexCoord: TRect); override;
    destructor Destroy; override;
    procedure FillFromFile(const AFileName: string); override;
    constructor Create(AOwner: TCGTextureLibrary; const AName: string);
      override;
  end;

  TTiledBilboardObject = class (TBilboardObject)
  public
    procedure DrawWithSize(const Pos: TPoint; const Size: TPoint); override;
  end;

  TSolidBrush = class (TCGSolidBrush)
  private
  protected
    procedure InnerInitContext; override;
    procedure InnerFreeContext(AContext: TCGContextBase); override;
  public
    procedure DrawFigure(const Pos: TPoint; const APonts: array of TPoint);
      override;
    procedure ActualizeContext; override;
  end;

const
  GL_BGR = $80E0;

implementation

{ TCustomContext }

procedure TCustomContext.Activate;
begin
  if wglGetCurrentContext <> FGLRC then
    wglMakeCurrent(FDC, FGLRC);
end;

constructor TCustomContext.Create;
begin
  inherited;

end;

procedure TCustomContext.CreateContext(DC: HDC);
var nPixelFormat : Integer;
begin
  FDC:= DC;
  FPF.nSize:= SizeOf(FPF);
  FPF.nVersion:= 1;
  FPF.dwFlags:= PFD_DRAW_TO_WINDOW or
    PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  FPF.cColorBits:= 32;
  FPF.cDepthBits:= 24;
  FPF.cStencilBits:= 8;
  FPF.iPixelType:= PFD_TYPE_RGBA;

  nPixelFormat := ChoosePixelFormat (DC, @FPF);
  SetPixelFormat (DC, nPixelFormat, @FPF);
  DescribePixelFormat(DC, nPixelFormat, SizeOf(FPF), FPF);
  //ReleaseDC(DC, Handle);
  //DC := GetDC(Handle);
  FGLRC := wglCreateContext(DC);
  wglMakeCurrent(DC, FGLRC);
end;

procedure TCustomContext.Deactivate;
begin
  wglMakeCurrent(0, 0);
end;

procedure TCustomContext.DestroyContext;
begin
  wglMakeCurrent(0, 0);;
  wglDeleteContext(FGLRC);
end;

procedure TCustomContext.DoScissorActive(IsActive: Boolean);
begin
  if IsActive then
    glEnable(GL_SCISSOR_TEST)
  else
    glDisable(GL_SCISSOR_TEST);
end;

function TCustomContext.IsContextCreated: Boolean;
begin
  Result:= FGLRC <> 0;
end;

procedure TCustomContext.PrepareNewFrame(ClearBits: LongWord;
  const Color: TColor4f);
begin
  glClearColor(Color.Red, Color.Green, Color.Blue, Color.Alpha);
  glClear(ClearBits);
end;

procedure TCustomContext.SetScissor(const R: TRect);
begin
  inherited;
  glScissor(r.Left, r.Top, r.Width, r.Height);
end;

procedure TCustomContext.SetViewPort(const R: TRect);
var f: array [0..15] of single;
begin
  glViewport(R.Left, R.Top, R.Right, R.Bottom);
  glLoadIdentity;
  glOrtho(0, R.Width, R.Height, 0, 0, 3);
  glGetFloatv(GL_MODELVIEW_MATRIX, @f[0]);
  glTranslatef(0, 0, -2);
end;

{ TSolidBrush }

procedure TSolidBrush.ActualizeContext;
begin
end;

procedure TSolidBrush.DrawFigure(const Pos: TPoint;
  const APonts: array of TPoint);
var
  i: Integer;
begin
  glColor3f(Color4f.Red, Color4f.Green, Color4f.Blue);
  glBegin(GL_TRIANGLE_STRIP);
  for i := 0 to High(APonts) do with APonts[i] do
    glVertex2f(X + Pos.X, Y + Pos.Y);
  glEnd;
end;

procedure TSolidBrush.InnerFreeContext(AContext: TCGContextBase);
begin
  inherited;

end;

procedure TSolidBrush.InnerInitContext;
begin
  inherited;

end;

{ TCustomFontGenerator }

constructor TCustomFontGenerator.Create(AFont: TFont; const CharPages: string);
begin
  inherited;
  FFont:= TFont.Create;
  FFont.Assign(AFont);
end;

destructor TCustomFontGenerator.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure TCustomFontGenerator.FreeContext(AContext: TCGContextBase);
begin
  inherited;
  if FIsGenerated then begin
    glDeleteLists(1, 256);
    FIsGenerated:= False;
  end;
end;

function TCustomFontGenerator.GenerateText(
  const AInfo: TTextData): TSimple2DText;
begin
  if not FIsGenerated then begin
    FIsGenerated:= wglUseFontBitmapsA(GetDC(0), 0, 255, 1);
  end;
  Result:= TTextObject.Create(1, AInfo);
end;

function TCustomFontGenerator.GetCursorPosition(const AInfo: TTextData; X,
  Y: Integer): TTextPosition;
begin

end;

function TCustomFontGenerator.GetCursorPosition(const AInfo: TTextData;
  Index: Integer): TTextPosition;
begin

end;

function TCustomFontGenerator.GetLineHeight: Integer;
begin

end;

function TCustomFontGenerator.GetSizes(const AInfo: TTextData; var ASize: TPoint): Boolean;
begin

end;

procedure TCustomFontGenerator.SetNeedRefresh(const Value: TNotifyEvent);
begin
  inherited;

end;

{ TTextObject }

procedure TTextObject.ActualizeContext;
begin
  inherited;

end;

constructor TTextObject.Create(FOffset: Integer; const AInfo: TTextData);
begin

end;

procedure TTextObject.Draw(X, Y: Integer);
begin
end;

procedure TTextObject.DrawWithSize(const Pos, Size: TPoint);
begin
  Draw(Pos.X, Pos.Y);
end;

function TTextObject.GetColor: TColor;
begin

end;

function TTextObject.GetHeight: Integer;
begin

end;

function TTextObject.GetWidth: Integer;
begin

end;

procedure TTextObject.InnerFreeContext(AContext: TCGContextBase);
begin
  inherited;

end;

procedure TTextObject.InnerInitContext;
begin
  inherited;

end;

procedure TTextObject.SetColor(const Value: TColor);
begin
  inherited;

end;

{ TBilboardObject }

procedure TBilboardObject.ActualizeContext;
begin
  inherited;

end;

constructor TBilboardObject.Create(AOwner: TCGTextureLibrary;
  const AName: string);
begin
  inherited;

end;

destructor TBilboardObject.Destroy;
begin
  FGraphic.Free;
  inherited;
end;

procedure TBilboardObject.DrawBilboard(const Bilboard, TexCoord: TRect);
begin
  glBindTexture(GL_TEXTURE_2D, FTexture);
  glEnable(GL_TEXTURE_2D);

  glColor3f(1, 1, 1);
  glBegin(GL_TRIANGLE_STRIP);
  glTexCoord2f(Bilboard.Width / TexCoord.Right, TexCoord.Top / TexCoord.Bottom);
  glVertex2f(Bilboard.Right, Bilboard.Top);

  glTexCoord2f(TexCoord.Left / TexCoord.Right, TexCoord.Top / TexCoord.Bottom);
  glVertex2f(Bilboard.Left, Bilboard.Top);

  glTexCoord2f(Bilboard.Width / TexCoord.Right, Bilboard.Height / TexCoord.Bottom);
  glVertex2f(Bilboard.Right, Bilboard.Bottom);

  glTexCoord2f(TexCoord.Left / TexCoord.Right, Bilboard.Height / TexCoord.Bottom);
  glVertex2f(Bilboard.Left, Bilboard.Bottom);
  glEnd;
  glDisable(GL_TEXTURE_2D);
end;

procedure TBilboardObject.FillFromFile(const AFileName: string);
var p: TPicture;
begin
  if FGraphic <> nil then
    raise Exception.Create('Already initialized');
  p:= TPicture.Create;
  try
    try
      p.LoadFromFile(AFileName);
      FGraphic:= TBitmap.Create;
      TBitmap(FGraphic).AlphaFormat:= afIgnored;
      TBitmap(FGraphic).PixelFormat:= pf24bit;
      FGraphic.SetSize(p.Width, p.Height);
      TBitmap(FGraphic).Canvas.Draw(0, 0, p.Graphic);
    finally
      p.Free;
    end;
  except on E: Exception do
    raise Exception.Create(E.Message + ' File: ' + AFileName);
  end;
end;

function TBilboardObject.GetHeight: Integer;
begin
  if FGraphic <> nil then
    Result:= FGraphic.Height
  else
    Result:= 0;
end;

function TBilboardObject.GetWidth: Integer;
begin
  if FGraphic <> nil then
    Result:= FGraphic.Width
  else
    Result:= 0;
end;

procedure TBilboardObject.InnerFreeContext(AContext: TCGContextBase);
begin
  inherited;
  if FTexture <> 0 then begin
    glDeleteTextures(1, @FTexture);
    FTexture:= 0;
  end;
end;

procedure TBilboardObject.InnerInitContext;
var Target: GLenum;
    internalFormat: GLint;
    pixelFormat: GLenum;
    pixelType: GLenum;
    ProcessByLine: Boolean;
    lineSize: Integer;
    i: Integer;
    full: array of Byte;
begin
  Target:= GL_TEXTURE_2D;
  glGenTextures(1, @FTexture);
  internalFormat:= GL_RGB;
  pixelFormat:= GL_RGB;
  lineSize:= 3 * FGraphic.Width;
  pixelType:= GL_UNSIGNED_BYTE;

  glBindTexture(Target, FTexture);

  //glTexParameteri(Target, GL_GENERATE_MIPMAP, GL_TRUE);
  glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);//_MIPMAP_LINEAR);
  glTexParameteri(Target, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(Target, GL_TEXTURE_WRAP_T, GL_REPEAT);

  glTexParameteri(Target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  SetLength(full, LineSize * FGraphic.Height);
  for i := 0 to FGraphic.Height - 1 do
    Move(FGraphic.ScanLine[i]^, full[i * 3 * FGraphic.Width], 3 * FGraphic.Width);

  glTexImage2D(Target, 0, internalFormat, FGraphic.Width, FGraphic.Height, 0,
    pixelFormat, pixelType, @full[0]);
end;

{ TTiledBilboardObject }

procedure TTiledBilboardObject.DrawWithSize(const Pos, Size: TPoint);
var b, t: TRect;
begin
  b.Create(Pos, Size.X, Size.Y);
  t.Create(0, 0, Width, Height);
  DrawBilboard(b, t);
end;

initialization

  SetContextClass(TCustomContext);
  SetDefaultFontGeneratorClass(TCustomFontGenerator);
  SetSolidBrushClass(TSolidBrush);

end.

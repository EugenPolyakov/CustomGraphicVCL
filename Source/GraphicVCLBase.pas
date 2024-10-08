unit GraphicVCLBase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls,
  Vcl.Forms, System.UITypes, System.Generics.Collections;

type
  TColor4f = record
    Red, Green, Blue, Alpha: Single;
    constructor Create(Color: TColor); overload;
    constructor Create(Color: TColor; AAlpha: Single); overload;
    class operator Implicit(const V: TColor4f): TColor;
  end;

  TScissorRect = record
  private
    function GetRight: Integer; inline;
  public
    Left: Integer;
    Bottom: Integer;
    Width: Integer;
    Height: Integer;
    constructor Create(const R: TRect; ABottom: Integer);
    property Right: Integer read GetRight;
  end;

  TCGContextBase = class
  private
    FScissorList: TList<TScissorRect>;
  protected
    procedure SetScissor(const R: TScissorRect); virtual; abstract;
    procedure DoScissorActive(IsActive: Boolean); virtual; abstract;
  public
    constructor Create; virtual;
    procedure Activate; virtual; abstract;
    procedure SetViewPort(const R: TRect); virtual; abstract;
    procedure PrepareNewFrame(ClearBits: LongWord; const Color: TColor4f); virtual; abstract;
    procedure Deactivate; virtual;
    procedure CreateContext(DC: HDC); virtual;
    procedure DestroyContext; virtual; abstract;
    function IsContextCreated: Boolean; virtual; abstract;
    procedure PushScissor(const R: TScissorRect);
    procedure PushNewScissor(const R: TScissorRect);
    procedure PopScissor;
    destructor Destroy; override;
  end;

  TObjectWithContext = class (TInterfacedObject)
  private
    FContextCount: Integer;
  protected
    procedure InnerInitContext; virtual; abstract;
    procedure InnerFreeContext(AContext: TCGContextBase); virtual; abstract;
  public
    procedure Reference; inline;
    procedure Release; inline;
    procedure InitContext;
    procedure ActualizeContext; virtual; abstract;
    procedure FreeContext(AContext: TCGContextBase);
    procedure FreeContextAndRelease(AContext: TCGContextBase);
  end;

  TGeneric2DObject = class (TObjectWithContext)
  private
  protected
  public
    procedure DrawWithSize(const Pos: TPoint; const Size: TSize); virtual;
    procedure DrawFigure(const Pos: TPoint; const APonts: array of TPoint); virtual; abstract;
  end;

  TSized2DObject = class (TGeneric2DObject)
  private
  protected
    function GetHeight: Integer; virtual; abstract;
    function GetWidth: Integer; virtual; abstract;
  public
    procedure Draw(X, Y: Integer); virtual;
    property Height: Integer read GetHeight;
    property Width: Integer read GetWidth;
  end;

  TGeneric2DObjectClass = class of TGeneric2DObject;

  TColored2DObject = class (TSized2DObject)
  private
  protected
    procedure SetColor(const Value: TColor); virtual; abstract;
    function GetColor: TColor; virtual; abstract;
  public
    property Color: TColor read GetColor write SetColor;
  end;

  TTextData = record
    Layout: TTextLayout;
    Alignment: TAlignment;
    Text: string;
    WordWrap: Boolean;
    Color: TColor;
    MaxWidth: Integer;
    MaxHeight: Integer;
  end;

  TTextPosition = record
    SymbolPosition: Integer;
    LinePosition: Integer;
    InLinePosition: Integer;
    X, Y: Integer;
    class operator Equal(const a, b: TTextPosition) : Boolean;
    class operator NotEqual(const a, b: TTextPosition) : Boolean;
  end;

  TSimple2DText = class (TColored2DObject)
  private
    FReady: Boolean;
  protected
  public
    property Ready: Boolean read FReady write FReady;
    procedure DrawFrame(X, Y: Integer; const ARect: TRect); virtual; abstract;
  end;

  TCGContextBaseClass = class of TCGContextBase;

  TCGFontGeneratorBase = class
  private
  protected
    procedure SetNeedRefresh(const Value: TNotifyEvent); virtual; abstract;
    function GetLineHeight: Integer; virtual; abstract;
  public
    constructor Create(AFont: TFont; const CharPages: string); virtual; abstract;
    function GenerateText(const AInfo: TTextData): TSimple2DText; virtual; abstract;
    function GetCursorPosition(const AInfo: TTextData; X, Y: Integer): TTextPosition; overload; virtual; abstract;
    function GetCursorPosition(const AInfo: TTextData; Index: Integer): TTextPosition; overload; virtual; abstract;
    function GetSizes(const AInfo: TTextData; var ASize: TPoint): Boolean; virtual; abstract;
    procedure FreeContext(AContext: TCGContextBase); virtual; abstract;
    property OnNeedRefresh: TNotifyEvent write SetNeedRefresh;
    property LineHeight: Integer read GetLineHeight;
  end;

  TCGFontGeneratorClass = class of TCGFontGeneratorBase;

  TCGTexturedBilboard = class;
  TCGTexturedBilboardClass = class of TCGTexturedBilboard;

  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  TCGTextureLibrary = class (TComponent)
  private
    FBilboardClass: TCGTexturedBilboardClass;
    FTiledBilboardClass: TCGTexturedBilboardClass;
    FDictionary: TDictionary<string, TCGTexturedBilboard>;
    procedure OnTextureRemove(Sender: TObject; const Item: TCGTexturedBilboard;
      Action: TCollectionNotification);
  protected
    procedure RemoveTexture(const AName: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property BilboardClass: TCGTexturedBilboardClass read FBilboardClass write FBilboardClass;
    property TiledBilboardClass: TCGTexturedBilboardClass read FTiledBilboardClass write FTiledBilboardClass;
    function LoadTexture(const AFileName: string; Tiled: Boolean = False): TCGTexturedBilboard;
  end;

  TCGSolidBrush = class (TGeneric2DObject)
  private
    FColor: TColor4f;
    function GetColor: TColor;
  protected
  public
    constructor Create(AColor: TColor; Alpha: Single); virtual;
    property Color: TColor read GetColor;
    property Color4f: TColor4f read FColor;
  end;

  TCGSolidBrushClass = class of TCGSolidBrush;

  TCGBilboard = class (TSized2DObject)
  private
  protected
  public
    procedure DrawWithSize(const Pos: TPoint; const Size: TSize); override;
    procedure DrawBilboard(const Bilboard, TexCoord: TRect); virtual; abstract;
  end;

  TCGTexturedBilboard = class (TCGBilboard)
  private
    FOwner: TCGTextureLibrary;
    FName: string;
  protected
  public
    procedure BeforeDestruction; override;
    property Name: string read FName;
    procedure FillFromFile(const AFileName: string); virtual; abstract;
    constructor Create(AOwner: TCGTextureLibrary; const AName: string); virtual;
  end;

procedure SetContextClass(AContextClass: TCGContextBaseClass);
procedure SetDefaultFontGeneratorClass(AFontGeneratorClass: TCGFontGeneratorClass);
procedure SetSolidBrushClass(ASolidBrushClass: TCGSolidBrushClass);
function GetFontGeneratorClass: TCGFontGeneratorClass;
function GetContextClass: TCGContextBaseClass;
function GetSolidBrush(AColor: TColor; Alpha: Single = 1): TCGSolidBrush;

implementation

var
  ContextClass: TCGContextBaseClass;
  FontGeneratorClass: TCGFontGeneratorClass;
  SolidBrushClass: TCGSolidBrushClass;

procedure SetSolidBrushClass(ASolidBrushClass: TCGSolidBrushClass);
begin
  SolidBrushClass:= ASolidBrushClass;
end;

function GetSolidBrush(AColor: TColor; Alpha: Single): TCGSolidBrush;
begin
  Result:= SolidBrushClass.Create(AColor, Alpha);
end;

function GetContextClass: TCGContextBaseClass;
begin
  Result:= ContextClass;
  if Result = nil then
    Result:= TCGContextBase;
end;

procedure SetContextClass(AContextClass: TCGContextBaseClass);
begin
  ContextClass:= AContextClass;
end;

procedure SetDefaultFontGeneratorClass(AFontGeneratorClass: TCGFontGeneratorClass);
begin
  FontGeneratorClass:= AFontGeneratorClass;
end;

function GetFontGeneratorClass: TCGFontGeneratorClass;
begin
  Result:= FontGeneratorClass;
end;

{ TCGContextBase }

constructor TCGContextBase.Create;
begin
  FScissorList:= TList<TScissorRect>.Create;
end;

procedure TCGContextBase.CreateContext(DC: HDC);
begin

end;

procedure TCGContextBase.Deactivate;
begin
  if FScissorList.Count > 0 then
    raise Exception.Create('Have active scissor');
end;

destructor TCGContextBase.Destroy;
begin
  FScissorList.Free;
  inherited;
end;

procedure TCGContextBase.PopScissor;
begin
  if FScissorList.Count > 0 then
    FScissorList.Delete(FScissorList.Count - 1)
  else
    raise Exception.Create('No active scissor');
  if FScissorList.Count > 0 then
    SetScissor(FScissorList[FScissorList.Count - 1])
  else
    DoScissorActive(False);
end;

procedure TCGContextBase.PushNewScissor(const R: TScissorRect);
begin
  if FScissorList.Count = 0 then
    DoScissorActive(True);

  SetScissor(R);
  FScissorList.Add(R);
end;

procedure TCGContextBase.PushScissor(const R: TScissorRect);
var fixed, orig: TScissorRect;
begin
  if FScissorList.Count = 0 then begin
    DoScissorActive(True);

    SetScissor(R);
    FScissorList.Add(R);
  end else begin
    orig:= FScissorList.Last;
    fixed:= R;
    if fixed.Left < orig.Left then begin
      fixed.Left:= orig.Left;
      if R.Left + R.Width > orig.Left + orig.Width then
        fixed.Width:= orig.Left
      else
        fixed.Width:= R.Width - (orig.Left - R.Left);
    end else
      if R.Left + R.Width > orig.Left + orig.Width then
        fixed.Width:= orig.Left + orig.Width - fixed.Left;

    if fixed.Bottom < orig.Bottom then begin
      fixed.Bottom:= orig.Bottom;
      if R.Bottom + R.Height > orig.Bottom + orig.Height then
        fixed.Height:= orig.Height
      else
        fixed.Height:= R.Height - (orig.Bottom - R.Bottom);
    end else
      if R.Bottom + R.Height > orig.Bottom + orig.Height then
        fixed.Height:= orig.Bottom + orig.Height - fixed.Bottom;

    if fixed.Width < 0 then
      fixed.Width:= 0;
    if fixed.Height < 0 then
      fixed.Height:= 0;

    SetScissor(fixed);
    FScissorList.Add(fixed);
  end;
end;

{ TCGBilboard }

procedure TCGBilboard.DrawWithSize(const Pos: TPoint; const Size: TSize);
var b, t: TRect;
begin
  b.Create(Pos, Size.cx, Size.cy);
  t.Create(0, 0, Width, Height);
  DrawBilboard(b, t);
end;

{ TCGTextureLibrary }

constructor TCGTextureLibrary.Create(AOwner: TComponent);
begin
  inherited;
  FDictionary:= TDictionary<string, TCGTexturedBilboard>.Create;
  FDictionary.OnValueNotify:= OnTextureRemove;
end;

destructor TCGTextureLibrary.Destroy;
begin
  FDictionary.Free;
  inherited;
end;

function TCGTextureLibrary.LoadTexture(const AFileName: string; Tiled: Boolean): TCGTexturedBilboard;
var TextureName: string;
begin
  if AFileName = '' then
    Exit(nil);
  TextureName:= StringReplace(AnsiUpperCase(AFileName), '\', '/', [rfReplaceAll]);
  if Tiled then
    TextureName:= ':' + TextureName;
  if not FDictionary.TryGetValue(TextureName, Result) then begin
    if Tiled then
      Result:= FTiledBilboardClass.Create(Self, TextureName)
    else
      Result:= FBilboardClass.Create(Self, TextureName);
    Result.FillFromFile(AFileName);
    FDictionary.Add(TextureName, Result);
  end;
end;

procedure TCGTextureLibrary.OnTextureRemove(Sender: TObject;
  const Item: TCGTexturedBilboard; Action: TCollectionNotification);
begin
  if Action = cnRemoved then
    Item.FOwner:= nil;
end;

procedure TCGTextureLibrary.RemoveTexture(const AName: string);
begin
  FDictionary.Remove(AName);
end;

{ TColor4f }

constructor TColor4f.Create(Color: TColor);
begin
  Color:= ColorToRGB(Color);
  Red:= Color and $FF / 255;
  Green:= Color shr 8 and $FF / 255;
  Blue:= Color shr 16 and $FF / 255;
  Alpha:= 1;
end;

constructor TColor4f.Create(Color: TColor; AAlpha: Single);
begin
  Color:= ColorToRGB(Color);
  Red:= Color and $FF / 255;
  Green:= Color shr 8 and $FF / 255;
  Blue:= Color shr 16 and $FF / 255;
  Alpha:= AAlpha;
end;

class operator TColor4f.Implicit(const V: TColor4f): TColor;
begin
  Result:= Round(V.Red * 255) + Round(V.Green * 255) shl 8 + Round(V.Blue * 255) shl 16;
end;

{ TGeneric2DObject }

procedure TGeneric2DObject.DrawWithSize(const Pos: TPoint; const Size: TSize);
begin
  DrawFigure(Pos, [TPoint.Create(0, 0), TPoint.Create(0, Size.cy), TPoint.Create(Size.cx, 0), TPoint(Size)]);
end;

{ TSized2DObject }

procedure TSized2DObject.Draw(X, Y: Integer);
begin
  DrawWithSize(TPoint.Create(X, Y), TSize.Create(Width, Height));
end;

{ TCGSolidBrush }

constructor TCGSolidBrush.Create(AColor: TColor; Alpha: Single);
begin
  inherited Create;
  FColor.Create(AColor, Alpha);
end;

function TCGSolidBrush.GetColor: TColor;
begin
  Result:= FColor;
end;

{ TTextPosition }

class operator TTextPosition.Equal(const a, b: TTextPosition): Boolean;
begin
  Result:= (a.SymbolPosition = b.SymbolPosition) and
    (a.LinePosition = b.LinePosition) and
    (a.InLinePosition = b.InLinePosition);
end;

class operator TTextPosition.NotEqual(const a, b: TTextPosition): Boolean;
begin
  Result:= (a.SymbolPosition <> b.SymbolPosition) or
    (a.LinePosition <> b.LinePosition) or
    (a.InLinePosition <> b.InLinePosition);
end;

{ TCGTexturedBilboard }

procedure TCGTexturedBilboard.BeforeDestruction;
begin
  inherited;
  if Assigned(FOwner) then
    FOwner.RemoveTexture(FName);
end;

constructor TCGTexturedBilboard.Create(AOwner: TCGTextureLibrary; const AName: string);
begin
  inherited Create;
  FOwner:= AOwner;
  FName:= AName;
end;

{ TScissorRect }

constructor TScissorRect.Create(const R: TRect; ABottom: Integer);
begin
  Left:= R.Left;
  Bottom:= ABottom;
  Height:= R.Height;
  Width:= R.Width;
end;

function TScissorRect.GetRight: Integer;
begin
  Result:= Left + Width;
end;

{ TObjectWithContext }

procedure TObjectWithContext.FreeContext(AContext: TCGContextBase);
begin
  Dec(FContextCount);
  if FContextCount = 0 then
    InnerFreeContext(AContext);
end;

procedure TObjectWithContext.FreeContextAndRelease(AContext: TCGContextBase);
begin
  FreeContext(AContext);
  Release;
end;

procedure TObjectWithContext.InitContext;
begin
  if FContextCount = 0 then
    InnerInitContext;
  Inc(FContextCount);
end;

procedure TObjectWithContext.Reference;
begin
  _AddRef;
end;

procedure TObjectWithContext.Release;
begin
  _Release;
end;

end.

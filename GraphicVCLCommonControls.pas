unit GraphicVCLCommonControls;

interface

uses System.SysUtils, System.Classes, Vcl.StdCtrls, Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics, GraphicVCLBase, GraphicVCLControls, Vcl.Buttons,
  System.Generics.Collections, GraphicVCLExtension;

type
  TCGLabel = class (TControlWithFont)
  private
    FLayout: TTextLayout;
    FAlignment: TAlignment;
    FWordWrap: Boolean;
    FText: TTextObjectBase;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetLayout(const Value: TTextLayout);
    procedure SetWordWrap(const Value: Boolean);
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure CMFontGeneratorChanged(var Message: TCMFontGeneratorChanged); message CM_FONTGENERATORCHANGED;
  protected
    procedure AdjustSize; override;
    function EnsureTextReady: Boolean;
    procedure DoRender(Context: TCGContextBase; R: TRect); override;
    procedure DesignCalcRect(var R: TRect; var Flags: TTextFormat);
    procedure DesignPaint; override;
  public
    procedure FreeContext(Context: TCGContextBase); override;
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Anchors;
    property AutoSize default True;
    property Caption;
    property Constraints;
    property Enabled;
    property Touch;
    property Layout: TTextLayout read FLayout write SetLayout default tlTop;
    property Visible;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property OnClick;
    property OnDblClick;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

  TBilboardNotify = procedure (ABilboard: TCGBilboard) of object;

  TCGButton = class (TControlWithFont)
  private type
    TBilboardContext = TContextController<TCGBilboard>;
    PBilboardContext = ^TBilboardContext;
  private
    FText: TTextObjectBase;
    FHoverPicture: TContextController<TCGBilboard>;
    FPressedPicture: TContextController<TCGBilboard>;
    FDefaultPicture: TContextController<TCGBilboard>;
    FDisabledPicture: TContextController<TCGBilboard>;
    FHoverDisabledPicture: TContextController<TCGBilboard>;
    FState: TButtonState;
    FLastPicture: PBilboardContext;
    FOnNewPictureRender: TBilboardNotify;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure SetDefaultPicture(const Value: TCGBilboard);
    procedure SetDisabledPicture(const Value: TCGBilboard);
    procedure SetHoverPicture(const Value: TCGBilboard);
    procedure SetPressedPicture(const Value: TCGBilboard);
    procedure SetHoverDisabledPicture(const Value: TCGBilboard);
  protected
    function EnsureTextReady: Boolean;
    procedure DoRender(Context: TCGContextBase; R: TRect); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DesignCalcRect(var R: TRect; var Flags: TTextFormat);
    procedure DesignPaint; override;
  public
    procedure FreeContext(Context: TCGContextBase); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DefaultPicture: TCGBilboard read FDefaultPicture.Value write SetDefaultPicture;
    property HoverPicture: TCGBilboard read FHoverPicture.Value write SetHoverPicture;
    property PressedPicture: TCGBilboard read FPressedPicture.Value write SetPressedPicture;
    property DisabledPicture: TCGBilboard read FDisabledPicture.Value write SetDisabledPicture;
    property HoverDisabledPicture: TCGBilboard read FHoverDisabledPicture.Value write SetHoverDisabledPicture;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Text;
    property Touch;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnNewPictureRender: TBilboardNotify read FOnNewPictureRender write FOnNewPictureRender;
  end;

  TCGEdit = class (TControlWithInput)
  private
    FSelectionColor: TColor;
    FSelectionBrush: TContextController<TCGSolidBrush>;
    FCursorBrush: TContextController<TCGSolidBrush>;
    FTextOffset: Integer;
    FText: TTextObjectBase;
    FSelStart, FSelEnd: TTextPosition;
    FOnChange: TNotifyEvent;
    FHideSelection: Boolean;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure CMFontGeneratorChanged(var Message: TCMFontGeneratorChanged); message CM_FONTGENERATORCHANGED;

    procedure WMCopy(var Message: TWMCopy); message WM_COPY;
    procedure WMClear(var Message: TWMClear); message WM_CLEAR;
    procedure WMCut(var Message: TWMCut); message WM_CUT;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;

    function GetSelLength: Integer;
    function GetSelStart: Integer;
    function GetSelText: string;
    procedure SetSelLength(const Value: Integer);
    procedure SetSelStart(const Value: Integer);
    procedure SetSelText(const Value: string);
    procedure SetSelectionColor(const Value: TColor);
    procedure SetHideSelection(const Value: Boolean);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function EnsureTextReady: Boolean;
    procedure EnsureSelectionBrushReady;
    procedure DoRender(Context: TCGContextBase; R: TRect); override;
    procedure DesignPaint; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Change; virtual;
    procedure DblClick; override;
  public
    procedure FreeContext(Context: TCGContextBase); override;
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelText: string read GetSelText write SetSelText;
  published
    property Align;
    property Anchors;
    property Text;
    property SelectionColor: TColor read FSelectionColor write SetSelectionColor;
    property Constraints;
    property Enabled;
    property Touch;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property HideSelection: Boolean read FHideSelection write SetHideSelection default True;
  end;

  TCGSpinEdit = class (TCGEdit)
  private
    FMinValue: Integer;
    FUpDown: TUpDownTemplate;
    FMaxValue: Integer;
    FMouseControl: TMouseControlState;
    FUpIsActive: Boolean;
    FRepeatTimer: DWORD;
    FDoRepeat: Boolean;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMRepeatTimer(var Message: TMessage); message CM_REPEATTIMER;
    procedure SetMaxValue(const Value: Integer);
    procedure SetMinValue(const Value: Integer);
    procedure SetUpDown(const Value: TUpDownTemplate);
    procedure SetValue(const Value: Integer);
    function GetValue: Integer;
  protected
    procedure DesignPaint; override;
    procedure DoRender(Context: TCGContextBase; R: TRect); override;
    procedure KeyPress(var Key: Char); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    procedure IncrementValue(Incr: Integer);
    constructor Create(AOwner: TComponent); override;
    property Value: Integer read GetValue write SetValue;
  published
    property UpDown: TUpDownTemplate read FUpDown write SetUpDown;
    property MaxValue: Integer read FMaxValue write SetMaxValue;
    property MinValue: Integer read FMinValue write SetMinValue;
  end;

  TScrolledWithFont = class (TControlWithInput)
  strict private
    FActualWidth: Integer;
    FActualHeight: Integer;
    FScrollRealignCount: Integer;
    FScrollRealignNeeded: Boolean;
    procedure CMRepeatTimer(var Message: TMessage); message CM_REPEATTIMER;
    procedure SetActualHeight(const Value: Integer);
    procedure SetActualWidth(const Value: Integer);
    procedure SetHorizontalScrollBar(const Value: TCGScrollBarTemplate);
    procedure SetVerticalScrollBar(const Value: TCGScrollBarTemplate);
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
  protected
    FScrollBars: THVScrolls;
    property ScrollRealignNeeded: Boolean read FScrollRealignNeeded;
    function GetScrollRect: TRect; virtual;
    procedure BeginReAlignScrolls;
    procedure EndReAlignScrolls;
    procedure DoRealign; virtual;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    property ActualWidth: Integer read FActualWidth write SetActualWidth;
    property ActualHeight: Integer read FActualHeight write SetActualHeight;
    procedure OnScroll(const Scroll: TScrollBarStatus); virtual;
    property HorizontalScrollBar: TCGScrollBarTemplate read FScrollBars.Horizontal.Template write SetHorizontalScrollBar;
    property VerticalScrollBar: TCGScrollBarTemplate read FScrollBars.Vertical.Template write SetVerticalScrollBar;
  public
    constructor Create(AOwner: TComponent); override;
  published
  end;

  TCustomList = class;
  TTextObjectWithObject = record
    Text: TTextObjectBase;
    UserObject: TObject;
  end;

  TCGListBoxStrings = class (TStrings)
  private
    FLines: TList<TTextObjectWithObject>;
    FOwner: TCustomList;
    procedure OnLineNotify(Sender: TObject; const Item: TTextObjectWithObject;
        Action: TCollectionNotification);
  protected
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure SetUpdateState(Updating: Boolean); override;
    procedure Put(Index: Integer; const S: string); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
  public
    constructor Create(AOwner: TCustomList);
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    destructor Destroy; override;
  end;

  TCustomList = class (TScrolledWithFont)
  private
    FItems: TStrings;
    FLayout: TTextLayout;
    FAlignment: TAlignment;
    FWordWrap: Boolean;
    procedure CMFontGeneratorChanged(var Message: TCMFontGeneratorChanged); message CM_FONTGENERATORCHANGED;
    function GetCount: Integer;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetItems(const Value: TStrings);
    procedure SetLayout(const Value: TTextLayout);
    procedure SetWordWrap(const Value: Boolean);
  protected
    procedure RecalculateSize(R: TRect);
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Layout: TTextLayout read FLayout write SetLayout default tlTop;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    property Count: Integer read GetCount;
    procedure FreeContext(Context: TCGContextBase); override;
  published
    property Items: TStrings read FItems write SetItems;
  end;

  TCGListBox = class (TCustomList)
  private
    FItemIndex: Integer;
    FSelectionBackground: TContextController<TGeneric2DObject>;
    FOnSelectionChange: TNotifyEvent;
    function GetItemIndex: Integer;
    procedure SetItemIndex(const Value: Integer);
    procedure SetSelectionBackground(const Value: TGeneric2DObject);

    procedure WMCopy(var Message: TWMCopy); message WM_COPY;
    procedure WMClear(var Message: TWMClear); message WM_CLEAR;
    procedure WMCut(var Message: TWMCut); message WM_CUT;
  protected
    procedure DoChangeItemIndex;
    procedure DoRealign; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DoRender(Context: TCGContextBase; R: TRect); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure FreeContext(Context: TCGContextBase); override;
    property SelectionBackground: TGeneric2DObject read FSelectionBackground.Value write SetSelectionBackground;
  published
    property Alignment;
    property Items;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property VerticalScrollBar;
    property Anchors;
    property Constraints;
    property Enabled;
    property Touch;
    property Visible;
    property OnDblClick;
    property OnClick;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
  end;

  TColoredLabel = class (TCustomList)
  private
    FAutoScroll: Boolean;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure SetAutoScroll(const Value: Boolean);
  protected
    procedure OnScroll(const Scroll: TScrollBarStatus); override;
    procedure DoRender(Context: TCGContextBase; R: TRect); override;
    //procedure DesignCalcRect(var R: TRect; var Flags: TTextFormat);
    //procedure DesignPaint; override;
  public
    procedure Add(const AText: string; AColor: TColor);
  published
    property Align;
    property AutoScroll: Boolean read FAutoScroll write SetAutoScroll;
    property Alignment;
    property Anchors;
    property HorizontalScrollBar;
    property VerticalScrollBar;
    property Constraints;
    property Enabled;
    property Touch;
    property Items;
    property Layout;
    property Visible;
    property WordWrap;
    property OnClick;
    property OnDblClick;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

  TGetDrawCellParameters = procedure (Sender: TObject; X, Y: Integer;
      var AColor: TColor; IsHover: Boolean) of object;
  TCellClick = procedure (Sender: TObject; Button: TMouseButton; X, Y: Integer) of object;
  THeaderClick = procedure (Sender: TObject; Button: TMouseButton; Index: Integer) of object;

  TCGStringGrid = class (TScrolledWithFont)
  private
    FHeaderBackground: TContextController<TGeneric2DObject>;
    FHoverBackground: TContextController<TGeneric2DObject>;
    FDefaultColWidth: Integer;
    FColCount: Integer;
    FLayout: TTextLayout;
    FWordWrap: Boolean;
    FAlignment: TAlignment;
    FHeaderLayout: TTextLayout;
    FHeaderWordWrap: Boolean;
    FHeaderAlignment: TAlignment;
    FRowCount: Integer;
    FOnGetDrawCellParameters: TGetDrawCellParameters;
    FOnCellClick: TCellClick;
    FHeaderHeight: Integer;
    FOnHeaderClick: THeaderClick;
    FHeaderTitles: array of TTextObjectBase;
    FRowData: array of Integer;
    FRowHeights: array of Integer;
    FCells: TList<TList<TTextObjectBase>>;
    FColWidths: array of Integer;
    FActiveLine: Integer;
    FAutoScroll: Boolean;

    //render optimisation
    FLastVericalScrollOffset: Integer;

    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure CMFontGeneratorChanged(var Message: TCMFontGeneratorChanged); message CM_FONTGENERATORCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    function GetCells(ACol, ARow: Integer): string;
    function GetColWidths(Index: Integer): Integer;
    function GetHeaderTitle(Index: Integer): string;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetCells(ACol, ARow: Integer; const Value: string);
    procedure SetColCount(const Value: Integer);
    procedure SetColWidths(Index: Integer; const Value: Integer);
    procedure SetDefaultColWidth(const Value: Integer);
    procedure SetHeaderBackground(const Value: TGeneric2DObject);
    procedure SetHeaderTitle(Index: Integer; const Value: string);
    procedure SetHoverBackground(const Value: TGeneric2DObject);
    procedure SetLayout(const Value: TTextLayout);
    procedure SetRowCount(const Value: Integer);
    procedure SetWordWrap(const Value: Boolean);
    function GetRowData(Index: Integer): Integer;
    procedure SetRowData(Index: Integer; const Value: Integer);
    procedure SetHeaderHeight(const Value: Integer);
    procedure CellNotify(Sender: TObject; const Item: TList<TTextObjectBase>; Action: TCollectionNotification);
    procedure CellTextNotify(Sender: TObject; const Item: TTextObjectBase; Action: TCollectionNotification);
    procedure SetHeaderAlignment(const Value: TAlignment);
    procedure SetHeaderLayout(const Value: TTextLayout);
    procedure SetHeaderWordWrap(const Value: Boolean);
    procedure SetAutoScroll(const Value: Boolean);
  protected
    function GetScrollRect: TRect; override;
    procedure PrepareRows;
    function GetLine(X, Y: Integer): Integer;
    function GetColumn(X, Y: Integer): Integer;
    function GetHeaderCell(X, Y: Integer): Integer;
    procedure DoRender(Context: TCGContextBase; R: TRect); override;
    procedure DesignPaint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure OnScroll(const Scroll: TScrollBarStatus); override;
    procedure ChangeScale(M: Integer; D: Integer); override;
  public
    procedure FreeContext(Context: TCGContextBase); override;
    destructor Destroy; override;
    procedure Exchange(A, B: Integer);
    constructor Create(AOwner: TComponent); override;
    property HeaderBackground: TGeneric2DObject read FHeaderBackground.Value write SetHeaderBackground;
    property HoverBackground: TGeneric2DObject read FHoverBackground.Value write SetHoverBackground;
    property HeaderTitle[Index: Integer]: string read GetHeaderTitle write SetHeaderTitle;
    property Cells[ACol, ARow: Integer]: string read GetCells write SetCells;
    property RowData[Index: Integer]: Integer read GetRowData write SetRowData;
    property ColWidths[Index: Integer]: Integer read GetColWidths write SetColWidths;
  published
    property AutoScroll: Boolean read FAutoScroll write SetAutoScroll;
    property OnGetDrawCellParameters: TGetDrawCellParameters read FOnGetDrawCellParameters write FOnGetDrawCellParameters;
    property HeaderLayout: TTextLayout read FHeaderLayout write SetHeaderLayout default tlTop;
    property HeaderWordWrap: Boolean read FHeaderWordWrap write SetHeaderWordWrap default False;
    property HeaderAlignment: TAlignment read FHeaderAlignment write SetHeaderAlignment default taLeftJustify;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Layout: TTextLayout read FLayout write SetLayout default tlTop;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property RowCount: Integer read FRowCount write SetRowCount;
    property ColCount: Integer read FColCount write SetColCount;
    property DefaultColWidth: Integer read FDefaultColWidth write SetDefaultColWidth;
    property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight;
    property Align;
    property Anchors;
    property HorizontalScrollBar;
    property VerticalScrollBar;
    property Constraints;
    property Enabled;
    property Touch;
    property Visible;
    property OnCellClick: TCellClick read FOnCellClick write FOnCellClick;
    property OnHeaderClick: THeaderClick read FOnHeaderClick write FOnHeaderClick;
    property OnClick;
    property OnDblClick;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

implementation

uses
  System.Math, Vcl.Clipbrd;

type
  THackControl = class (TControl);

{ TCGLabel }

procedure TCGLabel.AdjustSize;
var
  DC: HDC;
  X: Integer;
  Rect: TRect;
  f: TTextFormat;
begin
  if not (csLoading in ComponentState) and AutoSize then begin
    Rect:= ClientRect;
    if (csDesigning in ComponentState) then begin
      DC := GetDC(0);
      try
        Canvas.Handle := DC;
        DesignCalcRect(Rect, f);
        Inc(Rect.Bottom);
        Inc(Rect.Right);
        Canvas.Handle := 0;
      finally
        ReleaseDC(0, DC);
      end;
    end else if FText <> nil then
      Rect.BottomRight:= FText.CalculateSize;

    if WordWrap and (Rect.Right < Width) then
      Rect.Right:= Width;
    X := Left;
    if Alignment = taRightJustify then
      Inc(X, Width - Rect.Right);
    SetBounds(X, Top, Rect.Right, Rect.Bottom);
  end;
end;

procedure TCGLabel.CMColorChanged(var Message: TMessage);
begin
  if FText <> nil then
    FText.Color:= Color;
  Invalidate;
end;

procedure TCGLabel.CMFontGeneratorChanged(var Message: TCMFontGeneratorChanged);
begin
  inherited;
  if FText <> nil then begin
    if Message.IsFontChanged then begin
      FText.DoInvalid;
      if Scene <> nil then
        Scene.AddToFreeContext(FText.FreeContextAndDestroy)
      else
        FText.Destroy;
      FText:= nil;
    end else
      FText.Reset;
  end;
  AdjustSize;
end;

procedure TCGLabel.CMTextChanged(var Message: TMessage);
begin
  if EnsureTextReady then
    FText.Text:= Caption;
  AdjustSize;
  Invalidate;
end;

constructor TCGLabel.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle:= ControlStyle + [csSetCaption];
  AutoSize:= True;
end;

procedure TCGLabel.DesignCalcRect(var R: TRect; var Flags: TTextFormat);
var s: string;
begin
  s:= Caption;
  R:= ClientRect;
  Canvas.Font:= THackControl(Self).Font;
  Flags:= [tfCalcRect];
  if WordWrap then
    Include(Flags, tfWordBreak);
  case Alignment of
    taLeftJustify: Include(Flags, tfLeft);
    taRightJustify: Include(Flags, tfRight);
    taCenter: Include(Flags, tfCenter);
  end;
  Canvas.TextRect(r, s, Flags);
  Exclude(Flags, tfCalcRect);
end;

procedure TCGLabel.DesignPaint;
var s: string;
    r: TRect;
    f: TTextFormat;
begin
  inherited;
  s:= Caption;
  DesignCalcRect(r, f);

  case Layout of
    tlTop: ;
    tlCenter: r.Offset(0, (Height - r.Bottom) div 2);
    tlBottom: r.Offset(0, Height - r.Bottom);
  end;
  case Alignment of
    taLeftJustify: ;
    taRightJustify: r.Offset(Width - r.Right, 0);
    taCenter: r.Offset((Width - r.Right) div 2, 0);
  end;

  Canvas.Font.Color:= Color;
  Canvas.TextRect(r, s, f);
end;

destructor TCGLabel.Destroy;
begin
  FreeText(FText);
  inherited;
end;

procedure TCGLabel.DoRender(Context: TCGContextBase; R: TRect);
var p: TPoint;
begin
  if (FText <> nil) and FText.IsInvalid then begin
    FText.FreeContext(Context);
    FreeAndNil(FText);
  end;
  EnsureTextReady;
  FText.InitContext;
  FText.Render(R.Left, R.Top);
  if AutoSize then begin
    p:= FText.CalculateSize;
    if (R.Height <> p.Y) or (not WordWrap and (R.Width <> p.X)) then
      AdjustSize;
  end;
end;

function TCGLabel.EnsureTextReady: Boolean;
begin
  Result:= FText <> nil;
  if not Result and (Font<> nil) then begin
    FText:= Font.GenerateText();
    FText.Color:= Color;
    FText.Text:= Caption;
    FText.Layout:= Layout;
    FText.Alignment:= Alignment;
    FText.WordWrap:= WordWrap;
    FText.MaxHeight:= Height;
    FText.MaxWidth:= Width;
    Result:= True;
  end;
end;

procedure TCGLabel.FreeContext(Context: TCGContextBase);
begin
  if FText <> nil then
    FText.FreeContext(Context);
end;

procedure TCGLabel.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  if FText <> nil then
    FText.Alignment:= Value;
  Invalidate;
end;

procedure TCGLabel.SetLayout(const Value: TTextLayout);
begin
  FLayout := Value;
  if FText <> nil then
    FText.Layout:= Value;
  Invalidate;
end;

procedure TCGLabel.SetWordWrap(const Value: Boolean);
begin
  FWordWrap := Value;
  if FText <> nil then
    FText.WordWrap:= Value;
  AdjustSize;
  Invalidate;
end;

procedure TCGLabel.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  if FText <> nil then begin
    FText.MaxHeight:= Height;
    FText.MaxWidth:= Width;
  end;
  Invalidate;
end;

{ TCGEdit }

procedure TCGEdit.Change;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCGEdit.CMColorChanged(var Message: TMessage);
begin
  if FText <> nil then
    FText.Color:= Color;
  Invalidate;
end;

procedure TCGEdit.CMFontGeneratorChanged(var Message: TCMFontGeneratorChanged);
begin
  inherited;
  if FText <> nil then begin
    if Message.IsFontChanged then begin
      FText.DoInvalid;
      if Scene <> nil then
        Scene.AddToFreeContext(FText.FreeContextAndDestroy)
      else
        FText.Destroy;
      FText:= nil;
    end else
      FText.Reset;
  end;
end;

procedure TCGEdit.CMTextChanged(var Message: TMessage);
begin
  if FText <> nil then begin
    FText.Text:= Caption;
    if (FSelStart.SymbolPosition > Length(FText.Text)) or
        (FSelEnd.SymbolPosition > Length(FText.Text)) then begin
      FSelEnd:= FText.GetCursorPosition(Length(FText.Text));
      FSelStart:= FSelEnd;
    end;
  end;
  Change;
  Invalidate;
end;

constructor TCGEdit.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle:= [csCaptureMouse, csClickEvents, csDoubleClicks, csSetCaption];
  FSelStart.SymbolPosition:= 1;
  FSelStart.LinePosition:= 0;
  FSelStart.InLinePosition:= 0;
  FSelEnd:= FSelStart;
  FHideSelection:= True;
end;

procedure TCGEdit.DblClick;
begin
  if FText <> nil then begin
    FSelStart:= FText.GetCursorPosition(0);
    FSelEnd:= FText.GetCursorPosition(Length(FText.Text));
  end;
  inherited;
end;

procedure TCGEdit.DesignPaint;
var s: string;
    r: TRect;
begin
  inherited DesignPaint;

  Canvas.Font:= THackControl(Self).Font;
  R:= ClientRect;
  if Border <> nil then
    R.Inflate(-Border.BorderSize, -Border.BorderSize);
  s:= Caption;

  Canvas.TextRect(r, s, [tfSingleLine, tfVerticalCenter]);
end;

destructor TCGEdit.Destroy;
begin
  FreeText(FText);
  FSelectionBrush.UpdateValue(nil, Scene);
  FCursorBrush.UpdateValue(nil, Scene);
  inherited;
end;

procedure TCGEdit.DoRender(Context: TCGContextBase; R: TRect);
var sc: TScissorRect;
    rStart, rEnd: TTextPosition;
begin
  sc:= TScissorRect.Create(R, Scene.Height - R.Bottom);
  Context.PushScissor(sc);
  try
    if (FText <> nil) and FText.IsInvalid then begin
      FText.FreeContext(Context);
      FreeAndNil(FText);
    end;
    EnsureTextReady;
    if FSelEnd.SymbolPosition >= Length(FText.Text) then begin
      FTextOffset:= FSelEnd.X - R.Width + 2;
      if FTextOffset < 0 then
        FTextOffset:= 0;
    end else if FSelEnd.X - FTextOffset - 2 < 0 then
      FTextOffset:= FSelEnd.X
    else if FSelEnd.X - FTextOffset + 2 > R.Width then
      FTextOffset:= FSelEnd.X - R.Width + 2;
    if FSelStart <> FSelEnd then begin
      if IsFocused or not FHideSelection then begin
        if FSelStart.SymbolPosition <= FSelEnd.SymbolPosition then begin
          rStart:= FSelStart;
          rEnd:= FSelEnd;
        end else begin
          rStart:= FSelEnd;
          rEnd:= FSelStart;
        end;
        EnsureSelectionBrushReady;
        FSelectionBrush.Value.DrawWithSize(
            TPoint.Create(R.Left + rStart.X - FTextOffset, R.Top + (R.Height - Font.LineHeight) div 2),
            TSize.Create(rEnd.X - rStart.X, Font.LineHeight));
      end;
    end else if IsFocused then begin
      if FCursorBrush.Value = nil then
        FCursorBrush.UpdateValue(GetSolidBrush(Color), Scene);
      FCursorBrush.InitializeContext;
      FCursorBrush.Value.DrawWithSize(
          TPoint.Create(R.Left + FSelStart.X - FTextOffset, R.Top + (R.Height - Font.LineHeight) div 2),
          TSize.Create(2, Font.LineHeight));
    end;
    FText.InitContext;
    FText.Render(R.Left - FTextOffset, R.Top);
  finally
    Context.PopScissor;
  end;
end;

procedure TCGEdit.EnsureSelectionBrushReady;
begin
  if FSelectionBrush.Value = nil then
    FSelectionBrush.UpdateValue(GetSolidBrush(FSelectionColor), Scene);
  FSelectionBrush.InitializeContext;
end;

function TCGEdit.EnsureTextReady: Boolean;
begin
  Result:= FText <> nil;
  if not Result and (Font <> nil) then begin
    FText:= Font.GenerateText();
    FText.Color:= Color;
    FText.Text:= Caption;
    FText.Layout:= tlCenter;
    FText.Alignment:= taLeftJustify;
    FText.WordWrap:= False;
    FText.MaxHeight:= Height;
    FText.MaxWidth:= Width;
    Result:= True;
  end;
end;

procedure TCGEdit.FreeContext(Context: TCGContextBase);
begin
  if FText <> nil then
    FText.FreeContext(Context);
  FSelectionBrush.FreeContext(Context);
  FCursorBrush.FreeContext(Context);
end;

function TCGEdit.GetSelLength: Integer;
begin
  Result:= Abs(FSelStart.SymbolPosition - FSelEnd.SymbolPosition);
end;

function TCGEdit.GetSelStart: Integer;
begin
  Result:= Min(FSelStart.SymbolPosition, FSelEnd.SymbolPosition);
end;

function TCGEdit.GetSelText: string;
begin
  Result:= Copy(Text, SelStart + 1, SelLength);
end;

procedure TCGEdit.KeyDown(var Key: Word; Shift: TShiftState);
var s: string;
begin
  inherited;
  case Key of
    VK_DOWN:;
    VK_LEFT: begin
      EnsureTextReady;
      FSelEnd:= FText.GetCursorPosition(FSelEnd.SymbolPosition - 1);
      if not (ssShift in Shift) then
        FSelStart:= FSelEnd;
      Invalidate;
    end;
    VK_RIGHT: begin
      EnsureTextReady;
      FSelEnd:= FText.GetCursorPosition(FSelEnd.SymbolPosition + 1);
      if not (ssShift in Shift) then
        FSelStart:= FSelEnd;
      Invalidate;
    end;
    VK_UP:;
    VK_HOME: begin
      EnsureTextReady;
      FSelEnd:= FText.GetCursorPosition(0);
      if not (ssShift in Shift) then
        FSelStart:= FSelEnd;
      Invalidate;
    end;
    VK_END: begin
      EnsureTextReady;
      FSelEnd:= FText.GetCursorPosition(Length(Text));
      if not (ssShift in Shift) then
        FSelStart:= FSelEnd;
      Invalidate;
    end;
    VK_DELETE, VK_BACK: begin
      EnsureTextReady;
      if SelLength > 0 then begin
        s:= Text;
        Delete(s, SelStart + 1, SelLength);
        FSelEnd:= FText.GetCursorPosition(SelStart);
        FSelStart:= FSelEnd;
        Text:= s;
      end else if Key = VK_DELETE then begin
        s:= Text;
        Delete(s, SelStart + 1, 1);
        Text:= s;
      end else if SelStart > 0 then begin
        s:= Text;
        Delete(s, SelStart, 1);
        SelStart:= SelStart - 1;
        Text:= s;
      end;
    end;
    VK_RETURN:;
  end;
end;

procedure TCGEdit.KeyPress(var Key: Char);
var s: string;
begin
  inherited;
  case Key of
    #0..#31: ;
  else
    s:= Text;
    if SelLength > 0 then begin
      Delete(s, SelStart + 1, SelLength);
      SelLength:= 0;
    end;
    Insert(Key, s, SelStart + 1);
    Text:= s;
    if Text = s then
      SelStart:= SelStart + 1;
  end;
end;

procedure TCGEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;

end;

procedure TCGEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var p, old: TTextPosition;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not (csDesigning in ComponentState) and not (ssDouble in Shift) then begin
    if Text <> '' then begin
      EnsureTextReady;
      p:= FText.GetCursorPosition(X + FTextOffset, Y + (Height - Font.LineHeight) div 2);
      if ssShift in Shift then begin
        old:= FSelEnd;
        FSelEnd:= p;
      end else begin
        old:= FSelStart;
        FSelStart:= p;
        FSelEnd:= p;
      end;
      if old <> p then
        Invalidate;
    end else begin
      FillChar(p, SizeOf(p), 0);
      if (p <> FSelStart) or (p <> FSelEnd) then
        Invalidate;
      FSelStart:= p;
      FSelEnd:= p;
    end;
  end;
end;

procedure TCGEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
var p, old: TTextPosition;
begin
  inherited MouseMove(Shift, X, Y);
  if ssLeft in Shift then begin
    EnsureTextReady;
    p:= FText.GetCursorPosition(X + FTextOffset, Y + (Height - Font.LineHeight) div 2);
    old:= FSelEnd;
    FSelEnd:= p;
    if old <> p then
      Invalidate;
  end;
end;

procedure TCGEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TCGEdit.SetHideSelection(const Value: Boolean);
begin
  if FHideSelection <> Value then begin
    FHideSelection:= Value;
    Invalidate;
  end;
end;

procedure TCGEdit.SetSelectionColor(const Value: TColor);
begin
  FSelectionColor := Value;
  if (FSelectionBrush.Value <> nil) and (FSelectionBrush.Value.Color <> Value) then begin
    FSelectionBrush.UpdateValue(nil, Scene);
  end;
end;

procedure TCGEdit.SetSelLength(const Value: Integer);
begin
  if SelLength <> Value then begin
    if FSelStart.SymbolPosition > FSelEnd.SymbolPosition then
      FSelStart:= FSelEnd;
    if Value = 0 then
      FSelEnd:= FSelStart
    else begin
      EnsureTextReady;
      FSelEnd:= FText.GetCursorPosition(FSelStart.SymbolPosition + Value);
    end;
    Invalidate;
  end;
end;

procedure TCGEdit.SetSelStart(const Value: Integer);
var oldLength, oldStart: Integer;
begin
  oldStart:= SelStart;
  if Value <> oldStart then begin
    oldLength:= SelLength;
    EnsureTextReady;
    FSelStart:= FText.GetCursorPosition(Value);
    if oldLength = 0 then
      FSelEnd:= FSelStart
    else
      FSelEnd:= FText.GetCursorPosition(Value + oldLength);
    Invalidate;
  end;
end;

procedure TCGEdit.SetSelText(const Value: string);
var oldLength: Integer;
begin
  oldLength:= SelLength;
  Text:= Copy(Text, 1, SelStart) + Value + Copy(Text, SelStart + 1 + oldLength);
  SelLength:= 0;
  SelStart:= SelStart + Length(Value);
end;

procedure TCGEdit.WMClear(var Message: TWMClear);
begin
  SelText:= '';
end;

procedure TCGEdit.WMCopy(var Message: TWMCopy);
var s: string;
    clip: TClipboard;
begin
  s:= SelText;
  if s <> '' then begin
    clip:= TClipboard.Create;
    try
      clip.AsText:= s;
    finally
      clip.Free;
    end;
  end;
end;

procedure TCGEdit.WMCut(var Message: TWMCut);
var s: string;
    clip: TClipboard;
begin
  s:= SelText;
  if s <> '' then begin
    clip:= TClipboard.Create;
    try
      clip.AsText:= s;
    finally
      clip.Free;
    end;
    SelText:= '';
  end;
end;

procedure TCGEdit.WMPaste(var Message: TWMPaste);
var s: string;
    clip: TClipboard;
begin
  clip:= TClipboard.Create;
  try
    s:= clip.AsText;
    SelText:= s;
  finally
    clip.Free;
  end;
end;

procedure TCGEdit.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  {if FText <> nil then begin
    FText.MaxHeight:= Height;
    FText.MaxWidth:= Width;
  end;}
  Invalidate;
end;

{ TCGSpinEdit }

procedure TCGSpinEdit.CMRepeatTimer(var Message: TMessage);
begin
  if FMouseControl.IsDragging and (FMouseControl.State = bsDown) then begin
    if FRepeatTimer + 600 < GetTickCount then
      FDoRepeat:= True;
    if FDoRepeat then begin
      if FUpIsActive then
        IncrementValue(1)
      else
        IncrementValue(-1);
    end;
  end;
end;

procedure TCGSpinEdit.CMTextChanged(var Message: TMessage);
begin
  if Text = '' then begin
    Text:= IntToStr(MinValue);
    SelStart:= 0;
    SelLength:= Length(Text);
  end else
    inherited;
end;

constructor TCGSpinEdit.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle:= ControlStyle - [csSetCaption];
end;

procedure TCGSpinEdit.DesignPaint;
var R: TRect;
begin
  inherited DesignPaint;
  if UpDown <> nil then begin
    R:= ClientRect;
    if Border <> nil then
      R.Inflate(-Border.BorderSize, -Border.BorderSize);
    R.Left:= R.Right - UpDown.ButtonWidth;

    Canvas.Rectangle(r);
  end;
end;

function TCGSpinEdit.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  Result:= inherited;
  if not Result then begin
    IncrementValue(WheelDelta div 120);
    Result:= True;
  end;
end;

procedure TCGSpinEdit.DoRender(Context: TCGContextBase; R: TRect);
begin
  if UpDown <> nil then
    R.Right:= R.Right - UpDown.ButtonWidth;

  inherited DoRender(Context, R);

  if UpDown <> nil then begin
    R.Left:= R.Right;
    UpDown.DoRender(Context, R, False, False);
  end;
end;

function TCGSpinEdit.GetValue: Integer;
begin
  Result:= StrToIntDef(Text, MinValue);
end;

procedure TCGSpinEdit.IncrementValue(Incr: Integer);
var v: Integer;
begin
  v:= Value;
  Inc(v, Incr);
  if v > MaxValue then
    v:= MaxValue
  else if v < MinValue then
    v:= MinValue;
  Value:= v;
end;

procedure TCGSpinEdit.KeyPress(var Key: Char);
begin
  case Key of
    #0..#31, '0'..'9': inherited;
  else
    Key:= #0;
  end;
end;

procedure TCGSpinEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var R: TRect;
begin
  if (UpDown <> nil) and not FMouseControl.IsDragging and (Button = mbLeft) then begin
    R:= ClientRect;
    FUpIsActive:= FMouseControl.ProcessDown(Rect(R.Right - UpDown.ButtonWidth, R.Top, R.Right, R.Top + R.Height div 2), X, Y);
    if FUpIsActive or
        FMouseControl.ProcessDown(Rect(R.Right - UpDown.ButtonWidth, R.Top + R.Height div 2, R.Right, R.Bottom), X, Y) then begin
      FRepeatTimer:= GetTickCount;
      FDoRepeat:= False;
      if FUpIsActive then
        IncrementValue(1)
      else
        IncrementValue(-1);
      MouseCapture:= True;
      Invalidate;
      Exit;
    end;
  end;
  inherited;
end;

procedure TCGSpinEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FMouseControl.IsDragging then begin
    if FMouseControl.ProcessMove(X, Y) then
      Invalidate;
    Exit;
  end;
  inherited;
end;

procedure TCGSpinEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if FMouseControl.IsDragging and (Button = mbLeft) then begin
    FMouseControl.ProcessUp(X, Y);
    MouseCapture:= False;
    Invalidate;
    Exit;
  end;
  inherited;
end;

procedure TCGSpinEdit.SetMaxValue(const Value: Integer);
begin
  FMaxValue := Value;
end;

procedure TCGSpinEdit.SetMinValue(const Value: Integer);
begin
  FMinValue := Value;
end;

procedure TCGSpinEdit.SetUpDown(const Value: TUpDownTemplate);
begin
  FUpDown := Value;
end;

procedure TCGSpinEdit.SetValue(const Value: Integer);
begin
  Text:= IntToStr(Value);
  if EnsureTextReady then begin
    FSelEnd:= FText.GetCursorPosition(Length(Text));
    FSelStart:= FText.GetCursorPosition(0);
  end;
end;

{ TColoredLabel }

procedure TColoredLabel.Add(const AText: string; AColor: TColor);
begin
  TCGListBoxStrings(FItems).FLines[FItems.Add(AText)].Text.Color:= AColor;
  Invalidate;
end;

procedure TColoredLabel.DoRender(Context: TCGContextBase; R: TRect);
var
  i: Integer;
  curHeight: Integer;
  p: TPoint;
  b: TScissorRect;
begin
  //inherited DoRender(Context, R);
  RecalculateSize(R);

  if FAutoScroll then
    FScrollBars.DoVericalOffset(-FScrollBars.Vertical.ScrollLength);

  FScrollBars.DoRender(Context, R.Left, R.Top);
  FScrollBars.AdjustClientRect(R);

  Inc(R.Left);
  b.Create(R, Scene.Height - R.Bottom);
  Context.PushScissor(b);
  try
    Dec(R.Left, FScrollBars.Horizontal.ScrollOffset);
    curHeight:= R.Top - FScrollBars.Vertical.ScrollOffset;
    for i := 0 to TCGListBoxStrings(FItems).FLines.Count - 1 do begin
      p:= TCGListBoxStrings(FItems).FLines[i].Text.CalculateSize;
      if curHeight + p.Y > R.Top then
        TCGListBoxStrings(FItems).FLines[i].Text.Render(R.Left, curHeight);
      Inc(curHeight, p.Y);
      if curHeight > R.Bottom then
        Break;
    end;
  finally
    Context.PopScissor;
  end;
end;

procedure TColoredLabel.OnScroll(const Scroll: TScrollBarStatus);
begin
  FAutoScroll:= FScrollBars.Vertical.ScrollOffset = FScrollBars.Vertical.ScrollLength;
end;

procedure TColoredLabel.SetAutoScroll(const Value: Boolean);
begin
  if FAutoScroll <> Value then begin
    FAutoScroll := Value;
    Invalidate;
  end;
end;

procedure TColoredLabel.WMWindowPosChanged(var Message: TWMWindowPosChanged);
var
  i: Integer;
begin
  BeginReAlignScrolls;
  try
    for i := 0 to TCGListBoxStrings(FItems).FLines.Count - 1 do begin
      TCGListBoxStrings(FItems).FLines[i].Text.MaxHeight:= Font.LineHeight;
      TCGListBoxStrings(FItems).FLines[i].Text.MaxWidth:= Width - 1;
    end;
  finally
    EndReAlignScrolls;
  end;
  Invalidate;
end;

{ TCGStringGrid }

procedure TCGStringGrid.CellNotify(Sender: TObject;
  const Item: TList<TTextObjectBase>; Action: TCollectionNotification);
begin
  case Action of
    cnAdded: Item.OnNotify:= CellTextNotify;
    cnRemoved: Item.Free;
    cnExtracted: ;
  end;
end;

procedure TCGStringGrid.CellTextNotify(Sender: TObject;
  const Item: TTextObjectBase; Action: TCollectionNotification);
begin
  if Item = nil then
    Exit;
  case Action of
    cnRemoved:
      if Scene <> nil then
        Scene.AddToFreeContext(Item.FreeContextAndDestroy)
      else
        Item.Destroy;
    cnExtracted: ;
  end;
end;

procedure TCGStringGrid.ChangeScale(M, D: Integer);
var oldWidth: Integer;
  i: Integer;
begin
  oldWidth:= Width;

  inherited ChangeScale(M, D);

  if (M <> D) and (oldWidth <> Width) then
    for i := 0 to ColCount - 1 do
      ColWidths[i]:= MulDiv(ColWidths[i], M, D);
end;

procedure TCGStringGrid.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  FActiveLine:= -1;
end;

procedure TCGStringGrid.CMFontGeneratorChanged(var Message: TCMFontGeneratorChanged);
var
  i, j: Integer;
  t: TTextObjectBase;
  l: TList<TTextObjectBase>;
begin
  inherited;
  if Message.IsFontChanged then begin
    for i:= 0 to High(FHeaderTitles) do
      if FHeaderTitles[i] <> nil then
        FHeaderTitles[i].DoInvalid;

    for i := 0 to FCells.Count - 1 do begin
      l:= FCells[i];
      if l <> nil then
        for j := 0 to l.Count - 1 do
          if l[j] <> nil then
            l[j].DoInvalid;
    end;

    if Font <> nil then begin
      for i:= 0 to High(FHeaderTitles) do
        if FHeaderTitles[i] <> nil then begin
          t:= Font.GenerateText;
          t.Text:= FHeaderTitles[i].Text;
          t.Color:= Color;
          t.Alignment:= HeaderAlignment;
          t.WordWrap:= HeaderWordWrap;
          t.Layout:= HeaderLayout;
          t.MaxHeight:= HeaderHeight;
          t.MaxWidth:= ColWidths[i];
          FHeaderTitles[i]:= t;
        end;

      for i := 0 to FCells.Count - 1 do begin
        l:= FCells[i];
        if l <> nil then
          for j := 0 to l.Count - 1 do
            if l[j] <> nil then begin
              t:= Font.GenerateText;
              with l[j] do begin
                t.Text:= Text;
                t.Color:= Color;
              end;
              t.Alignment:= Alignment;
              t.WordWrap:= WordWrap;
              t.Layout:= Layout;
              t.MaxHeight:= Height;
              t.MaxWidth:= ColWidths[j];
              l[j]:= t;
            end;
      end;
    end;
  end else begin
    for i:= 0 to High(FHeaderTitles) do
      if FHeaderTitles[i] <> nil then
        FHeaderTitles[i].Reset;

    for i := 0 to FCells.Count - 1 do begin
      l:= FCells[i];
      if l <> nil then
        for j := 0 to l.Count - 1 do
          if l[j] <> nil then
            l[j].Reset;
    end;
  end;
end;

procedure TCGStringGrid.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  FActiveLine:= -1;
end;

constructor TCGStringGrid.Create(AOwner: TComponent);
begin
  inherited;
  FCells:= TList<TList<TTextObjectBase>>.Create;
  FCells.OnNotify:= CellNotify;
  FActiveLine:= -1;
end;

procedure TCGStringGrid.DesignPaint;
begin
  inherited;
  with Canvas do begin
    MoveTo(0, HeaderHeight);
    LineTo(Width, HeaderHeight);
  end;
end;

destructor TCGStringGrid.Destroy;
var i: Integer;
begin
  FCells.Clear;

  for i := 0 to High(FHeaderTitles) do
    if FHeaderTitles[i] <> nil then
      if Scene <> nil then
        Scene.AddToFreeContext(FHeaderTitles[i].FreeContextAndDestroy)
      else
        FHeaderTitles[i].Destroy;

  FHeaderTitles:= nil;

  FHeaderBackground.UpdateValue(nil, Scene);
  FHoverBackground.UpdateValue(nil, Scene);

  inherited;

  FCells.Free;
end;

procedure TCGStringGrid.DoRender(Context: TCGContextBase; R: TRect);
var Z: TScissorRect;
  l: TList<TTextObjectBase>;
  FrameRect: TRect;
  xOfs, yOfs: Integer;
  firstColumn: Integer;

  function DrawRow(i: Integer): Boolean;
  var j: Integer;
      c: TTextObjectBase;
  begin
    Dec(Z.Bottom, FRowHeights[i]);

    Result:= FrameRect.Bottom > R.Bottom;
    if Result then
      FrameRect.Bottom:= R.Bottom;
    if (FActiveLine = i) and (FHoverBackground.Value <> nil) then begin
      FHoverBackground.InitializeContext;
      FHoverBackground.Value.DrawWithSize(FrameRect.TopLeft, FrameRect.Size);
    end;

    Z.Left:= xOfs;
    for j := firstColumn to FColCount - 1 do begin
      c:= l[j];
      if c <> nil then begin
        Z.Width:= FColWidths[j];
        Context.PushScissor(Z);
        try
          c.InitContext;
          c.RenderFrame(Z.Left, yOfs, FrameRect);
        finally
          Context.PopScissor;
        end;
      end;
      Inc(Z.Left, FColWidths[j]);
    end;
    Inc(yOfs, FRowHeights[i]);
  end;

  procedure FreeRow;
  var
    j: Integer;
    c: TTextObjectBase;
  begin
    for j := 0 to l.Count - 1 do begin
      c:= l[j];
      if c <> nil then
        c.FreePrepared(Context);
    end;
  end;
var
  i: Integer;
  j, frameHeight, beginDrawIndex, endDrawIndex: Integer;
  needFreeUnused: Boolean;
begin
  Z.Create(R, Scene.Height - R.Bottom);
  BeginReAlignScrolls;
  try
    PrepareRows;
  finally
    needFreeUnused:= ScrollRealignNeeded;
    EndReAlignScrolls;

    if FAutoScroll then
      FScrollBars.DoVericalOffset(-FScrollBars.Vertical.ScrollLength);

    needFreeUnused:= needFreeUnused or (FScrollBars.Vertical.ScrollOffset <> FLastVericalScrollOffset);
  end;

  FLastVericalScrollOffset:= FScrollBars.Vertical.ScrollOffset;

  Context.PushScissor(Z);
  try
    FrameRect.Create(R.TopLeft, ActualWidth, HeaderHeight);
    FrameRect.Offset(-FScrollBars.Horizontal.ScrollOffset, 0);
    if FHeaderBackground.Value <> nil then begin
      FHeaderBackground.InitializeContext;
      FHeaderBackground.Value.DrawWithSize(FrameRect.TopLeft, FrameRect.Size);
    end;

    firstColumn:= 0;
    xOfs:= FrameRect.Left;
    yOfs:= FrameRect.Top;
    while firstColumn < Length(FHeaderTitles) do begin
      if xOfs + FColWidths[firstColumn] > R.Left then
        Break;
      Inc(xOfs, FColWidths[firstColumn]);
      Inc(firstColumn);
    end;

    Z.Left:= xOfs;
    Z.Bottom:= Scene.Height - R.Top - HeaderHeight;
    Z.Height:= HeaderHeight;

    for i := firstColumn to High(FHeaderTitles) do begin
      Z.Width:= FColWidths[i];
      if FHeaderTitles[i] <> nil then begin
        FHeaderTitles[i].InitContext;
        Context.PushScissor(Z);
        try
          FHeaderTitles[i].Render(Z.Left, yOfs);
        finally
          Context.PopScissor;
        end;
      end;
      Inc(Z.Left, FColWidths[i]);
    end;

    Inc(R.Top, HeaderHeight);
    yOfs:= R.Top;

    Dec(yOfs, FScrollBars.Vertical.ScrollOffset);
    Inc(Z.Bottom, FScrollBars.Vertical.ScrollOffset);
    i:= 0;
    while (i < FRowCount) and (yOfs + FRowHeights[i] <= R.Top) do begin
      Dec(Z.Bottom, FRowHeights[i]);
      Inc(yOfs, FRowHeights[i]);
      Inc(i);
    end;

    beginDrawIndex:= i;

    while (i < FRowCount) and (FCells[i] = nil) do
      Inc(i);

    if (yOfs < R.Top) and (i < FRowCount) then begin
      l:= FCells[i]; //l used in DrawRow
      FrameRect.Top:= R.Top;
      FrameRect.Bottom:= FRowHeights[i] + yOfs;
      Z.Height:= FRowHeights[i] - (FrameRect.Top - yOfs);
      DrawRow(i);
      Inc(i);
    end;

    while (i < FRowCount) and (yOfs < R.Bottom) do begin
      l:= FCells[i]; //l used in DrawRow
      if l <> nil then begin
        FrameRect.Top:= yOfs;
        Z.Height:= FRowHeights[i];
        FrameRect.Height:= FRowHeights[i];
        DrawRow(i);
      end;
      Inc(i);
    end;

    endDrawIndex:= i;

    if needFreeUnused then begin
      frameHeight:= endDrawIndex - beginDrawIndex;
      if frameHeight > 0 then begin
        for j := 0 to beginDrawIndex - frameHeight do begin
          l:= FCells[j];
          if l <> nil then
            FreeRow;
        end;
        for j := endDrawIndex + frameHeight to FRowCount - 1 do begin
          l:= FCells[j];
          if l <> nil then
            FreeRow;
        end;
      end;
    end;
  finally
    Context.PopScissor;
  end;
  Dec(R.Top, HeaderHeight);
  FScrollBars.DoRender(Context, R.Left, R.Top);
end;

procedure TCGStringGrid.Exchange(A, B: Integer);
var tmp: Integer;
begin
  if (A < 0) or (B < 0) or (A >= FCells.Count) or (B >= FCells.Count) then
    Exit;

  FCells.Exchange(A, B);
  tmp:= FRowData[A];
  FRowData[A]:= FRowData[B];
  FRowData[B]:= tmp;
  Invalidate;
end;

procedure TCGStringGrid.FreeContext(Context: TCGContextBase);
var i, j: Integer;
    l: TList<TTextObjectBase>;
begin
  inherited;
  for i := 0 to FCells.Count - 1 do begin
    l:= FCells[i];
    if FCells[i] <> nil then
      for j := 0 to l.Count - 1 do
        if l[j] <> nil then
          l[j].FreeContext(Context);
  end;

  for i := 0 to High(FHeaderTitles) do
    if FHeaderTitles[i] <> nil then
      FHeaderTitles[i].FreeContext(Context);

  FHeaderBackground.FreeContext(Context);
  FHoverBackground.FreeContext(Context);
end;

function TCGStringGrid.GetCells(ACol, ARow: Integer): string;
var l: TList<TTextObjectBase>;
begin
  if (ARow < 0) or (ARow >= FCells.Count) then
    Exit('');

  l:= FCells[ARow];
  if l <> nil then begin
    if (ACol < 0) or (ACol >= l.Count) then
      Exit('');
    if l[ACol] <> nil then
      Exit(l[ACol].Text);
  end;
  Result:= '';
end;

function TCGStringGrid.GetColumn(X, Y: Integer): Integer;
var i, w: Integer;
begin
  if (Y <= Height) and (Y >= 0) then begin
    w:= -FScrollBars.Horizontal.ScrollOffset;
    for I := 0 to ColCount - 1 do begin
      if (X >= w) and (X < w + FColWidths[i]) then
        Exit(I);
      Inc(w, FColWidths[i]);
    end;
  end;
  Result:= -1;
end;

function TCGStringGrid.GetColWidths(Index: Integer): Integer;
begin
  if (Index < 0) or (Index >= Length(FColWidths)) then
    Exit(0);

  Result:= FColWidths[Index];
end;

function TCGStringGrid.GetHeaderCell(X, Y: Integer): Integer;
begin
  if (Y < FHeaderHeight) and (Y >= 0) then
    Result:= GetColumn(X, Y)
  else
    Result:= -1;
end;

function TCGStringGrid.GetHeaderTitle(Index: Integer): string;
begin
  if (Index < 0) or (Index >= Length(FHeaderTitles)) then
    Exit('');

  if FHeaderTitles[Index] <> nil then
    Exit(FHeaderTitles[index].Text);

  Result:= '';
end;

function TCGStringGrid.GetLine(X, Y: Integer): Integer;
var i, h: Integer;
    r: TRect;
begin
  h:= HeaderHeight - FScrollBars.Vertical.ScrollOffset;
  R:= ClientRect;
  if Border <> nil then
    R.Inflate(-Border.BorderSize, -Border.BorderSize);
  if FScrollBars.Horizontal.Enabled then
    Dec(r.Bottom, FScrollBars.Horizontal.Template.ButtonSize);
  if FScrollBars.Vertical.Enabled then
    Dec(R.Right, FScrollBars.Vertical.Template.ButtonSize);
  Inc(R.Top, HeaderHeight);
  if R.Contains(Point(X, Y)) then begin
    i:= 0;
    while (i < FRowCount) and (FRowHeights[i] + h < R.Top) do begin
      Inc(h, FRowHeights[i]);
      Inc(i);
    end;
    for i := i to FRowCount - 1 do begin
      if (Y >= h) and (y < FRowHeights[i] + h) then
        Exit(i);
      Inc(h, FRowHeights[i]);
    end;
  end;
  Result:= -1;
end;

function TCGStringGrid.GetRowData(Index: Integer): Integer;
begin
  if (Index < 0) or (Index >= Length(FRowData)) then
    Exit(0);
  Result:= FRowData[Index];
end;

function TCGStringGrid.GetScrollRect: TRect;
begin
  Result:= inherited;
  Inc(Result.Top, HeaderHeight);
end;

procedure TCGStringGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var old: Integer;
begin
  inherited;
  old:= GetHeaderCell(X, Y);
  if old >= 0 then begin
    if Assigned(FOnHeaderClick) then
      FOnHeaderClick(Self, Button, old);
  end else begin
    old:= FActiveLine;
    FActiveLine:= GetLine(X, Y);
    if old <> FActiveLine then
      Invalidate;
    if (FActiveLine >= 0) and Assigned(FOnCellClick) then
      FOnCellClick(Self, Button, GetColumn(X, Y), FActiveLine);
  end;
end;

procedure TCGStringGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var old: Integer;
begin
  inherited;
  old:= FActiveLine;
  FActiveLine:= GetLine(X, Y);
  if old <> FActiveLine then
    Invalidate;
end;

procedure TCGStringGrid.OnScroll(const Scroll: TScrollBarStatus);
begin
  FAutoScroll:= FScrollBars.Vertical.ScrollOffset = FScrollBars.Vertical.ScrollLength;
end;

procedure TCGStringGrid.PrepareRows;
var i, j: Integer;
    l: TList<TTextObjectBase>;
    c: TTextObjectBase;
    cellColor: TColor;
    p: TPoint;
    h: Integer;
begin
  h:= 0;
  for i := 0 to FRowCount - 1 do begin
    FRowHeights[i]:= 0;
    l:= FCells[i];
    if l = nil then
      Continue;
    for j := 0 to FColCount - 1 do begin
      c:= l[j];
      if c <> nil then begin
        if Assigned(OnGetDrawCellParameters) then begin
          cellColor:= Color;
          OnGetDrawCellParameters(Self, j, i, cellColor, FActiveLine = i);
          c.Color:= cellColor;
        end;
        p:= c.CalculateSize;
        if p.Y > FRowHeights[i] then
          FRowHeights[i]:= p.Y;
      end;
    end;
    Inc(h, FRowHeights[i]);
  end;
  ActualHeight:= h;
end;

procedure TCGStringGrid.SetAlignment(const Value: TAlignment);
var i, j: Integer;
    l: TList<TTextObjectBase>;
begin
  if FAlignment <> Value then begin
    FAlignment:= Value;
    for i := 0 to FCells.Count - 1 do begin
      l:= FCells[i];
      if l <> nil then
        for j := 0 to l.Count - 1 do
          if l[j] <> nil then
            l[j].Alignment:= Alignment;
    end;
  end;
  Invalidate;
end;

procedure TCGStringGrid.SetAutoScroll(const Value: Boolean);
begin
  if FAutoScroll <> Value then begin
    FAutoScroll := Value;
    Invalidate;
  end;
end;

procedure TCGStringGrid.SetCells(ACol, ARow: Integer; const Value: string);
var l: TList<TTextObjectBase>;
    o: TTextObjectBase;
begin
  if (ACol < 0) or (ARow < 0) then
    Exit;

  if ARow >= FRowCount then
    RowCount:= ARow + 1;

  if ACol >= FColCount then
    ColCount:= ACol + 1;

  l:= FCells[ARow];
  if l = nil then begin
    l:= TList<TTextObjectBase>.Create;
    FCells[ARow]:= l;
  end;

  if ACol >= l.Count then begin
    l.Count:= ACol + 1;
    o:= Font.GenerateText;
    o.Color:= Color;
    o.Layout:= Layout;
    o.Alignment:= Alignment;
    o.WordWrap:= WordWrap;
    o.MaxHeight:= Height;
    o.MaxWidth:= ColWidths[ACol];
    l[ACol]:= o;
  end;
  l[ACol].Text:= Value;
end;

procedure TCGStringGrid.SetColCount(const Value: Integer);
var i, j, w: Integer;
    l: TList<TTextObjectBase>;
begin
  if FColCount <> Value then begin
    if FColCount > Value then begin
      for i := 0 to FCells.Count - 1 do begin
        l:= FCells[i];
        if l <> nil then
          l.Count:= Value;
      end;
    end;

    j:= Length(FColWidths);
    SetLength(FColWidths, Value + 1);
    w:= ActualWidth;
    for i := j to Value do begin
      Inc(w, DefaultColWidth);
      FColWidths[i]:= DefaultColWidth;
    end;
    ActualWidth:= w;

    SetLength(FHeaderTitles, Value + 1);

    FColCount:= Value;
    Invalidate;
  end;
end;

procedure TCGStringGrid.SetColWidths(Index: Integer; const Value: Integer);
var i: Integer;
  l: TList<TTextObjectBase>;
begin
  if Index < 0 then
    Exit;
  if Index >= ColCount then
    ColCount:= Index + 1;

  ActualWidth:= ActualWidth - FColWidths[Index] + Value;
  FColWidths[Index]:= Value;
  for i := 0 to FRowCount - 1 do begin
    l:= FCells[i];
    if l <> nil then
      if l[Index] <> nil then
        l[Index].MaxWidth:= Value;
  end;
  Invalidate;
end;

procedure TCGStringGrid.SetDefaultColWidth(const Value: Integer);
begin
  FDefaultColWidth := Value;
end;

procedure TCGStringGrid.SetHeaderAlignment(const Value: TAlignment);
var i: Integer;
begin
  if FHeaderAlignment <> Value then begin
    FHeaderAlignment:= Value;
    for i := 0 to High(FHeaderTitles) do
      if FHeaderTitles[i] <> nil then
        FHeaderTitles[i].Alignment:= FHeaderAlignment;
  end;
  Invalidate;
end;

procedure TCGStringGrid.SetHeaderBackground(const Value: TGeneric2DObject);
begin
  FHeaderBackground.UpdateValue(Value, Scene);
  Invalidate;
end;

procedure TCGStringGrid.SetHeaderTitle(Index: Integer; const Value: string);
begin
  if Index >= ColCount then
    ColCount:= Index + 1;

  if FHeaderTitles[Index] = nil then begin
    FHeaderTitles[Index]:= Font.GenerateText;
    FHeaderTitles[Index].Color:= Color;
    FHeaderTitles[Index].Layout:= HeaderLayout;
    FHeaderTitles[Index].Alignment:= HeaderAlignment;
    FHeaderTitles[Index].WordWrap:= HeaderWordWrap;
    FHeaderTitles[Index].MaxHeight:= Height;
    FHeaderTitles[Index].MaxWidth:= ColWidths[Index];
  end;
  FHeaderTitles[Index].Text:= Value;
  Invalidate;
end;

procedure TCGStringGrid.SetHeaderWordWrap(const Value: Boolean);
var i: Integer;
begin
  if FHeaderWordWrap <> Value then begin
    FHeaderWordWrap:= Value;
    for i := 0 to High(FHeaderTitles) do
      if FHeaderTitles[i] <> nil then
        FHeaderTitles[i].WordWrap:= FHeaderWordWrap;
    Invalidate;
  end;
end;

procedure TCGStringGrid.SetHeaderHeight(const Value: Integer);
begin
  if FHeaderHeight <> Value then begin
    FHeaderHeight := Value;
    Invalidate;
  end;
end;

procedure TCGStringGrid.SetHeaderLayout(const Value: TTextLayout);
var i: Integer;
begin
  if FHeaderLayout <> Value then begin
    FHeaderLayout:= Value;
    for i := 0 to High(FHeaderTitles) do
      if FHeaderTitles[i] <> nil then
        FHeaderTitles[i].Layout:= FHeaderLayout;
    Invalidate;
  end;
end;

procedure TCGStringGrid.SetHoverBackground(const Value: TGeneric2DObject);
begin
  FHoverBackground.UpdateValue(Value, Scene);
end;

procedure TCGStringGrid.SetLayout(const Value: TTextLayout);
var i, j: Integer;
    l: TList<TTextObjectBase>;
begin
  if FLayout <> Value then begin
    FLayout:= Value;
    for i := 0 to FCells.Count - 1 do begin
      l:= FCells[i];
      if l <> nil then
        for j := 0 to l.Count - 1 do
          if l[j] <> nil then
            l[j].Layout:= Layout;
    end;
    Invalidate;
  end;
end;

procedure TCGStringGrid.SetRowData(Index: Integer; const Value: Integer);
begin
  if Index >= RowCount then
    RowCount:= Index + 1;

  FRowData[Index]:= Value;
end;

procedure TCGStringGrid.SetRowCount(const Value: Integer);
begin
  if FRowCount <> Value then begin
    FCells.Count:= Value;
    SetLength(FRowData, Value);
    SetLength(FRowHeights, Value);
    FRowCount := Value;
    Invalidate;
  end;
end;

procedure TCGStringGrid.SetWordWrap(const Value: Boolean);
var i, j: Integer;
    l: TList<TTextObjectBase>;
begin
  if FWordWrap <> Value then begin
    FWordWrap:= Value;
    for i := 0 to FCells.Count - 1 do begin
      l:= FCells[i];
      if l <> nil then
        for j := 0 to l.Count - 1 do
          if l[j] <> nil then
            l[j].WordWrap:= WordWrap;
    end;
    Invalidate;
  end;
end;

procedure TCGStringGrid.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  Invalidate;
end;

{ TScrolledWithFont }

procedure TScrolledWithFont.BeginReAlignScrolls;
begin
  Inc(FScrollRealignCount);
end;

procedure TScrolledWithFont.CMRepeatTimer(var Message: TMessage);
begin
  inherited;
  FScrollBars.RepeatTimer;
end;

constructor TScrolledWithFont.Create(AOwner: TComponent);
var t: TOnScrollOffsetChanged;
begin
  inherited;
  FScrollBars.Vertical.IsVertical:= True;
  t:= OnScroll;
  FScrollBars.Vertical.OnScrollOffsetChanged:= TScrollBarStatus.TOnScrollOffsetChanged(t);
end;

function TScrolledWithFont.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  Result:= inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  if not Result then begin
    Result:= True;
    FScrollBars.DoVericalOffset(WheelDelta);
  end;
end;

procedure TScrolledWithFont.DoRealign;
begin
  FScrollBars.ReAlign(GetScrollRect, FActualWidth, FActualHeight);
  FScrollRealignNeeded:= False;
end;

procedure TScrolledWithFont.EndReAlignScrolls;
begin
  Dec(FScrollRealignCount);
  if (FScrollRealignCount = 0) and FScrollRealignNeeded then begin
    DoRealign;
  end;
end;

function TScrolledWithFont.GetScrollRect: TRect;
begin
  Result:= ClientRect;
  if Border <> nil then
    Result.Inflate(-Border.BorderSize, -Border.BorderSize);
end;

procedure TScrolledWithFont.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FScrollBars.MouseDown(Button, Shift, X, Y);
  inherited;
end;

procedure TScrolledWithFont.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  FScrollBars.MouseMove(Shift, X, Y);
  inherited;
end;

procedure TScrolledWithFont.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  FScrollBars.MouseUp(Button, Shift, X, Y);
  inherited;
end;

procedure TScrolledWithFont.OnScroll(const Scroll: TScrollBarStatus);
begin

end;

procedure TScrolledWithFont.SetActualHeight(const Value: Integer);
begin
  if FActualHeight <> Value then begin
    BeginReAlignScrolls;
    FScrollRealignNeeded:= True;
    FActualHeight := Value;
    EndReAlignScrolls;
  end;
end;

procedure TScrolledWithFont.SetActualWidth(const Value: Integer);
begin
  if FActualWidth <> Value then begin
    BeginReAlignScrolls;
    FScrollRealignNeeded:= True;
    FActualWidth := Value;
    EndReAlignScrolls;
  end;
end;

procedure TScrolledWithFont.SetHorizontalScrollBar(
  const Value: TCGScrollBarTemplate);
begin
  if FScrollBars.Horizontal.Template <> Value then begin
    BeginReAlignScrolls;
    FScrollRealignNeeded:= True;
    FScrollBars.Horizontal.Template := Value;
    EndReAlignScrolls;
  end;
end;

procedure TScrolledWithFont.SetVerticalScrollBar(
  const Value: TCGScrollBarTemplate);
begin
  if FScrollBars.Vertical.Template <> Value then begin
    BeginReAlignScrolls;
    FScrollRealignNeeded:= True;
    FScrollBars.Vertical.Template := Value;
    EndReAlignScrolls;
  end;
end;

procedure TScrolledWithFont.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var p: TPoint;
    old: TControlStyle;
begin
  with Message do
    if (Width > 32768) or (Height > 32768) then
      with CalcCursorPos do
       p.Create(X, Y)
    else
      p.Create(XPos, YPos);
  old:= ControlStyle;
  try
    if FScrollBars.MouseInScrollArea(p.X, p.Y) then
      ControlStyle:= ControlStyle - [csClickEvents];
    inherited;
  finally
    ControlStyle:= old;
  end;
end;

{ TCGListBox }

procedure TCGListBox.Clear;
begin
  FItems.Clear;
end;

constructor TCGListBox.Create(AOwner: TComponent);
begin
  inherited;
  FItemIndex:= -1;
end;

destructor TCGListBox.Destroy;
begin
  FSelectionBackground.UpdateValue(nil, Scene);
  inherited;
end;

procedure TCGListBox.DoChangeItemIndex;
begin
  if Assigned(FOnSelectionChange) then
    FOnSelectionChange(Self);
end;

function TCGListBox.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var m: TWMMouse;
begin
  Result:= inherited;
  m.Msg:= WM_MOUSEMOVE;
  m.Pos:= PointToSmallPoint(MousePos);
  WindowProc(TMessage(m));
end;

procedure TCGListBox.DoRealign;
begin
  inherited;
  SetItemIndex(FItemIndex);
end;

procedure TCGListBox.DoRender(Context: TCGContextBase; R: TRect);
var
  i: Integer;
  curHeight: Integer;
  b: TScissorRect;
begin
  if Font = nil then
    Exit;

  BeginReAlignScrolls;
  try
    ActualHeight:= FItems.Count * Font.LineHeight;
    ActualWidth:= R.Width;
  finally
    EndReAlignScrolls;
  end;

  FScrollBars.DoRender(Context, R.Left, R.Top);

  FScrollBars.AdjustClientRect(R);

  Inc(R.Left);
  b.Create(R, Scene.Height - R.Bottom);
  Context.PushScissor(b);
  try
    Dec(R.Left, FScrollBars.Horizontal.ScrollOffset);
    curHeight:= R.Top - FScrollBars.Vertical.ScrollOffset;
    for i := 0 to FItems.Count - 1 do begin
      TCGListBoxStrings(FItems).FLines[i].Text.InitContext;
      if curHeight + Font.LineHeight > R.Top then begin
        if (i = FItemIndex) and (FSelectionBackground.Value <> nil) then begin
          FSelectionBackground.InitializeContext;
          FSelectionBackground.Value.DrawWithSize(Point(R.Left, curHeight), TSize.Create(R.Width, Font.LineHeight));
        end;
        TCGListBoxStrings(FItems).FLines[i].Text.Render(R.Left, curHeight);
      end;
      Inc(curHeight, Font.LineHeight);
      if curHeight > R.Bottom then
        Break;
    end;
  finally
    Context.PopScissor;
  end;
end;

procedure TCGListBox.FreeContext(Context: TCGContextBase);
begin
  inherited;
  FSelectionBackground.FreeContext(Context);
end;

function TCGListBox.GetItemIndex: Integer;
begin
  Result:= FItemIndex;
end;

procedure TCGListBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_DOWN:
      if FItemIndex < Count - 1 then begin
        Inc(FItemIndex);
        DoChangeItemIndex;
        Invalidate;
      end;
    VK_UP:
      if FItemIndex > 0 then begin
        Dec(FItemIndex);
        DoChangeItemIndex;
        Invalidate;
      end;
  end;
end;

procedure TCGListBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if not FScrollBars.MouseInScrollArea(X, Y) then
    if Button = mbLeft then
      ItemIndex:= (FScrollBars.Vertical.ScrollOffset + Y) div Font.LineHeight;
  inherited;
end;

procedure TCGListBox.SetItemIndex(const Value: Integer);
var old: Integer;
begin
  old:= FItemIndex;
  if (Value >= 0) and (Value < Count) then
    FItemIndex:= Value
  else
    FItemIndex:= -1;
  if old <> FItemIndex then
    DoChangeItemIndex;
end;

procedure TCGListBox.SetSelectionBackground(const Value: TGeneric2DObject);
begin
  FSelectionBackground.UpdateValue(Value, Scene);
end;

procedure TCGListBox.WMClear(var Message: TWMClear);
begin
  ItemIndex:= -1;
end;

procedure TCGListBox.WMCopy(var Message: TWMCopy);
var s: string;
    clip: TClipboard;
begin
  if ItemIndex <> -1 then begin
    s:= Items[ItemIndex];
    if s <> '' then begin
      clip:= TClipboard.Create;
      try
        clip.AsText:= s;
      finally
        clip.Free;
      end;
    end;
  end;
end;

procedure TCGListBox.WMCut(var Message: TWMCut);
begin
  WMCopy(Message);
end;

{ TCGListBoxStrings }

procedure TCGListBoxStrings.Clear;
begin
  BeginUpdate;
  FLines.Clear;
  EndUpdate;
end;

constructor TCGListBoxStrings.Create(AOwner: TCustomList);
begin
  FLines:= TList<TTextObjectWithObject>.Create;
  FLines.OnNotify:= OnLineNotify;
  FOwner:= AOwner;
end;

procedure TCGListBoxStrings.Delete(Index: Integer);
begin
  BeginUpdate;
  FLines.Delete(Index);
  EndUpdate;
end;

destructor TCGListBoxStrings.Destroy;
begin
  FLines.Free;
  inherited;
end;

function TCGListBoxStrings.Get(Index: Integer): string;
begin
  Result:= FLines[Index].Text.Text;
end;

function TCGListBoxStrings.GetCount: Integer;
begin
  Result:= FLines.Count;
end;

function TCGListBoxStrings.GetObject(Index: Integer): TObject;
begin
  Result:= FLines[Index].UserObject;
end;

procedure TCGListBoxStrings.Insert(Index: Integer; const S: string);
var o: TTextObjectWithObject;
begin
  o.Text:= FOwner.Font.GenerateText;
  o.Text.Text:= S;
  o.Text.Alignment:= FOwner.Alignment;
  o.Text.Layout:= FOwner.Layout;
  o.Text.WordWrap:= FOwner.WordWrap;
  o.Text.MaxHeight:= FOwner.Font.LineHeight;
  o.Text.MaxWidth:= FOwner.Width;
  o.Text.Color:= FOwner.Color;

  BeginUpdate;
  FLines.Insert(Index, o);
  EndUpdate;
end;

procedure TCGListBoxStrings.OnLineNotify(Sender: TObject;
  const Item: TTextObjectWithObject; Action: TCollectionNotification);
begin
  if (Action = cnRemoved) and (Item.Text <> nil) then begin
    if FOwner.Scene <> nil then
      FOwner.Scene.AddToFreeContext(Item.Text.FreeContextAndDestroy)
    else
      Item.Text.Destroy;
  end;
end;

procedure TCGListBoxStrings.Put(Index: Integer; const S: string);
begin
  BeginUpdate;
  FLines[Index].Text.Text:= S;
  EndUpdate;
end;

procedure TCGListBoxStrings.PutObject(Index: Integer; AObject: TObject);
begin
  FLines.List[Index].UserObject:= AObject;
end;

procedure TCGListBoxStrings.SetUpdateState(Updating: Boolean);
begin
  if Updating then
    FOwner.BeginReAlignScrolls
  else
    FOwner.EndReAlignScrolls;
end;

{ TCustomList }

procedure TCustomList.Clear;
begin
  FItems.Clear;
end;

procedure TCustomList.CMFontGeneratorChanged(var Message: TCMFontGeneratorChanged);
var
  i: Integer;
  t: TTextObjectWithObject;
begin
  inherited;
  if Message.IsFontChanged then begin
    for i := 0 to FItems.Count - 1 do
      TCGListBoxStrings(FItems).FLines[i].Text.DoInvalid;
    if Font <> nil then
      for i := 0 to FItems.Count - 1 do begin
        t.Text:= Font.GenerateText;
        with TCGListBoxStrings(FItems).FLines[i] do begin
          t.Text.Assign(Text);
          t.UserObject:= UserObject;
        end;
        TCGListBoxStrings(FItems).FLines[i]:= t;
      end;
  end else
    for i := 0 to FItems.Count - 1 do
      TCGListBoxStrings(FItems).FLines[i].Text.Reset;
end;

constructor TCustomList.Create(AOwner: TComponent);
begin
  inherited;
  FItems:= TCGListBoxStrings.Create(Self);
end;

destructor TCustomList.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TCustomList.FreeContext(Context: TCGContextBase);
var
  i: Integer;
begin
  inherited;
  for i := 0 to FItems.Count - 1 do
    TCGListBoxStrings(FItems).FLines[i].Text.FreeContext(Context);
end;

function TCustomList.GetCount: Integer;
begin
  Result:= FItems.Count;
end;

procedure TCustomList.RecalculateSize(R: TRect);
var eHeight, eWidth: Integer;
    curHeight, maxWidth: Integer;
    i: Integer;
    p: TPoint;
begin
  BeginReAlignScrolls;
  try
    eHeight:= R.Height;
    eWidth:= R.Width - 1;

    curHeight:= 0;
    maxWidth:= eWidth;
    for i := 0 to TCGListBoxStrings(FItems).FLines.Count - 1 do begin
      TCGListBoxStrings(FItems).FLines[i].Text.InitContext;
      p:= TCGListBoxStrings(FItems).FLines[i].Text.CalculateSize;
      Inc(curHeight, p.Y);
      if p.X > maxWidth then
        maxWidth:= p.X;
    end;
    ActualHeight:= curHeight;
    ActualWidth:= maxWidth;

    if not WordWrap and (HorizontalScrollBar <> nil) and (maxWidth > eWidth) then
      Dec(eHeight, HorizontalScrollBar.ButtonSize);

    if (curHeight > eHeight) and (VerticalScrollBar <> nil) then begin
      Dec(eWidth, VerticalScrollBar.ButtonSize);
      if WordWrap and (maxWidth > eWidth) then begin
        curHeight:= 0;
        maxWidth:= R.Width - 1;
        for i := 0 to TCGListBoxStrings(FItems).FLines.Count - 1 do begin
          TCGListBoxStrings(FItems).FLines[i].Text.MaxWidth:= eWidth;
          TCGListBoxStrings(FItems).FLines[i].Text.InitContext;
          p:= TCGListBoxStrings(FItems).FLines[i].Text.CalculateSize;
          Inc(curHeight, p.Y);
          if p.X > maxWidth then
            maxWidth:= p.X;
        end;
      end;
    end;

    ActualHeight:= curHeight;
    ActualWidth:= maxWidth;
  finally
    EndReAlignScrolls;
  end;
end;

procedure TCustomList.SetAlignment(const Value: TAlignment);
var
  i: Integer;
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
    for i := 0 to TCGListBoxStrings(FItems).FLines.Count - 1 do
      TCGListBoxStrings(FItems).FLines[i].Text.Alignment:= FAlignment;
  end;
end;

procedure TCustomList.SetItems(const Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TCustomList.SetLayout(const Value: TTextLayout);
var
  i: Integer;
begin
  if FLayout <> Value then begin
    FLayout := Value;
    for i := 0 to TCGListBoxStrings(FItems).FLines.Count - 1 do
      TCGListBoxStrings(FItems).FLines[i].Text.Layout:= Layout;
  end;
end;

procedure TCustomList.SetWordWrap(const Value: Boolean);
var
  i: Integer;
begin
  if FWordWrap <> Value then begin
    FWordWrap := Value;
    for i := 0 to TCGListBoxStrings(FItems).FLines.Count - 1 do
      TCGListBoxStrings(FItems).FLines[i].Text.WordWrap:= FWordWrap;
  end;
end;

{ TCGButton }

procedure TCGButton.CMColorChanged(var Message: TMessage);
begin
  if FText <> nil then
    FText.Color:= Color;
  Invalidate;
end;

procedure TCGButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if csClicked in ControlState then
    FState:= bsDown
  else
    FState:= bsExclusive;
  Invalidate;
end;

procedure TCGButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FState:= bsUp;
  Invalidate;
end;

procedure TCGButton.CMTextChanged(var Message: TMessage);
begin
  if EnsureTextReady then
    FText.Text:= Caption;
  AdjustSize;
  Invalidate;
end;

constructor TCGButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TCGButton.DesignCalcRect(var R: TRect; var Flags: TTextFormat);
var s: string;
begin
  s:= Caption;
  R:= ClientRect;
  Canvas.Font:= THackControl(Self).Font;
  Flags:= [tfCalcRect];
  //if WordWrap then
  Include(Flags, tfWordBreak);
  //case Alignment of
  //  taLeftJustify: Include(Flags, tfLeft);
  //  taRightJustify: Include(Flags, tfRight);
  {  taCenter:} Include(Flags, tfCenter);
  //end;
  Canvas.TextRect(r, s, Flags);
  Exclude(Flags, tfCalcRect);
end;

procedure TCGButton.DesignPaint;
var s: string;
    r: TRect;
    f: TTextFormat;
begin
  inherited;
  s:= Caption;
  DesignCalcRect(r, f);

  r.Offset(0, (Height - r.Bottom) div 2);
  r.Offset((Width - r.Right) div 2, 0);

  Canvas.Font.Color:= Color;
  Canvas.TextRect(r, s, f);
end;

destructor TCGButton.Destroy;
begin
  FHoverPicture.UpdateValue(nil, Scene);
  FPressedPicture.UpdateValue(nil, Scene);
  FDefaultPicture.UpdateValue(nil, Scene);
  FDisabledPicture.UpdateValue(nil, Scene);
  FHoverDisabledPicture.UpdateValue(nil, Scene);
  FreeText(FText);
  inherited;
end;

procedure TCGButton.DoRender(Context: TCGContextBase; R: TRect);
var t: TRect;
    p: PBilboardContext;
begin
  p:= nil;
  case FState of
    bsUp: begin
        if not Enabled then
          p:= @FDisabledPicture;
        if Enabled or (p.Value = nil) then
          p:= @FDefaultPicture;
      end;
    bsDown: begin
        p:= @FPressedPicture;
        if p.Value = nil then
          p:= @FDefaultPicture;
      end;
    bsExclusive: begin
        p:= @FHoverPicture;
        if not Enabled then begin
          p:= @FHoverDisabledPicture;
          if p.Value = nil then
            p:= @FDisabledPicture;
        end;
        if p.Value = nil then
          p:= @FDefaultPicture;
      end;
  end;

  if (p <> nil) and (p.Value <> nil) then begin
    p.InitializeContext;
    if FLastPicture <> p then begin
      FLastPicture:= p;
      if Assigned(OnNewPictureRender) then
        OnNewPictureRender(p.Value);
    end;
    t.Create(0, 0, p.Value.Width, p.Value.Height);
    p.Value.DrawBilboard(R, t);
  end;

  if (FText <> nil) and FText.IsInvalid then begin
    FText.FreeContext(Context);
    FreeAndNil(FText);
  end;
  EnsureTextReady;
  FText.InitContext;
  //s:= FText.CalculateSize;
  FText.Render(R.Left, R.Top);
end;

function TCGButton.EnsureTextReady: Boolean;
begin
  Result:= FText <> nil;
  if not Result and (Font<> nil) then begin
    FText:= Font.GenerateText();
    FText.Color:= Color;
    FText.Text:= Caption;
    FText.Layout:= tlCenter;
    FText.Alignment:= taCenter;
    FText.WordWrap:= True;
    FText.MaxHeight:= Height;
    FText.MaxWidth:= Width;
    Result:= True;
  end;
end;

procedure TCGButton.FreeContext(Context: TCGContextBase);
begin
  inherited;
  FHoverPicture.FreeContext(Context);
  FPressedPicture.FreeContext(Context);
  FDefaultPicture.FreeContext(Context);
  FDisabledPicture.FreeContext(Context);
  FHoverDisabledPicture.FreeContext(Context);
  if FText <> nil then
    FText.FreeContext(Context);
end;

procedure TCGButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if csClicked in ControlState then
  begin
    FState := bsDown;
    Invalidate;
  end;
end;

procedure TCGButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewState: TButtonState;
begin
  inherited MouseMove(Shift, X, Y);
  if csClicked in ControlState then
  begin
    NewState := bsUp;
    if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
      NewState := bsDown;
    if NewState <> FState then
    begin
      FState := NewState;
      Invalidate;
    end;
  end;
end;

procedure TCGButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if csClicked in ControlState then
  begin
    FState := bsUp;
    Invalidate;
  end;
end;

procedure TCGButton.SetDefaultPicture(const Value: TCGBilboard);
begin
  FDefaultPicture.UpdateValue(Value, Scene);
  if (FLastPicture = @FDefaultPicture) and not FDefaultPicture.Initialised then
    FLastPicture:= nil;
end;

procedure TCGButton.SetDisabledPicture(const Value: TCGBilboard);
begin
  FDisabledPicture.UpdateValue(Value, Scene);
  if (FLastPicture = @FDisabledPicture) and not FDisabledPicture.Initialised then
    FLastPicture:= nil;
end;

procedure TCGButton.SetHoverDisabledPicture(const Value: TCGBilboard);
begin
  FHoverDisabledPicture.UpdateValue(Value, Scene);
  if (FLastPicture = @FHoverDisabledPicture) and not FHoverDisabledPicture.Initialised then
    FLastPicture:= nil;
end;

procedure TCGButton.SetHoverPicture(const Value: TCGBilboard);
begin
  FHoverPicture.UpdateValue(Value, Scene);
  if (FLastPicture = @FHoverPicture) and not FHoverPicture.Initialised then
    FLastPicture:= nil;
end;

procedure TCGButton.SetPressedPicture(const Value: TCGBilboard);
begin
  FPressedPicture.UpdateValue(Value, Scene);
  if (FLastPicture = @FPressedPicture) and not FPressedPicture.Initialised then
    FLastPicture:= nil;
end;

procedure TCGButton.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  if FText <> nil then begin
    FText.MaxHeight:= Height;
    FText.MaxWidth:= Width;
  end;
  Invalidate;
end;

end.

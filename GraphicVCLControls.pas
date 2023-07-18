unit GraphicVCLControls;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls, Vcl.Buttons, Vcl.ImgList, Vcl.ExtCtrls,
  Vcl.Forms, System.UITypes, System.Generics.Collections, GraphicVCLBase;

const
  CM_PARENTSTATECHANGED      = CM_BASE + 90;
  CM_FONTGENERATORCHANGED    = CM_BASE + 91;
  CM_FONTGENERATORDESTROY    = CM_BASE + 92;
  CM_REPEATTIMER             = CM_BASE + 93;
  CM_BORDERSIZECHANGED       = CM_BASE + 94;

type
  TCMFontGeneratorChanged = record
    Msg: Cardinal;
    IsFontChanged: LongBool;
    IsFontChangedFiller: TDWordFiller;
    LParam: LPARAM;
    Result: LRESULT;
  end;

  TCGScene = class;
  TCGWinControl = class;
  TCGControl = class;
  TCGFontGenerator = class;

  TBorderSizeChanged = record
    Msg: Cardinal;
    BorderTemplate: WPARAM;
    OldValue: LPARAM;
    Result: LRESULT;
  end;

  TMouseControlState = record
    IsDragging: Boolean;
    CurrentRect: TRect;
    State: TButtonState;
    function ProcessDown(const R: TRect; X, Y: Integer): Boolean;
    function ProcessMove(X, Y: Integer): Boolean;
    function ProcessUp(X, Y: Integer): Boolean;
  end;

  TContextController<T: TGeneric2DObject> = record
  private
    FInitialised: Boolean;
  public
    Value: T;
    property Initialised: Boolean read FInitialised;
    procedure InitializeContext; //inline;
    procedure FreeContext(AContext: TCGContextBase); inline;
    procedure UpdateValue(AValue: T; Scene: TCGScene); //inline;
  end;

  TChangedFlag = (cfAlignment, cfLayout, cfText, cfWordWrap, cfColor, cfMaxHeight, cfMaxWidth);
  TChangedFlags = set of TChangedFlag;

  TTextObjectBase = class (TObject)
  private
    FFontGenerator: TCGFontGenerator;
    FTextData: TTextData;
    FLastChanging: TChangedFlags;
    FPreparedObject: TSimple2DText;
    FSizeIsReady: Boolean;
    FSize: TPoint;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetLayout(const Value: TTextLayout);
    procedure SetText(const Value: string);
    procedure SetWordWrap(const Value: Boolean);
    function GetIsInvalid: Boolean;
    procedure SetColor(const Value: TColor);
    procedure SetMaxHeight(const Value: Integer);
    procedure SetMaxWidth(const Value: Integer);
  protected
    function DoInitContext(Flags: TChangedFlags): TChangedFlags; virtual;
    procedure InitPrepared;
  public
    constructor Create(AFontGenerator: TCGFontGenerator); virtual;
    destructor Destroy; override;
    procedure Reset; virtual;
    procedure Render(X, Y: Integer); virtual;
    procedure RenderFrame(X, Y: Integer; const ABound: TRect); virtual;
    function CalculateSize: TPoint;
    procedure DoInvalid; virtual;
    procedure InitContext; virtual;
    procedure FreeContext(AContext: TCGContextBase); virtual;
    procedure FreePrepared(AContext: TCGContextBase);
    procedure FreeContextAndDestroy(AContext: TCGContextBase);
    function GetCursorPosition(X, Y: Integer): TTextPosition; overload; virtual;
    function GetCursorPosition(Index: Integer): TTextPosition; overload; virtual;
    procedure Assign(V: TTextObjectBase); virtual;
    property FontGenerator: TCGFontGenerator read FFontGenerator;
    property Text: string read FTextData.Text write SetText;
    property Alignment: TAlignment read FTextData.Alignment write SetAlignment;
    property WordWrap: Boolean read FTextData.WordWrap write SetWordWrap;
    property Layout: TTextLayout read FTextData.Layout write SetLayout;
    property Color: TColor read FTextData.Color write SetColor;
    property IsInvalid: Boolean read GetIsInvalid;
    property MaxHeight: Integer read FTextData.MaxHeight write SetMaxHeight;
    property MaxWidth: Integer read FTextData.MaxWidth write SetMaxWidth;
  end;

  TSceneComponent = class (TComponent)
  private
    FScene: TCGScene;
    FSubscribers: TList<TNotifyEvent>;
    procedure SetScene(const Value: TCGScene);
  protected
    procedure NotifySubscribers;
    function FindScene(AWin: TWinControl): Boolean;
    procedure ContextEvent(AContext: TCGContextBase; IsInitialization: Boolean); virtual;
  public
    procedure Subscribe(Event: TNotifyEvent);
    procedure Unsubscribe(Event: TNotifyEvent);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Scene: TCGScene read FScene write SetScene;
  end;

  TCGFontGenerator = class (TSceneComponent)
  private
    FFont: TFont;
    FSubscribers: TList<TControl>;
    FGeneric2DObjectClass: TGeneric2DObjectClass;
    FFontGeneratorClass: TCGFontGeneratorClass;
    FFontGenerator: TCGFontGeneratorBase;
    FCharSet: string;
    procedure SetFont(const Value: TFont);
    procedure SetGeneric2DObjectClass(const Value: TGeneric2DObjectClass);
    procedure SetFontGeneratorClass(const Value: TCGFontGeneratorClass);
    procedure SetCharSet(const Value: string);
    function GetLineHeight: Integer;
  protected
    procedure NeedRefresh(Sender: TObject);
    function GetFontGenerator: TCGFontGeneratorBase;
    procedure ProcessFontUpdate(AFontChanged: Boolean);
    procedure OnFontChange(Sender: TObject);
    procedure ContextEvent(AContext: TCGContextBase; IsInitialization: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SubscribeOnChange(AControl: TCGControl); overload;
    procedure SubscribeOnChange(AScene: TCGScene); overload;
    procedure UnSubscribeOnChange(AControl: TCGControl); overload;
    procedure UnSubscribeOnChange(AScene: TCGScene); overload;
    function GenerateText: TTextObjectBase;
    function GenerateTextContext(const ATextData: TTextData): TSimple2DText;
    function GetCursorPosition(AText: TTextObjectBase; X, Y: Integer): TTextPosition; overload; virtual;
    function GetCursorPosition(AText: TTextObjectBase; Index: Integer): TTextPosition; overload; virtual;
    function GetSizes(const AInfo: TTextData; var ASize: TPoint): Boolean;
    property Generic2DObjectClass: TGeneric2DObjectClass read FGeneric2DObjectClass write SetGeneric2DObjectClass;
    property FontGeneratorClass: TCGFontGeneratorClass read FFontGeneratorClass write SetFontGeneratorClass;
    property LineHeight: Integer read GetLineHeight;
    property FontGenerator: TCGFontGeneratorBase read GetFontGenerator;
  published
    property Font: TFont read FFont write SetFont;
    property CharSet: string read FCharSet write SetCharSet;
  end;

  TScrollBarElement = (sbeBackground, sbeUp, sbeDown, sbePage);
  TScrollBarState = (sbsDefault, sbsActive, sbsPressed, sbsDisabled);

  TCGScrollBarTemplate = class (TSceneComponent)
  private
    FButtonSize: Integer;
    FButtonUp: array [TScrollBarState] of TContextController<TGeneric2DObject>;
    FButtonDown: array [TScrollBarState] of TContextController<TGeneric2DObject>;
    FButtonPage: array [TScrollBarState] of TContextController<TGeneric2DObject>;
    FButtonBackground: TContextController<TGeneric2DObject>;
    procedure SetButtonDown(const Value: TGeneric2DObject);
    procedure SetButtonPage(const Value: TGeneric2DObject);
    procedure SetButtonSize(const Value: Integer);
    procedure SetButtonUp(const Value: TGeneric2DObject);
    procedure SetButtonBackground(const Value: TGeneric2DObject);
    procedure SetButtonActiveDown(const Value: TGeneric2DObject);
    procedure SetButtonActivePage(const Value: TGeneric2DObject);
    procedure SetButtonActiveUp(const Value: TGeneric2DObject);
    procedure SetButtonPressedDown(const Value: TGeneric2DObject);
    procedure SetButtonPressedPage(const Value: TGeneric2DObject);
    procedure SetButtonPressedUp(const Value: TGeneric2DObject);
  protected
    procedure ContextEvent(AContext: TCGContextBase; IsInitialization: Boolean); override;
  public
    destructor Destroy; override;
    property ButtonUp: TGeneric2DObject read FButtonUp[sbsDefault].Value write SetButtonUp;
    property ButtonDown: TGeneric2DObject read FButtonDown[sbsDefault].Value write SetButtonDown;
    property ButtonPage: TGeneric2DObject read FButtonPage[sbsDefault].Value write SetButtonPage;
    property ButtonActiveUp: TGeneric2DObject read FButtonUp[sbsActive].Value write SetButtonActiveUp;
    property ButtonActiveDown: TGeneric2DObject read FButtonDown[sbsActive].Value write SetButtonActiveDown;
    property ButtonActivePage: TGeneric2DObject read FButtonPage[sbsActive].Value write SetButtonActivePage;
    property ButtonPressedUp: TGeneric2DObject read FButtonUp[sbsPressed].Value write SetButtonPressedUp;
    property ButtonPressedDown: TGeneric2DObject read FButtonDown[sbsPressed].Value write SetButtonPressedDown;
    property ButtonPressedPage: TGeneric2DObject read FButtonPage[sbsPressed].Value write SetButtonPressedPage;
    property ButtonBackground: TGeneric2DObject read FButtonBackground.Value write SetButtonBackground;
  published
    property ButtonSize: Integer read FButtonSize write SetButtonSize;
  end;

  TScrollBarStatus = record
  type
    TOnScrollOffsetChanged = procedure (const Scroll: TScrollBarStatus) of object;
  private
    Bounds: TRect;
    Captured: TScrollBarElement;
    RepeatTimerValue: DWORD;
    DoRepeat: Boolean;
    function GetOffset: Single; inline;
    procedure SetOffset(Value: Single); inline;
    procedure AutoSrollGoUp; inline;
    procedure AutoSrollGoDown; inline;
  public
    OnScrollOffsetChanged: TOnScrollOffsetChanged;
    Template: TCGScrollBarTemplate;
    ElementState: array [TScrollBarElement] of TScrollBarState;
    IsVertical: Boolean;
    LastX, LastY: Integer;
    Enabled: Boolean;
    ScrollOffset, ScrollLength: Integer;
    property Offset: Single read GetOffset write SetOffset;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
    procedure DoRender(AContext: TCGContextBase; X, Y: Integer);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function MouseInScrollArea(X, Y: Integer): Boolean;
    procedure RepeatTimer;
  end;

  TOnScrollOffsetChanged = procedure (const Scroll: TScrollBarStatus) of object;

  THVScrolls = record
  private
    procedure SetOnScrollOffsetChanged(const Value: TOnScrollOffsetChanged);
  public
    Vertical: TScrollBarStatus;
    Horizontal: TScrollBarStatus;
    procedure ReAlign(const R: TRect; RealWidth, RealHeight: Integer);
    procedure DoRender(AContext: TCGContextBase; X, Y: Integer);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoVericalOffset(Offset: Integer);
    procedure DoHorizontalOffset(Offset: Integer);
    procedure RepeatTimer;
    procedure AdjustClientRect(var R: TRect);
    function MouseInScrollArea(X, Y: Integer): Boolean;
    function Offset: TPoint; inline;
    property OnScrollOffsetChanged: TOnScrollOffsetChanged write SetOnScrollOffsetChanged;
  end;

  TCGBorderTemplate = class (TSceneComponent)
  private
    FBottomLeftCornerImage: TContextController<TGeneric2DObject>;
    FRightBorderImage: TContextController<TGeneric2DObject>;
    FBottomRightCornerImage: TContextController<TGeneric2DObject>;
    FBorderSize: Integer;
    FTopLeftCornerImage: TContextController<TGeneric2DObject>;
    FBottomBorderImage: TContextController<TGeneric2DObject>;
    FTopRightCornerImage: TContextController<TGeneric2DObject>;
    FTopBorderImage: TContextController<TGeneric2DObject>;
    FLeftBorderImage: TContextController<TGeneric2DObject>;
    procedure SetBorderSize(const Value: Integer);
    procedure SetBottomBorderImage(const Value: TGeneric2DObject);
    procedure SetBottomLeftCornerImage(const Value: TGeneric2DObject);
    procedure SetBottomRightCornerImage(const Value: TGeneric2DObject);
    procedure SetLeftBorderImage(const Value: TGeneric2DObject);
    procedure SetRightBorderImage(const Value: TGeneric2DObject);
    procedure SetTopBorderImage(const Value: TGeneric2DObject);
    procedure SetTopLeftCornerImage(const Value: TGeneric2DObject);
    procedure SetTopRightCornerImage(const Value: TGeneric2DObject);
  protected
    procedure ContextEvent(AContext: TCGContextBase; IsInitialization: Boolean); override;
  public
    procedure DoRender(AContext: TCGContextBase; const R: TRect);
    destructor Destroy; override;
    property TopBorderImage: TGeneric2DObject read FTopBorderImage.Value write SetTopBorderImage;
    property BottomBorderImage: TGeneric2DObject read FBottomBorderImage.Value write SetBottomBorderImage;
    property LeftBorderImage: TGeneric2DObject read FLeftBorderImage.Value write SetLeftBorderImage;
    property RightBorderImage: TGeneric2DObject read FRightBorderImage.Value write SetRightBorderImage;
    property TopLeftCornerImage: TGeneric2DObject read FTopLeftCornerImage.Value write SetTopLeftCornerImage;
    property TopRightCornerImage: TGeneric2DObject read FTopRightCornerImage.Value write SetTopRightCornerImage;
    property BottomLeftCornerImage: TGeneric2DObject read FBottomLeftCornerImage.Value write SetBottomLeftCornerImage;
    property BottomRightCornerImage: TGeneric2DObject read FBottomRightCornerImage.Value write SetBottomRightCornerImage;
  published
    property BorderSize: Integer read FBorderSize write SetBorderSize;
  end;

  TCGWinControl = class (TWinControl)
  private
    FCanvas: TCanvas;
    FFontGenerator: TCGFontGenerator;
    FParentFont: Boolean;
    FOnFreeContext: TNotifyEvent;
    FBorder: TCGBorderTemplate;
    FBackground: TContextController<TGeneric2DObject>;
    procedure CMParentFontChanged(var Message: TCMParentFontChanged); message CM_PARENTFONTCHANGED;
    procedure CMRepeatTimer(var Message: TMessage); message CM_REPEATTIMER;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentStateChanged(var Message: TMessage); message CM_PARENTSTATECHANGED;
    procedure CMBorderSizeChanged(var Message: TBorderSizeChanged); message CM_BORDERSIZECHANGED;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;

    procedure WMCopy(var Message: TWMCopy); message WM_COPY;
    procedure WMClear(var Message: TWMClear); message WM_CLEAR;
    procedure WMCut(var Message: TWMCut); message WM_CUT;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;

    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure CNKeyUp(var Message: TWMKeyUp); message CN_KEYUP;
    procedure CNChar(var Message: TWMChar); message CN_CHAR;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    function GetCanvas: TCanvas;
    function IsFontStored: Boolean;
    procedure SetParentFont(const Value: Boolean);
    procedure SetBorder(const Value: TCGBorderTemplate);
    procedure SetBackground(const Value: TGeneric2DObject);
  protected
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CorrectMouseEvent(var Message: TWMMouse); virtual;
    procedure ValidateParent(AParent: TWinControl); virtual;
    procedure ValidateInsert(AComponent: TComponent); override;
    procedure ChangeFontGenerator(const Value: TCGFontGenerator);
    procedure SetFontGenerator(const Value: TCGFontGenerator); virtual;
    function GetScene: TCGScene; virtual;
    function GetClientRect: TRect; override;
    function GetClientOrigin: TPoint; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure AdjustSize; override;
    property Canvas: TCanvas read GetCanvas;
    procedure DesignPaint; virtual;
    procedure PaintWindow(DC: HDC); override;
    procedure CreateHandle; override;
    function GetClientRectWithOffset: TRect; virtual;
    procedure SceneChanged(AParent: TWinControl); virtual;
    procedure SetParent(AParent: TWinControl); override;
    function IsControlMouseMsg(var Message: TWMMouse): Boolean;
    procedure WndProc(var Message: TMessage); override;
    procedure ControlWndProc(var Message: TMessage);
    procedure DoUpdateBorder(Sender: TObject); virtual;
    procedure RenderChild(Context: TCGContextBase);
    property ParentFont: Boolean read FParentFont write SetParentFont default True;
    property OnFreeContext: TNotifyEvent read FOnFreeContext write FOnFreeContext;
  public
    procedure MouseWheelHandler(var Message: TMessage); override;
    property Font: TCGFontGenerator read FFontGenerator write SetFontGenerator stored IsFontStored;
    function GetClientOffset: TPoint; virtual;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    destructor Destroy; override;
    property Scene: TCGScene read GetScene;
    procedure Invalidate; override;
    procedure FreeContext(Context: TCGContextBase); virtual;
    procedure Render(Context: TCGContextBase); virtual;
    property Background: TGeneric2DObject read FBackground.Value write SetBackground;
    constructor Create(AOwner: TComponent); override;
  published
    property Border: TCGBorderTemplate read FBorder write SetBorder;
    property Padding;
  end;

  TCGControl = class (TControl)
  private
    FCanvas: TCanvas;
    FBorder: TCGBorderTemplate;
    FAutoHint: TCGControl;
    FPadding: TPadding;
    FBackground: TContextController<TGeneric2DObject>;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure CMMouseEnter(var msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg: TMessage); message CM_MOUSELEAVE;
    procedure CMBorderSizeChanged(var Message: TBorderSizeChanged); message CM_BORDERSIZECHANGED;
    function GetCanvas: TCanvas;
    function GetScene: TCGScene;
    procedure SetBorder(const Value: TCGBorderTemplate);
    procedure SetAutoHint(const Value: TCGControl);
    procedure SetPadding(const Value: TPadding);
    procedure SetBackground(const Value: TGeneric2DObject);
  protected
    procedure Loaded; override;
    property Canvas: TCanvas read GetCanvas;
    procedure DesignPaint; virtual;
    procedure DoRender(Context: TCGContextBase; R: TRect); virtual; abstract;
    procedure DoUpdateBorder(Sender: TObject); virtual;
    procedure SetParent(AParent: TWinControl); override;
    procedure DoLostFocus; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyPress(var Key: Char); virtual;
  public
    function GetClientRectWithOffset: TRect; virtual;
    procedure FreeContext(Context: TCGContextBase); virtual;
    procedure Render(Context: TCGContextBase);
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
    property Scene: TCGScene read GetScene;
    property Background: TGeneric2DObject read FBackground.Value write SetBackground;
    procedure Invalidate; override;
  published
    property Padding: TPadding read FPadding write SetPadding;
    property Border: TCGBorderTemplate read FBorder write SetBorder;
    property AutoHint: TCGControl read FAutoHint write SetAutoHint;
  end;

  TFreeContextEvent = procedure (AContext: TCGContextBase) of object;
  TCustomContextEvent = procedure (AContext: TCGContextBase; AInitialization: Boolean) of object;

  TCGScene = class (TCGWinControl)
  private
    FOwnDC: HDC;
    FContext: TCGContextBase;
    FMouseInControl: Boolean;
    FDoubleBuffered: Boolean;
    FOnPaint: TNotifyEvent;
    FClearMask: LongWord;
    FClearAlpha: Single;
    FToFreeContextList: TList<TFreeContextEvent>;
    FContextEventList: TList<TCustomContextEvent>;
    FCanvas: TCanvas;
    FOnCreateContext: TNotifyEvent;
    FKeyControl: TCGControl;
    FTimer: TTimer;
    FOnRepeatTimer: TNotifyEvent;

    FLastMouseClickMessage: DWORD;
    FLastMouseControl: TControl;
    FLastMouseTime: DWORD;
    procedure CMParentFontChanged(var Message: TCMParentFontChanged); message CM_PARENTFONTCHANGED;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;

    procedure WMCopy(var Message: TWMCopy); message WM_COPY;
    procedure WMClear(var Message: TWMClear); message WM_CLEAR;
    procedure WMCut(var Message: TWMCut); message WM_CUT;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;

    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMDestroy(var Message: TWMDestroy); message WM_DESTROY;
    procedure CMMouseEnter(var msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg: TMessage); message CM_MOUSELEAVE;
    procedure CMInvalidate(var Message: TMessage); message CM_INVALIDATE;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure SetClearMask(const Value: LongWord);
    procedure SetClearAlpha(const Value: Single);
    function GetIsRenderingContextAvailable: Boolean;
    function GetCanvas: TCanvas;
    function GetRepeatTimer: Cardinal;
    procedure SetRepeatTimer(const Value: Cardinal);
  protected
    procedure AdjustSize; override;
    procedure DoRepeatTimer(Sender: TObject);
    procedure CorrectMouseEvent(var Message: TWMMouse); override;
    function GetScene: TCGScene; override;
    procedure OnToFreeContextEvent(Sender: TObject; const Item: TFreeContextEvent; Action: TCollectionNotification);
    procedure ValidateParent(AParent: TWinControl); override;
    procedure SceneChanged(AParent: TWinControl); override;
    property Canvas: TCanvas read GetCanvas;
    procedure QueueFreeContext;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    function GetClientOrigin: TPoint; override;
    procedure PaintWindow(DC: HDC); override;
    procedure SetKeyControl(AControl: TCGControl);
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function TransformMouseEvent(AMessage: DWORD; AControl: TControl): DWORD;
  public
    procedure DoFreeContext;
    function GetClientOffset: TPoint; override;
    procedure AddToFreeContext(Value: TFreeContextEvent);
    procedure SubscribeToContext(ACallBack: TCustomContextEvent);
    procedure UnsubscribeToContext(ACallBack: TCustomContextEvent);
    procedure FreeContext(Context: TCGContextBase); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
    property KeyControl: TCGControl read FKeyControl write SetKeyControl;
    property IsRenderingContextAvailable: Boolean read GetIsRenderingContextAvailable;
    property ClearMask: LongWord read FClearMask write SetClearMask;
    property ClearAlpha: Single read FClearAlpha write SetClearAlpha;
    property GraphicContext: TCGContextBase read FContext;
  published
    property RepeatTimer: Cardinal read GetRepeatTimer write SetRepeatTimer default 200;
    property Align;
    property Anchors;
    property Color;
    property Font;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnMouseLeave;
    property OnMouseEnter;
    property OnFreeContext;
    property OnCreateContext: TNotifyEvent read FOnCreateContext write FOnCreateContext;
    property DoubleBuffered: Boolean read FDoubleBuffered write FDoubleBuffered default True;
    property Constraints;
    property UseDockManager;
    property DockSite;
    property DragKind;
    property DragMode;
    property Enabled;
    property Height;
    property Padding;
    property ShowHint;
    property Touch;
    property TipMode;
    property Visible;
    property Width;
    property OnAlignInsertBefore;
    property OnAlignPosition;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDblClick;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnGesture;
    property OnGetSiteInfo;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDock;
    property OnUnDock;
    property OnRepeatTimer: TNotifyEvent read FOnRepeatTimer write FOnRepeatTimer;
  end;

  TCGPanel = class (TCGWinControl)
  private
  protected
  public
  published
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property Touch;
    property Visible;
    //property OnAlignInsertBefore;
    //property OnAlignPosition;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnGesture;
    //property OnGetSiteInfo;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

  TCGScrollBox = class (TCGWinControl)
  private
    FScrollBars: THVScrolls;
    procedure CMRepeatTimer(var Message: TMessage); message CM_REPEATTIMER;
    procedure SetHorizontalScrollBar(const Value: TCGScrollBarTemplate);
    procedure SetVerticalScrollBar(const Value: TCGScrollBarTemplate);
  protected
    procedure CorrectMouseEvent(var Message: TWMMouse); override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure OnScroll(const Scroll: TScrollBarStatus);
  public
    function GetClientOrigin: TPoint; override;
    function GetClientOffset: TPoint; override;
    procedure SetVerticalScroll(Value: Integer);
    procedure SetHorizontalScroll(Value: Integer);
    procedure Render(Context: TCGContextBase); override;
    constructor Create(AOwner: TComponent); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  published
    property HorizontalScrollBar: TCGScrollBarTemplate read FScrollBars.Horizontal.Template write SetHorizontalScrollBar;
    property VerticalScrollBar: TCGScrollBarTemplate read FScrollBars.Vertical.Template write SetVerticalScrollBar;
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property Touch;
    property Visible;
    //property OnAlignInsertBefore;
    //property OnAlignPosition;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnGesture;
    //property OnGetSiteInfo;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

  TCGFrame = class (TCGWinControl)
  private
    FOnCreateContext: TNotifyEvent;
    FNeedInitContext: Boolean;
    FScene: TCGScene;
  protected
    function GetScene: TCGScene; override;
    procedure SetScene(const Value: TCGScene);
    procedure SceneChanged(AParent: TWinControl); override;
    procedure DesignPaint; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoContextEvent(AContext: TCGContextBase; AInitialization: Boolean);
    procedure ValidateParent(AParent: TWinControl); override;
  public
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure FreeContextAndDestroy(Context: TCGContextBase);
    constructor Create(AOwner: TComponent); override;
    procedure Render(Context: TCGContextBase); override;
  published
    property Align;
    property Anchors;
    //property AutoSize;
    //property BiDiMode;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property Scene: TCGScene read GetScene write SetScene;
    property Touch;
    property Visible;
    property OnAlignInsertBefore;
    property OnAlignPosition;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnFreeContext;
    property OnCreateContext: TNotifyEvent read FOnCreateContext write FOnCreateContext;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnGetSiteInfo;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
  end;

  TCGCustom = class (TCGControl)
  private
    FOnPaint: TNotifyEvent;
    FOnFreeContext: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
  protected
    procedure DoRender(Context: TCGContextBase; R: TRect); override;
    procedure DesignPaint; override;
  public
    procedure FreeContext(Context: TCGContextBase); override;
    procedure BeforeDestruction; override;
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
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
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnFreeContext: TNotifyEvent read FOnFreeContext write FOnFreeContext;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
  end;

  TCGImage = class (TCGControl)
  private
    FStretch: Boolean;
    FProportional: Boolean;
    FPicture: TContextController<TCGBilboard>;
    procedure SetProportional(const Value: Boolean);
    procedure SetStretch(const Value: Boolean);
    procedure SetPicture(const Value: TCGBilboard);
  protected
    procedure DoRender(Context: TCGContextBase; R: TRect); override;
  public
    procedure FreeContext(Context: TCGContextBase); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Picture: TCGBilboard read FPicture.Value write SetPicture;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Proportional: Boolean read FProportional write SetProportional default False;
    property Stretch: Boolean read FStretch write SetStretch default False;
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
  end;

  TCGGroupBox = class (TCGControl)
  private
    FHoverPicture: TContextController<TGeneric2DObject>;
    FPressedPicture: TContextController<TGeneric2DObject>;
    FDefaultPicture: TContextController<TGeneric2DObject>;
    FOnSelectionChanged: TNotifyEvent;
    FSelectedItem: Integer;
    FItemsCount: Integer;
    FOrientation: TScrollBarKind;
    procedure SetDefaultPicture(const Value: TGeneric2DObject);
    procedure SetHoverPicture(const Value: TGeneric2DObject);
    procedure SetItemsCount(const Value: Integer);
    procedure SetOrientation(const Value: TScrollBarKind);
    procedure SetPressedPicture(const Value: TGeneric2DObject);
    procedure SetSelectedItem(const Value: Integer);
  protected
    procedure DesignPaint; override;
    procedure DoRender(Context: TCGContextBase; R: TRect); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure AdjustSize; override;
  public
    property DefaultPicture: TGeneric2DObject read FDefaultPicture.Value write SetDefaultPicture;
    property HoverPicture: TGeneric2DObject read FHoverPicture.Value write SetHoverPicture;
    property PressedPicture: TGeneric2DObject read FPressedPicture.Value write SetPressedPicture;
  published
    property Align;
    property AutoSize;
    property Anchors;
    property Constraints;
    property Enabled;
    property ItemsCount: Integer read FItemsCount write SetItemsCount;
    property Orientation: TScrollBarKind read FOrientation write SetOrientation;
    property Touch;
    property SelectedItem: Integer read FSelectedItem write SetSelectedItem;
    //property SingleSelection: Boolean read FSingleSelection write FSingleSelection;
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
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
  end;

implementation

uses System.RTLConsts, System.Types, WinApi.CommCtrl, Winapi.UxTheme, Vcl.Themes,
  Vcl.Consts;

type
  TWinControlHelper = class helper for TWinControl
    function NonWinControlCount: Integer;
    function GetControl(Index: Integer): TControl;
    function WinControlCount: Integer;
    function GetWinControl(Index: Integer): TWinControl;
    function WinControlAtPos(const Pos: TPoint; AllowDisabled: Boolean): TWinControl;
    procedure ProcessMouseMove(AControl, CaptureControl: TControl);
    procedure ProcessMouseLeave;
    procedure ProcessMouseLocalLeave;
    function IsWinControlMouseMsg(var Message: TWMMouse): Boolean;
    function IsWinControlActivateMsg(var Message: TWMMouseActivate; Control: TControl = nil): Boolean;
    function TranslateToChildWindows(var Message: TMessage): Boolean;
    procedure PrivateRemoveFocus(Removing: Boolean); inline;
    procedure SetMouseControl(AControl: TControl); inline;
    procedure SetWindowPosCustom(X, Y, cx, cy: Integer; uFlags: UINT);
  end;

  TControlHelper = class helper for TControl
    procedure PrivateSetBounds(ALeft, ATop, AWidth, AHeight: Integer);
    procedure PrivateUpdateAnchorRules;
    procedure ProcessWMWindowPosChanged(var Message: TWMWindowPosChanged);
  end;

  TSizeConstraintsHelper = class helper for TSizeConstraints
    procedure SetMaxWidth(V: TConstraintSize); inline;
    procedure SetMaxHeight(V: TConstraintSize); inline;
    procedure SetMinWidth(V: TConstraintSize); inline;
    procedure SetMinHeight(V: TConstraintSize); inline;
  end;

{ TWinControlHelper }

function TWinControlHelper.GetControl(Index: Integer): TControl;
begin
  Result:= TControl(Self.FControls[Index]);
end;

function TWinControlHelper.GetWinControl(Index: Integer): TWinControl;
begin
  Result:= TWinControl(Self.FWinControls[Index]);
end;

function TWinControlHelper.IsWinControlActivateMsg(var Message: TWMMouseActivate;
  Control: TControl): Boolean;
var
  P: TPoint;
  KeyState: TKeyboardState;
  MouseActivateRec: TMouseActivateRec;
begin
  P := ScreenToClient(SmallPointToPoint(System.Types.SmallPoint(GetMessagePos)));
  if Control = nil then
    Control := WinControlAtPos(P, False);
  if Control <> nil then
  begin
    with MouseActivateRec do
    begin
      if Control <> Self then
      begin
        MousePos.X := P.X - Control.Left;
        MousePos.Y := P.Y - Control.Top;
      end else
        MousePos := P;
      HitTest := Message.HitTestCode;
      TopLevel := Message.TopLevel;
      case Message.MouseMsg of
        WM_LBUTTONDOWN, WM_LBUTTONUP, WM_NCLBUTTONDOWN, WM_NCLBUTTONUP:
          Button := mbLeft;
        WM_MBUTTONDOWN, WM_MBUTTONUP, WM_NCMBUTTONDOWN, WM_NCMBUTTONUP:
          Button := mbMiddle;
        WM_RBUTTONDOWN, WM_RBUTTONUP, WM_NCRBUTTONDOWN, WM_NCRBUTTONUP:
          Button := mbRight;
      else
        Button := mbLeft;
      end;
      GetKeyboardState(KeyState);
      ShiftState := KeyboardStateToShiftState(KeyState) + MouseOriginToShiftState;
    end;
    Message.Result := Control.Perform(CM_MOUSEACTIVATE, 0, LPARAM(@MouseActivateRec));
    Result := True;
  end else
    Result := False;
end;

function TWinControlHelper.IsWinControlMouseMsg(var Message: TWMMouse): Boolean;
var
  Control: TControl;
  P: TPoint;
begin
  if GetCapture = Handle then
    Exit(False)
  else begin
    if (Width > 32768) or (Height > 32768) then
      P:= CalcCursorPos
    else
      P:= SmallPointToPoint(Message.Pos);
    Control := WinControlAtPos(P, True);
  end;
  Result := False;
  if Control <> nil then
  begin
    if Message.Msg = WM_MOUSEMOVE then
      ProcessMouseMove(Control, GetCaptureControl);
    P.X := P.X - Control.Left;
    P.Y := P.Y - Control.Top;
    Message.Result := Control.Perform(Message.Msg, Message.Keys, PointToLParam(P));
    Result := True;
  end;
end;

function TWinControlHelper.NonWinControlCount: Integer;
begin
  if Self.FControls = nil then
    Result:= 0
  else
    Result:= Self.FControls.Count;
end;

procedure TWinControlHelper.PrivateRemoveFocus(Removing: Boolean);
begin
  Self.RemoveFocus(Removing);
end;

procedure TWinControlHelper.ProcessMouseLeave;
begin
  Self.FMouseInClient := False;
  if Self.FMouseControl <> nil then
    Self.FMouseControl.Perform(CM_MOUSELEAVE, 0, 0)
  else
    Perform(CM_MOUSELEAVE, 0, 0);
  Self.FMouseControl := nil;
end;

procedure TWinControlHelper.ProcessMouseLocalLeave;
begin
  Self.FMouseInClient := False;
  if (Self.FMouseControl <> nil) and (Self.FMouseControl <> Self) then
    Self.FMouseControl.Perform(CM_MOUSELEAVE, 0, 0);
  Self.FMouseControl := nil;
end;

procedure TWinControlHelper.ProcessMouseMove(AControl, CaptureControl: TControl);
var
  LMouseEvent: TTrackMouseEvent;
begin
  if (Self.FMouseControl <> AControl) then
  begin
    if ((Self.FMouseControl <> nil) and (CaptureControl = nil)) or
       ((CaptureControl <> nil) and (Self.FMouseControl = CaptureControl)) or
       ((CaptureControl is TControl) and (CaptureControl.Parent = Self.FMouseControl)) then
      Self.FMouseControl.Perform(CM_MOUSELEAVE, 0, 0);
    if Self.FMouseControl <> nil then
      Self.FMouseControl.RemoveFreeNotification(Self);
    Self.FMouseControl := AControl;
    if Self.FMouseControl <> nil then
      Self.FMouseControl.FreeNotification(Self);
    if ((Self.FMouseControl <> nil) and (CaptureControl = nil)) or
       ((CaptureControl <> nil) and (Self.FMouseControl = CaptureControl)) then
      Self.FMouseControl.Perform(CM_MOUSEENTER, 0, 0);
  end;
  if not Self.FMouseInClient then
  begin
    Self.FMouseInClient := True;
    // Register for a WM_MOUSELEAVE message which ensures CM_MOUSELEAVE
    // is called when the mouse leaves the TWinControl
    LMouseEvent.dwFlags := TME_LEAVE;
    LMouseEvent.hwndTrack := Handle;
    LMouseEvent.dwHoverTime := HOVER_DEFAULT;
    LMouseEvent.cbSize := SizeOf(LMouseEvent);
    _TrackMouseEvent(@LMouseEvent);
  end;
end;

procedure TWinControlHelper.SetMouseControl(AControl: TControl);
begin
  Self.FMouseControl:= AControl;
  Self.FMouseInClient:= AControl <> nil;
end;

procedure TWinControlHelper.SetWindowPosCustom(X, Y, cx, cy: Integer;
  uFlags: UINT);
var c: TWMWindowPosChanged;
    c2: TWMWindowPosChanging;
    t: TWindowPos;
begin
  t.hwnd:= Handle;
  t.x:= X;
  t.y:= Y;
  t.cx:= cx;
  t.cy:= cy;
  t.flags:= uFlags or SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_NOCOPYBITS or SWP_NOOWNERZORDER or SWP_NOSENDCHANGING;
  c2.WindowPos:= @t;
  c2.Msg:= WM_WINDOWPOSCHANGING;
  WindowProc(TMessage(c2));
  c.WindowPos:= @t;
  c.Msg:= WM_WINDOWPOSCHANGED;
  WindowProc(TMessage(c));
end;

function TWinControlHelper.TranslateToChildWindows(
  var Message: TMessage): Boolean;
begin
  Result:= False;
  case Message.Msg of
    WM_MOUSEFIRST..WM_MOUSELAST:
      begin
        if (Message.Msg <> WM_MOUSEWHEEL) and (WM_MOUSEHWHEEL <> Message.Msg) then
          Result:= IsWinControlMouseMsg(TWMMouse(Message));
      end;
    WM_MOUSEACTIVATE:
      begin
        Result:= IsWinControlActivateMsg(TWMMouseActivate(Message));
      end;
    WM_KEYFIRST..WM_KEYLAST:
      ;//if Dragging then Exit;
  end;
end;

function TWinControlHelper.WinControlAtPos(const Pos: TPoint; AllowDisabled: Boolean): TWinControl;
  function GetControlAtPos(AControl: TControl): Boolean;
  var P: TPoint;
  begin
    with AControl do
    begin
      P.Create(Pos.X - Left, Pos.Y - Top);
      Result := ClientRect.Contains(P) and
                ((csDesigning in ComponentState) and (Visible or
                not (csNoDesignVisible in ControlStyle)) or
                (Visible and (Enabled or AllowDisabled) and
                (Perform(CM_HITTEST, 0, PointToLParam(P)) <> 0)));
    end;
  end;
var I: Integer;
begin
  if Self.FWinControls <> nil then
  for I := Self.FWinControls.Count - 1 downto 0 do
  begin
    if GetControlAtPos(TWinControl(Self.FWinControls[I])) then
      Exit(TWinControl(Self.FWinControls[I]));
  end;
  Result:= nil;
end;

function TWinControlHelper.WinControlCount: Integer;
begin
  if Self.FWinControls = nil then
    Result:= 0
  else
    Result:= Self.FWinControls.Count;
end;

{ TCGScene }

procedure TCGScene.AddToFreeContext(Value: TFreeContextEvent);
begin
  FToFreeContextList.Add(Value);
end;

procedure TCGScene.AdjustSize;
begin
  if not (csLoading in ComponentState) and HandleAllocated then
  begin
    SetWindowPos(Handle, 0, 0, 0, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or
      SWP_NOZORDER);
    RequestAlign;
  end;
end;

procedure TCGScene.CMEnabledChanged(var Message: TMessage);
begin
  if not Enabled and (Parent <> nil) then PrivateRemoveFocus(False);
  if HandleAllocated and not (csDesigning in ComponentState) then
    EnableWindow(WindowHandle, Enabled);
end;

procedure TCGScene.CMInvalidate(var Message: TMessage);
begin
  if HandleAllocated then
  begin
    if Parent <> nil then Parent.Perform(CM_INVALIDATE, 1, 0);
    if Message.WParam = 0 then
    begin
      InvalidateRect(WindowHandle, nil, False);
    end;
  end;
end;

procedure TCGScene.CMMouseEnter(var msg: TMessage);
begin
  inherited;
  FMouseInControl := True;
  {if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);}
end;

procedure TCGScene.CMMouseLeave(var msg: TMessage);
begin
  inherited;
  FMouseInControl := False;
  {if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);}
end;

procedure TCGScene.CMMouseWheel(var Message: TCMMouseWheel);
var P: TPoint;
begin
  P:= ScreenToClient(SmallPointToPoint(TWMMouse(Message).Pos));
  Message.XPos:= P.X;
  Message.YPos:= P.Y;
  inherited;
end;

procedure TCGScene.CMParentFontChanged(var Message: TCMParentFontChanged);
begin
  //do nothing
end;

procedure TCGScene.CMShowingChanged(var Message: TMessage);
const
  ShowFlags: array[Boolean] of Word = (
    SWP_NOSIZE + SWP_NOMOVE + SWP_NOZORDER + SWP_NOACTIVATE + SWP_HIDEWINDOW,
    SWP_NOSIZE + SWP_NOMOVE + SWP_NOZORDER + SWP_NOACTIVATE + SWP_SHOWWINDOW);
begin
  SetWindowPos(WindowHandle, 0, 0, 0, 0, 0, ShowFlags[Showing]);
end;

procedure TCGScene.CMVisibleChanged(var Message: TMessage);
begin
  if not Visible and (Parent <> nil) then PrivateRemoveFocus(False);
  if not (csDesigning in ComponentState) or
    (csNoDesignVisible in ControlStyle) then UpdateControlState;
  if Visible and not (csDesigning in ComponentState) then
    FTimer.Enabled:= True
  else
    FTimer.Enabled:= False;
end;

procedure TCGScene.CorrectMouseEvent(var Message: TWMMouse);
begin
  //do nothing
end;

constructor TCGScene.Create(AOwner: TComponent);
begin
  inherited;
  ParentFont:= False;
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csOpaque, csReplicatable, csPannable, csGestures];
  inherited DoubleBuffered:= False;
  FDoubleBuffered:= True;
  FClearAlpha:= 1.0;
  FToFreeContextList:= TList<TFreeContextEvent>.Create;
  FToFreeContextList.OnNotify:= OnToFreeContextEvent;
  FContextEventList:= TList<TCustomContextEvent>.Create;
  FTimer:= TTimer.Create(Self);
  FTimer.OnTimer:= DoRepeatTimer;
  FTimer.Interval:= 200;
end;

procedure TCGScene.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;
    WindowClass.Style := WindowClass.Style or CS_OWNDC;
    X := Left;
    Y := Top;
  end;
end;

procedure TCGScene.CreateWnd;
var
  i: Integer;
begin
  inherited CreateWnd;
  // initialize and activate the OpenGL rendering context
  // need to do this only once per window creation as we have a private DC
  //FBuffer.Resize(0, 0, Self.Width, Self.Height);
  FOwnDC := GetDC(Handle);
  FContext:= GetContextClass.Create;
  FContext.CreateContext(FOwnDC);

  for i := 0 to FContextEventList.Count - 1 do
    FContextEventList[i](FContext, True);

  if Assigned(FOnCreateContext) then
    FOnCreateContext(Self);
end;

destructor TCGScene.Destroy;
begin
  FCanvas.Free;
  FToFreeContextList.OnNotify:= nil;
  FToFreeContextList.Free;
  FContextEventList.Free;
  inherited;
end;

procedure TCGScene.DestroyWnd;
begin
  DoFreeContext;
  if FOwnDC <> 0 then
  begin
    ReleaseDC(Handle, FOwnDC);
    FOwnDC := 0;
  end;
  inherited DestroyWnd;
end;

procedure TCGScene.DoFreeContext;
begin
  if not (csDesigning in ComponentState) then begin
    if Assigned(FContext) then begin
      FContext.Activate;
      try
        FreeContext(FContext);
      finally
        FContext.DestroyContext;
        FreeAndNil(FContext);
      end;
    end;
  end else
    FreeAndNil(FContext);
end;

procedure TCGScene.DoRepeatTimer(Sender: TObject);
begin
  Perform(CM_REPEATTIMER, 0, 0);
  if Assigned(FOnRepeatTimer) then
    FOnRepeatTimer(Self);
end;

procedure TCGScene.FreeContext(Context: TCGContextBase);
var I: Integer;
begin
  QueueFreeContext;

  for i := 0 to FContextEventList.Count - 1 do
    FContextEventList[i](FContext, False);

  inherited FreeContext(Context);
end;

function TCGScene.GetCanvas: TCanvas;
begin
  if FCanvas = nil then
    FCanvas:= TCanvas.Create;
  Result:= FCanvas;
end;

function TCGScene.GetClientOffset: TPoint;
begin
  Result.Create(0, 0);
end;

function TCGScene.GetClientOrigin: TPoint;
begin
  Result:= inherited GetClientOrigin;
  //Result.Create(0, 0);
end;

function TCGScene.GetIsRenderingContextAvailable: Boolean;
begin
  Result:= (FContext <> nil) and FContext.IsContextCreated;
end;

function TCGScene.GetRepeatTimer: Cardinal;
begin
  Result:= FTimer.Interval;
end;

function TCGScene.GetScene: TCGScene;
begin
  Result:= Self;
end;

procedure TCGScene.Invalidate;
begin
  if csDesigning in ComponentState then
    inherited
  else
    Perform(CM_INVALIDATE, 0, 0);
end;

procedure TCGScene.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if KeyControl <> nil then begin
    KeyControl.KeyDown(Key, Shift);
    if Shift = [ssCtrl] then begin
      if (Key = Ord('C')) or (Key = VK_INSERT) then
        Perform(WM_COPY, 0, 0)
      else if Key = Ord('V') then
        Perform(WM_PASTE, 0, 0)
      else if Key = Ord('X') then
        Perform(WM_CUT, 0, 0)
    end else if Shift = [ssShift] then begin
      if Key = VK_INSERT then
        Perform(WM_PASTE, 0, 0)
      else if Key = VK_DELETE then
        Perform(WM_CUT, 0, 0);
    end;
    Exit;
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TCGScene.KeyPress(var Key: Char);
begin
  if KeyControl <> nil then begin
    KeyControl.KeyPress(Key);
    Exit;
  end;
  inherited KeyPress(Key);
end;

procedure TCGScene.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if KeyControl <> nil then begin
    KeyControl.KeyUp(Key, Shift);
    Exit;
  end;
  inherited KeyUp(Key, Shift);
end;

procedure TCGScene.OnToFreeContextEvent(Sender: TObject;
  const Item: TFreeContextEvent; Action: TCollectionNotification);
begin
  if Action = cnRemoved then
    Item(FContext);
end;

procedure TCGScene.PaintWindow(DC: HDC);
begin
  Canvas.Lock;
  try
    Canvas.Handle := DC;
    try
      Canvas.Brush.Color:= clBtnFace;
      Canvas.FillRect(Rect(0,0,Width, height));
    finally
      Canvas.Handle := 0;
    end;
  finally
    Canvas.Unlock;
  end;
end;

procedure TCGScene.QueueFreeContext;
begin
  FToFreeContextList.Clear;
end;

procedure TCGScene.SceneChanged(AParent: TWinControl);
begin
  //do nothing
end;

procedure TCGScene.SetClearAlpha(const Value: Single);
begin
  FClearAlpha := Value;
end;

procedure TCGScene.SetClearMask(const Value: LongWord);
begin
  FClearMask := Value;
end;

procedure TCGScene.SetKeyControl(AControl: TCGControl);
begin
  if FKeyControl <> AControl then begin
    if FKeyControl <> nil then
      FKeyControl.DoLostFocus;
    FKeyControl:= AControl;
  end;
end;

procedure TCGScene.SetRepeatTimer(const Value: Cardinal);
begin
  FTimer.Interval:= Value;
end;

procedure TCGScene.SubscribeToContext(ACallBack: TCustomContextEvent);
var i: Integer;
begin
  i:= FContextEventList.IndexOf(ACallBack);
  if i < 0 then
    FContextEventList.Add(ACallBack);
end;

function TCGScene.TransformMouseEvent(AMessage: DWORD; AControl: TControl): DWORD;
begin
  Result:= AMessage;
  case AMessage of
    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN: begin
      if (AMessage <> FLastMouseClickMessage) or (AControl <> FLastMouseControl) then begin
        FLastMouseClickMessage:= AMessage;
        FLastMouseControl:= AControl;
        FLastMouseTime:= GetTickCount;
      end else if FLastMouseTime + GetDoubleClickTime > GetTickCount then begin
        //convert to XBUTTONDBLCLK
        Inc(Result, WM_LBUTTONDBLCLK - WM_LBUTTONDOWN);
      end else begin
        FLastMouseClickMessage:= AMessage;
        FLastMouseControl:= AControl;
        FLastMouseTime:= GetTickCount;
      end
    end;
  end;
end;

procedure TCGScene.UnsubscribeToContext(ACallBack: TCustomContextEvent);
var i: Integer;
begin
  i:= FContextEventList.IndexOf(ACallBack);
  if i >= 0 then
    FContextEventList.Delete(i);
end;

procedure TCGScene.ValidateParent(AParent: TWinControl);
begin
  //do nothing
end;

procedure TCGScene.WMClear(var Message: TWMClear);
begin
  if KeyControl <> nil then
    KeyControl.Perform(WM_CLEAR, 0, 0);
end;

procedure TCGScene.WMCopy(var Message: TWMCopy);
begin
  if KeyControl <> nil then
    KeyControl.Perform(WM_COPY, 0, 0);
end;

procedure TCGScene.WMCut(var Message: TWMCut);
begin
  if KeyControl <> nil then
    KeyControl.Perform(WM_CUT, 0, 0);
end;

procedure TCGScene.WMDestroy(var Message: TWMDestroy);
begin
  DoFreeContext;
  if FOwnDC <> 0 then
  begin
    ReleaseDC(Handle, FOwnDC);
    FOwnDC := 0;
  end;
  inherited;
end;

procedure TCGScene.WMPaint(var Message: TWMPaint);
var
  PS: TPaintStruct;
  clearColor: TColor4f;
begin
  if csDesigning in ComponentState then begin
    ControlState:= ControlState + [csCustomPaint];
    inherited;
    ControlState:= ControlState - [csCustomPaint];
    Exit;
  end;
  {p := ClientToScreen(Point(0, 0));
  if (FLastScreenPos.X <> p.X) or (FLastScreenPos.Y <> p.Y) then
  begin
    // Workaround for MS OpenGL "black borders" bug
    if FBuffer.RCInstantiated then
      PostMessage(Handle, WM_SIZE, SIZE_RESTORED,
        Width + (Height shl 16));
    FLastScreenPos := p;
  end;}
  BeginPaint(Handle, PS);
  try
    FContext.Activate;
    FContext.SetViewPort(ClientRect);
    clearColor.Create(Color, FClearAlpha);
    FContext.PrepareNewFrame(FClearMask, clearColor);
    if Assigned(FOnPaint) then
      FOnPaint(Self);

    RenderChild(FContext);

    QueueFreeContext;

    if FDoubleBuffered then
      SwapBuffers(FOwnDC);

    FContext.Deactivate;
  finally
    EndPaint(Handle, PS);
    Message.Result := 0;
  end;
end;

procedure TCGScene.WMPaste(var Message: TWMPaste);
begin
  if KeyControl <> nil then
    KeyControl.Perform(WM_PASTE, 0, 0);
end;

procedure TCGScene.WMSize(var Message: TWMSize);
begin
  inherited;
  //FBuffer.Resize(0, 0, Message.Width, Message.Height);
end;

{ TCGControl }

procedure TCGControl.CMBorderSizeChanged(var Message: TBorderSizeChanged);
begin
  if (FBorder = TCGBorderTemplate(Message.BorderTemplate)) and
      not (csDesigning in ComponentState) then
    Padding.SetBounds(Padding.Left - Message.OldValue + FBorder.BorderSize,
        Padding.Top - Message.OldValue + FBorder.BorderSize,
        Padding.Right - Message.OldValue + FBorder.BorderSize,
        Padding.Bottom - Message.OldValue + FBorder.BorderSize);
end;

procedure TCGControl.CMMouseEnter(var msg: TMessage);
begin
  if (msg.LParam = 0) and (FAutoHint <> nil) then
    FAutoHint.Caption:= Hint;
  inherited;
end;

procedure TCGControl.CMMouseLeave(var msg: TMessage);
begin
  if (msg.LParam = 0) and (FAutoHint <> nil) then
    FAutoHint.Caption:= '';
  inherited;
end;

procedure TCGControl.CMMouseWheel(var Message: TCMMouseWheel);
begin
  with Message do begin
    Result := 0;
    if DoMouseWheel(ShiftState, WheelDelta, SmallPointToPoint(Pos)) then
      Message.Result := 1;
  end;
end;

constructor TCGControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPadding:= TPadding.Create(Self);
end;

procedure TCGControl.DesignPaint;
var R: TRect;
begin
  with Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);

      if FBorder <> nil then begin
        R:= ClientRect;
        R.Inflate(-FBorder.BorderSize, -FBorder.BorderSize);
        Rectangle(R);
      end;
    end;
end;

destructor TCGControl.Destroy;
begin
  FCanvas.Free;
  FBackground.UpdateValue(nil, Scene);
  FPadding.Free;
  if FBorder <> nil then
    FBorder.Unsubscribe(DoUpdateBorder);
  inherited;
end;

procedure TCGControl.DoLostFocus;
begin

end;

procedure TCGControl.DoUpdateBorder(Sender: TObject);
begin
  Invalidate;
end;

procedure TCGControl.FreeContext(Context: TCGContextBase);
begin
  FBackground.FreeContext(Context);
end;

function TCGControl.GetCanvas: TCanvas;
begin
  if FCanvas = nil then
    FCanvas:= TCanvas.Create;
  Result:= FCanvas;
end;

function TCGControl.GetClientRectWithOffset: TRect;
begin
  Result.Create(TCGWinControl(Parent).GetClientOffset, Width, Height);
  Result.Offset(Left, Top);

  Inc(Result.Left, Padding.Left);
  Inc(Result.Top, Padding.Top);
  Dec(Result.Right, Padding.Right);
  Dec(Result.Bottom, Padding.Bottom);
end;

function TCGControl.GetScene: TCGScene;
begin
  if Parent = nil then
    Result:= nil
  else
    Result:= TCGWinControl(Parent).Scene;
end;

procedure TCGControl.Invalidate;
begin
  if csDesigning in ComponentState then
    inherited Invalidate
  else
    if Visible and (Scene <> nil) then
      Scene.Invalidate;
end;

procedure TCGControl.KeyDown(var Key: Word; Shift: TShiftState);
begin

end;

procedure TCGControl.KeyPress(var Key: Char);
begin

end;

procedure TCGControl.KeyUp(var Key: Word; Shift: TShiftState);
begin

end;

procedure TCGControl.Loaded;
begin
  if (FBorder <> nil) and not (csDesigning in ComponentState) then
    Padding.SetBounds(Padding.Left + FBorder.BorderSize,
        Padding.Top + FBorder.BorderSize,
        Padding.Right + FBorder.BorderSize,
        Padding.Bottom + FBorder.BorderSize);
  inherited;
end;

procedure TCGControl.Render(Context: TCGContextBase);
var R: TRect;
begin
  R:= GetClientRectWithOffset;
  if FBackground.Value <> nil then begin
    FBackground.InitializeContext;
    FBackground.Value.DrawWithSize(R.TopLeft, R.Size);
  end;
  DoRender(Context, R);
  if FBorder <> nil then begin
    R.Create(TCGWinControl(Parent).GetClientOffset, Width, Height);
    R.Offset(Left, Top);
    FBorder.DoRender(Context, R);
  end;
end;

procedure TCGControl.SetAutoHint(const Value: TCGControl);
begin
  FAutoHint := Value;
end;

procedure TCGControl.SetBackground(const Value: TGeneric2DObject);
begin
  FBackground.UpdateValue(Value, Scene);
  Invalidate;
end;

procedure TCGControl.SetBorder(const Value: TCGBorderTemplate);
var s: Integer;
begin
  if FBorder <> Value then begin
    if FBorder <> nil then begin
      FBorder.Unsubscribe(DoUpdateBorder);
      s:= FBorder.BorderSize;
    end else
      s:= 0;
    FBorder := Value;
    if FBorder <> nil then begin
      FBorder.Subscribe(DoUpdateBorder);
      Dec(s, FBorder.BorderSize);
    end;
    if (s <> 0) and ([csLoading, csDesigning] * ComponentState = []) then
      Padding.SetBounds(Padding.Left - s, Padding.Top - s, Padding.Right - s, Padding.Bottom - s);
    Invalidate;
  end;
end;

procedure TCGControl.SetPadding(const Value: TPadding);
begin
  FPadding.Assign(Value);
end;

procedure TCGControl.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent is TCGScene) or (AParent is TCGWinControl) then begin
    //
  end else if not (csDestroying in ComponentState) then
    raise EInvalidOperation.Create('Custom Graphic Controls can be placed only on TCGScene or Custom Graphic containers');
end;

procedure TCGControl.WMPaint(var Message: TWMPaint);
begin
  if (csDesigning in ComponentState) and (Message.DC <> 0) and not (csDestroying in ComponentState) then begin
    Canvas.Lock;
    try
      Canvas.Handle := Message.DC;
      try
        DesignPaint;
      finally
        Canvas.Handle := 0;
      end;
    finally
      Canvas.Unlock;
    end;
  end;
end;

{ TCGWinControl }

procedure TCGWinControl.AdjustClientRect(var Rect: TRect);
begin
  inherited AdjustClientRect(Rect);
  if (csDesigning in ComponentState) and (FBorder <> nil) then begin
    Inc(Rect.Left, FBorder.BorderSize);
    Inc(Rect.Top, FBorder.BorderSize);
    Dec(Rect.Right, FBorder.BorderSize);
    Dec(Rect.Bottom, FBorder.BorderSize);
  end;
end;

procedure TCGWinControl.AdjustSize;
begin
  if not (csLoading in ComponentState) and HandleAllocated then
  begin
    SetWindowPosCustom(0, 0, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or
      SWP_NOZORDER);
    RequestAlign;
  end;
end;

procedure TCGWinControl.ChangeFontGenerator(const Value: TCGFontGenerator);
begin
  FFontGenerator:= Value;
  NotifyControls(CM_PARENTFONTCHANGED);
end;

procedure TCGWinControl.CMBorderSizeChanged(var Message: TBorderSizeChanged);
var i: Integer;
begin
  if (FBorder = TCGBorderTemplate(Message.BorderTemplate)) and
      not (csDesigning in ComponentState) then
    Padding.SetBounds(Padding.Left - Message.OldValue + FBorder.BorderSize,
        Padding.Top - Message.OldValue + FBorder.BorderSize,
        Padding.Right - Message.OldValue + FBorder.BorderSize,
        Padding.Bottom - Message.OldValue + FBorder.BorderSize);

  for i := 0 to ControlCount - 1 do
    Controls[i].Perform(CM_BORDERSIZECHANGED, Message.BorderTemplate, Message.OldValue);

  Invalidate;
end;

procedure TCGWinControl.CMEnabledChanged(var Message: TMessage);
var i: Integer;
begin
  for i := 0 to ControlCount - 1 do
    Controls[i].Perform(CM_PARENTSTATECHANGED, 0, 0);
end;

procedure TCGWinControl.CMMouseEnter(var Message: TMessage);
begin
  if Parent <> nil then
    Parent.Perform(CM_MOUSEENTER, 0, Winapi.Windows.LPARAM(Self));
  if (Message.LParam = 0) then
  begin
    if Assigned(OnMouseEnter) then
      OnMouseEnter(Self);

    if ShowHint and not (csDesigning in ComponentState) then
      if CustomHint <> nil then
        CustomHint.ShowHint(Self);
  end else
    SetMouseControl(TControl(Message.LParam));
end;

procedure TCGWinControl.CMMouseLeave(var Message: TMessage);
begin
  if Parent <> nil then
    Parent.Perform(CM_MOUSELEAVE, 0, Winapi.Windows.LPARAM(Self));
  if (Message.LParam = 0) then
  begin
    ProcessMouseLocalLeave;

    if Assigned(OnMouseLeave) then
      OnMouseLeave(Self);

    if ShowHint and not (csDesigning in ComponentState) then
      if CustomHint <> nil then
        CustomHint.HideHint(Self);
  end;
end;

procedure TCGWinControl.CMMouseWheel(var Message: TCMMouseWheel);
var
  w: TWinControl;
  c: TControl;
  p: TPoint;
  r: TSmallPoint;
begin
  r:= Message.Pos;
  Dec(Message.XPos, Left);
  Dec(Message.YPos, Top);
  try
    p:= SmallPointToPoint(Message.Pos);
    w:= WinControlAtPos(p, False);
    if w <> nil then begin
      Message.Result:= w.Perform(CM_MOUSEWHEEL, TMessage(Message).WParam, TMessage(Message).LParam);
      if Message.Result <> 0 then
        Exit;
    end;
    c:= ControlAtPos(p, False);
    if c <> nil then begin
      Message.Result:= c.Perform(CM_MOUSEWHEEL, TMessage(Message).WParam, TMessage(Message).LParam);
      if Message.Result <> 0 then
        Exit;
    end;

    with Message do
      if DoMouseWheel(ShiftState, WheelDelta, p) then
        Result := 1;
  finally
    Message.Pos:= r;
  end;
end;

procedure TCGWinControl.CMParentFontChanged(var Message: TCMParentFontChanged);
begin
  if ParentFont then
    if Parent is TCGWinControl then
      ChangeFontGenerator(TCGWinControl(Parent).Font)
    else if Scene <> nil then
      ChangeFontGenerator(Scene.Font);
end;

procedure TCGWinControl.CMParentStateChanged(var Message: TMessage);
var i: Integer;
begin
  for i := 0 to ControlCount - 1 do
    Controls[i].Perform(CM_PARENTSTATECHANGED, 0, 0);
end;

procedure TCGWinControl.CMRepeatTimer(var Message: TMessage);
var i: Integer;
    c: TControl;
begin
  for i := 0 to ControlCount - 1 do
  begin
    c:= Controls[I];
    if c.Enabled and c.Visible then
      TControl(c).WindowProc(Message);
  end;
end;

procedure TCGWinControl.CMShowingChanged(var Message: TMessage);
begin
  if csDesigning in ComponentState then
    inherited;
end;

procedure TCGWinControl.CMVisibleChanged(var Message: TMessage);
var i: Integer;
begin
  for i := 0 to ControlCount - 1 do
    Controls[i].Perform(CM_PARENTSTATECHANGED, 0, 0);
  UpdateControlState;
  Invalidate;
end;

procedure TCGWinControl.CNChar(var Message: TWMChar);
begin
  if csDesigning in ComponentState then
    inherited
  else begin
    if Scene <> Self then
    //case Message.CharCode of
    //  VK_TAB, VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_RETURN, VK_EXECUTE, VK_ESCAPE, VK_CANCEL:
        Message.Result:= Scene.Perform(WM_CHAR, TMessage(Message).WParam, TMessage(Message).LParam);
    //else
    //  inherited;
    //end;
  end;
end;

procedure TCGWinControl.CNKeyDown(var Message: TWMKeyDown);
begin
  if csDesigning in ComponentState then
    inherited
  else begin
    if Scene <> Self then
      case Message.CharCode of
        VK_TAB, VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_RETURN, VK_EXECUTE, VK_ESCAPE, VK_CANCEL:
          Message.Result:= Scene.Perform(WM_KEYDOWN, TMessage(Message).WParam, TMessage(Message).LParam);
      else
        //inherited;
      end;
  end;
end;

procedure TCGWinControl.CNKeyUp(var Message: TWMKeyUp);
begin
  if csDesigning in ComponentState then
    inherited
  else begin
    if Scene <> Self then
      case Message.CharCode of
        VK_TAB, VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_RETURN, VK_EXECUTE, VK_ESCAPE, VK_CANCEL:
          Message.Result:= Scene.Perform(WM_KEYUP, TMessage(Message).WParam, TMessage(Message).LParam);
      else
        //inherited;
      end;
  end;
end;

procedure TCGWinControl.ControlWndProc(var Message: TMessage);
var
  Form: TCustomForm;
  KeyState: TKeyboardState;
  WheelMsg: TCMMouseWheel;
  Panned: Boolean;
begin
  if (csDesigning in ComponentState) then
  begin
    Form := GetParentForm(Self, False);
    if (Form <> nil) and (Form.Designer <> nil) and
      Form.Designer.IsDesignMsg(Self, Message) then Exit
  end;
  if (Message.Msg >= WM_KEYFIRST) and (Message.Msg <= WM_KEYLAST) then
  begin
    Form := GetParentForm(Self);
    if (Form <> nil) and Form.WantChildKey(Self, Message) then Exit;
  end
  else if (Message.Msg >= WM_MOUSEFIRST) and (Message.Msg <= WM_MOUSELAST) then
  begin
    if not (csDoubleClicks in ControlStyle) then
      case Message.Msg of
        WM_LBUTTONDBLCLK, WM_RBUTTONDBLCLK, WM_MBUTTONDBLCLK:
          Dec(Message.Msg, WM_LBUTTONDBLCLK - WM_LBUTTONDOWN);
      end;
    case Message.Msg of
      WM_MOUSEMOVE: Application.HintMouseMessage(Self, Message);
      WM_MBUTTONDOWN:
      begin
        if (csPannable in ControlStyle) and
        (ControlState * [csDestroyingHandle, csPanning] = []) and
        not Mouse.IsDragging then
        begin
          Mouse.CreatePanningWindow;
          Panned := False;
          if Assigned(Mouse.PanningWindow) then
          begin
            if Self is TWinControl then
              Panned := Mouse.PanningWindow.StartPanning(TWinControl(Self).Handle, Self)
            else if Parent <> nil then
              Panned := Mouse.PanningWindow.StartPanning(Parent.Handle, Self)
            else
            begin
              Form := GetParentForm(Self, False);
              if Form <> nil then
                Panned := Mouse.PanningWindow.StartPanning(Form.Handle, Self);
            end;
          end;
          if Panned then
          begin
            Message.Result := 1;
            Application.HideHint;
          end
          else if Assigned(Mouse.PanningWindow) then
            Mouse.PanningWindow := nil;
        end;
      end;
      WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
        begin
          if DragMode = dmAutomatic then
          begin
            BeginAutoDrag;
            Exit;
          end;
          ControlState:= ControlState + [csLButtonDown];
        end;
      WM_LBUTTONUP:
        ControlState:= ControlState - [csLButtonDown];
    else
      with Mouse do
        if WheelPresent and (RegWheelMessage <> 0) and
          (Integer(Message.Msg) = Integer(RegWheelMessage)) then
        begin
          GetKeyboardState(KeyState);
          with WheelMsg do
          begin
            Msg := Message.Msg;
            ShiftState := KeyboardStateToShiftState(KeyState);
            WheelDelta := Message.WParam;
            Pos := SmallPoint(LongWord(Message.LParam));
          end;
          MouseWheelHandler(TMessage(WheelMsg));
          Exit;
        end;
    end;
  end
  else if Message.Msg = CM_VISIBLECHANGED then
    with Message do
      SendDockNotification(Msg, WParam, LParam);
  Dispatch(Message);
end;

procedure TCGWinControl.CorrectMouseEvent(var Message: TWMMouse);
var CaptureControl: TControl;
    P: TPoint;
begin
  //fix mouse position on capture
  CaptureControl := GetCaptureControl;
  if (CaptureControl <> nil) and (
      (CaptureControl = Self) or (CaptureControl.Parent = Self)) then begin
    P.Create(0, 0);
    P:= ClientToParent(p, Scene);
    Dec(Message.XPos, P.X);
    Dec(Message.YPos, P.Y);
  end;
end;

constructor TCGWinControl.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := [csAcceptsControls];
  ParentFont:= True;
end;

procedure TCGWinControl.CreateHandle;
var
  I: Integer;
begin
  if (csDesigning in ComponentState) or (ClassType = TCGScene) then
    inherited CreateHandle
  else if WindowHandle = 0 then begin
    CreateWnd;
    if Parent <> nil then
      SetWindowPos(WindowHandle, 0, 0, 0, 0, 0,
        SWP_NOMOVE + SWP_NOSIZE + SWP_NOACTIVATE + SWP_HIDEWINDOW);
    for I := 0 to ControlCount - 1 do
      Controls[I].PrivateUpdateAnchorRules;
  end;
end;

procedure TCGWinControl.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if not (csDesigning in ComponentState) then begin
    Params.X:= 0;
    Params.Y:= 0;
    Params.WindowClass.style:= Params.WindowClass.style and not CS_DBLCLKS;
  end;
end;

procedure TCGWinControl.CreateWnd;
var
  Params: TCreateParams;
  ClassRegistered: Boolean;
  TempClass: TWndClass;
begin
  CreateParams(Params);
  with Params do
  begin
    if (WndParent = 0) and (Style and WS_CHILD <> 0) then
      if (Owner <> nil) and (csReading in Owner.ComponentState) and
        (Owner is TWinControl) then
        WndParent := TWinControl(Owner).Handle
      else
        raise EInvalidOperation.CreateFmt(SParentRequired, [Name]);
    DefWndProc := WindowClass.lpfnWndProc;
    ClassRegistered := GetClassInfo(WindowClass.hInstance, WinClassName, TempClass);
    if not ClassRegistered or (TempClass.lpfnWndProc <> @InitWndProc) then
    begin
      if ClassRegistered then
        Winapi.Windows.UnregisterClass(WinClassName, WindowClass.hInstance);
      WindowClass.lpfnWndProc := @InitWndProc;
      WindowClass.lpszClassName := WinClassName;
      if Winapi.Windows.RegisterClass(WindowClass) = 0 then
        RaiseLastOSError;
    end;
    CreationControl := Self;
    CreateWindowHandle(Params);
    if WindowHandle = 0 then
      RaiseLastOSError;
    if (GetWindowLong(WindowHandle, GWL_STYLE) and WS_CHILD <> 0) and
      (GetWindowLong(WindowHandle, GWL_ID) = 0) then
      SetWindowLong(WindowHandle, GWL_ID, WindowHandle);
  end;
  StrDispose(WindowText);
  WindowText := nil;
  if (csDesigning in ComponentState) or (ClassType = TCGScene) then
    UpdateBounds
  else
    PrivateUpdateAnchorRules;
  Perform(WM_SETFONT, inherited Font.Handle, 1);
  if AutoSize then
    AdjustSize;
  if (Touch.GestureEngine <> nil) and (csGestures in ControlStyle) then
    Touch.GestureEngine.Active := True;
end;

procedure TCGWinControl.DesignPaint;
begin
  with Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Color:= clBlack;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
      if FBorder <> nil then
        Rectangle(ClientRect);
    end;
end;

destructor TCGWinControl.Destroy;
begin
  FCanvas.Free;
  FBackground.UpdateValue(nil, Scene);
  if FBorder <> nil then
    FBorder.Unsubscribe(DoUpdateBorder);
  inherited;
end;

procedure TCGWinControl.DoUpdateBorder(Sender: TObject);
begin
  Invalidate;
end;

procedure TCGWinControl.FreeContext(Context: TCGContextBase);
var I: Integer;
    c: TControl;
    wc: TWinControl;
begin
  for I := 0 to NonWinControlCount - 1 do begin
    c:= GetControl(I);
    if c is TCGControl then
      TCGControl(c).FreeContext(Context);
  end;

  for i := 0 to WinControlCount - 1 do
  begin
    wc:= GetWinControl(I);
    TCGWinControl(wc).FreeContext(Context);
  end;

  FBackground.FreeContext(Context);

  if Assigned(FOnFreeContext) then
    FOnFreeContext(Self);
end;

function TCGWinControl.GetCanvas: TCanvas;
begin
  if FCanvas = nil then
    FCanvas:= TCanvas.Create;
  Result:= FCanvas;
end;

function TCGWinControl.GetClientOffset: TPoint;
var P: TWinControl;
    S: TCGScene;
begin
  P:= Parent;
  S:= Scene;
  Result.Create(Left, Top);
  if S <> P then
    Result:= Result + TCGWinControl(P).GetClientOffset;
end;

function TCGWinControl.GetClientOrigin: TPoint;
begin
  if (csDesigning in ComponentState) or (ClassType = TCGScene) then
    Result:= inherited GetClientOrigin
  else begin
    Result := Parent.ClientOrigin;
    Inc(Result.X, Left);
    Inc(Result.Y, Top);
  end;
end;

function TCGWinControl.GetClientRect: TRect;
begin
  if (csDesigning in ComponentState) or (ClassType = TCGScene) then
    Result:= inherited GetClientRect
  else
    Result.Create(0, 0, Width, Height);
end;

function TCGWinControl.GetClientRectWithOffset: TRect;
begin
  Result.Create(GetClientOffset, Width, Height);
end;

function TCGWinControl.GetScene: TCGScene;
begin
  if Parent = nil then
    Result:= nil
  else
    Result:= TCGWinControl(Parent).Scene;
end;

procedure TCGWinControl.Invalidate;
begin
  if csDesigning in ComponentState then
    inherited
  else if Parent <> nil then
    Parent.Invalidate;
end;

function TCGWinControl.IsControlMouseMsg(var Message: TWMMouse): Boolean;
var
  Control: TControl;
  P: TPoint;
  FixedMsg: DWORD;
begin
  if (Width > 32768) or (Height > 32768) then
    P:= CalcCursorPos
  else
    P:= SmallPointToPoint(Message.Pos);

  if GetCapture = Handle then
  begin
    Control:= GetCaptureControl;
    if Control.Parent <> Self then
      Control := nil;
  end else
    Control := ControlAtPos(P, False);
  Result := False;
  if Control <> nil then
  begin
    FixedMsg:= Scene.TransformMouseEvent(Message.Msg, Control);
    P.X := P.X - Control.Left;
    P.Y := P.Y - Control.Top;
    Message.Result := Control.Perform(FixedMsg, Message.Keys, PointToLParam(P));
    Result := True;
  end;
end;

function TCGWinControl.IsFontStored: Boolean;
begin
  Result:= not ParentFont and (Font <> nil);
end;

procedure TCGWinControl.KeyDown(var Key: Word; Shift: TShiftState);
var
  i: Integer;
  wc: TWinControl;
  oldKey: Word;
begin
  for i := 0 to WinControlCount - 1 do
  begin
    wc:= GetWinControl(I);
    if wc.Visible and wc.Enabled then begin
      oldKey:= Key;
      TCGWinControl(wc).KeyDown(oldKey, Shift);
    end;
  end;
  inherited;
end;

procedure TCGWinControl.KeyPress(var Key: Char);
var
  i: Integer;
  wc: TWinControl;
  oldKey: Char;
begin
  for i := 0 to WinControlCount - 1 do
  begin
    wc:= GetWinControl(I);
    if wc.Visible and wc.Enabled then begin
      oldKey:= Key;
      TCGWinControl(wc).KeyPress(oldKey);
    end;
  end;
  inherited;
end;

procedure TCGWinControl.KeyUp(var Key: Word; Shift: TShiftState);
var
  i: Integer;
  wc: TWinControl;
  oldKey: Word;
begin
  for i := 0 to WinControlCount - 1 do
  begin
    wc:= GetWinControl(I);
    if wc.Visible and wc.Enabled then begin
      oldKey:= Key;
      TCGWinControl(wc).KeyUp(oldKey, Shift);
    end;
  end;
  inherited;
end;

procedure TCGWinControl.Loaded;
begin
  if (FBorder <> nil) and not (csDesigning in ComponentState) then
    Padding.SetBounds(Padding.Left + FBorder.BorderSize,
        Padding.Top + FBorder.BorderSize,
        Padding.Right + FBorder.BorderSize,
        Padding.Bottom + FBorder.BorderSize);
  inherited;
end;

procedure TCGWinControl.MouseWheelHandler(var Message: TMessage);
var
  Capture: TControl;
begin
  Capture := GetCaptureControl;
  if Assigned(Capture) and (Capture <> Self) then
    TCGWinControl(Capture).WndProc(Message); //lazy hack
  if Message.Result = 0 then
    Message.Result:= Perform(CM_MOUSEWHEEL, Message.WParam, Message.LParam);
end;

procedure TCGWinControl.PaintWindow(DC: HDC);
begin
  if csDesigning in ComponentState then begin
    Canvas.Handle:= DC;
    DesignPaint;
    Canvas.Handle:= 0;
    inherited PaintWindow(DC);
  end;
end;

procedure TCGWinControl.Render(Context: TCGContextBase);
var R: TRect;
begin
  R:= GetClientRectWithOffset;
  if FBackground.Value <> nil then begin
    FBackground.InitializeContext;
    FBackground.Value.DrawWithSize(R.TopLeft, R.Size);
  end;
  AdjustClientRect(R);
  RenderChild(Context);
  if FBorder <> nil then
    FBorder.DoRender(Context, GetClientRectWithOffset);
end;

procedure TCGWinControl.RenderChild(Context: TCGContextBase);
var i: Integer;
    c: TControl;
    wc: TWinControl;
begin
  for i := 0 to NonWinControlCount - 1 do
  begin
    c:= GetControl(I);
    if c.Visible then
      TCGControl(c).Render(Context);
  end;

  for i := 0 to WinControlCount - 1 do
  begin
    wc:= GetWinControl(I);
    if wc.Visible then
      TCGWinControl(wc).Render(Context);
  end;
end;

procedure TCGWinControl.SceneChanged(AParent: TWinControl);
begin
  if AParent is TCGScene then
  else if AParent is TCGWinControl then
  else if AParent <> nil then
    raise EInvalidOperation.Create('Custom Graphic container can be placed only on TCGScene or Custom Graphic containers: ' + AParent.ClassName);
end;

procedure TCGWinControl.SetBackground(const Value: TGeneric2DObject);
begin
  FBackground.UpdateValue(Value, Scene);
end;

procedure TCGWinControl.SetBorder(const Value: TCGBorderTemplate);
var s: Integer;
begin
  if FBorder <> Value then begin
    if FBorder <> nil then begin
      FBorder.Unsubscribe(DoUpdateBorder);
      s:= FBorder.BorderSize;
    end else
      s:= 0;
    FBorder := Value;
    if FBorder <> nil then begin
      FBorder.Subscribe(DoUpdateBorder);
      Dec(s, FBorder.BorderSize);
    end;

    if (s <> 0) and ([csLoading, csDesigning] * ComponentState = []) then
      Padding.SetBounds(Padding.Left - s, Padding.Top - s, Padding.Right - s, Padding.Bottom - s);
    Invalidate;
  end;
end;

procedure TCGWinControl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if (csDesigning in ComponentState) or (ClassType = TCGScene) then
    inherited SetBounds(ALeft, ATop, AWidth, AHeight)
  else
    if (ALeft <> Left) or (ATop <> Top) or
      (AWidth <> Width) or (AHeight <> Height) then
    begin
      PrivateSetBounds(ALeft, ATop, AWidth, AHeight);
    end;
end;

procedure TCGWinControl.SetFontGenerator(const Value: TCGFontGenerator);
begin
  if FFontGenerator <> Value then begin
    ParentFont:= False;
    ChangeFontGenerator(Value);
  end;
end;

procedure TCGWinControl.SetParent(AParent: TWinControl);
begin
  if not (csDestroying in ComponentState) then
    SceneChanged(AParent);
  ValidateParent(AParent);
  inherited;
end;

procedure TCGWinControl.SetParentFont(const Value: Boolean);
begin
  if FParentFont <> Value then begin
    FParentFont := Value;
    if FParentFont and (Scene <> nil) then
      Perform(CM_PARENTFONTCHANGED, 0, 0);
  end;
end;

procedure TCGWinControl.ValidateInsert(AComponent: TComponent);
begin
  inherited;
  if (AComponent is TCGControl) or (AComponent is TCGWinControl) then
  else if AComponent is TControl then
    raise EInvalidOperation.Create('TCGScene support only Custom Graphic Controls');
end;

procedure TCGWinControl.ValidateParent(AParent: TWinControl);
begin
  if (AParent = nil) or (AParent is TCGWinControl) then
  else
    raise EInvalidOperation.Create('Custom Graphic Container can be placed only on TCGScene or another Custom Graphic containers: ' + AParent.ClassName);
end;

procedure TCGWinControl.WMClear(var Message: TWMClear);
begin
  if csDesigning in ComponentState then
    inherited
  else begin
    if Scene <> Self then
      Message.Result:= Scene.Perform(WM_CLEAR, 0, 0);
  end;
end;

procedure TCGWinControl.WMCopy(var Message: TWMCopy);
begin
  if csDesigning in ComponentState then
    inherited
  else begin
    if Scene <> Self then
      Message.Result:= Scene.Perform(WM_COPY, 0, 0);
  end;
end;

procedure TCGWinControl.WMCut(var Message: TWMCut);
begin
  if csDesigning in ComponentState then
    inherited
  else begin
    if Scene <> Self then
      Message.Result:= Scene.Perform(WM_CUT, 0, 0);
  end;
end;

procedure TCGWinControl.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  if csDesigning in ComponentState then
    inherited
  else
    Message.Result := 1;
end;

procedure TCGWinControl.WMMove(var Message: TWMMove);
begin
  if (csDesigning in ComponentState) or (ClassType = TCGScene) then
    inherited
  else begin
    //DefaultHandler(Message);
    PrivateUpdateAnchorRules;
    UpdateExplicitBounds;
  end;
end;

procedure TCGWinControl.WMPaint(var Message: TWMPaint);
begin
  if csDesigning in ComponentState then
    inherited
  else
    Message.Result := 0;
end;

procedure TCGWinControl.WMPaste(var Message: TWMPaste);
begin
  if csDesigning in ComponentState then
    inherited
  else begin
    if Scene <> Self then
      Message.Result:= Scene.Perform(WM_PASTE, 0, 0);
  end;
end;

procedure TCGWinControl.WMSetCursor(var Message: TWMSetCursor);
var
  Cursor: TCursor;
  Control: TControl;
  w, n: TWinControl;
  P: TPoint;
begin
  with Message do
    if CursorWnd = WindowHandle then
      case HitTest of
        HTCLIENT:
          begin
            Cursor := Screen.Cursor;
            if Cursor = crDefault then
            begin
              GetCursorPos(P);
              P:= ScreenToClient(P);
              w:= Self;
              n:= w.WinControlAtPos(P, True);
              if n <> nil then begin
                Message.Result:= n.Perform(Message.Msg, TCGWinCOntrol(n).WindowHandle, TMessage(Message).LParam);
                Exit;
              end else begin
                Control := w.ControlAtPos(P, False);
                if (Control <> nil) then
                  if csDesigning in Control.ComponentState then
                    Cursor := crArrow
                  else
                    Cursor := Control.Cursor;
                if Cursor = crDefault then
                  if csDesigning in ComponentState then
                    Cursor := crArrow
                  else
                    Cursor := Cursor;
              end;
            end;
            if Cursor <> crDefault then
            begin
              Winapi.Windows.SetCursor(Screen.Cursors[Cursor]);
              Result := 1;
              Exit;
            end;
          end;
        HTERROR:
          if (MouseMsg = WM_LBUTTONDOWN) and (Application.Handle <> 0) and
            (GetForegroundWindow <> GetLastActivePopup(Application.Handle)) then
            Application.BringToFront;
      end;
  with TMessage(Message) do
    Result := CallWindowProc(DefWndProc, WindowHandle, Msg, WParam, LParam);
end;

procedure TCGWinControl.WMSize(var Message: TWMSize);
var
  LList: TList;
begin
  if (csDesigning in ComponentState) or (ClassType = TCGScene) then
    inherited
  else begin
    //DefaultHandler(Message);
    LList := nil;
    if (Parent <> nil) and (TCGWinControl(Parent).AlignControlList <> nil) then
      LList := TCGWinControl(Parent).AlignControlList
    else if AlignControlList <> nil then
      LList := AlignControlList;

    if LList <> nil then
    begin
      if LList.IndexOf(Self) = -1 then
        LList.Add(Self);
    end
    else
    begin
      Realign;
      if not (csLoading in ComponentState) then
        Resize;
    end;
  end;
end;

procedure TCGWinControl.WMWindowPosChanged(var Message: TWMWindowPosChanged);
var
  Framed, Moved, Sized: Boolean;
  WindowPos: PWindowPos;
begin
  if (csDesigning in ComponentState) or (ClassType = TCGScene) then
    inherited
  else begin
    WindowPos := Message.WindowPos;
    Framed := Ctl3D and (csFramed in ControlStyle) and (Parent <> nil) and
      (WindowPos.flags and SWP_NOREDRAW = 0);
    Moved := (WindowPos.flags and SWP_NOMOVE = 0) and
      IsWindowVisible(WindowHandle);
    Sized := (WindowPos.flags and SWP_NOSIZE = 0) and
      IsWindowVisible(WindowHandle);
    if Framed and (Moved or Sized) then
      Invalidate;

    if ClassType = TCGScene then
      with TMessage(Message) do
        Result := CallWindowProc(DefWndProc, WindowHandle, Msg, WParam, LParam)
    else
      ProcessWMWindowPosChanged(Message);
    { Update min/max width/height to actual extents control will allow }
    if ComponentState * [csReading, csLoading] = [] then
    begin
      with Constraints do
      begin
        if (MaxWidth > 0) and (Width > MaxWidth) then
          SetMaxWidth(Width)
        else if (MinWidth > 0) and (Width < MinWidth) then
          SetMinWidth(Width);
        if (MaxHeight > 0) and (Height > MaxHeight) then
          SetMaxHeight(Height)
        else if (MinHeight > 0) and (Height < MinHeight) then
          SetMinHeight(Height);
      end;
    end;

    if Framed and ((Moved or Sized) or (WindowPos.flags and
      (SWP_SHOWWINDOW or SWP_HIDEWINDOW) <> 0)) then
      Invalidate;
  end;
end;

procedure TCGWinControl.WndProc(var Message: TMessage);
var
  Form: TCustomForm;
  Target, CaptureControl: TControl;
begin
  if (csDesigning in ComponentState) then
    inherited WndProc(Message)
  else begin
    case Message.Msg of
      WM_MOUSEFIRST..WM_MOUSELAST:
        CorrectMouseEvent(TWMMouse(Message));
    end;
    if not TranslateToChildWindows(Message) then begin
      //corrected TWinControl.WndProc
      //don't support dragging
      if HandleAllocated and
         ((sfHandleMessages) in TStyleManager.Flags) and
         not (csDestroying in ComponentState) and
         not (csDestroyingHandle in ControlState) and
         not (csOverrideStylePaint in ControlStyle) and
         (StyleElements <> []) and
         DoHandleStyleMessage(Message) then
        Exit;

      case Message.Msg of
        CM_UNTHEMECONTROL:
          if (csDesigning in ComponentState) and StyleServices.Available then
          begin
            SetWindowTheme(Handle, ' ', ' ');
            SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_SHOWWINDOW or SWP_FRAMECHANGED);
          end;
        CM_SETACTIVECONTROL:
          begin
            Form := GetParentForm(Self);
            if Form <> nil then
              Form.Perform(CM_SETACTIVECONTROL, Message.WParam, Message.LParam);
          end;
        WM_SETFOCUS:
          begin
            Form := GetParentForm(Self);
            if (Form <> nil) and (not (csDesigning in Form.ComponentState) or (Form.Parent = nil)) then
              if not Form.SetFocusedControl(Self) then Exit;
          end;
        WM_KILLFOCUS:
          if csFocusing in ControlState then Exit;
        WM_NCHITTEST:
          begin
            inherited WndProc(Message);
            if (Message.Result = HTTRANSPARENT) and (ControlAtPos(ScreenToClient(
              SmallPointToPoint(TWMNCHitTest(Message).Pos)), False) <> nil) then
              Message.Result := HTCLIENT;
            Exit;
          end;
        WM_MOUSELEAVE: {if ClassType = TCGScene then} ProcessMouseLeave;
        WM_MOUSEFIRST..WM_MOUSELAST:
          begin
            with Touch do
              if (GestureEngine <> nil) and (efMouseEvents in GestureEngine.Flags) then
                GestureEngine.Notification(Message);
            if Message.Msg = WM_MOUSEMOVE then
            begin
              CaptureControl := GetCaptureControl;
              if CaptureControl = nil then begin
                Target := ControlAtPos(SmallPointToPoint(TWMMouseMove(Message).Pos), True)
              end else
                Target := CaptureControl;
              ProcessMouseMove(Target, CaptureControl);
            end;
            if (Message.Msg <> WM_MOUSEWHEEL) and (Message.Msg <> WM_MOUSEHWHEEL) then
              if IsControlMouseMsg(TWMMouse(Message)) then
              begin
                { Check HandleAllocated because IsControlMouseMsg might have freed the
                  window if user code executed something like Parent := nil. }
                if (Message.Result = 0) and HandleAllocated
                     and (Message.Msg <> WM_MOUSEWHEEL)
                     and (Message.Msg <> WM_MOUSEHWHEEL) then
                  DefWindowProc(Handle, Message.Msg, Message.wParam, Message.lParam);
                Exit;
              end else
                Message.Msg:= Scene.TransformMouseEvent(Message.Msg, Self);
          end;
        WM_MOUSEACTIVATE:
          begin
            if IsControlActivateMsg(TWMMouseActivate(Message)) then
            begin
              if (Message.Result = 0) and HandleAllocated then
                ControlWndProc(Message);
              Exit;
            end;
          end;
        WM_KEYFIRST..WM_KEYLAST:
          if Dragging then Exit;
        WM_CANCELMODE:
          begin
            CaptureControl := GetCaptureControl;
            if (CaptureControl <> nil) and (CaptureControl.Parent = Self) then
              CaptureControl.Perform(WM_CANCELMODE, 0, 0);
          end;
        CM_DESTROYHANDLE:
          begin
            if Boolean(Message.WParam) then // Sender has csRecreating set
              UpdateRecreatingFlag(True);
            try
              DestroyHandle;
            finally
              if Boolean(Message.WParam) then
                UpdateRecreatingFlag(False);
            end;
            Exit;
          end;
        WM_TOUCH:
          with Touch do
            if (GestureEngine <> nil) and (efTouchEvents in GestureEngine.Flags) then
              GestureEngine.Notification(Message);
      end;
      //TControl.WndProc
      ControlWndProc(Message);

      if Message.Msg = WM_UPDATEUISTATE then
        Invalidate; // Ensure control is repainted
    end;
  end;
end;

{ TCGFontGenerator }

procedure TCGFontGenerator.ContextEvent(AContext: TCGContextBase;
  IsInitialization: Boolean);
begin
  if IsInitialization then begin

  end else begin
    if FFontGenerator <> nil then
      FFontGenerator.FreeContext(AContext);
  end;
end;

constructor TCGFontGenerator.Create(AOwner: TComponent);
begin
  inherited;
  FFont:= TFont.Create;
  FFont.OnChange:= OnFontChange;
  FSubscribers:= TList<TControl>.Create;

  FFontGeneratorClass:= GetFontGeneratorClass;
end;

destructor TCGFontGenerator.Destroy;
var c: TControl;
begin
  while FSubscribers.Count > 0 do begin
    c:= FSubscribers[0];
    TCGControl(c).Perform(CM_FONTGENERATORDESTROY, 0, 0);
  end;
  FSubscribers.Free;
  FFont.Free;
  FFontGenerator.Free;
  inherited;
end;

function TCGFontGenerator.GenerateText: TTextObjectBase;
begin
  Result:= TTextObjectBase.Create(Self);
end;

function TCGFontGenerator.GenerateTextContext(
  const ATextData: TTextData): TSimple2DText;
begin
  Result:= GetFontGenerator.GenerateText(ATextData);
end;

function TCGFontGenerator.GetCursorPosition(AText: TTextObjectBase; X,
  Y: Integer): TTextPosition;
begin
  Result:= GetFontGenerator.GetCursorPosition(AText.FTextData, X, Y);
end;

function TCGFontGenerator.GetCursorPosition(AText: TTextObjectBase;
  Index: Integer): TTextPosition;
begin
  Result:= GetFontGenerator.GetCursorPosition(AText.FTextData, Index);
end;

function TCGFontGenerator.GetFontGenerator: TCGFontGeneratorBase;
begin
  if FFontGenerator = nil then begin
    FFontGenerator:= FFontGeneratorClass.Create(Font, FCharSet);
    FFontGenerator.OnNeedRefresh:= NeedRefresh;
  end;

  Result:= FFontGenerator;
end;

function TCGFontGenerator.GetLineHeight: Integer;
begin
  Result:= GetFontGenerator.LineHeight;
end;

function TCGFontGenerator.GetSizes(const AInfo: TTextData; var ASize: TPoint): Boolean;
begin
  Result:= GetFontGenerator.GetSizes(AInfo, ASize);
end;

procedure TCGFontGenerator.NeedRefresh(Sender: TObject);
begin
  if FScene <> nil then begin
    FScene.Invalidate;
    ProcessFontUpdate(False);
  end;
end;

procedure TCGFontGenerator.OnFontChange(Sender: TObject);
begin
  ProcessFontUpdate(True);
end;

procedure TCGFontGenerator.ProcessFontUpdate(AFontChanged: Boolean);
var i: Integer;
    c: TControl;
begin
  for i := 0 to FSubscribers.Count - 1 do begin
    c:= FSubscribers[i];
    TCGControl(c).Perform(CM_FONTGENERATORCHANGED, WPARAM(AFontChanged), 0);
  end;
end;

procedure TCGFontGenerator.SetCharSet(const Value: string);
begin
  FCharSet := Value;
end;

procedure TCGFontGenerator.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TCGFontGenerator.SetFontGeneratorClass(
  const Value: TCGFontGeneratorClass);
begin
  if FFontGeneratorClass <> Value then begin
    FFontGeneratorClass := Value;
    ProcessFontUpdate(True);
    GetFontGenerator;
  end;
end;

procedure TCGFontGenerator.SetGeneric2DObjectClass(
  const Value: TGeneric2DObjectClass);
begin
  FGeneric2DObjectClass := Value;
end;

procedure TCGFontGenerator.SubscribeOnChange(AScene: TCGScene);
begin
  if not FSubscribers.Contains(AScene) then
    FSubscribers.Add(AScene);
end;

procedure TCGFontGenerator.UnSubscribeOnChange(AScene: TCGScene);
var i: Integer;
begin
  i:= FSubscribers.IndexOf(AScene);
  if i >= 0 then
    FSubscribers.Delete(i);
end;

procedure TCGFontGenerator.SubscribeOnChange(AControl: TCGControl);
begin
  if not FSubscribers.Contains(AControl) then
    FSubscribers.Add(AControl);
end;

procedure TCGFontGenerator.UnSubscribeOnChange(AControl: TCGControl);
var i: Integer;
begin
  i:= FSubscribers.IndexOf(AControl);
  if i >= 0 then
    FSubscribers.Delete(i);
end;

{ TCGImage }

constructor TCGImage.Create(AOwner: TComponent);
begin
  inherited;
  //ControlStyle := ControlStyle + [csAcceptsControls];
end;

destructor TCGImage.Destroy;
begin
  FPicture.UpdateValue(nil, Scene);
  inherited;
end;

procedure TCGImage.DoRender(Context: TCGContextBase; R: TRect);
var t: TRect;
    wp, hp: Single;
begin
  if FPicture.Value <> nil then begin
    FPicture.InitializeContext;
    t.Create(0, 0, FPicture.Value.Width, FPicture.Value.Height);
    if not Stretch then begin
      if t.Right > R.Width then
        t.Right:= R.Width
      else if R.Width > t.Right then
        R.Width:= t.Right;
      if t.Bottom > R.Height then
        t.Bottom:= R.Height
      else if R.Height > t.Bottom then
        R.Height:= t.Bottom;
    end else if Proportional then begin
      wp:= R.Width / t.Right;
      hp:= R.Height / t.Bottom;
      if wp < hp then
        R.Height:= Round(t.Bottom * wp)
      else
        R.Width:= Round(t.Right * hp);
    end;
    FPicture.Value.DrawBilboard(R, t);
  end;
end;

procedure TCGImage.FreeContext(Context: TCGContextBase);
begin
  inherited;
  FPicture.FreeContext(Context);
end;

procedure TCGImage.SetPicture(const Value: TCGBilboard);
begin
  FPicture.UpdateValue(Value, Scene);
end;

procedure TCGImage.SetProportional(const Value: Boolean);
begin
  FProportional:= Value;
end;

procedure TCGImage.SetStretch(const Value: Boolean);
begin
  FStretch:= Value;
end;

{ TCGCustom }

procedure TCGCustom.BeforeDestruction;
begin
  inherited;
  if Assigned(FOnDestroy) then
    FOnDestroy(Self);
end;

constructor TCGCustom.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle:= [csClickEvents, csDoubleClicks, csAlignWithMargins, csGestures];
end;

procedure TCGCustom.DesignPaint;
var s: string;
    r: TRect;
begin
  inherited;
  s:= 'Custom';
  r:= ClientRect;
  Canvas.TextRect(r, s, [tfCenter, tfVerticalCenter, tfSingleLine, tfWordEllipsis]);
end;

procedure TCGCustom.DoRender(Context: TCGContextBase; R: TRect);
begin
  if Assigned(FOnPaint) then
    FOnPaint(Self);
end;

procedure TCGCustom.FreeContext(Context: TCGContextBase);
begin
  inherited;
  if Assigned(FOnFreeContext) then
    FOnFreeContext(Self);
end;

{ TContextController }

procedure TContextController<T>.FreeContext(AContext: TCGContextBase);
begin
  if FInitialised then begin
    Value.FreeContext(AContext);
    FInitialised:= False;
  end;
end;

procedure TContextController<T>.InitializeContext;
begin
  if not FInitialised then begin
    Value.InitContext;
    FInitialised:= True;
  end;
  Value.ActualizeContext;
end;

procedure TContextController<T>.UpdateValue(AValue: T; Scene: TCGScene);
var old: T;
begin
  if Value <> AValue then begin
    old:= Value;
    if AValue <> nil then
      AValue.Reference;
    Value:= AValue;
    if (Scene <> nil) and Initialised then begin
      old.Reference;
      Scene.AddToFreeContext(old.FreeContextAndRelease);
    end;
    FInitialised:= False;
    if old <> nil then
      old.Release;
  end;
end;

{ TTextObjectBase }

procedure TTextObjectBase.Assign(V: TTextObjectBase);
begin
  Alignment:= V.Alignment;
  Text:= V.Text;
  WordWrap:= V.WordWrap;
  Layout:= V.Layout;
  MaxHeight:= V.MaxHeight;
  MaxWidth:= V.MaxWidth;
  Color:= V.Color;
end;

function TTextObjectBase.CalculateSize: TPoint;
begin
  if not IsInvalid then begin
    if not FSizeIsReady then
      if (FPreparedObject <> nil) and FPreparedObject.Ready and (FLastChanging - [cfColor] = []) then begin
        FSizeIsReady:= True;
        FSize.Create(FPreparedObject.Width, FPreparedObject.Height)
      end else
        FSizeIsReady:= FFontGenerator.GetSizes(FTextData, FSize);
    Result:= FSize;
  end else
    Result.Create(0, 0);
end;

constructor TTextObjectBase.Create(AFontGenerator: TCGFontGenerator);
begin
  FFontGenerator:= AFontGenerator;
end;

destructor TTextObjectBase.Destroy;
begin
  DoInvalid;
  FPreparedObject.Free;
  inherited;
end;

function TTextObjectBase.DoInitContext(Flags: TChangedFlags): TChangedFlags;
begin
  if Flags - [cfColor] <> [] then begin
    FreePrepared(FFontGenerator.Scene.GraphicContext);
    InitPrepared;
  end;
  if cfColor in Flags then
    FPreparedObject.Color:= FTextData.Color;
  Result:= [];
end;

procedure TTextObjectBase.DoInvalid;
begin
  if FFontGenerator <> nil then begin
    FFontGenerator:= nil;
  end;
  FSizeIsReady:= False;
end;

procedure TTextObjectBase.FreeContext(AContext: TCGContextBase);
begin
  Reset;
  FreePrepared(AContext);
end;

procedure TTextObjectBase.FreeContextAndDestroy(AContext: TCGContextBase);
begin
  FreeContext(AContext);
  Destroy;
end;

procedure TTextObjectBase.FreePrepared(AContext: TCGContextBase);
begin
  if FPreparedObject <> nil then begin
    FPreparedObject.FreeContextAndRelease(AContext);
    FPreparedObject:= nil;
  end;
end;

function TTextObjectBase.GetCursorPosition(X, Y: Integer): TTextPosition;
begin
  Result:= FFontGenerator.GetCursorPosition(Self, X, Y);
end;

function TTextObjectBase.GetCursorPosition(Index: Integer): TTextPosition;
begin
  Result:= FFontGenerator.GetCursorPosition(Self, Index);
end;

function TTextObjectBase.GetIsInvalid: Boolean;
begin
  Result:= FFontGenerator = nil;
end;

procedure TTextObjectBase.InitContext;
begin
  if FLastChanging <> [] then
    FLastChanging:= DoInitContext(FLastChanging);
  if FPreparedObject = nil then
    InitPrepared;
  FPreparedObject.ActualizeContext;
end;

procedure TTextObjectBase.InitPrepared;
begin
  Assert(FPreparedObject = nil);
  FPreparedObject:= FFontGenerator.GenerateTextContext(FTextData);
  FPreparedObject.Reference;
  FPreparedObject.InitContext;
end;

procedure TTextObjectBase.Render(X, Y: Integer);
begin
  case FTextData.Layout of
    tlTop: FPreparedObject.Draw(X, Y);
    tlCenter: FPreparedObject.Draw(X, Y + (MaxHeight - FPreparedObject.Height) div 2);
    tlBottom: FPreparedObject.Draw(X, Y + (MaxHeight - FPreparedObject.Height));
  end;
end;

procedure TTextObjectBase.RenderFrame(X, Y: Integer; const ABound: TRect);
begin
  case FTextData.Layout of
    tlTop: FPreparedObject.DrawFrame(X, Y, ABound);
    tlCenter: FPreparedObject.DrawFrame(X, Y + (MaxHeight - FPreparedObject.Height) div 2, ABound);
    tlBottom: FPreparedObject.DrawFrame(X, Y + (MaxHeight - FPreparedObject.Height), ABound);
  end;
end;

procedure TTextObjectBase.Reset;
begin
  FLastChanging:= [cfAlignment, cfLayout, cfText, cfWordWrap, cfColor, cfMaxHeight, cfMaxWidth];
end;

procedure TTextObjectBase.SetAlignment(const Value: TAlignment);
begin
  if FTextData.Alignment <> Value then begin
    Include(FLastChanging, cfAlignment);
    FSizeIsReady:= False;
    FTextData.Alignment := Value;
  end;
end;

procedure TTextObjectBase.SetColor(const Value: TColor);
begin
  if FTextData.Color <> Value then begin
    Include(FLastChanging, cfColor);
    FTextData.Color := Value;
  end;
end;

procedure TTextObjectBase.SetLayout(const Value: TTextLayout);
begin
  if FTextData.Layout <> Value then begin
    Include(FLastChanging, cfLayout);
    FSizeIsReady:= False;
    FTextData.Layout := Value;
  end;
end;

procedure TTextObjectBase.SetMaxHeight(const Value: Integer);
begin
  if FTextData.MaxHeight <> Value then begin
    Include(FLastChanging, cfMaxHeight);
    FSizeIsReady:= False;
    FTextData.MaxHeight := Value;
  end;
end;

procedure TTextObjectBase.SetMaxWidth(const Value: Integer);
begin
  if FTextData.MaxWidth <> Value then begin
    Include(FLastChanging, cfMaxWidth);
    FSizeIsReady:= False;
    FTextData.MaxWidth := Value;
  end;
end;

procedure TTextObjectBase.SetText(const Value: string);
begin
  if FTextData.Text <> Value then begin
    Include(FLastChanging, cfText);
    FSizeIsReady:= False;
    FTextData.Text := Value;
  end;
end;

procedure TTextObjectBase.SetWordWrap(const Value: Boolean);
begin
  if FTextData.WordWrap <> Value then begin
    Include(FLastChanging, cfWordWrap);
    FSizeIsReady:= False;
    FTextData.WordWrap := Value;
  end;
end;

{ TCGFrame }

constructor TCGFrame.Create(AOwner: TComponent);
begin
  inherited;
{$IF DEFINED(CLR)}
  GlobalNameSpace.AcquireWriterLock(MaxInt);
{$ELSE}
  GlobalNameSpace.BeginWrite;
{$ENDIF}
  try
    if not (csDesigning in ComponentState) then
    begin
      //Include(FFormState, fsCreating);
      try
        if not InitInheritedComponent(Self, TCGFrame) then
          raise EResNotFound.CreateFmt(SResNotFound, [ClassName]);
      finally
        //Exclude(FFormState, fsCreating);
      end;
    end;
  finally
{$IF DEFINED(CLR)}
    GlobalNameSpace.ReleaseWriterLock;
{$ELSE}
    GlobalNameSpace.EndWrite;
{$ENDIF}
  end;
end;

procedure TCGFrame.CreateParams(var Params: TCreateParams);
begin
  //if csDesigning in ComponentState then begin
    inherited CreateParams(Params);
    with Params.WindowClass do
      style := style and not (CS_HREDRAW or CS_VREDRAW or WS_CAPTION or WS_THICKFRAME or WS_MINIMIZEBOX or
          WS_MAXIMIZEBOX or WS_SYSMENU);
    if Parent = nil then
      Params.WndParent := Application.Handle;
  //end;
end;

procedure TCGFrame.DesignPaint;
begin
end;

procedure TCGFrame.DoContextEvent(AContext: TCGContextBase;
  AInitialization: Boolean);
begin
  if AInitialization then begin
    if Assigned(FOnCreateContext) then
      FOnCreateContext(Self);
  end else
    FreeContext(AContext);
end;

procedure TCGFrame.FreeContextAndDestroy(Context: TCGContextBase);
begin
  FreeContext(Context);
  Destroy;
end;

procedure TCGFrame.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
  OwnedComponent: TComponent;
begin
  inherited GetChildren(Proc, Root);
  if Root = Self then
    for I := 0 to ComponentCount - 1 do
    begin
      OwnedComponent := Components[I];
      if not OwnedComponent.HasParent then Proc(OwnedComponent);
    end;
end;

function TCGFrame.GetScene: TCGScene;
begin
  Result:= FScene;
end;

procedure TCGFrame.Render(Context: TCGContextBase);
begin
  if FNeedInitContext then begin
    FNeedInitContext:= False;
    DoContextEvent(Context, True);
  end;
  inherited;
end;

procedure TCGFrame.SceneChanged(AParent: TWinControl);
var newScene: TCGScene;
begin
  if [csDesigning, csDestroying] * ComponentState = [] then begin
    newScene:= nil;
    if AParent is TCGWinControl then
      newScene:= TCGWinControl(AParent).Scene
    else if AParent <> nil then
      raise EInvalidOperation.Create('TCGFrame can be placed only on TCGScene or Custom Graphic containers: ' + AParent.ClassName);

    if newScene <> FScene then
      Scene:= newScene;

    if (FScene <> nil) and FScene.IsRenderingContextAvailable then
      FNeedInitContext:= True;
  end;
end;

procedure TCGFrame.SetScene(const Value: TCGScene);
begin
  FScene:= Value;
  if Value <> nil then begin
    if (csDesigning in ComponentState) then begin
      if ParentFont then
        ChangeFontGenerator(Value.Font);
    end else if Parent = nil then
      Parent:= Value;
  end;
end;

procedure TCGFrame.ValidateParent(AParent: TWinControl);
begin
  if not (csDesigning in ComponentState) then
    inherited ValidateParent(AParent);
end;

{ TControlHelper }

procedure TControlHelper.PrivateSetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  if TWinControl(Self).HandleAllocated then begin
    TWinControl(Self).SetWindowPosCustom(ALeft, ATop, AWidth, AHeight, 0);
  end else begin
    Self.FLeft := ALeft;
    Self.FTop := ATop;
    Self.FWidth := AWidth;
    Self.FHeight := AHeight;
    Self.UpdateAnchorRules;
    UpdateExplicitBounds;
    RequestAlign;
  end;
end;

procedure TControlHelper.PrivateUpdateAnchorRules;
begin
  Self.UpdateAnchorRules;
end;

procedure TControlHelper.ProcessWMWindowPosChanged(
  var Message: TWMWindowPosChanged);
var m: TWMMove;
    s: TWMSize;
    t: PWindowPos;
begin
  t:= TWMWindowPosChanged(Message).WindowPos;
  if (t.flags and SWP_NOMOVE = 0) and
      ((Left <> t.x) or (Top <> t.y)) then begin
    Self.FLeft := t.x;
    Self.FTop := t.y;
    m.Msg:= WM_MOVE;
    m.XPos:= t.x;
    m.YPos:= t.y;
    WindowProc(TMessage(m));
  end;

  if (t.flags and SWP_NOSIZE = 0) and
      ((Width <> t.cx) or (Height <> t.cy)) then begin
    Self.FWidth := t.cx;
    Self.FHeight := t.cy;
    s.Msg:= WM_SIZE;
    s.SizeType:= SIZE_RESTORED;
    s.Width:= t.cx;
    s.Height:= t.cy;
    WindowProc(TMessage(s));
  end;
end;

{ TSizeConstraintsHelper }

procedure TSizeConstraintsHelper.SetMaxHeight(V: TConstraintSize);
begin
  Self.FMaxHeight:= V;
end;

procedure TSizeConstraintsHelper.SetMaxWidth(V: TConstraintSize);
begin
  Self.FMaxWidth:= V;
end;

procedure TSizeConstraintsHelper.SetMinHeight(V: TConstraintSize);
begin
  Self.FMinHeight:= V;
end;

procedure TSizeConstraintsHelper.SetMinWidth(V: TConstraintSize);
begin
  Self.FMinWidth:= V;
end;

{ TSceneComponent }

procedure TSceneComponent.ContextEvent(AContext: TCGContextBase;
  IsInitialization: Boolean);
begin

end;

constructor TSceneComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FSubscribers:= TList<TNotifyEvent>.Create;

  if AOwner is TWinControl then
    FindScene(TWinControl(AOwner));
end;

destructor TSceneComponent.Destroy;
begin
  FSubscribers.Free;
  inherited;
end;

function TSceneComponent.FindScene(AWin: TWinControl): Boolean;
var
  i: Integer;
begin
  if AWin is TCGScene then begin
    Scene:= TCGScene(AWin);
    Result:= True;
  end else begin
    Result:= False;
    for i := 0 to AWin.WinControlCount - 1 do
      if FindScene(AWin.GetWinControl(i)) then
        Exit(True);
  end;
end;

procedure TSceneComponent.NotifySubscribers;
var
  i: Integer;
begin
  for i := 0 to FSubscribers.Count - 1 do
    FSubscribers[i](Self);
end;

procedure TSceneComponent.SetScene(const Value: TCGScene);
begin
  if FScene <> Value then begin
    if FScene <> nil then
      if csDesigning in ComponentState then
        FScene.UnsubscribeToContext(ContextEvent)
      else
        raise Exception.Create('Can''t change scene after assigning');
    FScene := Value;
    if FScene <> nil then
      FScene.SubscribeToContext(ContextEvent);
  end;
end;

procedure TSceneComponent.Subscribe(Event: TNotifyEvent);
begin
  if FSubscribers.IndexOf(Event) = -1 then
    FSubscribers.Add(Event);
end;

procedure TSceneComponent.Unsubscribe(Event: TNotifyEvent);
begin
  FSubscribers.Remove(Event);
end;

{ TCGScrollBarTemplate }

procedure TCGScrollBarTemplate.ContextEvent(AContext: TCGContextBase;
  IsInitialization: Boolean);
var
  i: TScrollBarState;
begin
  inherited;
  if not IsInitialization then begin
    for i := Low(TScrollBarState) to High(TScrollBarState) do begin
      FButtonUp[i].FreeContext(AContext);
      FButtonDown[i].FreeContext(AContext);
      FButtonPage[i].FreeContext(AContext);
    end;
    FButtonBackground.FreeContext(AContext);
  end;
end;

destructor TCGScrollBarTemplate.Destroy;
var
  i: TScrollBarState;
begin
  for i := Low(TScrollBarState) to High(TScrollBarState) do begin
    FButtonUp[i].UpdateValue(nil, Scene);
    FButtonDown[i].UpdateValue(nil, Scene);
    FButtonPage[i].UpdateValue(nil, Scene);
  end;
  FButtonBackground.UpdateValue(nil, Scene);
  inherited;
end;

procedure TCGScrollBarTemplate.SetButtonActiveDown(
  const Value: TGeneric2DObject);
begin
  FButtonDown[sbsActive].UpdateValue(Value, Scene);
end;

procedure TCGScrollBarTemplate.SetButtonActivePage(
  const Value: TGeneric2DObject);
begin
  FButtonPage[sbsActive].UpdateValue(Value, Scene);
end;

procedure TCGScrollBarTemplate.SetButtonActiveUp(const Value: TGeneric2DObject);
begin
  FButtonUp[sbsActive].UpdateValue(Value, Scene);
end;

procedure TCGScrollBarTemplate.SetButtonBackground(
  const Value: TGeneric2DObject);
begin
  FButtonBackground.UpdateValue(Value, Scene);
end;

procedure TCGScrollBarTemplate.SetButtonDown(const Value: TGeneric2DObject);
begin
  FButtonDown[sbsDefault].UpdateValue(Value, Scene);
end;

procedure TCGScrollBarTemplate.SetButtonPage(const Value: TGeneric2DObject);
begin
  FButtonPage[sbsDefault].UpdateValue(Value, Scene);
end;

procedure TCGScrollBarTemplate.SetButtonPressedDown(
  const Value: TGeneric2DObject);
begin
  FButtonDown[sbsPressed].UpdateValue(Value, Scene);
end;

procedure TCGScrollBarTemplate.SetButtonPressedPage(
  const Value: TGeneric2DObject);
begin
  FButtonPage[sbsPressed].UpdateValue(Value, Scene);
end;

procedure TCGScrollBarTemplate.SetButtonPressedUp(
  const Value: TGeneric2DObject);
begin
  FButtonUp[sbsPressed].UpdateValue(Value, Scene);
end;

procedure TCGScrollBarTemplate.SetButtonSize(const Value: Integer);
begin
  FButtonSize := Value;
end;

procedure TCGScrollBarTemplate.SetButtonUp(const Value: TGeneric2DObject);
begin
  FButtonUp[sbsDefault].UpdateValue(Value, Scene);
end;

{ TCGScrollBox }

procedure TCGScrollBox.AlignControls(AControl: TControl; var Rect: TRect);
var MaxWidth, MaxHeight, AlHeight, AlWidth: Integer;
  i: Integer;
  R: TRect;
begin
  AlHeight:= 0;
  AlWidth:= 0;
  for i := 0 to ControlCount - 1 do with Controls[i] do
    case Align of
      alTop, alBottom: Inc(AlHeight, Height);
      alLeft, alRight: Inc(AlWidth, Width);
    end;

  R:= Rect;
  if Rect.Width < AlWidth then
    R.Width:= AlWidth;
  if Rect.Height < AlHeight then
    R.Height:= AlHeight;

  inherited AlignControls(AControl, R);

  //AlHeight:= 0;
  //AlWidth:= 0;
  MaxWidth:= 0;
  MaxHeight:= 0;
  for i := 0 to ControlCount - 1 do with Controls[i] do
    case Align of
      //alTop, alBottom: Inc(AlHeight, Height);
      //alLeft, alRight: Inc(AlWidth, Width);
      alNone, alCustom: begin
        if MaxWidth < Left + Width then
          MaxWidth:= Left + Width;
        if MaxHeight < Top + Height then
          MaxHeight:= Top + Height;
      end;
    end;

  R:= GetClientRect;
  AdjustClientRect(R);
  FScrollBars.ReAlign(R, MaxWidth, MaxHeight);
end;

procedure TCGScrollBox.CMRepeatTimer(var Message: TMessage);
begin
  inherited;
  FScrollBars.RepeatTimer;
end;

procedure TCGScrollBox.CorrectMouseEvent(var Message: TWMMouse);
begin
  inherited;
  Inc(Message.XPos, FScrollBars.Horizontal.ScrollOffset);
  Inc(Message.YPos, FScrollBars.Vertical.ScrollOffset);
end;

constructor TCGScrollBox.Create(AOwner: TComponent);
begin
  inherited;
  FScrollBars.Vertical.IsVertical:= True;
  FScrollBars.OnScrollOffsetChanged:= OnScroll;
end;

function TCGScrollBox.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  Result:= True;
  if ssShift in Shift then
    FScrollBars.DoHorizontalOffset(WheelDelta)
  else
    FScrollBars.DoVericalOffset(WheelDelta);
  inherited DoMouseWheel(Shift, WheelDelta, MousePos);
end;

function TCGScrollBox.GetClientOffset: TPoint;
begin
  Result:= inherited GetClientOffset;
  Result.Offset(FScrollBars.Offset);
end;

function TCGScrollBox.GetClientOrigin: TPoint;
begin
  Result:= inherited GetClientOrigin;
  Result.Offset(FScrollBars.Offset);
end;

procedure TCGScrollBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if FScrollBars.MouseDown(Button, Shift,
      X - FScrollBars.Horizontal.ScrollOffset, Y - FScrollBars.Vertical.ScrollOffset) then
    MouseCapture:= True;
  inherited;
end;

procedure TCGScrollBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  FScrollBars.MouseMove(Shift,
      X - FScrollBars.Horizontal.ScrollOffset, Y - FScrollBars.Vertical.ScrollOffset);
  inherited;
end;

procedure TCGScrollBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  FScrollBars.MouseUp(Button, Shift,
      X - FScrollBars.Horizontal.ScrollOffset, Y - FScrollBars.Vertical.ScrollOffset);
  if Button = mbLeft then
    MouseCapture:= False;
  inherited;
end;

procedure TCGScrollBox.OnScroll(const Scroll: TScrollBarStatus);
var msg: TWMSetCursor;
begin
  msg.Msg:= WM_SETCURSOR;
  msg.CursorWnd:= WindowHandle;
  msg.HitTest:= HTCLIENT;
  WindowProc(TMessage(msg));
  Invalidate;
end;

procedure TCGScrollBox.Render(Context: TCGContextBase);
var R: TRect;
    b: TPoint;
begin
  R.Create(inherited GetClientOffset, Width, Height);
  AdjustClientRect(R);
  if FBackground.Value <> nil then begin
    FBackground.InitializeContext;
    FBackground.Value.DrawWithSize(R.TopLeft, R.Size);
  end;
  Context.PushScissor(TScissorRect.Create(R, Scene.Height - R.Bottom));
  try
    RenderChild(Context);
  finally
    Context.PopScissor;
  end;

  b:= inherited GetClientOffset;
  FScrollBars.DoRender(Context, b.X, b.Y);

  if FBorder <> nil then begin
    R.Create(b, Width, Height);
    FBorder.DoRender(Context, R);
  end;
end;

procedure TCGScrollBox.SetHorizontalScroll(Value: Integer);
begin

end;

procedure TCGScrollBox.SetHorizontalScrollBar(
  const Value: TCGScrollBarTemplate);
var R: TRect;
begin
  FScrollBars.Horizontal.Template := Value;
  R:= ClientRect;
  AdjustClientRect(R);
  AlignControls(nil, R);
  Invalidate;
end;

procedure TCGScrollBox.SetVerticalScroll(Value: Integer);
begin

end;

procedure TCGScrollBox.SetVerticalScrollBar(const Value: TCGScrollBarTemplate);
var R: TRect;
begin
  FScrollBars.Vertical.Template := Value;
  R:= ClientRect;
  AdjustClientRect(R);
  AlignControls(nil, R);
  Invalidate;
end;

{ TCGBorderTemplate }

procedure TCGBorderTemplate.ContextEvent(AContext: TCGContextBase;
  IsInitialization: Boolean);
begin
  inherited;
  if not IsInitialization then begin
    FBottomLeftCornerImage.FreeContext(AContext);
    FRightBorderImage.FreeContext(AContext);
    FBottomRightCornerImage.FreeContext(AContext);
    FTopLeftCornerImage.FreeContext(AContext);
    FBottomBorderImage.FreeContext(AContext);
    FTopRightCornerImage.FreeContext(AContext);
    FTopBorderImage.FreeContext(AContext);
    FLeftBorderImage.FreeContext(AContext);
  end;
end;

destructor TCGBorderTemplate.Destroy;
begin
  FBottomLeftCornerImage.UpdateValue(nil, Scene);
  FRightBorderImage.UpdateValue(nil, Scene);
  FBottomRightCornerImage.UpdateValue(nil, Scene);
  FTopLeftCornerImage.UpdateValue(nil, Scene);
  FBottomBorderImage.UpdateValue(nil, Scene);
  FTopRightCornerImage.UpdateValue(nil, Scene);
  FTopBorderImage.UpdateValue(nil, Scene);
  FLeftBorderImage.UpdateValue(nil, Scene);
  inherited;
end;

procedure TCGBorderTemplate.DoRender(AContext: TCGContextBase; const R: TRect);
var b: TPoint;
    s: TSize;
begin
  s.Create(BorderSize, BorderSize);
  if FTopLeftCornerImage.Value <> nil then begin
    b:= R.TopLeft;
    FTopLeftCornerImage.InitializeContext;
    FTopLeftCornerImage.Value.DrawWithSize(b, s);
  end;
  if FTopRightCornerImage.Value <> nil then begin
    b.Create(R.Right - BorderSize, R.Top);
    FTopRightCornerImage.InitializeContext;
    FTopRightCornerImage.Value.DrawWithSize(b, s);
  end;
  if FBottomLeftCornerImage.Value <> nil then begin
    b.Create(R.Left, R.Bottom - BorderSize);
    FBottomLeftCornerImage.InitializeContext;
    FBottomLeftCornerImage.Value.DrawWithSize(b, s);
  end;
  if FBottomRightCornerImage.Value <> nil then begin
    b.Create(R.Right - BorderSize, R.Bottom - BorderSize);
    FBottomRightCornerImage.InitializeContext;
    FBottomRightCornerImage.Value.DrawWithSize(b, s);
  end;
  s.cX:= R.Width - BorderSize * 2;
  if s.cX > 0 then begin
    if FTopBorderImage.Value <> nil then begin
      b.Create(R.Left + BorderSize, R.Top);
      FTopBorderImage.InitializeContext;
      FTopBorderImage.Value.DrawWithSize(b, s);
    end;
    if FBottomBorderImage.Value <> nil then begin
      b.Create(R.Left + BorderSize, R.Bottom - BorderSize);
      FBottomBorderImage.InitializeContext;
      FBottomBorderImage.Value.DrawWithSize(b, s);
    end;
  end;
  s.Create(BorderSize, R.Height - BorderSize * 2);
  if s.cY > 0 then begin
    if FLeftBorderImage.Value <> nil then begin
      b.Create(R.Left, R.Top + BorderSize);
      FLeftBorderImage.InitializeContext;
      FLeftBorderImage.Value.DrawWithSize(b, s);
    end;
    if FRightBorderImage.Value <> nil then begin
      b.Create(R.Right - BorderSize, R.Top + BorderSize);
      FRightBorderImage.InitializeContext;
      FRightBorderImage.Value.DrawWithSize(b, s);
    end;
  end;
end;

procedure TCGBorderTemplate.SetBorderSize(const Value: Integer);
var old: Integer;
  i: Integer;
begin
  if FBorderSize <> Value then begin
    old:= FBorderSize;
    FBorderSize:= Value;
    Scene.Perform(CM_BORDERSIZECHANGED, WPARAM(Self), LPARAM(old));
    if csDesigning in ComponentState then begin
      for i := 0 to FSubscribers.Count - 1 do
        TControl(TMethod(FSubscribers[i]).Data).Perform(CM_BORDERSIZECHANGED, WPARAM(Self), LPARAM(old));
    end;
  end;
end;

procedure TCGBorderTemplate.SetBottomBorderImage(const Value: TGeneric2DObject);
begin
  if FBottomBorderImage.Value <> Value then begin
    FBottomBorderImage.UpdateValue(Value, Scene);
    NotifySubscribers;
  end;
end;

procedure TCGBorderTemplate.SetBottomLeftCornerImage(
  const Value: TGeneric2DObject);
begin
  if FBottomLeftCornerImage.Value <> Value then begin
    FBottomLeftCornerImage.UpdateValue(Value, Scene);
    NotifySubscribers;
  end;
end;

procedure TCGBorderTemplate.SetBottomRightCornerImage(
  const Value: TGeneric2DObject);
begin
  if FBottomRightCornerImage.Value <> Value then begin
    FBottomRightCornerImage.UpdateValue(Value, Scene);
    NotifySubscribers;
  end;
end;

procedure TCGBorderTemplate.SetLeftBorderImage(const Value: TGeneric2DObject);
begin
  if FLeftBorderImage.Value <> Value then begin
    FLeftBorderImage.UpdateValue(Value, Scene);
    NotifySubscribers;
  end;
end;

procedure TCGBorderTemplate.SetRightBorderImage(const Value: TGeneric2DObject);
begin
  if FRightBorderImage.Value <> Value then begin
    FRightBorderImage.UpdateValue(Value, Scene);
    NotifySubscribers;
  end;
end;

procedure TCGBorderTemplate.SetTopBorderImage(const Value: TGeneric2DObject);
begin
  if FTopBorderImage.Value <> Value then begin
    FTopBorderImage.UpdateValue(Value, Scene);
    NotifySubscribers;
  end;
end;

procedure TCGBorderTemplate.SetTopLeftCornerImage(
  const Value: TGeneric2DObject);
begin
  if FTopLeftCornerImage.Value <> Value then begin
    FTopLeftCornerImage.UpdateValue(Value, Scene);
    NotifySubscribers;
  end;
end;

procedure TCGBorderTemplate.SetTopRightCornerImage(
  const Value: TGeneric2DObject);
begin
  if FTopRightCornerImage.Value <> Value then begin
    FTopRightCornerImage.UpdateValue(Value, Scene);
    NotifySubscribers;
  end;
end;

{ TCGGroupBox }

procedure TCGGroupBox.AdjustSize;
begin
  inherited AdjustSize;

end;

procedure TCGGroupBox.DesignPaint;
var R: TRect;
    i, l: Integer;
begin
  inherited;
  with Canvas do
    begin
      if FBorder <> nil then begin
        R:= ClientRect;
        Rectangle(R);
      end;
      Pen.Style := psSolid;
      Brush.Style := bsClear;
      if Orientation = sbHorizontal then begin
        l:= Width div ItemsCount;
        for i:= 0 to ItemsCount - 1 do
          Ellipse(i * l, 0, l, Height);
      end else begin
        l:= Height div ItemsCount;
        for i:= 0 to ItemsCount - 1 do
          Ellipse(0, i * l, Width, l);
      end;
    end;
end;

procedure TCGGroupBox.DoRender(Context: TCGContextBase; R: TRect);
begin

end;

procedure TCGGroupBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

end;

procedure TCGGroupBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TCGGroupBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

end;

procedure TCGGroupBox.SetDefaultPicture(const Value: TGeneric2DObject);
begin
  FDefaultPicture.UpdateValue(Value, Scene);
end;

procedure TCGGroupBox.SetHoverPicture(const Value: TGeneric2DObject);
begin
  FHoverPicture.UpdateValue(Value, Scene);
end;

procedure TCGGroupBox.SetItemsCount(const Value: Integer);
begin
  if FItemsCount <> Value then begin
    FItemsCount := Value;
    Invalidate;
  end;
end;

procedure TCGGroupBox.SetOrientation(const Value: TScrollBarKind);
begin
  if FOrientation <> Value then begin
    FOrientation := Value;
    Invalidate;
  end;
end;

procedure TCGGroupBox.SetPressedPicture(const Value: TGeneric2DObject);
begin
  FPressedPicture.UpdateValue(Value, Scene);
end;

procedure TCGGroupBox.SetSelectedItem(const Value: Integer);
begin
  FSelectedItem := Value;
end;

{ TScrollBarStatus }

procedure TScrollBarStatus.AutoSrollGoDown;
var ofs: Integer;
begin
  ofs:= ScrollOffset;
  Offset:= Offset - 0.1;
  if (ofs = ScrollOffset) and (ScrollOffset > 0) then
    Dec(ScrollOffset);
end;

procedure TScrollBarStatus.AutoSrollGoUp;
var ofs: Integer;
begin
  ofs:= ScrollOffset;
  Offset:= Offset + 0.1;
  if (ofs = ScrollOffset) and (ScrollOffset < ScrollLength) then
    Inc(ScrollOffset);
end;

procedure TScrollBarStatus.DoRender(AContext: TCGContextBase; X, Y: Integer);
var b: TSize;
    t: TPoint;
    l: Integer;
    button: ^TContextController<TGeneric2DObject>;
  i: TScrollBarState;
begin
  b.Create(Template.ButtonSize, Template.ButtonSize);
  if Template.FButtonBackground.Value <> nil then begin
    Template.FButtonBackground.InitializeContext;
    Template.FButtonBackground.Value.DrawWithSize(
        TPoint.Create(Bounds.Left + X, Bounds.Top + Y),
        Bounds.Size);
  end;

  button:= nil;

  for i := ElementState[sbeUp] downto Low(TScrollBarState) do begin
    button:= @Template.FButtonUp[i];
    if button.Value <> nil then
      Break;
  end;

  if button.Value <> nil then begin
    button.InitializeContext;
    button.Value.DrawWithSize(
        TPoint.Create(Bounds.Left + X, Bounds.Top + Y), b);
  end;

  for i := ElementState[sbeDown] downto Low(TScrollBarState) do begin
    button:= @Template.FButtonDown[i];
    if button.Value <> nil then
      Break;
  end;

  if IsVertical then begin
    if button.Value <> nil then begin
      button.InitializeContext;
      t.Create(Bounds.Left + X, Bounds.Bottom - b.cY + Y);
      button.Value.DrawWithSize(t, b);
    end;

    l:= Bounds.Height - Template.ButtonSize * 3;
    if l >= Template.ButtonSize then begin
      for i := ElementState[sbePage] downto Low(TScrollBarState) do begin
        button:= @Template.FButtonPage[i];
        if button.Value <> nil then
          Break;
      end;

      if button.Value <> nil then begin
        button.InitializeContext;
        t.X:= Bounds.Left + X;
        t.Y:= Round(Offset * l) + Bounds.Top + Template.ButtonSize + Y;
        button.Value.DrawWithSize(t, b);
      end;
    end;
  end else begin
    if button.Value <> nil then begin
      button.InitializeContext;
      t.Create(Bounds.Right - b.cY + X, Bounds.Top + Y);
      button.Value.DrawWithSize(t, b);
    end;

    l:= Bounds.Width - Template.ButtonSize * 3;
    if l >= Template.ButtonSize then begin
      for i := ElementState[sbePage] downto Low(TScrollBarState) do begin
        button:= @Template.FButtonPage[i];
        if button.Value <> nil then
          Break;
      end;

      if button.Value <> nil then begin
        button.InitializeContext;
        t.X:= Round(Offset * l) + Bounds.Left + Template.ButtonSize + X;
        t.Y:= Bounds.Top + Y;
        button.Value.DrawWithSize(t, b);
      end;
    end;
  end;
end;

function TScrollBarStatus.GetOffset: Single;
begin
  if ScrollLength = 0 then
    Result:= 0
  else
    Result:= ScrollOffset / ScrollLength;
end;

function TScrollBarStatus.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer): Boolean;

  procedure ScrollUp;
  begin
    ElementState[sbeUp]:= sbsPressed;
    RepeatTimerValue:= GetTickCount;
    AutoSrollGoDown;
    DoRepeat:= False;
    Captured:= sbeUp;
  end;

  procedure ScrollDown;
  begin
    ElementState[sbeDown]:= sbsPressed;
    RepeatTimerValue:= GetTickCount;
    AutoSrollGoUp;
    DoRepeat:= False;
    Captured:= sbeDown;
  end;
var
  i: TScrollBarElement;
  l, ofs: Integer;
begin
  if Button = mbLeft then begin
    for i := Low(TScrollBarElement) to High(TScrollBarElement) do
      ElementState[i]:= sbsDefault;
    if (X < Bounds.Left) or (Y < Bounds.Top) or (X >= Bounds.Right) or
        (Y >= Bounds.Bottom) then
      Exit(False);
    if IsVertical then begin
      if Y < Template.ButtonSize then begin
        ScrollUp;
        Exit(True);
      end else if (Y >= Bounds.Bottom - Template.ButtonSize) and (Y < Bounds.Bottom) then begin
        ScrollDown;
        Exit(True);
      end else begin
        l:= Bounds.Height - Template.ButtonSize * 3;
        if l >= Template.ButtonSize then begin
          ofs:= Round(Offset * l) + Bounds.Top;
          if (Y >= Template.ButtonSize + ofs) and (Y < Template.ButtonSize * 2 + ofs) then begin
            ElementState[sbePage]:= sbsPressed;
            LastX:= X - Bounds.Left;
            LastY:= Y - Template.ButtonSize - ofs;
            Captured:= sbePage;
            Exit(True);
          end;
        end;
        Offset:= (Y - Template.ButtonSize - Bounds.Top) / (Bounds.Height - Template.ButtonSize * 2);
      end;
    end else begin
      if X < Template.ButtonSize then begin
        ScrollUp;
        Exit(True);
      end else if (X >= Bounds.Right - Template.ButtonSize) and (X < Bounds.Right) then begin
        ScrollDown;
        Exit(True);
      end else begin
        l:= Bounds.Width - Template.ButtonSize * 3;
        if l >= Template.ButtonSize then begin
          ofs:= Round(Offset * l) + Bounds.Left;
          if (X >= Template.ButtonSize + ofs) and (X < Template.ButtonSize * 2 + ofs) then begin
            ElementState[sbePage]:= sbsPressed;
            LastX:= X - Template.ButtonSize - ofs;
            LastY:= Y - Bounds.Top;
            Captured:= sbePage;
            Exit(True);
          end;
        end;
        Offset:= (X - Template.ButtonSize - Bounds.Left) / (Bounds.Width - Template.ButtonSize * 2);
      end;
    end;
  end;
  Captured:= sbeBackground;
  Result:= False;
end;

function TScrollBarStatus.MouseInScrollArea(X, Y: Integer): Boolean;
begin
  if (X < Bounds.Left) or (Y < Bounds.Top) or (X >= Bounds.Right) or
      (Y >= Bounds.Bottom) then
    Exit(False);
  Result:= True;
end;

procedure TScrollBarStatus.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i: TScrollBarElement;
  l: Integer;
  ofs: Integer;
begin
  for i := Low(TScrollBarElement) to High(TScrollBarElement) do
    ElementState[i]:= sbsDefault;
  if (Captured <> sbePage) and ((X < Bounds.Left) or (Y < Bounds.Top) or (X >= Bounds.Right) or
      (Y >= Bounds.Bottom)) then
    Exit;
  if IsVertical then begin
    if Y < Template.ButtonSize then begin
      if Captured = sbeUp then
        ElementState[sbeUp]:= sbsPressed
      else
        ElementState[sbeUp]:= sbsActive;
    end else if (Y >= Bounds.Bottom - Template.ButtonSize) and (Y < Bounds.Bottom) then begin
      if Captured = sbeDown then
        ElementState[sbeDown]:= sbsPressed
      else
        ElementState[sbeDown]:= sbsActive;
    end else begin
      l:= Bounds.Height - Template.ButtonSize * 3;
      if Captured = sbePage then begin
        Offset:= (Y - LastY - Bounds.Top - Template.ButtonSize) / l;
      end else if l >= Template.ButtonSize then begin
        ofs:= Round(Offset * l) + Bounds.Top;
        if (Y >= Template.ButtonSize + ofs) and (Y < Template.ButtonSize * 2 + ofs) then begin
          ElementState[sbePage]:= sbsActive;
        end;
      end;
    end;
  end else begin
    if X < Template.ButtonSize then begin
      if Captured = sbeUp then
        ElementState[sbeUp]:= sbsPressed
      else
        ElementState[sbeUp]:= sbsActive;
    end else if (X >= Bounds.Right - Template.ButtonSize) and (Y < Bounds.Right) then begin
      if Captured = sbeDown then
        ElementState[sbeDown]:= sbsPressed
      else
        ElementState[sbeDown]:= sbsActive;
    end else begin
      l:= Bounds.Width - Template.ButtonSize * 3;
      if Captured = sbePage then begin
        Offset:= (X - LastX - Bounds.Left - Template.ButtonSize) / l;
      end else if l >= Template.ButtonSize then begin
        ofs:= Round(Offset * l) + Bounds.Left;
        if (X >= Template.ButtonSize + ofs) and (X < Template.ButtonSize * 2 + ofs) then begin
          ElementState[sbePage]:= sbsActive;
        end;
      end;
    end;
  end;
end;

procedure TScrollBarStatus.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if Button = mbLeft then begin
    Captured:= sbeBackground;
    DoRepeat:= False;
    MouseMove(Shift, X, Y);
  end;
end;

procedure TScrollBarStatus.RepeatTimer;
begin
  if (Captured = sbeUp) or (Captured = sbeDown) then begin
    if RepeatTimerValue + 600 < GetTickCount then
      DoRepeat:= True;
    if DoRepeat then begin
      if ElementState[sbeUp] = sbsPressed then
        AutoSrollGoDown
      else if ElementState[sbeDown] = sbsPressed then
        AutoSrollGoUp;
    end;
  end;
end;

procedure TScrollBarStatus.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if Template <> nil then begin
    if IsVertical then
      AWidth:= Template.ButtonSize
    else
      AHeight:= Template.ButtonSize;
    Bounds.Create(ALeft, ATop, ALeft + AWidth, ATop + AHeight);
  end;
end;

procedure TScrollBarStatus.SetOffset(Value: Single);
var old: Integer;
begin
  old:= ScrollOffset;
  if ScrollLength = 0 then
    ScrollOffset:= 0
  else begin
    ScrollOffset:= Round(Value * ScrollLength);
    if ScrollOffset < 0 then
      ScrollOffset:= 0
    else if ScrollOffset > ScrollLength then
      ScrollOffset:= ScrollLength;
  end;
  if Assigned(OnScrollOffsetChanged) and (old <> ScrollOffset) then
    OnScrollOffsetChanged(Self);
end;

{ THVScrolls }

procedure THVScrolls.AdjustClientRect(var R: TRect);
begin
  if Vertical.Enabled then
    Dec(R.Right, Vertical.Template.ButtonSize);
  if Horizontal.Enabled then
    Dec(R.Bottom, Horizontal.Template.ButtonSize);
end;

procedure THVScrolls.DoHorizontalOffset(Offset: Integer);
var old: Integer;
begin
  if Horizontal.Enabled then begin
    old:= Horizontal.ScrollOffset;
    Dec(Horizontal.ScrollOffset, Offset);
    if Horizontal.ScrollOffset < 0 then
      Horizontal.ScrollOffset:= 0
    else if Horizontal.ScrollOffset > Horizontal.ScrollLength then
      Horizontal.ScrollOffset:= Horizontal.ScrollLength;
    if Assigned(Horizontal.OnScrollOffsetChanged) and (old <> Horizontal.ScrollOffset) then
      Horizontal.OnScrollOffsetChanged(Horizontal);
  end;
end;

procedure THVScrolls.DoRender(AContext: TCGContextBase; X, Y: Integer);
begin
  if Horizontal.Enabled then
    Horizontal.DoRender(AContext, X, Y);

  if Vertical.Enabled then
    Vertical.DoRender(AContext, X, Y);
end;

procedure THVScrolls.DoVericalOffset(Offset: Integer);
var old: Integer;
begin
  if Vertical.Enabled then begin
    old:= Vertical.ScrollOffset;
    Dec(Vertical.ScrollOffset, Offset);
    if Vertical.ScrollOffset < 0 then
      Vertical.ScrollOffset:= 0
    else if Vertical.ScrollOffset > Vertical.ScrollLength then
      Vertical.ScrollOffset:= Vertical.ScrollLength;
    if Assigned(Vertical.OnScrollOffsetChanged) and (old <> Vertical.ScrollOffset) then
      Vertical.OnScrollOffsetChanged(Vertical);
  end else
    DoHorizontalOffset(Offset);
end;

function THVScrolls.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer): Boolean;
begin
  Result:= False;
  if Horizontal.Enabled then
    Result:= Horizontal.MouseDown(Button, Shift, X, Y);

  if not Result and Vertical.Enabled then
    Result:= Vertical.MouseDown(Button, Shift, X, Y);
end;

function THVScrolls.MouseInScrollArea(X, Y: Integer): Boolean;
begin
  Result:= False;

  if Horizontal.Enabled then
    Result:= Horizontal.MouseInScrollArea(X, Y);

  if Vertical.Enabled then
    Result:= Result or Vertical.MouseInScrollArea(X, Y);
end;

procedure THVScrolls.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Horizontal.Enabled then
    Horizontal.MouseMove(Shift, X, Y);

  if Vertical.Enabled then
    Vertical.MouseMove(Shift, X, Y);
end;

procedure THVScrolls.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Horizontal.Enabled then
    Horizontal.MouseUp(Button, Shift, X, Y);

  if Vertical.Enabled then
    Vertical.MouseUp(Button, Shift, X, Y);
end;

function THVScrolls.Offset: TPoint;
begin
  Result.Create(-Horizontal.ScrollOffset, -Vertical.ScrollOffset);
end;

procedure THVScrolls.ReAlign(const R: TRect; RealWidth, RealHeight: Integer);
var ctrlHeight, ctrlWidth: Integer;
begin
  ctrlHeight:= R.Height;
  ctrlWidth:= R.Width;
  if Horizontal.Template <> nil then begin
    Horizontal.Enabled:= ctrlWidth < RealWidth;
    if Horizontal.Enabled then
      ctrlHeight:= R.Height - Horizontal.Template.ButtonSize;
  end else
    Horizontal.Enabled:= False;

  if Vertical.Template <> nil then begin
    Vertical.Enabled:= ctrlHeight < RealHeight;
    if Vertical.Enabled then begin
      ctrlWidth:= ctrlWidth - Vertical.Template.ButtonSize;
      if Horizontal.Template <> nil then
        Horizontal.Enabled:= ctrlWidth < RealWidth;
    end;
  end else
    Horizontal.Enabled:= False;

  if Horizontal.Enabled then begin
    if Horizontal.ScrollOffset + ctrlWidth > RealWidth then
      Horizontal.ScrollOffset:= RealWidth - ctrlWidth;
    Horizontal.ScrollLength:= RealWidth - ctrlWidth;

    Horizontal.Bounds.Create(R.Left, R.Bottom - Horizontal.Template.ButtonSize, R.Right, R.Bottom);
  end else
    Horizontal.ScrollOffset:= 0;

  if Vertical.Enabled then begin
    if Vertical.ScrollOffset + ctrlHeight > RealHeight then
      Vertical.ScrollOffset:= RealHeight - ctrlHeight;
    Vertical.ScrollLength:= RealHeight - ctrlHeight;
    Vertical.Bounds.Create(R.Right - Vertical.Template.ButtonSize, R.Top, R.Right, R.Bottom);
  end else
    Vertical.ScrollOffset:= 0;
end;

procedure THVScrolls.RepeatTimer;
begin
  if Vertical.Enabled then
    Vertical.RepeatTimer;
  if Horizontal.Enabled then
    Horizontal.RepeatTimer;
end;

procedure THVScrolls.SetOnScrollOffsetChanged(
  const Value: TOnScrollOffsetChanged);
begin
  Horizontal.OnScrollOffsetChanged:= TScrollBarStatus.TOnScrollOffsetChanged(Value);
  Vertical.OnScrollOffsetChanged:= TScrollBarStatus.TOnScrollOffsetChanged(Value);
end;

{ TMouseControlState }

function TMouseControlState.ProcessDown(const R: TRect; X, Y: Integer): Boolean;
begin
  Result:= False;
  if R.Contains(Point(X, Y)) then begin
    IsDragging:= True;
    CurrentRect:= R;
    State:= bsDown;
    Result:= True;
  end;
end;

function TMouseControlState.ProcessMove(X, Y: Integer): Boolean;
var NewState: TButtonState;
begin
  Result:= False;
  NewState := bsUp;
  if CurrentRect.Contains(Point(X, Y)) then
    NewState := bsDown;
  if NewState <> State then
  begin
    State := NewState;
    Result:= True;
  end;
end;

function TMouseControlState.ProcessUp(X, Y: Integer): Boolean;
begin
  IsDragging := False;
  Result := CurrentRect.Contains(Point(X, Y));
  State := bsUp;
end;

end.

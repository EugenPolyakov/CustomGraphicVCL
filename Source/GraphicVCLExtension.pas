unit GraphicVCLExtension;

interface

uses System.SysUtils, System.Classes, Vcl.StdCtrls, Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics, GraphicVCLBase, GraphicVCLControls;

type
  TControlWithFont = class (TCGControl)
  private
    FFontGenerator: TCGFontGenerator;
    FParentFont: Boolean;
    procedure CMParentFontChanged(var Message: TCMParentFontChanged); message CM_PARENTFONTCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMFontGeneratorChanged(var Message: TCMFontGeneratorChanged); message CM_FONTGENERATORCHANGED;
    procedure CMComponentDestroying(var Message: TCMComponentDestoyng); message CM_COMPONENTDESTROYING;
    procedure SetFontGenerator(const Value: TCGFontGenerator);
    procedure SetParentFont(const Value: Boolean);
  protected
    function IsFontStored: Boolean;
    procedure FreeText(var AText: TTextObjectBase);
    procedure DesignPaint; override;
    procedure DesignCalcRect(var R: TRect; var Flags: TTextFormat; AAlignment: TAlignment; AWordWrap: Boolean);
  public
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
  published
    property Font: TCGFontGenerator read FFontGenerator write SetFontGenerator stored IsFontStored;
    property ParentFont: Boolean read FParentFont write SetParentFont default True;
    property Color default clWindowText;
  end;

  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  TUpDownTemplate = class (TSceneComponent)
  private
    FButtonHoverUp: TContextController<TGeneric2DObject>;
    FButtonWidth: Integer;
    FButtonDown: TContextController<TGeneric2DObject>;
    FButtonHoverDown: TContextController<TGeneric2DObject>;
    FButtonUp: TContextController<TGeneric2DObject>;
    procedure SetButtonDown(const Value: TGeneric2DObject);
    procedure SetButtonHoverDown(const Value: TGeneric2DObject);
    procedure SetButtonHoverUp(const Value: TGeneric2DObject);
    procedure SetButtonUp(const Value: TGeneric2DObject);
    procedure SetButtonWidth(const Value: Integer);
  protected
    procedure ContextEvent(AContext: TCGContextBase; IsInitialization: Boolean); override;
  public
    procedure DoRender(AContext: TCGContextBase; const R: TRect; UpHover, DownHover: Boolean);
    destructor Destroy; override;
    property ButtonHoverUp: TGeneric2DObject read FButtonHoverUp.Value write SetButtonHoverUp;
    property ButtonUp: TGeneric2DObject read FButtonUp.Value write SetButtonUp;
    property ButtonHoverDown: TGeneric2DObject read FButtonHoverDown.Value write SetButtonHoverDown;
    property ButtonDown: TGeneric2DObject read FButtonDown.Value write SetButtonDown;
  published
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth;
  end;

  TControlWithInput = class (TControlWithFont)
  private
    FOnKeyDown: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnKeyUp: TKeyEvent;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentStateChanged(var Message: TMessage); message CM_PARENTSTATECHANGED;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
  public
    function CanFocus: Boolean;
    function IsFocused: Boolean;
    procedure SetFocus;
  published
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
  end;

  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  TCGStackPanel = class (TCGScrollBox)
  private
    FWrap: Boolean;
    FUseVerticalOrientation: Boolean;
    procedure SetWrap(const Value: Boolean);
    procedure SetUseVerticalOrientation(const Value: Boolean);
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Wrap: Boolean read FWrap write SetWrap default True;
    property UseVerticalOrientation: Boolean read FUseVerticalOrientation write SetUseVerticalOrientation default False;
  end;

implementation

type
  THackControl = class (TControl);

{ TControlWithFont }

procedure TControlWithFont.CMColorChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TControlWithFont.CMComponentDestroying(var Message: TCMComponentDestoyng);
begin
  inherited;

  if Font = Message.ComponentObject then
    Font:= nil;
end;

procedure TControlWithFont.CMFontGeneratorChanged(var Message: TCMFontGeneratorChanged);
begin
  if (csDesigning in ComponentState) and (Font <> nil) then
    THackControl(Self).Font:= Font.Font;
  if (Parent <> nil) and (FFontGenerator <> TCGWinControl(Parent).Font) then
    ParentFont:= False;
  Invalidate;
end;

procedure TControlWithFont.CMParentFontChanged(
  var Message: TCMParentFontChanged);
begin
  if FParentFont then
    if Parent is TCGWinControl then
      Font:= TCGWinControl(Parent).Font
    else if Scene <> nil then
      Font:= Scene.Font;
end;

constructor TControlWithFont.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParentFont:= True;
  Color:= clWindowText;
end;

procedure TControlWithFont.DesignCalcRect(var R: TRect; var Flags: TTextFormat; AAlignment: TAlignment; AWordWrap: Boolean);
var s: string;
begin
  s:= Caption;
  R:= TRect.Create(0, 0, Padding.ControlWidth, Padding.ControlHeight);
  Canvas.Font:= THackControl(Self).Font;
  Flags:= [tfCalcRect];
  if AWordWrap then
    Include(Flags, tfWordBreak);
  case AAlignment of
    taLeftJustify: Include(Flags, tfLeft);
    taRightJustify: Include(Flags, tfRight);
    taCenter: Include(Flags, tfCenter);
  end;
  Canvas.TextRect(r, s, Flags);
  Exclude(Flags, tfCalcRect);
end;

procedure TControlWithFont.DesignPaint;
begin
  inherited DesignPaint;
  Canvas.Font:= inherited Font;
end;

destructor TControlWithFont.Destroy;
begin
  Font:= nil;
  inherited;
end;

procedure TControlWithFont.FreeText(var AText: TTextObjectBase);
begin
  if (AText <> nil) and (Scene <> nil) then begin
    Scene.AddToFreeContext(AText.FreeContextAndDestroy);
    AText:= nil;
  end else
    FreeAndNil(AText);
end;

function TControlWithFont.IsFontStored: Boolean;
begin
  Result:= not ParentFont and (Font <> nil);
end;

procedure TControlWithFont.SetFontGenerator(const Value: TCGFontGenerator);
begin
  if FFontGenerator <> Value then begin
    if FFontGenerator <> nil then
      FFontGenerator.UnSubscribe(Self);

    FFontGenerator:= Value;
    if FFontGenerator <> nil then
      FFontGenerator.Subscribe(Self);

    Perform(CM_FONTGENERATORCHANGED, 0, 0);
  end;
end;

procedure TControlWithFont.SetParentFont(const Value: Boolean);
begin
  FParentFont := Value;
  if FParentFont and (Parent <> nil) then begin
    Font:= TCGWinControl(Parent).Font;
    Invalidate;
  end;
end;

{ TUpDownTemplate }

procedure TUpDownTemplate.ContextEvent(AContext: TCGContextBase;
  IsInitialization: Boolean);
begin
  inherited;
  if not IsInitialization then begin
    FButtonHoverUp.FreeContext(AContext);
    FButtonDown.FreeContext(AContext);
    FButtonHoverDown.FreeContext(AContext);
    FButtonUp.FreeContext(AContext);
  end;
end;

destructor TUpDownTemplate.Destroy;
begin
  FButtonHoverUp.UpdateValue(nil, Scene);
  FButtonDown.UpdateValue(nil, Scene);
  FButtonHoverDown.UpdateValue(nil, Scene);
  FButtonUp.UpdateValue(nil, Scene);
  inherited;
end;

procedure TUpDownTemplate.DoRender(AContext: TCGContextBase; const R: TRect;
  UpHover, DownHover: Boolean);
var p: TPoint;
    s: TSize;
begin
  p:= R.TopLeft;
  s.Create(ButtonWidth, R.Height div 2);
  if UpHover then begin
    FButtonHoverUp.InitializeContext;
    FButtonHoverUp.Value.DrawWithSize(p, s);
  end else begin
    FButtonUp.InitializeContext;
    FButtonUp.Value.DrawWithSize(p, s);
  end;

  p.Y:= p.Y + s.cY;
  s.cY:= R.Height - s.cY;
  if DownHover then begin
    FButtonHoverDown.InitializeContext;
    FButtonHoverDown.Value.DrawWithSize(p, s);
  end else begin
    FButtonDown.InitializeContext;
    FButtonDown.Value.DrawWithSize(p, s);
  end;
end;

procedure TUpDownTemplate.SetButtonDown(const Value: TGeneric2DObject);
begin
  FButtonDown.UpdateValue(Value, Scene);
end;

procedure TUpDownTemplate.SetButtonHoverDown(const Value: TGeneric2DObject);
begin
  FButtonHoverDown.UpdateValue(Value, Scene);
end;

procedure TUpDownTemplate.SetButtonHoverUp(const Value: TGeneric2DObject);
begin
  FButtonHoverUp.UpdateValue(Value, Scene);
end;

procedure TUpDownTemplate.SetButtonUp(const Value: TGeneric2DObject);
begin
  FButtonUp.UpdateValue(Value, Scene);
end;

procedure TUpDownTemplate.SetButtonWidth(const Value: Integer);
begin
  FButtonWidth:= Value;
end;

{ TControlWithInput }

function TControlWithInput.CanFocus: Boolean;
var Control, S: TWinControl;
begin
  Result:= False;
  S:= Scene;
  if S <> nil then begin
    Control := Self.Parent;
    while Control <> S do
    begin
      if not (Control.Visible and Control.Enabled) then Exit;
      Control := Control.Parent;
    end;
    Result:= True;
  end;
end;

procedure TControlWithInput.CMEnabledChanged(var Message: TMessage);
begin
  if not Enabled and (Scene <> nil) and (Scene.KeyControl = Self) then
    Scene.KeyControl:= nil;
  inherited;
end;

procedure TControlWithInput.CMParentStateChanged(var Message: TMessage);
begin
  if (Scene <> nil) and (Scene.KeyControl = Self) then
    if not CanFocus then
      Scene.KeyControl:= nil;
end;

procedure TControlWithInput.CMVisibleChanged(var Message: TMessage);
begin
  if not Visible and (Scene <> nil) and (Scene.KeyControl = Self) then
    Scene.KeyControl:= nil;
  inherited;
end;

function TControlWithInput.IsFocused: Boolean;
begin
  Result:= False;
  if CanFocus then
    Result:= Scene.KeyControl = Self;
end;

procedure TControlWithInput.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
end;

procedure TControlWithInput.KeyPress(var Key: Char);
begin
  inherited;
  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);
end;

procedure TControlWithInput.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Assigned(FOnKeyUp) then
    FOnKeyUp(Self, Key, Shift);
end;

procedure TControlWithInput.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not (csDesigning in ComponentState) then
    if CanFocus then
      Scene.KeyControl:= Self;
end;

procedure TControlWithInput.SetFocus;
begin
  if CanFocus then
    Scene.KeyControl:= Self;
end;

{ TCGStackPanel }

procedure TCGStackPanel.AlignControls(AControl: TControl; var Rect: TRect);
var
  AlignList: TList;

  function DoAlign(var Rect: TRect; CheckScrollBar: Boolean): Boolean;
  var
    I, k: Integer;
    Position: TPoint;
    Size: TSize;
    Control: TControl;
    minSize: Integer;
  begin
    minSize:= 0;
    Position:= Rect.TopLeft;
    for I := 0 to AlignList.Count - 1 do begin
      Control := TControl(AlignList[I]);
      if (Control.Visible or (csDesigning in ComponentState)) then begin
        // The area occupied by the control is affected by the Margins
        Size.cx := Control.Margins.ControlWidth;
        Size.cy := Control.Margins.ControlHeight;

        if UseVerticalOrientation then begin
          for k:= 0 to 1 do begin //2 iterations because only one wrap can be
            if Wrap and (Position.Y + Size.cy > Rect.Bottom) then begin
              Position.Y:= Rect.Top;
              Inc(Position.X, minSize);
              minSize:= 0;
              Continue;
            end;
            Break;
          end;

          if CheckScrollBar and (Position.X + Size.cx > Rect.Right) then
            Exit(True); //need realign with scrollbar

          Control.Margins.SetControlBounds(Position.X, Position.Y, Size.cx, Size.cy);
          Inc(Position.Y, Size.cy);
          if minSize < Size.cx then
            minSize:= Size.cx;
        end else begin
          for k:= 0 to 1 do begin //2 iterations because only one wrap can be
            if Wrap and (Position.X + Size.cx > Rect.Right) then begin
              Position.X:= Rect.Left;
              Inc(Position.Y, minSize);
              minSize:= 0;
              Continue;
            end;
            Break;
          end;

          if CheckScrollBar and (Position.X + Size.cx > Rect.Right) then
            Exit(True); //need realign with scrollbar

          Control.Margins.SetControlBounds(Position.X, Position.Y, Size.cx, Size.cy);
          Inc(Position.X, Size.cx);
          if minSize < Size.cy then
            minSize:= Size.cy;
        end;
      end;
    end;
    Result:= False;
  end;
var
  I, J: Integer;
  Control: TControl;
  Bounds: TRect;
  minSize: Integer;
begin
  AdjustClientRect(Rect);
  minSize:= 0;
  AlignList:= TList.Create;
  try
    if UseVerticalOrientation then begin
      for I := 0 to ControlCount - 1 do begin
        Control:= Controls[I];
        if minSize < Control.Height then
          minSize:= Control.Height;
        J := 0;
        while (J < AlignList.Count) and (Control.Top > TControl(AlignList[J]).Top) do
          Inc(J);
        AlignList.Insert(J, Control);
      end;

      if Rect.Height < minSize then
        Rect.Height:= minSize;
    end else begin
      for I := 0 to ControlCount - 1 do begin
        Control:= Controls[I];
        if minSize < Control.Width then
          minSize:= Control.Width;
        J := 0;
        while (J < AlignList.Count) and (Control.Left > TControl(AlignList[J]).Left) do
          Inc(J);
        AlignList.Insert(J, Control);
      end;

      if Rect.Width < minSize then
        Rect.Width:= minSize;
    end;

    Bounds:= Rect;
    if DoAlign(Bounds, Wrap and ((UseVerticalOrientation and (HorizontalScrollBar <> nil))
        or (not UseVerticalOrientation and (VerticalScrollBar <> nil)))) then begin
      Bounds:= Rect;
      if UseVerticalOrientation then
        Dec(Bounds.Bottom, HorizontalScrollBar.ButtonSize)
      else
        Dec(Bounds.Right, VerticalScrollBar.ButtonSize);
      DoAlign(Bounds, False);
    end;
  finally
    AlignList.Free;
  end;

  ControlsAligned;
  if Showing then
    AdjustSize;

  ReAlignScrollBars;
end;

constructor TCGStackPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FWrap:= True;
end;

procedure TCGStackPanel.SetUseVerticalOrientation(const Value: Boolean);
begin
  FUseVerticalOrientation := Value;
end;

procedure TCGStackPanel.SetWrap(const Value: Boolean);
begin
  FWrap := Value;
end;

end.

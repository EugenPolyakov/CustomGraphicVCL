unit GraphicToolsAPI;

interface

uses Classes, ToolsAPI, GraphicVCLBase, GraphicVCLControls, GraphicVCLCommonControls;

procedure Register;

implementation

uses DesignIntf, DesignEditors;

procedure Register;
begin
  RegisterComponents('Custom Graphic Extensions', [TCGScene, TCGImage, TCGPanel,
      TCGButton, TCGLabel, TCGFontGenerator, TCGTextureLibrary, TCGCustom,
      TCGScrollBarTemplate, TCGScrollBox, TCGBorderTemplate, TCGEdit, TCGSpinEdit,
      TUpDownTemplate, TColoredLabel, TCGStringGrid, TCGListBox]);
  RegisterCustomModule(TCGFrame, TCustomModule);

  RegisterPropertyEditor(TypeInfo(TCGFontGenerator), nil, '', TComponentProperty);
  RegisterPropertyEditor(TypeInfo(TCGScene), nil, '', TComponentProperty);
  RegisterPropertyEditor(TypeInfo(TCGScrollBarTemplate), nil, '', TComponentProperty);
  RegisterPropertyEditor(TypeInfo(TCGBorderTemplate), nil, '', TComponentProperty);
  RegisterPropertyEditor(TypeInfo(TUpDownTemplate), nil, '', TComponentProperty);
end;

end.

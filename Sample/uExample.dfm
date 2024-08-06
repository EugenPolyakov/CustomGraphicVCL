object fExample: TfExample
  Left = 0
  Top = 0
  Caption = 'fExample'
  ClientHeight = 550
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    635
    550)
  PixelsPerInch = 96
  TextHeight = 13
  object CGScene1: TCGScene
    Left = 8
    Top = 8
    Width = 619
    Height = 465
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clHighlight
    Font = CGFontGenerator1
    object CGImage1: TCGImage
      Left = 11
      Top = 0
      Width = 166
      Height = 121
      Stretch = True
    end
    object CGLabel2: TCGLabel
      Left = 96
      Top = 387
      Width = 153
      Height = 54
      Color = clRed
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'CGLabel2'
    end
    object CGScrollBox1: TCGScrollBox
      Left = 152
      Top = 176
      Width = 241
      Height = 185
      Border = CGBorderTemplateRed
      Padding.Left = 10
      Padding.Top = 10
      Padding.Right = 10
      Padding.Bottom = 10
      VerticalScrollBar = CGScrollBarTemplate1
      object CGEdit1: TCGEdit
        Left = 10
        Top = 142
        Width = 221
        Height = 41
        Hint = 'CGEdit1'
        AutoHint = CGLabel2
        Align = alTop
        Text = 'CGEdit1'
        SelectionColor = clBlack
        ExplicitLeft = -13
        ExplicitTop = 80
        ExplicitWidth = 257
      end
      object CGLabel1: TCGLabel
        Left = 10
        Top = 10
        Width = 221
        Height = 50
        Hint = 'CGLabel1'
        Padding.Top = 10
        AutoHint = CGLabel2
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'CGLabel1'
        Layout = tlCenter
        ExplicitWidth = 46
      end
      object CGSpinEdit1: TCGSpinEdit
        Left = 10
        Top = 101
        Width = 221
        Height = 41
        Hint = 'CGSpinEdit1'
        Padding.Left = 1
        Padding.Top = 1
        Padding.Right = 1
        Padding.Bottom = 1
        Border = CGBorderTemplateWhite
        AutoHint = CGLabel2
        Align = alTop
        SelectionColor = clBlack
        UpDown = UpDownTemplate1
        MaxValue = 100
        MinValue = 0
        ExplicitLeft = 16
        ExplicitTop = 40
        ExplicitWidth = 100
      end
      object CGSpinEdit2: TCGSpinEdit
        Left = 10
        Top = 60
        Width = 221
        Height = 41
        Hint = 'CGSpinEdit2'
        Padding.Left = 1
        Padding.Top = 1
        Padding.Right = 1
        Padding.Bottom = 1
        Border = CGBorderTemplateWhite
        AutoHint = CGLabel2
        Align = alTop
        SelectionColor = clBlack
        UpDown = UpDownTemplate1
        MaxValue = 100
        MinValue = 0
        ExplicitLeft = 7
        ExplicitTop = 18
      end
    end
  end
  object CGFontGenerator1: TCGFontGenerator
    Scene = CGScene1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 56
    Top = 264
  end
  object CGTextureLibrary1: TCGTextureLibrary
    Left = 520
    Top = 192
  end
  object CGScrollBarTemplate1: TCGScrollBarTemplate
    Scene = CGScene1
    ButtonSize = 10
    Left = 464
    Top = 40
  end
  object UpDownTemplate1: TUpDownTemplate
    Scene = CGScene1
    ButtonWidth = 10
    Left = 464
    Top = 280
  end
  object CGBorderTemplateWhite: TCGBorderTemplate
    Scene = CGScene1
    BorderSize = 1
    Left = 464
    Top = 336
  end
  object CGBorderTemplateRed: TCGBorderTemplate
    Scene = CGScene1
    BorderSize = 10
    Left = 464
    Top = 384
  end
end

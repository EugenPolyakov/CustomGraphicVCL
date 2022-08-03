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
      Left = 0
      Top = 451
      Width = 619
      Height = 14
      Align = alBottom
      Caption = 'CGLabel2'
      ExplicitLeft = 3
      ExplicitTop = 27
      ExplicitWidth = 100
    end
    object CGScrollBox1: TCGScrollBox
      Left = 152
      Top = 176
      Width = 241
      Height = 73
      VerticalScrollBar = CGScrollBarTemplate1
      object CGEdit1: TCGEdit
        Left = 0
        Top = 55
        Width = 241
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
        Left = 0
        Top = 0
        Width = 241
        Height = 14
        Hint = 'CGLabel1'
        AutoHint = CGLabel2
        Align = alTop
        Caption = 'CGLabel1'
        ExplicitLeft = 48
        ExplicitTop = 27
        ExplicitWidth = 46
      end
      object CGSpinEdit1: TCGSpinEdit
        Left = 0
        Top = 14
        Width = 241
        Height = 41
        Hint = 'CGSpinEdit1'
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
end

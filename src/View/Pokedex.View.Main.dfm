object PokedexView: TPokedexView
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Pok'#233'dex'
  ClientHeight = 580
  ClientWidth = 703
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlTopContainer: TPanel
    Left = 0
    Top = 0
    Width = 703
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
  end
  object pnlImage: TPanel
    Left = 0
    Top = 48
    Width = 368
    Height = 472
    Align = alLeft
    BevelOuter = bvNone
    Padding.Left = 10
    Padding.Top = 15
    Padding.Right = 10
    Padding.Bottom = 15
    ParentBackground = False
    TabOrder = 1
    object lblDisplayName: TLabel
      Left = 10
      Top = 15
      Width = 348
      Height = 37
      Align = alTop
      Alignment = taCenter
      Caption = 'Pok'#233'dex'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 110
    end
    object skImgPokemon: TSkAnimatedImage
      Left = 10
      Top = 52
      Width = 348
      Height = 405
      Align = alClient
      object btnNext: TSkSvg
        Left = 297
        Top = 144
        Width = 50
        Height = 50
        OnClick = btnNextClick
        Svg.Source = 
          '<svg viewBox="0 0 24 24"><path fill="currentColor" d="M8.59,16.5' +
          '8L13.17,12L8.59,7.41L10,6L16,12L10,18L8.59,16.58Z" /></svg>'
      end
      object btnPrev: TSkSvg
        Left = 0
        Top = 144
        Width = 50
        Height = 50
        OnClick = btnPrevClick
        Svg.Source = 
          '<svg viewBox="0 0 24 24">'#13#10'  <path fill="currentColor" d="M15.41' +
          ',16.58L10.83,12L15.41,7.41L14,6L8,12L14,18L15.41,16.58Z" />'#13#10'</s' +
          'vg>'
      end
    end
    object fpTypes: TFlowPanel
      Left = 8
      Top = 38
      Width = 3
      Height = 15
      AutoSize = True
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      object lblType: TLabel
        Left = 0
        Top = 0
        Width = 3
        Height = 15
        Align = alLeft
      end
    end
  end
  object pnlInfo: TRelativePanel
    Left = 368
    Top = 48
    Width = 335
    Height = 472
    ControlCollection = <>
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 2
  end
  object pnlDescription: TPanel
    Left = 0
    Top = 520
    Width = 703
    Height = 60
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 3
  end
end

object PokedexView: TPokedexView
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Pok'#233'dex'
  ClientHeight = 580
  ClientWidth = 368
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
    Width = 368
    Height = 41
    Align = alTop
    ParentBackground = False
    TabOrder = 0
    object cbSearchInput: TComboBox
      Left = 8
      Top = 10
      Width = 273
      Height = 23
      AutoCompleteDelay = 300
      TabOrder = 0
      TextHint = 'Digite o nome ou ID do Pok'#233'mon desejado.'
    end
    object btnSearchAction: TButton
      Left = 287
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnSearchActionClick
    end
  end
  object pnlImage: TPanel
    Left = 0
    Top = 41
    Width = 368
    Height = 468
    Align = alClient
    Padding.Left = 10
    Padding.Top = 15
    Padding.Right = 10
    Padding.Bottom = 15
    ParentBackground = False
    TabOrder = 1
    ExplicitHeight = 375
    object lblDisplayName: TLabel
      Left = 11
      Top = 16
      Width = 346
      Height = 37
      Align = alTop
      Alignment = taCenter
      Caption = 'Nome do Pok'#233'mon'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 247
    end
    object skImgPokemon: TSkAnimatedImage
      Left = 11
      Top = 53
      Width = 346
      Height = 339
      Align = alClient
      ExplicitLeft = 1
      ExplicitTop = 38
      ExplicitWidth = 366
      ExplicitHeight = 258
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
    object mmDescription: TMemo
      Left = 11
      Top = 392
      Width = 346
      Height = 60
      Align = alBottom
      Color = -1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      ExplicitTop = 398
    end
    object fpTypes: TFlowPanel
      Left = 8
      Top = 38
      Width = 3
      Height = 15
      AutoSize = True
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 2
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
    Left = 0
    Top = 509
    Width = 368
    Height = 71
    ControlCollection = <
      item
        Control = lblAbility
        AlignBottomWithPanel = False
        AlignHorizontalCenterWithPanel = False
        AlignLeftWithPanel = False
        AlignRightWithPanel = False
        AlignTopWithPanel = False
        AlignVerticalCenterWithPanel = False
      end
      item
        Control = lblWeight
        AlignBottomWithPanel = False
        AlignHorizontalCenterWithPanel = False
        AlignLeftWithPanel = False
        AlignRightWithPanel = False
        AlignTopWithPanel = False
        AlignVerticalCenterWithPanel = False
      end
      item
        Control = lblHeight
        AlignBottomWithPanel = False
        AlignHorizontalCenterWithPanel = False
        AlignLeftWithPanel = False
        AlignRightWithPanel = False
        AlignTopWithPanel = False
        AlignVerticalCenterWithPanel = False
      end>
    Align = alBottom
    ParentBackground = False
    TabOrder = 2
    ExplicitTop = 440
    DesignSize = (
      368
      71)
    object lblAbility: TLabel
      Left = 8
      Top = 48
      Width = 58
      Height = 15
      Anchors = []
      Caption = 'Habilidade'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblWeight: TLabel
      Left = 8
      Top = 6
      Width = 26
      Height = 15
      Anchors = []
      Caption = 'Peso'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblHeight: TLabel
      Left = 8
      Top = 27
      Width = 34
      Height = 15
      Anchors = []
      Caption = 'Altura'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
end

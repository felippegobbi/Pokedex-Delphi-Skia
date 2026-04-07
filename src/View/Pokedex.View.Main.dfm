object PokedexView: TPokedexView
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Pok'#233'dex'
  ClientHeight = 511
  ClientWidth = 341
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object pnlTopContainer: TPanel
    Left = 0
    Top = 0
    Width = 341
    Height = 41
    Align = alTop
    TabOrder = 0
    object edtSearchInput: TEdit
      Left = 8
      Top = 10
      Width = 241
      Height = 23
      TabOrder = 0
      TextHint = 'Digite o nome ou ID do Pok'#233'mon desejado.'
    end
    object btnSearchAction: TButton
      Left = 255
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
    Width = 341
    Height = 375
    Align = alClient
    TabOrder = 1
    object lblDisplayName: TLabel
      Left = 1
      Top = 1
      Width = 339
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
      ExplicitWidth = 247
    end
    object skImgPokemon: TSkAnimatedImage
      Left = 1
      Top = 38
      Width = 339
      Height = 202
      Align = alClient
      ExplicitHeight = 336
    end
    object mmDescription: TMemo
      Left = 1
      Top = 240
      Width = 339
      Height = 134
      Align = alBottom
      Color = clWindowFrame
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellowgreen
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      ExplicitTop = 241
    end
  end
  object pnlInfo: TRelativePanel
    Left = 0
    Top = 416
    Width = 341
    Height = 95
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
        Control = lblType
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
    TabOrder = 2
    DesignSize = (
      341
      95)
    object lblAbility: TLabel
      Left = 8
      Top = 6
      Width = 57
      Height = 15
      Anchors = []
      Caption = 'Habilidade'
    end
    object lblType: TLabel
      Left = 8
      Top = 27
      Width = 24
      Height = 15
      Anchors = []
      Caption = 'Tipo'
    end
    object lblWeight: TLabel
      Left = 8
      Top = 48
      Width = 25
      Height = 15
      Anchors = []
      Caption = 'Peso'
    end
    object lblHeight: TLabel
      Left = 8
      Top = 69
      Width = 32
      Height = 15
      Anchors = []
      Caption = 'Altura'
    end
  end
end

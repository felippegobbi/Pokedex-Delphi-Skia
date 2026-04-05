object PokedexView: TPokedexView
  Left = 0
  Top = 0
  Caption = 'Pok'#233'dex'
  ClientHeight = 511
  ClientWidth = 656
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object pnlTopContainer: TPanel
    Left = 0
    Top = 0
    Width = 656
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
    end
  end
  object pnlImage: TPanel
    Left = 0
    Top = 41
    Width = 656
    Height = 331
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitTop = 47
    ExplicitWidth = 648
    ExplicitHeight = 298
    object lblDisplayName: TLabel
      Left = 1
      Top = 315
      Width = 654
      Height = 15
      Align = alBottom
      Caption = 'Nome do Pok'#233'mon'
      ExplicitLeft = 8
      ExplicitTop = 316
      ExplicitWidth = 104
    end
    object imgPokemonDisplay: TSkAnimatedImage
      Left = 1
      Top = 1
      Width = 654
      Height = 314
      Align = alClient
      ExplicitLeft = 8
      ExplicitTop = -19
      ExplicitHeight = 329
    end
  end
  object memDebugLog: TMemo
    Left = 0
    Top = 372
    Width = 656
    Height = 139
    Align = alBottom
    TabOrder = 2
  end
end

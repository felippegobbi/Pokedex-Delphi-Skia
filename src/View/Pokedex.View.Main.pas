unit Pokedex.View.Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  REST.Types,
  REST.Client,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  System.Skia,
  Vcl.Skia,
  Vcl.WinXCtrls,
  System.UITypes;

type
  TPokedexView = class(TForm)
    pnlTopContainer: TPanel;
    edtSearchInput: TEdit;
    btnSearchAction: TButton;
    pnlImage: TPanel;
    lblDisplayName: TLabel;
    skImgPokemon: TSkAnimatedImage;
    pnlInfo: TRelativePanel;
    lblAbility: TLabel;
    lblType: TLabel;
    lblWeight: TLabel;
    lblHeight: TLabel;
    mmDescription: TMemo;
    procedure btnSearchActionClick(Sender: TObject);
  private
    procedure ApplyTheme(const AColor: TColor);
  public
    { Public declarations }
  end;

var
  PokedexView: TPokedexView;

implementation

{$R *.dfm}

uses
  Pokedex.Service.API,
  Pokedex.Controller.Pokemon,
  Pokedex.Model.Pokemon;

procedure TPokedexView.ApplyTheme(const AColor: TColor);
begin
  pnlImage.Color := AColor;
  pnlTopContainer.Color := AColor;
  pnlInfo.Color := AColor;

  if AColor = $002C2C2C then
    lblDisplayName.Font.Color := clWhite
  else
    lblDisplayName.Font.Color := clBlack;
end;

procedure TPokedexView.btnSearchActionClick(Sender: TObject);
var
  LPokemon: TPokemon;
  LStream: TMemoryStream;
  LTypeStr: string;
  I: Integer;
begin
  if Trim(edtSearchInput.Text).IsEmpty then
  begin
    MessageDlg('Por favor, informe o nome ou ID do Pokémon desejado.',
      mtWarning, [mbOK], 0);

    edtSearchInput.SetFocus;
    Exit;
  end;

  LPokemon := TPokemonController.ExecuteGetPokemon(edtSearchInput.Text);
  lblDisplayName.Caption := UpperCase(LPokemon.Name);
  try
    if not Assigned(LPokemon) then
    begin
      MessageDlg('Pokémon não encontrado. Verifique o nome ou ID.', mtError,
        [mbOK], 0);
      Exit;
    end;

    if Assigned(LPokemon.SpeciesData) then
    begin
      ApplyTheme(TPokemonController.GetColorByString
        (LPokemon.SpeciesData.Color.Name));
    end;

    lblDisplayName.Caption := UpperCase(LPokemon.Name);
    LStream := TPokemonController.DownloadImage(LPokemon.Sprites.FrontDefault);
    try
      if Assigned(LStream) then
        skImgPokemon.LoadFromStream(LStream)
      else
        MessageDlg('Dados carregados, mas não foi possível baixar a imagem.',
          mtWarning, [mbOK], 0);
    finally
      LStream.Free;
    end;

    lblWeight.Caption := 'Peso Médio: ' + TPokemonController.FormatMetric
      (LPokemon.Weight, 'kg');

    lblHeight.Caption := 'Altura Média: ' + TPokemonController.FormatMetric
      (LPokemon.Height, 'm');

    if length(LPokemon.Abilities) > 0 then
    begin
      lblAbility.Caption := 'Habilidade: ' +
        UpperCase(LPokemon.Abilities[0].Ability.Name);
    end;

    if length(LPokemon.Types) > 0 then
    begin
      LTypeStr := '';
      for I := 0 to length(LPokemon.Types) - 1 do
      begin
        if LTypeStr <> '' then
          LTypeStr := LTypeStr + ' / ';

        LTypeStr := LTypeStr + UpperCase(LPokemon.Types[I].&Type.Name);
      end;
      lblType.Caption := 'Tipo: ' + LTypeStr;
    end
    else
      lblType.Caption := 'Tipo: DESCONHECIDO';

    mmDescription.Lines.Clear;

    if Assigned(LPokemon.SpeciesData) then
      mmDescription.Text := LPokemon.SpeciesData.GetDescription
    else
      mmDescription.Text := 'Descrição não disponível para esse Pokémon.';

  finally
    LPokemon.Free;
  end;
end;

end.

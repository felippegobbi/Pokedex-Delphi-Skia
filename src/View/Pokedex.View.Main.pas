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
  System.UITypes,
  Pokedex.Model.Pokemon;

type
  TPokedexView = class(TForm)
    pnlTopContainer: TPanel;
    cbSearchInput: TComboBox;
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
    btnNext: TSkSvg;
    btnPrev: TSkSvg;
    fpTypes: TFlowPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnSearchActionClick(Sender: TObject);
  private
    FPokemonList: TStringList;
    FCurrentId: Integer;
    procedure ApplyTheme(const AColor: TColor);
    procedure PerformSearch(const AIdOrName: string);
    procedure LoadPokemonImage(APokemon: TPokemon);
    procedure UpdatePokemonStats(APokemon: TPokemon);
    procedure UpdatePokemonTypes(APokemon: TPokemon);
    procedure UpdateFlavorText(APokemon: TPokemon);
    procedure ClearTypeBadges;
    procedure CreateTypeBadge(const ATypeName: string);
    procedure PositionTypeContainer;
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
  Winapi.ShlObj,
  Winapi.ActiveX,
  System.Win.ComObj;

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

procedure TPokedexView.btnNextClick(Sender: TObject);
var
  LIdx: Integer;
begin
  LIdx := cbSearchInput.Items.IndexOf(cbSearchInput.Text);

  if (LIdx >= 0) and (LIdx < cbSearchInput.Items.Count - 1) then
    PerformSearch(cbSearchInput.Items[LIdx + 1])
  else
    MessageDlg('Você chegou ao fim da Pokédex.', mtInformation, [mbOK], 0);
end;

procedure TPokedexView.btnPrevClick(Sender: TObject);
var
  LIdx: Integer;
begin
  LIdx := cbSearchInput.Items.IndexOf(cbSearchInput.Text);

  if LIdx > 0 then
    PerformSearch(cbSearchInput.Items[LIdx - 1])
  else
    MessageDlg('Este é o primeiro Pokémon.', mtInformation, [mbOK], 0);
end;

procedure TPokedexView.btnSearchActionClick(Sender: TObject);
begin
  PerformSearch(cbSearchInput.Text);
end;

procedure TPokedexView.ClearTypeBadges;
begin
  fpTypes.Visible := True;
  fpTypes.AutoSize := False;
  while fpTypes.ControlCount > 0 do
    fpTypes.Controls[0].Free;
end;

procedure TPokedexView.CreateTypeBadge(const ATypeName: string);
var
  LContainer: TPanel;
  LBackground: TShape;
  LBadge: TSkLabel;
begin
  LContainer := TPanel.Create(Self);
  LContainer.Parent := fpTypes;
  LContainer.Width := 85;
  LContainer.Height := 22;
  LContainer.BevelOuter := bvNone;
  LContainer.ParentBackground := True;
  LContainer.ShowCaption := False;
  LContainer.Margins.Right := 6;

  LBackground := TShape.Create(Self);
  LBackground.Parent := LContainer;
  LBackground.Align := alClient;
  LBackground.Shape := stRoundRect;
  LBackground.Brush.Color := TPokemonController.GetTypeColor(ATypeName);
  LBackground.Pen.Color := clBlack;

  LBadge := TSkLabel.Create(Self);
  LBadge.Parent := LContainer;
  LBadge.Align := alClient;
  LBadge.TextSettings.HorzAlign := TSkTextHorzAlign.Center;
  LBadge.TextSettings.VertAlign := TSkTextVertAlign.Center;
  LBadge.Caption := UpperCase(ATypeName);

  if LBadge.Words.Count > 0 then
  begin
    LBadge.Words[0].Font.Size := 9;
    LBadge.Words[0].Font.Weight := TSkFontComponent.TSkFontWeight.Bold;
    LBadge.Words[0].FontColor := TAlphaColors.White;
  end;
end;

procedure TPokedexView.FormCreate(Sender: TObject);
begin
  FPokemonList := TStringList.Create;
  TPokemonController.FillAutoCompleteList(FPokemonList);

  cbSearchInput.Items.Assign(FPokemonList);
  cbSearchInput.Sorted := False;

  btnNext.Visible := False;
  btnPrev.Visible := False;
end;

procedure TPokedexView.FormDestroy(Sender: TObject);
begin
  FPokemonList.Free;
end;

procedure TPokedexView.LoadPokemonImage(APokemon: TPokemon);
var
  LStream: TMemoryStream;
begin
  LStream := TPokemonController.DownloadImage(APokemon.Sprites.FrontDefault);
  try
    if Assigned(LStream) then
      skImgPokemon.LoadFromStream(LStream)
    else
      skImgPokemon.Source.Data := nil;
  finally
    LStream.Free;
  end;
end;

procedure TPokedexView.PerformSearch(const AIdOrName: string);
var
  LPokemon: TPokemon;
begin
  if Trim(AIdOrName).IsEmpty then
  begin
    MessageDlg('Por favor, informe o nome ou ID do Pokémon desejado.',
      mtWarning, [mbOK], 0);
    cbSearchInput.SetFocus;
    Exit;
  end;

  LPokemon := TPokemonController.ExecuteGetPokemon(AIdOrName);

  try
    if not Assigned(LPokemon) then
    begin
      MessageDlg('Pokémon não encontrado.', mtError, [mbOK], 0);
      Exit;
    end;

    FCurrentId := LPokemon.Id;
    cbSearchInput.Text := LPokemon.Name;
    btnNext.Visible := True;
    btnPrev.Visible := True;

    if Assigned(LPokemon.SpeciesData) then
      ApplyTheme(TPokemonController.GetColorByString
        (LPokemon.SpeciesData.Color.Name));

    lblDisplayName.Caption := UpperCase(LPokemon.Name);

    LoadPokemonImage(LPokemon);
    UpdatePokemonStats(LPokemon);
    UpdatePokemonTypes(LPokemon);
    UpdateFlavorText(LPokemon);

  finally
    LPokemon.Free;
  end;
end;

procedure TPokedexView.PositionTypeContainer;
var
  LTotalWidth: Integer;
begin
  LTotalWidth := (fpTypes.ControlCount * (85 + 6)) - 6;
  fpTypes.Width := LTotalWidth;
  fpTypes.Height := 24;
  fpTypes.Left := (pnlImage.Width - LTotalWidth) div 2;
  fpTypes.Top := lblDisplayName.Top + lblDisplayName.Height + 5;
  fpTypes.BringToFront;
end;

procedure TPokedexView.UpdateFlavorText(APokemon: TPokemon);
begin
  mmDescription.Lines.Clear;

  if Assigned(APokemon.SpeciesData) then
    mmDescription.Text := APokemon.SpeciesData.GetDescription
  else
    mmDescription.Text := 'Descrição não disponível para esse Pokémon.';
end;

procedure TPokedexView.UpdatePokemonStats(APokemon: TPokemon);
begin
  lblWeight.Caption := 'Peso Médio: ' + TPokemonController.FormatMetric
    (APokemon.Weight, 'kg');
  lblHeight.Caption := 'Altura Média: ' + TPokemonController.FormatMetric
    (APokemon.Height, 'm');

  if length(APokemon.Abilities) > 0 then
    lblAbility.Caption := 'Habilidade: ' +
      UpperCase(APokemon.Abilities[0].Ability.Name);
end;

procedure TPokedexView.UpdatePokemonTypes(APokemon: TPokemon);
var
  I: Integer;
begin
  ClearTypeBadges;

  if length(APokemon.Types) > 0 then
  begin
    for I := 0 to length(APokemon.Types) - 1 do
      CreateTypeBadge(APokemon.Types[I].&Type.Name);

    PositionTypeContainer;
  end;
end;

end.

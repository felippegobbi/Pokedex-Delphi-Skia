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
  Pokedex.Controller.Pokemon,
  Pokedex.Model.Pokemon,
  Pokedex.View.StatsPanel,
  System.Types;

type
  TPokedexView = class(TForm)
    pnlTopContainer: TPanel;
    pnlImage: TPanel;
    lblDisplayName: TLabel;
    skImgPokemon: TSkAnimatedImage;
    pnlInfo: TRelativePanel;
    pnlDescription: TPanel;
    lblType: TLabel;
    btnNext: TSkSvg;
    btnPrev: TSkSvg;
    fpTypes: TFlowPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
  private
    FCurrentId: Integer;
    FController: TPokemonController;
    FStatsPanel: TStatsPanel;
    FDescLabel: TSkLabel;
    FSearchBg: TSkPaintBox;
    FSearchEdit: TEdit;
    FSearchIcon: TSkSvg;
    procedure ApplyTheme(const AColor: TColor);
    procedure PerformSearch(const AIdOrName: string);
    procedure LoadPokemonImage(APokemon: TPokemon);
    procedure UpdatePokemonStats(APokemon: TPokemon);
    procedure UpdatePokemonTypes(APokemon: TPokemon);
    procedure UpdateFlavorText(APokemon: TPokemon);
    procedure ClearTypeBadges;
    procedure CreateTypeBadge(const ATypeName: string);
    procedure PositionTypeContainer;
    procedure WMAfterCreate(var Msg: TMessage); message WM_USER + 1;
    procedure SearchEditKeyPress(Sender: TObject; var Key: Char);
    procedure SearchIconClick(Sender: TObject);
    procedure DrawSearchBg(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);

  const
    MSG_NOT_FOUND = 'Pok'#233'mon n'#227'o encontrado.';
    MSG_EMPTY_SEARCH =
      'Por favor, informe o nome ou ID do Pok'#233'mon desejado.';
    MSG_NOT_AVAILABLE_DESCRIPTION =
      'Descri'#231#227'o n'#227'o dispon'#237'vel para esse Pok'#233'mon.';
    DESC_H = 60;
  public
    { Public declarations }
  end;

var
  PokedexView: TPokedexView;

implementation

{$R *.dfm}

uses
  Pokedex.Service.API,
  Winapi.ShellAPI,
  System.IOUtils,
  Winapi.ShlObj,
  Winapi.ActiveX,
  System.Win.ComObj;

procedure TPokedexView.FormCreate(Sender: TObject);
const
  SEARCH_W = 300;
  SEARCH_H = 34;
  SEARCH_T = 7;
begin
  FController := TPokemonController.Create(dmPokeService);

  btnNext.Visible := False;
  btnPrev.Visible := False;

  // Topbar
  pnlTopContainer.Height := SEARCH_H + (SEARCH_T * 2);
  pnlTopContainer.BringToFront;

  // Painéis cobrem altura total menos o rodapé
  pnlImage.Align := alNone;
  pnlImage.SetBounds(0, 0, 368, ClientHeight - DESC_H);
  pnlImage.Anchors := [akLeft, akTop, akBottom];

  pnlInfo.Align := alNone;
  pnlInfo.SetBounds(368, 0, ClientWidth - 368, ClientHeight - DESC_H);
  pnlInfo.Anchors := [akLeft, akTop, akRight, akBottom];

  lblDisplayName.Align := alNone;
  lblDisplayName.AutoSize := False;
  lblDisplayName.Alignment := taCenter;
  lblDisplayName.SetBounds(0, pnlTopContainer.Height + 8, pnlImage.Width, 37);
  skImgPokemon.Align := alNone;
  skImgPokemon.SetBounds(0, lblDisplayName.Top + lblDisplayName.Height + 30,
    // abaixo do nome + badges
    pnlImage.Width, pnlImage.Height - (lblDisplayName.Top +
    lblDisplayName.Height + 30));
  skImgPokemon.Anchors := [akLeft, akTop, akRight, akBottom];

  // Barra de busca
  FSearchBg := TSkPaintBox.Create(Self);
  FSearchBg.Parent := pnlTopContainer;
  FSearchBg.SetBounds(8, SEARCH_T, SEARCH_W, SEARCH_H);
  FSearchBg.OnDraw := DrawSearchBg;

  FSearchEdit := TEdit.Create(Self);
  FSearchEdit.Parent := pnlTopContainer;
  FSearchEdit.SetBounds(20, SEARCH_T + 5, SEARCH_W - 50, SEARCH_H - 10);
  FSearchEdit.BorderStyle := bsNone;
  FSearchEdit.Font.Color := clBlack;
  FSearchEdit.Font.Name := 'Segoe UI';
  FSearchEdit.Font.Size := 11;
  FSearchEdit.StyleElements := [seClient];
  FSearchEdit.TextHint := 'Nome ou ID...';
  FSearchEdit.OnKeyPress := SearchEditKeyPress;

  FSearchIcon := TSkSvg.Create(Self);
  FSearchIcon.Parent := pnlTopContainer;
  FSearchIcon.SetBounds(8 + SEARCH_W - 30, SEARCH_T + 7, 20, 20);
  FSearchIcon.Svg.Source :=
    '<svg viewBox="0 0 24 24"><path fill="rgba(0,0,0,0.5)" d="M15.5 14h-.79' +
    'l-.28-.27A6.47 6.47 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59' +
    ' 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5' +
    ' 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>';
  FSearchIcon.OnClick := SearchIconClick;

  // Painel de stats — margem superior simétrica ao rodapé
  FStatsPanel := TStatsPanel.Create(Self);
  FStatsPanel.Parent := pnlInfo;
  FStatsPanel.SetBounds(0, DESC_H, pnlInfo.Width, pnlInfo.Height - DESC_H);
  FStatsPanel.Anchors := [akLeft, akTop, akRight, akBottom];

  // Painel de descrição
  pnlDescription.Color := $00222222;
  pnlDescription.ParentBackground := False;

  FDescLabel := TSkLabel.Create(Self);
  FDescLabel.Parent := pnlDescription;
  FDescLabel.Align := alClient;
  FDescLabel.Margins.Left := 16;
  FDescLabel.Margins.Right := 16;
  FDescLabel.Margins.Top := 8;
  FDescLabel.Margins.Bottom := 8;

  PostMessage(Handle, WM_USER + 1, 0, 0);
end;

procedure TPokedexView.DrawSearchBg(ASender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LPaint: ISkPaint;
begin
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := $55000000;
  ACanvas.DrawRoundRect(ADest, ADest.Height / 2, ADest.Height / 2, LPaint);
end;

procedure TPokedexView.WMAfterCreate(var Msg: TMessage);
begin
  PerformSearch('bulbasaur');
end;

procedure TPokedexView.FormDestroy(Sender: TObject);
begin
  FController.Free;
end;

procedure TPokedexView.ApplyTheme(const AColor: TColor);
begin
  pnlImage.Color := AColor;
  pnlTopContainer.Color := AColor;
  pnlInfo.Color := AColor;
  pnlDescription.Color := $00222222;

  FSearchEdit.Color := AColor;
  FSearchBg.Redraw;

  if AColor = TPokemonController.BLACK_COLOR then
    lblDisplayName.Font.Color := clWhite
  else
    lblDisplayName.Font.Color := clBlack;

  FStatsPanel.BarColor := $FF000000 or (DWORD(GetRValue(AColor)) shl 16) or
    (DWORD(GetGValue(AColor)) shl 8) or DWORD(GetBValue(AColor));

  FStatsPanel.Redraw;
end;

procedure TPokedexView.SearchEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    PerformSearch(FSearchEdit.Text);
    Key := #0;
  end;
end;

procedure TPokedexView.SearchIconClick(Sender: TObject);
begin
  PerformSearch(FSearchEdit.Text);
end;

procedure TPokedexView.btnNextClick(Sender: TObject);
begin
  PerformSearch(IntToStr(FCurrentId + 1));
end;

procedure TPokedexView.btnPrevClick(Sender: TObject);
begin
  if FCurrentId > 1 then
    PerformSearch(IntToStr(FCurrentId - 1));
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

procedure TPokedexView.LoadPokemonImage(APokemon: TPokemon);
var
  LStream: TMemoryStream;
begin
  LStream := FController.DownloadFile(APokemon.SpriteUrl);
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
    MessageDlg(MSG_EMPTY_SEARCH, mtWarning, [mbOK], 0);
    FSearchEdit.SetFocus;
    Exit;
  end;

  LPokemon := FController.ExecuteGetPokemon(AIdOrName);

  try
    if not Assigned(LPokemon) then
    begin
      MessageDlg(MSG_NOT_FOUND, mtError, [mbOK], 0);
      Exit;
    end;

    FCurrentId := LPokemon.Id;
    FSearchEdit.Text := LPokemon.Name;
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
var
  LText: string;
begin
  if Assigned(APokemon.SpeciesData) then
    LText := APokemon.SpeciesData.GetDescription
  else
    LText := MSG_NOT_AVAILABLE_DESCRIPTION;

  FDescLabel.Caption := LText;
  FDescLabel.TextSettings.HorzAlign := TSkTextHorzAlign.Center;
  FDescLabel.TextSettings.VertAlign := TSkTextVertAlign.Center;

  if FDescLabel.Words.Count > 0 then
  begin
    FDescLabel.Words[0].Font.Size := 13;
    FDescLabel.Words[0].FontColor := TAlphaColors.White;
    FDescLabel.Words[0].Font.Slant := TSkFontComponent.TSkFontSlant.Italic;
  end;
end;

procedure TPokedexView.UpdatePokemonStats(APokemon: TPokemon);
var
  LStats: TArray<TPokemonStat>;
  LAbility: string;
  I: Integer;
begin
  if Length(APokemon.Abilities) > 0 then
    LAbility := UpperCase(APokemon.Abilities[0].Ability.Name)
  else
    LAbility := '';

  FStatsPanel.LoadInfo(TPokemonController.FormatMetric(APokemon.Weight, 'kg'),
    TPokemonController.FormatMetric(APokemon.Height, 'm'), LAbility);

  SetLength(LStats, Length(APokemon.Stats));
  for I := 0 to High(APokemon.Stats) do
  begin
    LStats[I].Name := APokemon.Stats[I].Stat.Name;
    LStats[I].Value := APokemon.Stats[I].BaseStat;
  end;

  FStatsPanel.LoadStats(LStats);
end;

procedure TPokedexView.UpdatePokemonTypes(APokemon: TPokemon);
var
  I: Integer;
begin
  ClearTypeBadges;

  if Length(APokemon.Types) > 0 then
  begin
    for I := 0 to Length(APokemon.Types) - 1 do
      CreateTypeBadge(APokemon.Types[I].&Type.Name);

    PositionTypeContainer;
  end;
end;

end.

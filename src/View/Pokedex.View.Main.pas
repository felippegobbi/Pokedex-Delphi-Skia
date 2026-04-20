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
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  System.Skia,
  Vcl.Skia,
  Vcl.WinXCtrls,
  System.UITypes,
  Pokedex.Service.Interfaces,
  Pokedex.Controller.Pokemon,
  Pokedex.Model.Pokemon,
  Pokedex.View.StatsPanel,
  Pokedex.View.EvolutionPanel,
  System.Types,
  Pokedex.Audio.Bass;

type
  TPokedexView = class(TForm)
    pnlTopContainer: TPanel;
    pnlImage: TPanel;
    skImgPokemon: TSkAnimatedImage;
    pnlInfo: TRelativePanel;
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
    FSearchContainer: TPanel;
    FSearchBg: TSkPaintBox;
    FSearchEdit: TEdit;
    FSearchIcon: TSkSvg;
    FFontName: string;
    FCryIcon: TSkSvg;
    FCurrentChannel: LongWord;
    FCurrentStream: TMemoryStream;
    FCryGeneration: Integer;
    FEvolutionPanel: TEvolutionPanel;
    FDisplayNameLabel: TSkLabel;
    FThemeTextColor: TAlphaColor;
    FIsShiny: Boolean;
    FCurrentSpriteUrl: string;
    FCurrentShinySpriteUrl: string;
    FShinyIcon: TSkSvg;
    procedure PlayCry;
    procedure CryIconClick(Sender: TObject);
    procedure ApplyTheme(const AColor: TColor);
    procedure PerformSearch(const AIdOrName: string);
    procedure UpdatePokemonStats(APokemon: TPokemon);
    procedure UpdatePokemonTypes(APokemon: TPokemon);
    procedure UpdateFlavorText(APokemon: TPokemon);
    procedure ClearTypeBadges;
    procedure CreateTypeBadge(const ATypeName: string);
    procedure PositionTypeContainer;
    procedure SetupLayout;
    procedure SetupSearchBar;
    procedure SetupStatsPanel;
    procedure SetupDescriptionPanel;
    procedure SetupEvolutionPanel;
    procedure ShinyIconClick(Sender: TObject);
    procedure UpdateShinyIcon;
    procedure ReloadSprite;
    function GetShinyIconSvg(const AActive: Boolean): string;
    procedure CenterSearchBar;
    procedure WMAfterCreate(var Msg: TMessage); message WM_USER + 1;
    procedure FormResize(Sender: TObject);
    procedure SearchIconClick(Sender: TObject);
    procedure SearchEditKeyPress(Sender: TObject; var Key: Char);
    procedure DrawSearchBg(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure ImgPokemonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  const
    FONT_FAMILY = 'Montserrat';
    FONT_FALLBACK = 'Segoe UI';
    MSG_NOT_FOUND = 'Pok'#233'mon n'#227'o encontrado.';
    MSG_EMPTY_SEARCH =
      'Por favor, informe o nome ou ID do Pok'#233'mon desejado.';
    MSG_NOT_AVAILABLE_DESCRIPTION =
      'Descri'#231#227'o n'#227'o dispon'#237'vel para esse Pok'#233'mon.';
    MSG_NETWORK_ERROR =
      'Erro de conex'#227'o. Verifique sua internet e tente novamente.';
    DARK_PANEL_ALPHA: TAlphaColor = $FF2A2A2A;
    DARK_PANEL_VCL: TColor = $002A2A2A;
    DESC_H = 60;
    FLAVOR_H = 80;
    EVOLUTION_H = 230;
    SEARCH_H = 34;
    SEARCH_T = 7;
    SEARCH_W = 340;
    ICON_SIZE = 20;
    ICON_PAD = 8;
  public
    procedure Initialize(const AService: IPokemonService);
  end;

var
  PokedexView: TPokedexView;

implementation

{$R *.dfm}

uses
  Winapi.ShellAPI,
  Winapi.ShlObj,
  Winapi.ActiveX,
  System.Win.ComObj;

procedure TPokedexView.FormCreate(Sender: TObject);
begin
  if Screen.Fonts.IndexOf(FONT_FAMILY) >= 0 then
    FFontName := FONT_FAMILY
  else
    FFontName := FONT_FALLBACK;

  FThemeTextColor := TAlphaColors.Black;
  OnResize := FormResize;
  SetupLayout;
  SetupSearchBar;
  SetupStatsPanel;
  SetupDescriptionPanel;
  SetupEvolutionPanel;
  BASS_Init(-1, 44100, 0, Handle, nil);
end;

procedure TPokedexView.SetupLayout;
begin
  pnlTopContainer.Height := SEARCH_H + (SEARCH_T * 2);
  pnlTopContainer.BringToFront;

  pnlImage.Align := alNone;
  pnlImage.SetBounds(0, 0, 368, ClientHeight - EVOLUTION_H);
  pnlImage.Anchors := [akLeft, akTop, akBottom];

  pnlInfo.Align := alNone;
  pnlInfo.SetBounds(368, 0, ClientWidth - 368, ClientHeight - EVOLUTION_H);
  pnlInfo.Anchors := [akLeft, akTop, akRight, akBottom];

  FDisplayNameLabel := TSkLabel.Create(Self);
  FDisplayNameLabel.Parent := pnlImage;
  FDisplayNameLabel.Align := alNone;
  FDisplayNameLabel.AutoSize := False;
  FDisplayNameLabel.SetBounds(0, pnlTopContainer.Height + 8,
    pnlImage.Width, 37);
  FDisplayNameLabel.Anchors := [akLeft, akTop, akRight];
  FDisplayNameLabel.TextSettings.HorzAlign := TSkTextHorzAlign.Center;
  FDisplayNameLabel.TextSettings.VertAlign := TSkTextVertAlign.Center;

  skImgPokemon.Align := alNone;
  skImgPokemon.SetBounds(0, 95, pnlImage.Width, pnlImage.Height - 100);
  skImgPokemon.Anchors := [akLeft, akTop, akRight, akBottom];

  btnNext.Visible := False;
  btnPrev.Visible := False;

  skImgPokemon.Cursor := crHandPoint;
  skImgPokemon.OnMouseDown := ImgPokemonMouseDown;

  FShinyIcon := TSkSvg.Create(Self);
  FShinyIcon.Parent := pnlImage;
  FShinyIcon.SetBounds(pnlImage.Width - ICON_SIZE - ICON_PAD,
    pnlImage.Height - ICON_SIZE - ICON_PAD, ICON_SIZE, ICON_SIZE);
  FShinyIcon.Anchors := [akRight, akBottom];
  FShinyIcon.Svg.Source := GetShinyIconSvg(False);
  FShinyIcon.Cursor := crHandPoint;
  FShinyIcon.OnClick := ShinyIconClick;
  FShinyIcon.Visible := False;
end;

procedure TPokedexView.SetupSearchBar;
var
  LEditLeft, LEditWidth: Integer;
begin
  FSearchContainer := TPanel.Create(Self);
  FSearchContainer.Parent := pnlTopContainer;
  FSearchContainer.Width := SEARCH_W;
  FSearchContainer.Height := SEARCH_H;
  FSearchContainer.Top := SEARCH_T;
  FSearchContainer.BevelOuter := bvNone;
  FSearchContainer.ParentBackground := True;
  CenterSearchBar;

  FSearchBg := TSkPaintBox.Create(Self);
  FSearchBg.Parent := FSearchContainer;
  FSearchBg.Align := alClient;
  FSearchBg.OnDraw := DrawSearchBg;

  LEditLeft := SEARCH_H div 2;
  LEditWidth := SEARCH_W - LEditLeft - (ICON_SIZE * 2) - (ICON_PAD * 3);

  FSearchEdit := TEdit.Create(Self);
  FSearchEdit.Parent := FSearchContainer;
  FSearchEdit.BorderStyle := bsNone;
  FSearchEdit.Color := DARK_PANEL_VCL;
  FSearchEdit.Font.Color := clWhite;
  FSearchEdit.Font.Name := FFontName;
  FSearchEdit.Font.Size := 12;
  FSearchEdit.Font.Style := [fsBold];
  FSearchEdit.TextHint := 'Nome ou ID do Pok'#233'mon...';
  FSearchEdit.Alignment := taCenter;
  FSearchEdit.Height := 22;
  FSearchEdit.SetBounds(LEditLeft, (SEARCH_H - FSearchEdit.Height) div 2,
    LEditWidth, FSearchEdit.Height);

  FSearchEdit.Anchors := [akLeft, akTop, akRight];
  FSearchEdit.OnKeyPress := SearchEditKeyPress;
  FSearchEdit.BringToFront;

  FSearchIcon := TSkSvg.Create(Self);
  FSearchIcon.Parent := FSearchContainer;
  FSearchIcon.SetBounds(SEARCH_W - (ICON_SIZE * 2) - (ICON_PAD * 3),
    (SEARCH_H - ICON_SIZE) div 2, ICON_SIZE, ICON_SIZE);
  FSearchIcon.Anchors := [akTop, akRight];
  FSearchIcon.Svg.Source :=
    '<svg viewBox="0 0 24 24"><path fill="white" d="M15.5 14h-.79' +
    'l-.28-.27A6.47 6.47 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59' +
    ' 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5' +
    ' 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>';
  FSearchIcon.Cursor := crHandPoint;
  FSearchIcon.OnClick := SearchIconClick;
  FSearchIcon.BringToFront;

  FCryIcon := TSkSvg.Create(Self);
  FCryIcon.Parent := FSearchContainer;
  FCryIcon.SetBounds(SEARCH_W - ICON_SIZE - ICON_PAD, (SEARCH_H - ICON_SIZE)
    div 2, ICON_SIZE, ICON_SIZE);
  FCryIcon.Svg.Source :=
    '<svg viewBox="0 0 24 24"><path fill="white" d="M3 9v6h4l5 5V4L7 9H3z' +
    'M16.5 12A4.5 4.5 0 0 0 14 7.97v8.05c1.48-.73 2.5-2.25 2.5-4.02z"/></svg>';
  FCryIcon.Cursor := crHandPoint;
  FCryIcon.OnClick := CryIconClick;
  FCryIcon.BringToFront;
end;

procedure TPokedexView.SetupStatsPanel;
begin
  FStatsPanel := TStatsPanel.Create(Self);
  FStatsPanel.Parent := pnlInfo;

  FStatsPanel.SetBounds(0, DESC_H, pnlInfo.Width, pnlInfo.Height - DESC_H);
  FStatsPanel.Anchors := [akLeft, akTop, akRight, akBottom];
  FStatsPanel.FontFamily := FONT_FAMILY;
end;

procedure TPokedexView.DrawSearchBg(ASender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LPaint: ISkPaint;
begin
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := DARK_PANEL_ALPHA;
  ACanvas.DrawRoundRect(ADest, ADest.Height / 2, ADest.Height / 2, LPaint);
end;

procedure TPokedexView.SearchEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    PerformSearch(FSearchEdit.Text);
  end;
end;

procedure TPokedexView.CenterSearchBar;
begin
  if Assigned(FSearchContainer) then
  begin
    FSearchContainer.Left :=
      (pnlTopContainer.Width - FSearchContainer.Width) div 2;
  end;
end;

procedure TPokedexView.FormResize(Sender: TObject);
begin
  CenterSearchBar;

  if Assigned(FDescLabel) and Assigned(pnlInfo) then
  begin
    FDescLabel.SetBounds(24, pnlInfo.Height - FLAVOR_H - 16, pnlInfo.Width - 48,
      FLAVOR_H);
    FDescLabel.BringToFront;
  end;
end;

procedure TPokedexView.ImgPokemonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    PlayCry;
end;

procedure TPokedexView.PlayCry;
var
  LCryId: Integer;
  LGen: Integer;
begin
  if FCurrentId = 0 then
    Exit;

  if FCurrentChannel <> 0 then
  begin
    BASS_ChannelStop(FCurrentChannel);
    BASS_StreamFree(FCurrentChannel);
    FCurrentChannel := 0;
  end;
  FreeAndNil(FCurrentStream);

  Inc(FCryGeneration);
  LGen   := FCryGeneration;
  LCryId := FCurrentId;

  TThread.CreateAnonymousThread(
    procedure
    var
      LStream: TMemoryStream;
    begin
      LStream := FController.DownloadFile(TPokemonController.GetCryUrl(LCryId));
      TThread.Synchronize(nil, TThreadProcedure(
        procedure
        begin
          if LGen <> FCryGeneration then
          begin
            LStream.Free;
            Exit;
          end;

          if not Assigned(LStream) then
            Exit;

          FCurrentStream := LStream;
          FCurrentChannel := BASS_StreamCreateFile(True, FCurrentStream.Memory,
            0, FCurrentStream.Size, 0);

          if FCurrentChannel <> 0 then
            BASS_ChannelPlay(FCurrentChannel, False);
        end));
    end).Start;
end;

procedure TPokedexView.SetupDescriptionPanel;
begin
  FDescLabel := TSkLabel.Create(Self);
  FDescLabel.Parent := pnlInfo;

  FDescLabel.AutoSize := False; // Skia só quebra linha com largura fixa
  FDescLabel.Align := alNone;

  FDescLabel.SetBounds(24, pnlInfo.Height - FLAVOR_H - 16, pnlInfo.Width - 48,
    FLAVOR_H);
  FDescLabel.Anchors := [akLeft, akRight, akBottom];

  FDescLabel.BringToFront;
end;

procedure TPokedexView.SetupEvolutionPanel;
begin
  FEvolutionPanel := TEvolutionPanel.Create(Self);
  FEvolutionPanel.Parent := Self;
  FEvolutionPanel.SetBounds(0, ClientHeight - EVOLUTION_H, ClientWidth,
    EVOLUTION_H);
  FEvolutionPanel.Anchors := [akLeft, akRight, akBottom];
  FEvolutionPanel.FontFamily := FONT_FAMILY;
  FEvolutionPanel.OnNodeClick := procedure(AId: Integer)
    begin
      PerformSearch(AId.ToString);
    end;
end;

procedure TPokedexView.Initialize(const AService: IPokemonService);
begin
  FController := TPokemonController.Create(AService);
  PostMessage(Handle, WM_USER + 1, 0, 0);
end;

procedure TPokedexView.WMAfterCreate(var Msg: TMessage);
begin
  PerformSearch('bulbasaur');
end;

procedure TPokedexView.FormDestroy(Sender: TObject);
begin
  if FCurrentChannel <> 0 then
  begin
    BASS_ChannelStop(FCurrentChannel);
    BASS_StreamFree(FCurrentChannel);
  end;
  FreeAndNil(FCurrentStream);
  FController.Free;
  BASS_Free;
end;

procedure TPokedexView.ApplyTheme(const AColor: TColor);
var
  LEffectiveColor: TColor;
  LLum: Integer;
  LAlphaColor: TAlphaColor;
begin
  LLum := (GetRValue(AColor) * 299 + GetGValue(AColor) * 587 + GetBValue(AColor)
    * 114) div 1000;

  if LLum > 200 then
  begin
    LEffectiveColor := $00F0F0F0;
    FThemeTextColor := TAlphaColors.Black;
  end
  else if AColor = TPokemonController.BLACK_COLOR then
  begin
    LEffectiveColor := AColor;
    FThemeTextColor := TAlphaColors.White;
  end
  else
  begin
    LEffectiveColor := AColor;
    FThemeTextColor := TAlphaColors.Black;
  end;

  pnlImage.Color := LEffectiveColor;
  pnlTopContainer.Color := LEffectiveColor;
  pnlInfo.Color := LEffectiveColor;

  FSearchBg.Redraw;

  if FDisplayNameLabel.Words.Count > 0 then
    FDisplayNameLabel.Words[0].FontColor := FThemeTextColor;

  LAlphaColor := $FF000000 or (DWORD(GetRValue(LEffectiveColor)) shl 16) or
    (DWORD(GetGValue(LEffectiveColor)) shl 8) or
    DWORD(GetBValue(LEffectiveColor));

  FStatsPanel.BarColor := LAlphaColor;
  FEvolutionPanel.ThemeColor := LAlphaColor;

  FStatsPanel.Redraw;
  FEvolutionPanel.Redraw;
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
    LBadge.Words[0].Font.Families := FONT_FAMILY;
  end;
end;

procedure TPokedexView.CryIconClick(Sender: TObject);
begin
  PlayCry;
end;

function TPokedexView.GetShinyIconSvg(const AActive: Boolean): string;
const
  PATH = 'M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 ' +
         '9.24l5.46 4.73L5.82 21z';
begin
  if AActive then
    Result := '<svg viewBox="0 0 24 24"><path fill="#FFD700" d="' + PATH + '"/></svg>'
  else
    Result := '<svg viewBox="0 0 24 24"><path fill="white" opacity="0.45" d="' +
              PATH + '"/></svg>';
end;

procedure TPokedexView.UpdateShinyIcon;
begin
  FShinyIcon.Svg.Source := GetShinyIconSvg(FIsShiny);
end;

procedure TPokedexView.ShinyIconClick(Sender: TObject);
begin
  FIsShiny := not FIsShiny;
  UpdateShinyIcon;
  ReloadSprite;
end;

procedure TPokedexView.ReloadSprite;
var
  LUrl: string;
begin
  if FCurrentId = 0 then
    Exit;

  if FIsShiny and not FCurrentShinySpriteUrl.IsEmpty then
    LUrl := FCurrentShinySpriteUrl
  else
    LUrl := FCurrentSpriteUrl;

  if LUrl.IsEmpty then
    Exit;

  TThread.CreateAnonymousThread(
    procedure
    var
      LStream: TMemoryStream;
    begin
      LStream := FController.DownloadFile(LUrl);
      TThread.Synchronize(nil, TThreadProcedure(
        procedure
        begin
          if not Assigned(LStream) then
            Exit;
          try
            skImgPokemon.LoadFromStream(LStream);
          finally
            LStream.Free;
          end;
        end));
    end).Start;
end;

procedure TPokedexView.PerformSearch(const AIdOrName: string);
begin
  if Trim(AIdOrName).IsEmpty then
  begin
    MessageDlg(MSG_EMPTY_SEARCH, mtWarning, [mbOK], 0);
    FSearchEdit.SetFocus;
    Exit;
  end;

  FSearchEdit.Enabled := False;
  btnNext.Visible := False;
  btnPrev.Visible := False;

  TThread.CreateAnonymousThread(
    procedure
    var
      LPokemon: TPokemon;
      LStream: TMemoryStream;
      LChain: TArray<TEvolutionNode>;
      LErrorMsg: string;
      LSpriteUrl: string;
    begin
      LPokemon := nil;
      LStream := nil;
      LErrorMsg := '';
      SetLength(LChain, 0);
      try
        LPokemon := FController.ExecuteGetPokemon(AIdOrName);
        if FIsShiny and not LPokemon.ShinySpriteUrl.IsEmpty then
          LSpriteUrl := LPokemon.ShinySpriteUrl
        else
          LSpriteUrl := LPokemon.SpriteUrl;
        LStream := FController.DownloadFile(LSpriteUrl);
        if Assigned(LPokemon.SpeciesData) and
          Assigned(LPokemon.SpeciesData.EvolutionChain) and
          not LPokemon.SpeciesData.EvolutionChain.Url.IsEmpty then
          LChain := FController.GetEvolutionChain
            (LPokemon.SpeciesData.EvolutionChain.Url);
      except
        on E: EPokemonNotFound do
          LErrorMsg := MSG_NOT_FOUND;
        on E: EPokemonNetworkError do
          LErrorMsg := MSG_NETWORK_ERROR;
        on E: Exception do
          LErrorMsg := MSG_NOT_FOUND;
      end;
      if not LErrorMsg.IsEmpty then
      begin
        FreeAndNil(LPokemon);
        FreeAndNil(LStream);
        SetLength(LChain, 0);
      end;

      TThread.Synchronize(nil, TThreadProcedure(
        procedure
        begin
          FSearchEdit.Enabled := True;
          try
            if not Assigned(LPokemon) then
            begin
              if LErrorMsg.IsEmpty then
                LErrorMsg := MSG_NOT_FOUND;
              MessageDlg(LErrorMsg, mtError, [mbOK], 0);
              Exit;
            end;

            FCurrentId := LPokemon.Id;
            FCurrentSpriteUrl := LPokemon.SpriteUrl;
            FCurrentShinySpriteUrl := LPokemon.ShinySpriteUrl;
            FSearchEdit.Text := LPokemon.Name;
            btnNext.Visible := True;
            btnPrev.Visible := True;
            FShinyIcon.Visible := True;
            UpdateShinyIcon;

            if Assigned(LPokemon.SpeciesData) then
              ApplyTheme(TPokemonController.GetColorByString
                (LPokemon.SpeciesData.Color.Name));

            FDisplayNameLabel.Caption := UpperCase(LPokemon.Name);
            if FDisplayNameLabel.Words.Count > 0 then
            begin
              FDisplayNameLabel.Words[0].Font.Families := FFontName;
              FDisplayNameLabel.Words[0].Font.Size := 22;
              FDisplayNameLabel.Words[0].Font.Weight :=
                TSkFontComponent.TSkFontWeight.Bold;
              FDisplayNameLabel.Words[0].FontColor := FThemeTextColor;
            end;

            try
              if Assigned(LStream) then
                skImgPokemon.LoadFromStream(LStream)
              else
                skImgPokemon.Source.Data := nil;
            finally
              FreeAndNil(LStream);
            end;

            UpdatePokemonStats(LPokemon);
            UpdatePokemonTypes(LPokemon);
            UpdateFlavorText(LPokemon);
            FEvolutionPanel.LoadChain(
              TPokemonController.FilterEvolutionChain(LChain, FCurrentId));
          finally
            FreeAndNil(LPokemon);
          end;
        end));
    end).Start;
end;

procedure TPokedexView.PositionTypeContainer;
var
  LTotalWidth: Integer;
begin
  LTotalWidth := (fpTypes.ControlCount * (85 + 6)) - 6;
  fpTypes.Width := LTotalWidth;
  fpTypes.Height := 24;
  fpTypes.Left := (pnlImage.Width - LTotalWidth) div 2;
  fpTypes.Top := FDisplayNameLabel.Top + FDisplayNameLabel.Height + 5;
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

  FDescLabel.TextSettings.Font.Size := 13;
  FDescLabel.TextSettings.FontColor := TAlphaColors.Whitesmoke;
  FDescLabel.TextSettings.Font.Slant := TSkFontComponent.TSkFontSlant.Italic;
  FDescLabel.TextSettings.Font.Families := FONT_FAMILY;

  FDescLabel.TextSettings.HorzAlign := TSkTextHorzAlign.Center;
  FDescLabel.TextSettings.VertAlign := TSkTextVertAlign.Center;

  FDescLabel.Caption := LText;
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

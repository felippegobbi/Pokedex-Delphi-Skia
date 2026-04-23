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
  System.Math,
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
    FSearchContainer: TPanel;
    FSearchBg: TSkPaintBox;
    FSearchEdit: TEdit;
    FSearchIcon: TSkSvg;
    FFontName: string;
    FCryIcon: TSkSvg;
    FRandomIcon: TSkSvg;
    FCurrentChannel: LongWord;
    FCurrentStream: TMemoryStream;
    FCryGeneration: Integer;
    FEvolutionPanel: TEvolutionPanel;
    FDisplayNameLabel: TSkLabel;
    FThemeTextColor: TAlphaColor;
    FIsShiny: Boolean;
    FCurrentSpriteUrl: string;
    FCurrentShinySpriteUrl: string;
    FSpeciesColor: TColor;
    FShinyBtn: TSkPaintBox;
    FIdLabel: TSkLabel;
    FSpritePaintBox: TSkPaintBox;
    FCurrentSprite: ISkImage;
    FHistoryPanel: TPanel;
    FHistoryOverlay: TSkPaintBox;
    FIsHistoryVisible: Boolean;
    FHistoryHoverIdx: Integer;
    FFilteredList: TArray<string>;
    FFilteredIdx: Integer;
    FIsFilteredMode: Boolean;
    FFilterTerm: string;
    FClearFilterIcon: TSkSvg;
    FFavBtn: TSkSvg;
    FFavModeIcon: TSkSvg;
    FIsFavMode: Boolean;
    FIsLoading: Boolean;
    FLoadingTick: Integer;
    FLoadingTimer: TTimer;
    FActiveSearchRequest: Int64;
    FActiveMovePoolRequest: Int64;
    procedure PlayCry;
    procedure CryIconClick(Sender: TObject);
    procedure ApplyTheme(const AColor: TColor);
    procedure PerformSearch(const AIdOrName: string);
    procedure UpdatePokemonStats(APokemon: TPokemon);
    procedure UpdatePokemonTypes(APokemon: TPokemon);
    procedure ClearTypeBadges;
    procedure CreateTypeBadge(const ATypeName: string);
    procedure PositionTypeContainer;
    procedure SetupLayout;
    procedure SetupSearchBar;
    procedure SetupHistoryOverlay;
    procedure HideHistoryPanel;
    procedure SetupStatsPanel;
    procedure SetupEvolutionPanel;
    procedure ShinyIconClick(Sender: TObject);
    procedure UpdateShinyIcon;
    procedure ReloadSprite;
    function ExtractDominantColor(AStream: TMemoryStream): TColor;
    procedure CenterSprite;
    procedure CenterSearchBar;
    procedure WMAfterCreate(var Msg: TMessage); message WM_USER + 1;
    procedure FormResize(Sender: TObject);
    procedure RandomIconClick(Sender: TObject);
    procedure SearchIconClick(Sender: TObject);
    procedure TypeBadgeClick(Sender: TObject);
    procedure SearchEditKeyPress(Sender: TObject; var Key: Char);
    procedure SearchEditEnter(Sender: TObject);
    procedure SearchEditExit(Sender: TObject);
    procedure ClearFilterClick(Sender: TObject);
    procedure FavBtnClick(Sender: TObject);
    procedure FavModeClick(Sender: TObject);
    procedure UpdateFavIcons;
    procedure StatsPanelMovesTabRequested(Sender: TObject);
    procedure StatsPanelInteracted(Sender: TObject);
    procedure SetLoading(const AValue: Boolean);
    procedure LoadingTimerTick(Sender: TObject);
    procedure DrawSearchBg(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure DrawHistoryOverlay(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure HistoryOverlayMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HistoryOverlayMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure DrawShinyBtn(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure DrawSprite(ASender: TObject; const ACanvas: ISkCanvas;
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
    POKEBALL_RED: TAlphaColor = $FFE14B3B;
    EVOLUTION_H = 160;
    TYPE_CHART_H = 140;
    SPRITE_TOP = 128;
    SEARCH_H = 34;
    SEARCH_T = 7;
    SEARCH_W = 340;
    HISTORY_ITEM_H = 30;
    ICON_SIZE = 20;
    ICON_PAD = 8;
    SPRITE_SIZE = 200;
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
  SetupEvolutionPanel;
  FLoadingTimer := TTimer.Create(Self);
  FLoadingTimer.Enabled := False;
  FLoadingTimer.Interval := 90;
  FLoadingTimer.OnTimer := LoadingTimerTick;
  BASS_Init(-1, 44100, 0, Handle, nil);
  Randomize;
end;

procedure TPokedexView.FormDestroy(Sender: TObject);
begin
  if FCurrentChannel <> 0 then
  begin
    BASS_ChannelStop(FCurrentChannel);
    BASS_StreamFree(FCurrentChannel);
  end;
  FreeAndNil(FCurrentStream);
  if Assigned(FController) then
    FController.Free;
  BASS_Free;
end;

procedure TPokedexView.SetupLayout;
begin
  if Width < 980 then
    Width := 980;
  if Height < 820 then
    Height := 820;
  Constraints.MinWidth := 980;
  Constraints.MinHeight := 820;
  pnlTopContainer.Align := alNone;
  pnlTopContainer.SetBounds(0, 0, 368, SEARCH_H + (SEARCH_T * 2));
  pnlTopContainer.Anchors := [akLeft, akTop];
  pnlTopContainer.Height := SEARCH_H + (SEARCH_T * 2);
  pnlTopContainer.BringToFront;

  pnlImage.BevelOuter := bvNone;
  pnlImage.BevelInner := bvNone;

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
  FDisplayNameLabel.Anchors := [akLeft, akTop, akRight];
  FDisplayNameLabel.TextSettings.HorzAlign := TSkTextHorzAlign.Center;
  FDisplayNameLabel.TextSettings.VertAlign := TSkTextVertAlign.Center;

  skImgPokemon.Visible := False;

  btnNext.Parent := pnlImage;
  btnPrev.Parent := pnlImage;

  FSpritePaintBox := TSkPaintBox.Create(Self);
  FSpritePaintBox.Parent := pnlImage;
  FSpritePaintBox.Anchors := [akLeft, akTop];
  FSpritePaintBox.Cursor := crHandPoint;
  FSpritePaintBox.OnDraw := DrawSprite;
  FSpritePaintBox.OnMouseDown := ImgPokemonMouseDown;

  btnNext.Visible := False;
  btnPrev.Visible := False;

  FIdLabel := TSkLabel.Create(Self);
  FIdLabel.Parent := pnlImage;
  FIdLabel.AutoSize := False;
  FIdLabel.Anchors := [akLeft, akTop, akRight];
  FIdLabel.TextSettings.HorzAlign := TSkTextHorzAlign.Center;
  FIdLabel.Visible := False;

  FFavBtn := TSkSvg.Create(Self);
  FFavBtn.Parent := pnlImage;
  FFavBtn.SetBounds(0, 0, 24, 24);
  FFavBtn.Cursor := crHandPoint;
  FFavBtn.Hint := 'Favoritar Pok'#233'mon';
  FFavBtn.ShowHint := True;
  FFavBtn.OnClick := FavBtnClick;
  FFavBtn.Visible := False;

  FShinyBtn := TSkPaintBox.Create(Self);
  FShinyBtn.Parent := pnlImage;
  FShinyBtn.Anchors := [akLeft, akTop];
  FShinyBtn.Cursor := crHandPoint;
  FShinyBtn.OnClick := ShinyIconClick;
  FShinyBtn.OnDraw := DrawShinyBtn;
  FShinyBtn.BringToFront;
  FShinyBtn.Visible := False;

  // Fix FlowPanel properties
  fpTypes.AutoSize := False;
  fpTypes.AutoWrap := False;
  fpTypes.FlowStyle := TFlowStyle.fsLeftRightTopBottom;
  fpTypes.BevelOuter := bvNone;
  fpTypes.ParentBackground := True;
  fpTypes.Height := 24; // Ensure height fits badges (22px)

  BorderIcons := BorderIcons - [biMaximize];
  CenterSprite;
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

  FClearFilterIcon := TSkSvg.Create(Self);
  FClearFilterIcon.Parent := FSearchContainer;
  FClearFilterIcon.SetBounds(ICON_PAD, (SEARCH_H - ICON_SIZE) div 2, ICON_SIZE,
    ICON_SIZE);
  FClearFilterIcon.Svg.Source :=
    '<svg viewBox="0 0 24 24"><path fill="#FF5555" d="M19 6.41L17.59 5 12 10.59'
    + ' 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>';
  FClearFilterIcon.Cursor := crHandPoint;
  FClearFilterIcon.Hint := 'Limpar Filtro';
  FClearFilterIcon.ShowHint := True;
  FClearFilterIcon.Visible := False;
  FClearFilterIcon.OnClick := ClearFilterClick;

  LEditLeft := SEARCH_H div 2;
  LEditWidth := SEARCH_W - LEditLeft - (ICON_PAD + ICON_SIZE) * 4 - ICON_PAD;

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
  FSearchEdit.OnEnter := SearchEditEnter;
  FSearchEdit.OnExit := SearchEditExit;
  FSearchEdit.BringToFront;
  FClearFilterIcon.BringToFront;

  FSearchIcon := TSkSvg.Create(Self);
  FSearchIcon.Parent := FSearchContainer;
  FSearchIcon.SetBounds(SEARCH_W - (ICON_PAD + ICON_SIZE) * 2,
    (SEARCH_H - ICON_SIZE) div 2, ICON_SIZE, ICON_SIZE);
  FSearchIcon.Anchors := [akTop, akRight];
  FSearchIcon.Svg.Source :=
    '<svg viewBox="0 0 24 24"><path fill="white" d="M15.5 14h-.79' +
    'l-.28-.27A6.47 6.47 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59' +
    ' 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5' +
    ' 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>';
  FSearchIcon.Cursor := crHandPoint;
  FSearchIcon.Hint := 'Buscar Pok'#233'mon';
  FSearchIcon.ShowHint := True;
  FSearchIcon.OnClick := SearchIconClick;
  FSearchIcon.BringToFront;

  FCryIcon := TSkSvg.Create(Self);
  FCryIcon.Parent := FSearchContainer;
  FCryIcon.SetBounds(SEARCH_W - ICON_PAD - ICON_SIZE, (SEARCH_H - ICON_SIZE)
    div 2, ICON_SIZE, ICON_SIZE);
  FCryIcon.Svg.Source :=
    '<svg viewBox="0 0 24 24"><path fill="white" d="M3 9v6h4l5 5V4L7 9H3z' +
    'M16.5 12A4.5 4.5 0 0 0 14 7.97v8.05c1.48-.73 2.5-2.25 2.5-4.02z"/></svg>';
  FCryIcon.Cursor := crHandPoint;
  FCryIcon.Hint := 'Ouvir Pok'#233'mon';
  FCryIcon.ShowHint := True;
  FCryIcon.OnClick := CryIconClick;
  FCryIcon.BringToFront;

  FRandomIcon := TSkSvg.Create(Self);
  FRandomIcon.Parent := FSearchContainer;
  FRandomIcon.SetBounds(SEARCH_W - (ICON_PAD + ICON_SIZE) * 3,
    (SEARCH_H - ICON_SIZE) div 2, ICON_SIZE, ICON_SIZE);
  FRandomIcon.Anchors := [akTop, akRight];
  FRandomIcon.Svg.Source :=
    '<svg viewBox="0 0 24 24"><path fill="white" d="M10.59 9.17L5.41 4 4 5.41' +
    'l5.17 5.17 1.42-1.41zM14.5 4l2.04 2.04L4 18.59 5.41 20 17.96 7.46 20 9.5' +
    'V4h-5.5zm.33 9.41l-1.41 1.41 3.13 3.13L14.5 20H20v-5.5l-2.04 2.04-3.13-3' +
    '.13z"/></svg>';
  FRandomIcon.Cursor := crHandPoint;
  FRandomIcon.Hint := 'Pok'#233'mon Aleat'#243'rio';
  FRandomIcon.ShowHint := True;
  FRandomIcon.OnClick := RandomIconClick;
  FRandomIcon.BringToFront;

  FFavModeIcon := TSkSvg.Create(Self);
  FFavModeIcon.Parent := FSearchContainer;
  FFavModeIcon.SetBounds(SEARCH_W - (ICON_PAD + ICON_SIZE) * 4,
    (SEARCH_H - ICON_SIZE) div 2, ICON_SIZE, ICON_SIZE);
  FFavModeIcon.Anchors := [akTop, akRight];
  FFavModeIcon.Cursor := crHandPoint;
  FFavModeIcon.Hint := 'Ver Favoritos';
  FFavModeIcon.ShowHint := True;
  FFavModeIcon.Svg.Source :=
    '<svg viewBox="0 0 24 24"><path fill="white" d="M22 9.24l-7.19-.62L12 2 9.19 8.63 2 9.24l5.46 ' +
    '4.73L5.82 21 12 17.27 18.18 21l-1.63-7.03L22 9.24zM12 15.4l-3.76 2.27 1-4.28-3.32-2.88 4.38' +
    '-.38L12 6.1l1.71 4.04 4.38.38-3.32 2.88 1 4.28L12 15.4z"/></svg>';
  FFavModeIcon.OnClick := FavModeClick;
  FFavModeIcon.BringToFront;

  SetupHistoryOverlay;
end;

procedure TPokedexView.SetupStatsPanel;
begin
  FStatsPanel := TStatsPanel.Create(Self);
  FStatsPanel.Parent := pnlInfo;
  FStatsPanel.SetBounds(0, 0, pnlInfo.Width, pnlInfo.Height);
  FStatsPanel.Anchors := [akLeft, akTop, akRight, akBottom];
  FStatsPanel.FontFamily := FONT_FAMILY;
  FStatsPanel.OnInteract := StatsPanelInteracted;
  FStatsPanel.OnMovesTabRequested := StatsPanelMovesTabRequested;
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

procedure TPokedexView.HideHistoryPanel;
begin
  FIsHistoryVisible := False;
  if Assigned(FHistoryPanel) then
    FHistoryPanel.Visible := False;
end;

function CapitalizePokemonName(const AName: string): string;
var
  I: Integer;
  LCapNext: Boolean;
begin
  Result := AName.ToLower;
  LCapNext := True;
  for I := 1 to Length(Result) do
  begin
    if LCapNext and CharInSet(Result[I], ['a' .. 'z']) then
    begin
      Result[I] := UpCase(Result[I]);
      LCapNext := False;
    end
    else if CharInSet(Result[I], ['-', ' ']) then
      LCapNext := True;
  end;
end;

procedure TPokedexView.ApplyTheme(const AColor: TColor);
var
  LEffectiveColor: TColor;
  LLum: Integer;
  LAlphaColor: TAlphaColor;
  LBoost, LBarR, LBarG, LBarB: Integer;
begin
  LLum := (GetRValue(AColor) * 299 + GetGValue(AColor) * 587 + GetBValue(AColor)
    * 114) div 1000;

  if LLum > 200 then
  begin
    LEffectiveColor := $00F0F0F0;
    FThemeTextColor := TAlphaColors.Black;
  end
  else if LLum < 60 then
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
  if Assigned(FHistoryPanel) then
    FHistoryPanel.Color := LEffectiveColor;

  FSearchBg.Redraw;

  if FDisplayNameLabel.Words.Count > 0 then
    FDisplayNameLabel.Words[0].FontColor := FThemeTextColor;

  if FIdLabel.Words.Count > 0 then
    FIdLabel.Words[0].FontColor := (FThemeTextColor and $00FFFFFF) or $88000000;

  LAlphaColor := $FF000000 or (DWORD(GetRValue(LEffectiveColor)) shl 16) or
    (DWORD(GetGValue(LEffectiveColor)) shl 8) or
    DWORD(GetBValue(LEffectiveColor));

  FEvolutionPanel.ThemeColor := LAlphaColor;

  if LLum < 60 then
    FStatsPanel.BarColor := $FFFFD700
  else
  begin
    LBoost := Max(0, 200 - LLum);
    LBarR := Min(255, GetRValue(LEffectiveColor) + LBoost);
    LBarG := Min(255, GetGValue(LEffectiveColor) + LBoost);
    LBarB := Min(255, GetBValue(LEffectiveColor) + LBoost);
    FStatsPanel.BarColor := $FF000000 or (DWORD(LBarR) shl 16) or
      (DWORD(LBarG) shl 8) or DWORD(LBarB);
  end;

  FStatsPanel.Redraw;
  FEvolutionPanel.Redraw;
  if Assigned(FShinyBtn) and FShinyBtn.Visible then
    FShinyBtn.Redraw;
  UpdateFavIcons;
end;

procedure TPokedexView.PerformSearch(const AIdOrName: string);
var
  LSearchRequestId: Int64;
begin
  if Trim(AIdOrName).IsEmpty then
  begin
    MessageDlg(MSG_EMPTY_SEARCH, mtWarning, [mbOK], 0);
    FSearchEdit.SetFocus;
    Exit;
  end;

  Inc(FActiveSearchRequest);
  Inc(FActiveMovePoolRequest);
  LSearchRequestId := FActiveSearchRequest;
  FSearchEdit.Enabled := False;
  btnNext.Visible := False;
  btnPrev.Visible := False;
  SetLoading(True);

  FController.AddToHistory(AIdOrName);
  HideHistoryPanel;

  TThread.CreateAnonymousThread(
    procedure
    var
      LPokemon: TPokemon;
      LStream: TMemoryStream;
      LChain: TArray<TEvolutionNode>;
      LTypeEffects, LOffensiveEffects: TArray<TTypeEffect>;
      LAbilityName, LAbilityDesc, LAbilityNote, LErrorMsg, LSpriteUrl: string;
      LDominantColor: TColor;
      LTypeNames, LTypeList: TArray<string>;
      I: Integer;
      LSearchTerm: string;
      LIsNavigating: Boolean;
      LUseShiny: Boolean;
      LShowShinyUnavailable: Boolean;
    begin
      LPokemon := nil;
      LStream := nil;
      LErrorMsg := '';
      LDominantColor := 0;
      LUseShiny := False;
      LShowShinyUnavailable := False;
      LSearchTerm := AIdOrName.ToLower.Trim;
      SetLength(LChain, 0);
      SetLength(LTypeEffects, 0);
      SetLength(LOffensiveEffects, 0);
      LAbilityName := '';
      LAbilityDesc := '';
      LAbilityNote := '';
      var
        LFlavorText: string := '';
      var
        LPokeAPILang: string := TPokemonController.GetPreferredLanguage;
      var
        LSystemLang: string := TPokemonController.GetSystemLanguage;

      LIsNavigating := False;
      TThread.Synchronize(nil, TThreadProcedure(
        procedure
        begin
          if (FIsFavMode or FIsFilteredMode) and (FFilteredIdx >= 0) and
            (FFilteredIdx < Length(FFilteredList)) then
            LIsNavigating := (FFilteredList[FFilteredIdx] = LSearchTerm);
          LUseShiny := FIsShiny;
        end));

      try
        if not LIsNavigating and not(StrToIntDef(LSearchTerm, 0) > 0) then
        begin
          LTypeList := FController.GetPokemonByType(LSearchTerm);
          if Length(LTypeList) > 0 then
          begin
            TThread.Synchronize(nil, TThreadProcedure(
              procedure
              begin
                FFilteredList := LTypeList;
                FFilteredIdx := 0;
                FIsFilteredMode := True;
                FIsFavMode := False;
                FFilterTerm := LSearchTerm;
              end));
            LSearchTerm := FFilteredList[0];
          end
          else
          begin
            TThread.Synchronize(nil, TThreadProcedure(
              procedure
              begin
                FIsFilteredMode := False;
                FIsFavMode := False;
              end));
          end;
        end
        else if not LIsNavigating then
        begin
          TThread.Synchronize(nil, TThreadProcedure(
            procedure
            begin
              FIsFilteredMode := False;
              FIsFavMode := False;
            end));
        end;

        LPokemon := FController.ExecuteGetPokemon(LSearchTerm);
        if LUseShiny and not LPokemon.ShinySpriteUrl.IsEmpty then
          LSpriteUrl := LPokemon.ShinySpriteUrl
        else
          LSpriteUrl := LPokemon.SpriteUrl;
        LStream := FController.DownloadFile(LSpriteUrl);
        if LUseShiny and (LPokemon.ShinySpriteUrl.IsEmpty or not Assigned(LStream))
        then
        begin
          LShowShinyUnavailable := True;
          FreeAndNil(LStream);
          LSpriteUrl := LPokemon.SpriteUrl;
          LStream := FController.DownloadFile(LSpriteUrl);
          LUseShiny := False;
        end;
        if LUseShiny and Assigned(LStream) then
        begin
          LDominantColor := ExtractDominantColor(LStream);
          LStream.Position := 0;
        end;
        if Assigned(LPokemon.SpeciesData) and
          Assigned(LPokemon.SpeciesData.EvolutionChain) and
          not LPokemon.SpeciesData.EvolutionChain.Url.IsEmpty then
          LChain := FController.GetEvolutionChain
            (LPokemon.SpeciesData.EvolutionChain.Url);
        if Length(LPokemon.Types) > 0 then
        begin
          SetLength(LTypeNames, Length(LPokemon.Types));
          for I := 0 to High(LPokemon.Types) do
            LTypeNames[I] := LPokemon.Types[I].&Type.Name;
          LOffensiveEffects := FController.GetOffensiveEffectiveness(LTypeNames);
        end;
        if Length(LPokemon.Abilities) > 0 then
        begin
          LAbilityName := LPokemon.Abilities[0].Ability.Name;
          LAbilityDesc := FController.GetAbilityDescription(LAbilityName, LPokeAPILang);
          LAbilityNote := TPokemonController.GetDefensiveAbilityNote(LAbilityName);
        end;
        if Length(LTypeNames) > 0 then
          LTypeEffects := FController.GetTypeEffectiveness(LTypeNames, LAbilityName);
        if Assigned(LPokemon.SpeciesData) then
          LFlavorText := LPokemon.SpeciesData.GetDescription(LPokeAPILang);
        // MyMemory only when PokeAPI has no native entry (e.g. pt-BR)
        if (LPokeAPILang = 'en') and (LSystemLang <> 'en') then
        begin
          if not LAbilityDesc.IsEmpty then
            LAbilityDesc := TPokemonController.Translate(LAbilityDesc,
              LSystemLang);
          if not LFlavorText.IsEmpty then
            LFlavorText := TPokemonController.Translate(LFlavorText,
              LSystemLang);
        end;
      except
        on E: EPokemonNotFound do
          LErrorMsg := MSG_NOT_FOUND;
        on E: EPokemonNetworkError do
          LErrorMsg := MSG_NETWORK_ERROR;
        on E: Exception do
          LErrorMsg := E.Message;
      end;

      TThread.Synchronize(nil, TThreadProcedure(
        procedure
        begin
          if LSearchRequestId <> FActiveSearchRequest then
          begin
            FreeAndNil(LStream);
            FreeAndNil(LPokemon);
            Exit;
          end;

          SetLoading(False);
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
            if FIsShiny <> LUseShiny then
              FIsShiny := LUseShiny;

            FClearFilterIcon.Visible := FIsFilteredMode or FIsFavMode;

            if FIsFilteredMode or FIsFavMode then
              FSearchEdit.Left := ICON_PAD + ICON_SIZE + 5
            else
              FSearchEdit.Left := SEARCH_H div 2;
            FSearchEdit.Width := SEARCH_W - FSearchEdit.Left -
              (ICON_PAD + ICON_SIZE) * 4 - ICON_PAD;

            if not(FIsFilteredMode or FIsFavMode) then
              FSearchEdit.Text := CapitalizePokemonName(LPokemon.Name);
            btnNext.Visible := True;
            btnPrev.Visible := True;
            if FIsFilteredMode or FIsFavMode then
            begin
              btnNext.Opacity := IfThen(FFilteredIdx <
                High(FFilteredList), 255, 80);
              btnPrev.Opacity := IfThen(FFilteredIdx > 0, 255, 80);
            end
            else
            begin
              btnNext.Opacity := 255;
              btnPrev.Opacity := 255;
            end;
            btnNext.ShowHint := True;
            btnPrev.ShowHint := True;

            FShinyBtn.Visible := True;
            UpdateShinyIcon;
            if LShowShinyUnavailable then
              MessageDlg('Sprite shiny n'#227'o dispon'#237'vel para este Pok'#233'mon.',
                mtInformation, [mbOK], 0);

            if Assigned(LPokemon.SpeciesData) then
            begin
              FSpeciesColor := TPokemonController.GetColorByString
                (LPokemon.SpeciesData.Color.Name);
              if FIsShiny and (LDominantColor <> 0) then
                ApplyTheme(LDominantColor)
              else
                ApplyTheme(FSpeciesColor);
            end;

            FDisplayNameLabel.Caption := UpperCase(LPokemon.Name);
            if FDisplayNameLabel.Words.Count > 0 then
            begin
              FDisplayNameLabel.Words[0].Font.Families := FFontName;
              FDisplayNameLabel.Words[0].Font.Size := 22;
              FDisplayNameLabel.Words[0].Font.Weight :=
                TSkFontComponent.TSkFontWeight.Bold;
              FDisplayNameLabel.Words[0].FontColor := FThemeTextColor;
            end;

            if FIsFilteredMode or FIsFavMode then
            begin
              if FIsFavMode then
                FIdLabel.Caption := Format('#%d  '#$00B7'  FAV %d/%d',
                  [LPokemon.Id, FFilteredIdx + 1, Length(FFilteredList)])
              else
                FIdLabel.Caption := Format('#%d  '#$00B7'  %s %d/%d',
                  [LPokemon.Id, UpperCase(FFilterTerm),
                  FFilteredIdx + 1, Length(FFilteredList)]);
            end
            else
              FIdLabel.Caption := Format('#%d', [LPokemon.Id]);
            FIdLabel.Visible := True;
            if FIdLabel.Words.Count > 0 then
            begin
              FIdLabel.Words[0].Font.Families := FFontName;
              FIdLabel.Words[0].Font.Size :=
                IfThen(FIsFilteredMode or FIsFavMode, 11, 16);
              FIdLabel.Words[0].Font.Weight :=
                TSkFontComponent.TSkFontWeight.Bold;
              FIdLabel.Words[0].FontColor := (FThemeTextColor and $00FFFFFF) or
                $AA000000;
            end;
            UpdateFavIcons;
            FCurrentSprite := nil;
            if Assigned(LStream) then
              try
                var
                  LBytes: TBytes;
                SetLength(LBytes, LStream.Size);
                LStream.Position := 0;
                LStream.Read(LBytes[0], LStream.Size);
                FCurrentSprite := TSkImage.MakeFromEncoded(LBytes);
              finally
                FreeAndNil(LStream);
              end;
            FSpritePaintBox.Redraw;
            UpdatePokemonStats(LPokemon);
            UpdatePokemonTypes(LPokemon);
            if LFlavorText.IsEmpty then
              FStatsPanel.LoadDescription(MSG_NOT_AVAILABLE_DESCRIPTION)
            else
              FStatsPanel.LoadDescription(LFlavorText);
            FEvolutionPanel.LoadChain(TPokemonController.FilterEvolutionChain
              (LChain, FCurrentId));
            FStatsPanel.LoadEffects(LTypeEffects, LOffensiveEffects,
              LAbilityNote);
            FStatsPanel.ResetMovePool;
            FStatsPanel.LoadAbilityDescription(LAbilityDesc);
          finally
            FreeAndNil(LPokemon);
          end;
        end));
    end).Start;
end;

procedure TPokedexView.btnNextClick(Sender: TObject);
begin
  HideHistoryPanel;
  if (FIsFavMode or FIsFilteredMode) then
  begin
    if FFilteredIdx < High(FFilteredList) then
    begin
      Inc(FFilteredIdx);
      PerformSearch(FFilteredList[FFilteredIdx]);
    end;
  end
  else
    PerformSearch(IntToStr(FCurrentId + 1));
end;

procedure TPokedexView.btnPrevClick(Sender: TObject);
begin
  HideHistoryPanel;
  if (FIsFavMode or FIsFilteredMode) then
  begin
    if FFilteredIdx > 0 then
    begin
      Dec(FFilteredIdx);
      PerformSearch(FFilteredList[FFilteredIdx]);
    end;
  end
  else if FCurrentId > 1 then
    PerformSearch(IntToStr(FCurrentId - 1));
end;

procedure TPokedexView.FavBtnClick(Sender: TObject);
begin
  HideHistoryPanel;
  if FCurrentId > 0 then
  begin
    FController.ToggleFavorite(FCurrentId);
    UpdateFavIcons;
  end;
end;

procedure TPokedexView.FavModeClick(Sender: TObject);
var
  LFavs: TArray<string>;
begin
  HideHistoryPanel;
  if FIsFavMode then
  begin
    FIsFavMode := False;
    PerformSearch(FCurrentId.ToString);
  end
  else
  begin
    LFavs := FController.GetFavorites;
    if Length(LFavs) = 0 then
    begin
      MessageDlg('Voc'#234' ainda n'#227'o tem Pok'#233'mon favoritos.',
        mtInformation, [mbOK], 0);
      Exit;
    end;
    FIsFavMode := True;
    FIsFilteredMode := False;
    FFilteredList := LFavs;
    FFilteredIdx := 0;
    FSearchEdit.Clear;
    PerformSearch(FFilteredList[0]);
  end;
  UpdateFavIcons;
end;

procedure TPokedexView.UpdateFavIcons;
const
  SVG_FAV_ON =
    '<svg viewBox="0 0 24 24"><path fill="#FFD700" d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>';
  SVG_FAV_OFF =
    '<svg viewBox="0 0 24 24"><path fill="currentColor" d="M22 9.24l-7.19-.62L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21 12 17.27 18.18 21l-1.63-7.03L22 9.24zM12 15.4l-3.76 2.27 1-4.28-3.32-2.88 4.38-.38L12 6.1l1.71 4.04 4.38.38-3.32 2.88 1 4.28L12 15.4z"/></svg>';
  SVG_FAV_MODE_ON =
    '<svg viewBox="0 0 24 24"><path fill="#FFD700" d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>';
  SVG_FAV_MODE_OFF =
    '<svg viewBox="0 0 24 24"><path fill="white" d="M22 9.24l-7.19-.62L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21 12 17.27 18.18 21l-1.63-7.03L22 9.24zM12 15.4l-3.76 2.27 1-4.28-3.32-2.88 4.38-.38L12 6.1l1.71 4.04 4.38.38-3.32 2.88 1 4.28L12 15.4z"/></svg>';
var
  LOffColor: string;
begin
  if not Assigned(FController) then
    Exit;
  if FThemeTextColor = TAlphaColors.White then
    LOffColor := 'white'
  else
    LOffColor := 'black';
  if FController.IsFavorite(FCurrentId) then
    FFavBtn.Svg.Source := SVG_FAV_ON
  else
    FFavBtn.Svg.Source := SVG_FAV_OFF.Replace('currentColor', LOffColor);
  if FIsFavMode then
    FFavModeIcon.Svg.Source := SVG_FAV_MODE_ON
  else
    FFavModeIcon.Svg.Source := SVG_FAV_MODE_OFF;
  FFavBtn.Visible := FCurrentId > 0;
end;

procedure TPokedexView.ClearFilterClick(Sender: TObject);
begin
  HideHistoryPanel;
  FIsFilteredMode := False;
  FIsFavMode := False;
  FClearFilterIcon.Visible := False;
  PerformSearch(FCurrentId.ToString);
end;

procedure TPokedexView.CryIconClick(Sender: TObject);
begin
  HideHistoryPanel;
  PlayCry;
end;

procedure TPokedexView.RandomIconClick(Sender: TObject);
begin
  HideHistoryPanel;
  PerformSearch(TPokemonController.RandomPokemonId.ToString);
end;

procedure TPokedexView.SearchIconClick(Sender: TObject);
begin
  HideHistoryPanel;
  PerformSearch(FSearchEdit.Text);
end;

procedure TPokedexView.ShinyIconClick(Sender: TObject);
begin
  HideHistoryPanel;
  FIsShiny := not FIsShiny;
  UpdateShinyIcon;
  ReloadSprite;
end;

procedure TPokedexView.SearchEditEnter(Sender: TObject);
var
  LHistory: TArray<string>;
  LPos: TPoint;
begin
  LHistory := FController.GetHistory;
  if Length(LHistory) > 0 then
  begin
    FHistoryPanel.Width := SEARCH_W;
    FHistoryPanel.Height := (Length(LHistory) * HISTORY_ITEM_H) + 20;
    LPos := FSearchContainer.ClientToParent
      (TPoint.Create(0, FSearchContainer.Height), Self);
    FHistoryPanel.Left := LPos.X;
    FHistoryPanel.Top := LPos.Y + 2;
    FHistoryPanel.Visible := True;
    FHistoryPanel.BringToFront;
    FIsHistoryVisible := True;
    FHistoryHoverIdx := -1;
    FHistoryOverlay.Redraw;
  end;
  if Length(LHistory) = 0 then
    HideHistoryPanel;
end;

procedure TPokedexView.SearchEditExit(Sender: TObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(200);
      TThread.Synchronize(nil, TThreadProcedure(
        procedure
        begin
          HideHistoryPanel;
        end));
    end).Start;
end;

procedure TPokedexView.DrawSearchBg(ASender: TObject; const ACanvas: ISkCanvas;
const ADest: TRectF; const AOpacity: Single);
var
  LPaint: ISkPaint;
  LSpinnerRect: TRectF;
  LSpinnerSize: Single;
  LSpinnerLeft: Single;
begin
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := DARK_PANEL_ALPHA;
  ACanvas.DrawRoundRect(ADest, ADest.Height / 2, ADest.Height / 2, LPaint);
  if FIsLoading then
  begin
    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 2.5;
    LPaint.Color := $33FFFFFF;
    LSpinnerSize := ICON_SIZE;
    LSpinnerLeft := ADest.Right - (ICON_PAD + ICON_SIZE) * 2 +
      ((ICON_SIZE - LSpinnerSize) / 2) + 1;
    LSpinnerRect := TRectF.Create(LSpinnerLeft,
      ADest.CenterPoint.Y - (LSpinnerSize / 2), LSpinnerLeft + LSpinnerSize,
      ADest.CenterPoint.Y + (LSpinnerSize / 2));
    ACanvas.DrawArc(LSpinnerRect, 0, 360, False, LPaint);
    LPaint.Color := POKEBALL_RED;
    ACanvas.DrawArc(LSpinnerRect, FLoadingTick * 28, 120, False, LPaint);
  end;
end;

procedure TPokedexView.DrawSprite(ASender: TObject; const ACanvas: ISkCanvas;
const ADest: TRectF; const AOpacity: Single);
var
  LPaint: ISkPaint;
  LCX, LCY, LR: Single;
  LSpinnerRect: TRectF;
begin
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LCX := (ADest.Left + ADest.Right) / 2;
  LCY := (ADest.Top + ADest.Bottom) / 2;
  LR := Min(ADest.Width, ADest.Height) / 2 * 0.92;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := $0EFFFFFF;
  ACanvas.DrawCircle(LCX, LCY, LR, LPaint);
  LPaint.Style := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := 2;
  LPaint.Color := $1AFFFFFF;
  ACanvas.DrawCircle(LCX, LCY, LR, LPaint);
  ACanvas.DrawLine(TPointF.Create(LCX - LR, LCY),
    TPointF.Create(LCX + LR, LCY), LPaint);
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := $10FFFFFF;
  ACanvas.DrawCircle(LCX, LCY, LR * 0.14, LPaint);
  if Assigned(FCurrentSprite) then
  begin
    LPaint.Style := TSkPaintStyle.Fill;
    LPaint.Color := TAlphaColors.White;
    ACanvas.DrawImageRect(FCurrentSprite, ADest,
      TSkSamplingOptions.Create(TSkFilterMode.Linear,
      TSkMipmapMode.None), LPaint);
  end;
  if FIsLoading then
  begin
    LSpinnerRect := TRectF.Create(LCX - 24, LCY - 24, LCX + 24, LCY + 24);
    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 4;
    LPaint.Color := $22FFFFFF;
    ACanvas.DrawArc(LSpinnerRect, 0, 360, False, LPaint);
    LPaint.Color := POKEBALL_RED;
    ACanvas.DrawArc(LSpinnerRect, FLoadingTick * 28, 110, False, LPaint);
  end;
end;

procedure TPokedexView.DrawShinyBtn(ASender: TObject; const ACanvas: ISkCanvas;
const ADest: TRectF; const AOpacity: Single);
var
  LPaint: ISkPaint;
  LParaStyle: ISkParagraphStyle;
  LTextStyle: ISkTextStyle;
  LBuilder: ISkParagraphBuilder;
  LP: ISkParagraph;
  LText: string;
  LTextColor: TAlphaColor;
begin
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := $28FFFFFF;
  ACanvas.DrawRoundRect(ADest, ADest.Height / 2, ADest.Height / 2, LPaint);
  LPaint.Style := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := 1;
  LPaint.Color := $44FFFFFF;
  ACanvas.DrawRoundRect(ADest, ADest.Height / 2, ADest.Height / 2, LPaint);
  if FIsShiny then
  begin
    LText := #$2605 + ' VER NORMAL';
    LTextColor := $FFFFD700;
  end
  else
  begin
    LText := #$2605 + ' VER SHINY';
    LTextColor := FThemeTextColor;
  end;
  LParaStyle := TSkParagraphStyle.Create;
  LParaStyle.MaxLines := 1;
  LParaStyle.TextAlign := TSkTextAlign.Center;
  LTextStyle := TSkTextStyle.Create;
  LTextStyle.FontFamilies := [FFontName, 'Segoe UI'];
  LTextStyle.FontSize := 10;
  LTextStyle.Color := LTextColor;
  LTextStyle.FontStyle := TSkFontStyle.Bold;
  LBuilder := TSkParagraphBuilder.Create(LParaStyle);
  LBuilder.PushStyle(LTextStyle);
  LBuilder.AddText(LText);
  LBuilder.Pop;
  LP := LBuilder.Build;
  LP.Layout(ADest.Width);
  LP.Paint(ACanvas, ADest.Left, ADest.Top + (ADest.Height - LP.Height) / 2);
end;

procedure TPokedexView.HistoryOverlayMouseDown(Sender: TObject;
Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LHistory: TArray<string>;
  LIdx: Integer;
begin
  if Button = mbLeft then
  begin
    LIdx := Trunc((Y - 10) / HISTORY_ITEM_H);
    LHistory := FController.GetHistory;
    if (LIdx >= 0) and (LIdx < Length(LHistory)) then
    begin
      FSearchEdit.Text := CapitalizePokemonName(LHistory[LIdx]);
      PerformSearch(LHistory[LIdx]);
    end;
    HideHistoryPanel;
  end;
end;

procedure TPokedexView.HistoryOverlayMouseMove(Sender: TObject;
Shift: TShiftState; X, Y: Integer);
var
  LOldIdx: Integer;
begin
  LOldIdx := FHistoryHoverIdx;
  FHistoryHoverIdx := Trunc((Y - 10) / HISTORY_ITEM_H);
  if (Y < 10) or (Y > FHistoryPanel.Height - 10) then
    FHistoryHoverIdx := -1;
  if FHistoryHoverIdx <> LOldIdx then
    FHistoryOverlay.Redraw;
end;

procedure TPokedexView.DrawHistoryOverlay(ASender: TObject;
const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LHistory: TArray<string>;
  I: Integer;
  LPaint: ISkPaint;
  LParaStyle: ISkParagraphStyle;
  LTextStyle: ISkTextStyle;
  LBuilder: ISkParagraphBuilder;
  LP: ISkParagraph;
  LY, LRadius: Single;
begin
  LHistory := FController.GetHistory;
  if Length(LHistory) = 0 then
    Exit;
  LRadius := 17;
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := $F82A2A2A;
  ACanvas.DrawRoundRect(ADest, LRadius, LRadius, LPaint);
  LPaint.Style := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := 1.5;
  LPaint.Color := $33FFFFFF;
  ACanvas.DrawRoundRect(ADest, LRadius, LRadius, LPaint);
  LY := 10;
  for I := 0 to High(LHistory) do
  begin
    if I = FHistoryHoverIdx then
    begin
      LPaint.Style := TSkPaintStyle.Fill;
      LPaint.Color := $22FFFFFF;
      ACanvas.DrawRoundRect(TRectF.Create(ADest.Left + 10, LY, ADest.Right - 10,
        LY + HISTORY_ITEM_H), 10, 10, LPaint);
    end;
    LParaStyle := TSkParagraphStyle.Create;
    LParaStyle.MaxLines := 1;
    LParaStyle.TextAlign := TSkTextAlign.Left;
    LTextStyle := TSkTextStyle.Create;
    LTextStyle.FontFamilies := [FFontName, 'Segoe UI'];
    LTextStyle.FontSize := 11;
    LTextStyle.Color := TAlphaColors.White;
    LTextStyle.FontStyle := TSkFontStyle.Bold;
    if I = FHistoryHoverIdx then
      LTextStyle.Color := $FFFFD700;
    LBuilder := TSkParagraphBuilder.Create(LParaStyle);
    LBuilder.PushStyle(LTextStyle);
    LBuilder.AddText('     ' + CapitalizePokemonName(LHistory[I]));
    LBuilder.Pop;
    LP := LBuilder.Build;
    LP.Layout(ADest.Width - 30);
    LP.Paint(ACanvas, ADest.Left + 10, LY + (HISTORY_ITEM_H - LP.Height) / 2);
    LY := LY + HISTORY_ITEM_H;
  end;
end;

procedure TPokedexView.FormResize(Sender: TObject);
begin
  pnlTopContainer.SetBounds(0, 0, pnlImage.Width, SEARCH_H + (SEARCH_T * 2));
  CenterSearchBar;
  CenterSprite;
  if Assigned(FStatsPanel) and Assigned(pnlInfo) then
    FStatsPanel.SetBounds(0, 0, pnlInfo.Width, pnlInfo.Height);
  if Assigned(FEvolutionPanel) then
    FEvolutionPanel.SetBounds(0, ClientHeight - EVOLUTION_H, ClientWidth,
      EVOLUTION_H);
end;

procedure TPokedexView.CenterSprite;
const
  ID_H = 18;
  NAME_H = 34;
  FAV_H = 24;
  NAME_BLOCK_H = NAME_H + FAV_H + 4;
  TYPE_H = 24;
  SHINY_H = 26;
  SHINY_W = 160;
var
  LAvailH, LTotalH, LGap, LY, LImgX, LNameY, LFavY: Integer;
begin
  LAvailH := pnlImage.Height - pnlTopContainer.Height;
  LTotalH := ID_H + NAME_BLOCK_H + TYPE_H + SPRITE_SIZE + SHINY_H;
  LGap := Max(10, (LAvailH - LTotalH) div 5);
  LY := pnlTopContainer.Height + LGap;
  LImgX := (pnlImage.Width - SPRITE_SIZE) div 2;
  if Assigned(FIdLabel) then
    FIdLabel.SetBounds(0, LY, pnlImage.Width, ID_H);
  if Assigned(FDisplayNameLabel) then
    FDisplayNameLabel.SetBounds(0, LY + ID_H, pnlImage.Width, NAME_H);
  LNameY := LY + ID_H;
  LFavY := LNameY + NAME_H + 4;
  if Assigned(FFavBtn) then
    FFavBtn.SetBounds((pnlImage.Width - 24) div 2, LFavY, 24, 24);
  btnPrev.SetBounds(20, LNameY + (NAME_H - btnPrev.Height) div 2, btnPrev.Width,
    btnPrev.Height);
  btnNext.SetBounds(pnlImage.Width - btnNext.Width - 20, LNameY +
    (NAME_H - btnNext.Height) div 2, btnNext.Width, btnNext.Height);
  LY := LY + ID_H + NAME_BLOCK_H + LGap;
  fpTypes.Top := LY;
  fpTypes.Left := (pnlImage.Width - fpTypes.Width) div 2;
  LY := LY + TYPE_H + LGap;
  if Assigned(FSpritePaintBox) then
    FSpritePaintBox.SetBounds(LImgX, LY, SPRITE_SIZE, SPRITE_SIZE);
  btnPrev.BringToFront;
  btnNext.BringToFront;
  LY := LY + SPRITE_SIZE + LGap;
  if Assigned(FShinyBtn) then
    FShinyBtn.SetBounds((pnlImage.Width - SHINY_W) div 2, LY, SHINY_W, SHINY_H);
end;

procedure TPokedexView.CenterSearchBar;
begin
  if Assigned(FSearchContainer) then
    FSearchContainer.Left := (pnlImage.Width - FSearchContainer.Width) div 2;
end;

procedure TPokedexView.ImgPokemonMouseDown(Sender: TObject;
Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  HideHistoryPanel;
  if Button = mbLeft then
    PlayCry;
end;

procedure TPokedexView.UpdateShinyIcon;
begin
  FShinyBtn.Redraw;
end;

procedure TPokedexView.StatsPanelMovesTabRequested(Sender: TObject);
var
  LMovePoolRequestId: Int64;
  LPokemonId: Integer;
begin
  if FCurrentId = 0 then
    Exit;

  LPokemonId := FCurrentId;
  Inc(FActiveMovePoolRequest);
  LMovePoolRequestId := FActiveMovePoolRequest;
  FStatsPanel.SetMovesLoading(True);

  TThread.CreateAnonymousThread(
    procedure
    var
      LSections: TArray<TMovePoolSection>;
      LErrorMsg: string;
    begin
      SetLength(LSections, 0);
      LErrorMsg := '';
      try
        LSections := FController.GetMovePool(LPokemonId.ToString);
      except
        on E: EPokemonNetworkError do
          LErrorMsg := MSG_NETWORK_ERROR;
        on E: Exception do
          LErrorMsg := E.Message;
      end;

      TThread.Synchronize(nil, TThreadProcedure(
        procedure
        begin
          if (LMovePoolRequestId <> FActiveMovePoolRequest) or
            (FStatsPanel.ActiveTab <> stMoves) then
            Exit;

          if not LErrorMsg.IsEmpty then
          begin
            FStatsPanel.SetMovesLoading(False);
            MessageDlg(LErrorMsg, mtError, [mbOK], 0);
            Exit;
          end;

          FStatsPanel.LoadMovePool(LSections);
        end));
    end).Start;
end;

procedure TPokedexView.StatsPanelInteracted(Sender: TObject);
begin
  HideHistoryPanel;
end;

procedure TPokedexView.SetLoading(const AValue: Boolean);
begin
  if FIsLoading = AValue then
    Exit;
  FIsLoading := AValue;
  if Assigned(FSearchIcon) then
    FSearchIcon.Visible := not AValue;
  FLoadingTimer.Enabled := AValue;
  if not AValue then
    FLoadingTick := 0;
  FSearchBg.Redraw;
  FSpritePaintBox.Redraw;
end;

procedure TPokedexView.LoadingTimerTick(Sender: TObject);
begin
  Inc(FLoadingTick);
  FSearchBg.Redraw;
  FSpritePaintBox.Redraw;
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

procedure TPokedexView.ReloadSprite;
begin
  PerformSearch(FCurrentId.ToString);
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
  I, LNextLeft: Integer;
  LBadge: TControl;
begin
  ClearTypeBadges;
  if Length(APokemon.Types) > 0 then
  begin
    fpTypes.AutoWrap := False;
    fpTypes.FlowStyle := TFlowStyle.fsLeftRightTopBottom;
    fpTypes.Width := pnlImage.Width;
    LNextLeft := 0;

    for I := 0 to Length(APokemon.Types) - 1 do
    begin
      CreateTypeBadge(APokemon.Types[I].&Type.Name);
      LBadge := fpTypes.Controls[fpTypes.ControlCount - 1];
      LBadge.Left := LNextLeft;
      LBadge.Top := 0;
      LNextLeft := LNextLeft + LBadge.Width + 6;
    end;
    PositionTypeContainer;
  end;
end;

procedure TPokedexView.ClearTypeBadges;
begin
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
  LContainer.Width := Max(48, Length(UpperCase(ATypeName)) * 7 + 22);
  LContainer.Height := 22;
  LContainer.BevelOuter := bvNone;
  LContainer.ParentBackground := True;
  LContainer.Margins.Right := 6;
  LBackground := TShape.Create(Self);
  LBackground.Parent := LContainer;
  LBackground.Align := alClient;
  LBackground.Shape := stRoundRect;
  LBackground.Brush.Color := TPokemonController.GetTypeColor(ATypeName);
  LBackground.Pen.Color := clBlack;
  LBackground.Enabled := False;
  LBadge := TSkLabel.Create(Self);
  LBadge.Parent := LContainer;
  LBadge.Align := alClient;
  LBadge.TextSettings.HorzAlign := TSkTextHorzAlign.Center;
  LBadge.TextSettings.VertAlign := TSkTextVertAlign.Center;
  LBadge.Caption := UpperCase(ATypeName);
  LBadge.Cursor := crHandPoint;
  LBadge.OnClick := TypeBadgeClick;
  if LBadge.Words.Count > 0 then
  begin
    LBadge.Words[0].Font.Size := 9;
    LBadge.Words[0].Font.Weight := TSkFontComponent.TSkFontWeight.Bold;
    LBadge.Words[0].FontColor := TAlphaColors.White;
    LBadge.Words[0].Font.Families := FONT_FAMILY;
  end;
end;

procedure TPokedexView.TypeBadgeClick(Sender: TObject);
begin
  HideHistoryPanel;
  if Sender is TSkLabel then
    PerformSearch(TSkLabel(Sender).Caption.ToLower);
end;

procedure TPokedexView.PositionTypeContainer;
var
  LTotalWidth, I: Integer;
begin
  LTotalWidth := 0;
  for I := 0 to fpTypes.ControlCount - 1 do
  begin
    Inc(LTotalWidth, fpTypes.Controls[I].Width + 6);
    fpTypes.Controls[I].Top := 0; // Force all to top line
  end;
  if fpTypes.ControlCount > 0 then
    Dec(LTotalWidth, 6);
  fpTypes.Width := Max(1, LTotalWidth);
  fpTypes.Left := (pnlImage.Width - fpTypes.Width) div 2;
end;

procedure TPokedexView.SearchEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    PerformSearch(FSearchEdit.Text);
  end;
end;

procedure TPokedexView.PlayCry;
var
  LCryId, LGen: Integer;
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
  LGen := FCryGeneration;
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

function TPokedexView.ExtractDominantColor(AStream: TMemoryStream): TColor;
var
  LBytes: TBytes;
  LImage: ISkImage;
  LInfo: TSkImageInfo;
  LPixels: TBytes;
  I, R, G, B, Count: Integer;
begin
  Result := clBlack;
  try
    AStream.Position := 0;
    SetLength(LBytes, AStream.Size);
    AStream.Read(LBytes[0], Length(LBytes));
    LImage := TSkImage.MakeFromEncoded(LBytes);
    if not Assigned(LImage) or (LImage.Width = 0) then
      Exit;
    LInfo := TSkImageInfo.Create(LImage.Width, LImage.Height,
      TSkColorType.RGBA8888, TSkAlphaType.Unpremul);
    SetLength(LPixels, LImage.Width * LImage.Height * 4);
    if not LImage.ReadPixels(LInfo, @LPixels[0], LImage.Width * 4) then
      Exit;
    R := 0;
    G := 0;
    B := 0;
    Count := 0;
    I := 0;
    while I <= Length(LPixels) - 4 do
    begin
      if LPixels[I + 3] > 128 then
      begin
        Inc(R, LPixels[I]);
        Inc(G, LPixels[I + 1]);
        Inc(B, LPixels[I + 2]);
        Inc(Count);
      end;
      Inc(I, 4);
    end;
    if Count > 0 then
      Result := RGB(R div Count, G div Count, B div Count);
  except
    Result := clBlack;
  end;
end;

procedure TPokedexView.SetupHistoryOverlay;
begin
  FHistoryPanel := TPanel.Create(Self);
  FHistoryPanel.Parent := Self;
  FHistoryPanel.BevelOuter := bvNone;
  FHistoryPanel.ParentBackground := False;
  FHistoryPanel.Color := DARK_PANEL_VCL;
  FHistoryPanel.Visible := False;
  FHistoryOverlay := TSkPaintBox.Create(Self);
  FHistoryOverlay.Parent := FHistoryPanel;
  FHistoryOverlay.Align := alClient;
  FHistoryOverlay.OnDraw := DrawHistoryOverlay;
  FHistoryOverlay.OnMouseDown := HistoryOverlayMouseDown;
  FHistoryOverlay.OnMouseMove := HistoryOverlayMouseMove;
end;

end.

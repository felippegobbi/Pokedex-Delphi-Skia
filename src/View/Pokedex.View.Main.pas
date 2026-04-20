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
    FDescLabel: TSkLabel;
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
    FShinyLabel: TSkLabel;
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
    function ExtractDominantColor(AStream: TMemoryStream): TColor;
    procedure CenterSprite;
    procedure CenterSearchBar;
    procedure WMAfterCreate(var Msg: TMessage); message WM_USER + 1;
    procedure FormResize(Sender: TObject);
    procedure RandomIconClick(Sender: TObject);
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
  SetupDescriptionPanel;
  SetupEvolutionPanel;
  BASS_Init(-1, 44100, 0, Handle, nil);
  Randomize;
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
  skImgPokemon.Anchors := [akLeft, akTop];

  // Re-parent buttons out of skImgPokemon (was clipping btnNext at X=297 in a 200px control)
  btnNext.Parent := pnlImage;
  btnPrev.Parent := pnlImage;

  CenterSprite;

  skImgPokemon.OnMouseDown := ImgPokemonMouseDown;

  btnNext.Visible := False;
  btnPrev.Visible := False;

  FShinyLabel := TSkLabel.Create(Self);
  FShinyLabel.Parent := pnlImage;
  FShinyLabel.AutoSize := False;
  FShinyLabel.SetBounds((pnlImage.Width - 130) div 2,
    pnlImage.Height - 30, 130, 22);
  FShinyLabel.Anchors := [akLeft, akBottom];
  FShinyLabel.TextSettings.HorzAlign := TSkTextHorzAlign.Center;
  FShinyLabel.Caption := #$2605 + '  VER SHINY';
  FShinyLabel.Cursor := crHandPoint;
  FShinyLabel.OnClick := ShinyIconClick;
  FShinyLabel.BringToFront;
  FShinyLabel.Visible := False;
  if FShinyLabel.Words.Count > 0 then
  begin
    FShinyLabel.Words[0].Font.Families := FFontName;
    FShinyLabel.Words[0].Font.Size := 11;
    FShinyLabel.Words[0].Font.Weight := TSkFontComponent.TSkFontWeight.Bold;
    FShinyLabel.Words[0].FontColor := TAlphaColors.White;
  end;
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
  LEditWidth := SEARCH_W - LEditLeft - (ICON_PAD + ICON_SIZE) * 3 - ICON_PAD;

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

procedure TPokedexView.CenterSprite;
var
  LImgX, LImgY, LAvailH: Integer;
begin
  LImgX := (pnlImage.Width - SPRITE_SIZE) div 2;
  LAvailH := pnlImage.Height - 95 - 40; // from below name/types to above VER SHINY
  LImgY := 95 + (LAvailH - SPRITE_SIZE) div 2;

  skImgPokemon.SetBounds(LImgX, LImgY, SPRITE_SIZE, SPRITE_SIZE);

  btnPrev.SetBounds(LImgX - btnPrev.Width,
    LImgY + (SPRITE_SIZE - btnPrev.Height) div 2,
    btnPrev.Width, btnPrev.Height);
  btnNext.SetBounds(LImgX + SPRITE_SIZE,
    LImgY + (SPRITE_SIZE - btnNext.Height) div 2,
    btnNext.Width, btnNext.Height);
  btnPrev.BringToFront;
  btnNext.BringToFront;
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
  CenterSprite;

  if Assigned(FDescLabel) and Assigned(pnlInfo) then
  begin
    FDescLabel.SetBounds(24, pnlInfo.Height - FLAVOR_H - 16, pnlInfo.Width - 48,
      FLAVOR_H);
    FDescLabel.BringToFront;
  end;
end;

procedure TPokedexView.ImgPokemonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LShinyRect: TRect;
begin
  if Button <> mbLeft then
    Exit;

  if FShinyLabel.Visible then
  begin
    LShinyRect := Rect(
      FShinyLabel.Left  - skImgPokemon.Left,
      FShinyLabel.Top   - skImgPokemon.Top,
      FShinyLabel.Left  + FShinyLabel.Width  - skImgPokemon.Left,
      FShinyLabel.Top   + FShinyLabel.Height - skImgPokemon.Top);
    if PtInRect(LShinyRect, Point(X, Y)) then
    begin
      ShinyIconClick(nil);
      Exit;
    end;
  end;

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

  FSearchBg.Redraw;

  if FDisplayNameLabel.Words.Count > 0 then
    FDisplayNameLabel.Words[0].FontColor := FThemeTextColor;

  LAlphaColor := $FF000000 or (DWORD(GetRValue(LEffectiveColor)) shl 16) or
    (DWORD(GetGValue(LEffectiveColor)) shl 8) or
    DWORD(GetBValue(LEffectiveColor));

  FEvolutionPanel.ThemeColor := LAlphaColor;

  // Boost bar color so it always contrasts against the dark stats panel background
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

  if Assigned(FShinyLabel) and FShinyLabel.Visible then
    UpdateShinyIcon;
end;

procedure TPokedexView.SearchIconClick(Sender: TObject);
begin
  PerformSearch(FSearchEdit.Text);
end;

procedure TPokedexView.RandomIconClick(Sender: TObject);
begin
  PerformSearch(TPokemonController.RandomPokemonId.ToString);
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

procedure TPokedexView.UpdateShinyIcon;
begin
  if FShinyLabel.Words.Count > 0 then
  begin
    if FIsShiny then
    begin
      FShinyLabel.Caption := #$2605 + '  VER NORMAL';
      FShinyLabel.Words[0].FontColor := TAlphaColor($FFFFD700);
    end
    else
    begin
      FShinyLabel.Caption := #$2605 + '  VER SHINY';
      FShinyLabel.Words[0].FontColor := FThemeTextColor;
    end;
  end;
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
  LIsShiny: Boolean;
begin
  if FCurrentId = 0 then
    Exit;

  LIsShiny := FIsShiny;
  if LIsShiny and not FCurrentShinySpriteUrl.IsEmpty then
    LUrl := FCurrentShinySpriteUrl
  else
    LUrl := FCurrentSpriteUrl;

  if LUrl.IsEmpty then
    Exit;

  TThread.CreateAnonymousThread(
    procedure
    var
      LStream: TMemoryStream;
      LThemeColor: TColor;
    begin
      LStream := FController.DownloadFile(LUrl);
      if LIsShiny and Assigned(LStream) then
      begin
        LThemeColor := ExtractDominantColor(LStream);
        LStream.Position := 0;
      end
      else
        LThemeColor := FSpeciesColor;

      TThread.Synchronize(nil, TThreadProcedure(
        procedure
        begin
          ApplyTheme(LThemeColor);
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
    R := 0; G := 0; B := 0; Count := 0;
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
      LDominantColor: TColor;
    begin
      LPokemon := nil;
      LStream := nil;
      LErrorMsg := '';
      LDominantColor := 0;
      SetLength(LChain, 0);
      try
        LPokemon := FController.ExecuteGetPokemon(AIdOrName);
        if FIsShiny and not LPokemon.ShinySpriteUrl.IsEmpty then
          LSpriteUrl := LPokemon.ShinySpriteUrl
        else
          LSpriteUrl := LPokemon.SpriteUrl;
        LStream := FController.DownloadFile(LSpriteUrl);
        if FIsShiny and Assigned(LStream) then
        begin
          LDominantColor := ExtractDominantColor(LStream);
          LStream.Position := 0;
        end;
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
            FShinyLabel.Visible := True;
            UpdateShinyIcon;

            if Assigned(LPokemon.SpeciesData) then
            begin
              FSpeciesColor := TPokemonController.GetColorByString(
                LPokemon.SpeciesData.Color.Name);
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
    LText := APokemon.SpeciesData.GetDescription(TPokemonController.GetPreferredLanguage)
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

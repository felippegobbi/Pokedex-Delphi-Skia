unit Pokedex.View.StatsPanel;

interface

uses
  System.SysUtils,
  System.Classes,
  System.UITypes,
  System.Math,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Graphics,
  System.Skia,
  Vcl.Skia,
  System.Types,
  Pokedex.Model.Pokemon,
  Pokedex.Controller.Pokemon;

type
  TPokemonStat = record
    Name: string;
    Value: Integer;
  end;

  TFlavorOptionSelectedEvent = procedure(Sender: TObject;
    AIndex: Integer) of object;
  TAbilitySelectedEvent = procedure(Sender: TObject;
    AIndex: Integer) of object;

  TStatsTab = (stStats, stMoves, stLocations);
  TMoveTab = (mtLevelUp, mtTM, mtEgg);

  TStatsPanel = class(TSkPaintBox)
  private
    FStats: TArray<TPokemonStat>;
    FBarColor: TAlphaColor;
    FWeight: string;
    FHeight: string;
    FGenderRatio: string;
    FEggGroups: string;
    FHatchCounter: string;
    FFontFamily: string;
    FDescription: string;
    FFlavorLabels: TArray<string>;
    FFlavorTexts: TArray<string>;
    FFlavorDropdownRect: TRectF;
    FFlavorOptionRects: TArray<TRectF>;
    FFlavorDropdownOpen: Boolean;
    FFlavorScrollOffset: Integer;
    FSelectedFlavorIdx: Integer;
    FAbilityNames: TArray<string>;
    FAbilityIsHidden: TArray<Boolean>;
    FAbilityUrls: TArray<string>;
    FSelectedAbilityIdx: Integer;
    FAbilityChipRects: TArray<TRectF>;
    FAbilityDescription: string;
    FGeneration: string;
    FHabitat: string;
    FPastTypes: string;
    FDefensiveEffects: TArray<TTypeEffect>;
    FMovePool: TArray<TMovePoolSection>;
    FEncounterSections: TArray<TEncounterSection>;
    FDefenseNote: string;
    FBST: Integer;
    FIsLegendary: Boolean;
    FIsMythical: Boolean;
    FActiveTab: TStatsTab;
    FTabsRect: array[TStatsTab] of TRectF;
    FActiveMoveTab: TMoveTab;
    FMoveTabsRect: array[TMoveTab] of TRectF;
    FMovePage: array[TMoveTab] of Integer;
    FMovePageRects: TArray<TRectF>;
    FMovesLoaded: Boolean;
    FMovesLoading: Boolean;
    FLocationsLoaded: Boolean;
    FLocationsLoading: Boolean;
    FLocationsPage: Integer;
    FLocationPageRects: TArray<TRectF>;
    FStatsScrollOffset: Integer;
    FStatsContentHeight: Integer;
    FStatsContentRect: TRectF;
    FOnMovesTabRequested: TNotifyEvent;
    FOnLocationsTabRequested: TNotifyEvent;
    FOnInteract: TNotifyEvent;
    FOnFlavorOptionSelected: TFlavorOptionSelectedEvent;
    FOnAbilitySelected: TAbilitySelectedEvent;
    procedure DrawStats(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure HandleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HandleMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    function AbbreviateStat(const AName: string): string;
    function MakeParagraph(const AText: string; AFontSize: Single;
      AColor: TAlphaColor; ABold, AItalic: Boolean;
      AAlign: TSkTextAlign = TSkTextAlign.Left;
      AMaxLines: Integer = 1): ISkParagraph;
    procedure DrawTabs(const ACanvas: ISkCanvas; const APanelRect: TRectF);
    procedure DrawMoveTabs(const ACanvas: ISkCanvas; const APanelRect: TRectF);
    procedure DrawStatsTab(const ACanvas: ISkCanvas; const APanelRect: TRectF);
    procedure DrawMovesTab(const ACanvas: ISkCanvas; const APanelRect: TRectF);
    procedure DrawLocationsTab(const ACanvas: ISkCanvas;
      const APanelRect: TRectF);
    function GetMoveSectionIndex(ATab: TMoveTab): Integer;
    class function ToAlphaColor(const AColor: TColor): TAlphaColor; static;
    function GetMoveTypeColor(const ASection: TMovePoolSection;
      const AIndex: Integer): TAlphaColor;
    function SplitLevelMove(const AMoveText: string; out ALevelLabel,
      AMoveName: string): Boolean;
    function GetAbilityUrl(AIndex: Integer): string;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadStats(const AStats: TArray<TPokemonStat>);
    procedure LoadInfo(const AWeight, AHeight: string);
    procedure LoadBreeding(const AGenderRatio, AEggGroups,
      AHatchCounter: string);
    procedure LoadDescription(const AText: string);
    procedure LoadFlavorOptions(const ALabels, ATexts: TArray<string>;
      const ASelectedText: string);
    procedure SetFlavorDescription(const AText: string);
    procedure LoadAbilities(const ANames: TArray<string>;
      const AIsHidden: TArray<Boolean>; const AUrls: TArray<string>;
      ASelectedIdx: Integer);
    procedure LoadAbilityDescription(const AText: string);
    procedure LoadSpeciesExtra(const AGeneration, AHabitat,
      APastTypes: string);
    procedure LoadSpeciesFlags(const AIsLegendary, AIsMythical: Boolean);
    procedure LoadEffects(const ADefensiveEffects: TArray<TTypeEffect>;
      const ADefenseNote: string = '');
    procedure ResetMovePool;
    procedure LoadMovePool(const ASections: TArray<TMovePoolSection>);
    procedure SetMovesLoading(const AValue: Boolean);
    procedure ResetLocations;
    procedure LoadLocations(const ASections: TArray<TEncounterSection>);
    procedure SetLocationsLoading(const AValue: Boolean);
    property ActiveTab: TStatsTab read FActiveTab;
    property BarColor: TAlphaColor read FBarColor write FBarColor;
    property FontFamily: string read FFontFamily write FFontFamily;
    property OnMovesTabRequested: TNotifyEvent read FOnMovesTabRequested
      write FOnMovesTabRequested;
    property OnLocationsTabRequested: TNotifyEvent read FOnLocationsTabRequested
      write FOnLocationsTabRequested;
    property OnInteract: TNotifyEvent read FOnInteract write FOnInteract;
    property OnFlavorOptionSelected: TFlavorOptionSelectedEvent
      read FOnFlavorOptionSelected write FOnFlavorOptionSelected;
    property OnAbilitySelected: TAbilitySelectedEvent
      read FOnAbilitySelected write FOnAbilitySelected;
    property AbilityUrl[AIndex: Integer]: string read GetAbilityUrl;
  end;

implementation

const
  MULT_LABELS: array[0..4] of string = ('4X', '2X', '1/2', '1/4', '0X');
  MULT_VALUES: array[0..4] of Single = (4.0, 2.0, 0.5, 0.25, 0.0);
const
  MAX_STAT = 180;
  PANEL_PAD = 12;
  PANEL_TOP_PAD = 7;
  ROW_H = 26;
  BAR_H = 8;
  BAR_R = 4.0;
  LABEL_W = 52;
  VAL_W = 32;
  TAB_H = 34;
  TAB_GAP = 10;
  DARK_BG: TAlphaColor = $FF2A2A2A;
  STATS_FONT_SIZE = 9.5;
  RANGE50_W = 54;
  RANGE100_W = 62;
  RANGE_GAP = 5;
  FLAVOR_OPTION_H = 22;
  FLAVOR_MAX_VISIBLE = 6;
  LOCATIONS_PER_PAGE = 8;

constructor TStatsPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBarColor := $FFE25D27;
  FFontFamily := '';
  FGenderRatio := '';
  FEggGroups := '';
  FHatchCounter := '';
  FDescription := '';
  SetLength(FFlavorLabels, 0);
  SetLength(FFlavorTexts, 0);
  SetLength(FFlavorOptionRects, 0);
  FFlavorDropdownRect := TRectF.Empty;
  FFlavorDropdownOpen := False;
  FFlavorScrollOffset := 0;
  FSelectedFlavorIdx := -1;
  SetLength(FAbilityNames, 0);
  SetLength(FAbilityIsHidden, 0);
  SetLength(FAbilityUrls, 0);
  SetLength(FAbilityChipRects, 0);
  FSelectedAbilityIdx := 0;
  FAbilityDescription := '';
  FGeneration := '';
  FHabitat := '';
  FPastTypes := '';
  FDefenseNote := '';
  FIsLegendary := False;
  FIsMythical := False;
  FActiveTab := stStats;
  FActiveMoveTab := mtLevelUp;
  FMovePage[mtLevelUp] := 0;
  FMovePage[mtTM] := 0;
  FMovePage[mtEgg] := 0;
  SetLength(FMovePageRects, 0);
  FMovesLoaded := False;
  FMovesLoading := False;
  FStatsScrollOffset := 0;
  FStatsContentHeight := 0;
  FStatsContentRect := TRectF.Empty;
  SetLength(FStats, 0);
  SetLength(FDefensiveEffects, 0);
  SetLength(FMovePool, 0);
  SetLength(FEncounterSections, 0);
  OnDraw := DrawStats;
  OnMouseDown := HandleMouseDown;
  OnMouseWheel := HandleMouseWheel;
  Cursor := crDefault;
end;

procedure TStatsPanel.LoadStats(const AStats: TArray<TPokemonStat>);
var
  I: Integer;
begin
  FStats := AStats;
  FBST := 0;
  for I := 0 to High(AStats) do
    Inc(FBST, AStats[I].Value);
  FActiveTab := stStats;
  FStatsScrollOffset := 0;
  Redraw;
end;

procedure TStatsPanel.LoadInfo(const AWeight, AHeight: string);
begin
  FWeight := AWeight;
  FHeight := AHeight;
  Redraw;
end;

procedure TStatsPanel.LoadBreeding(const AGenderRatio, AEggGroups,
  AHatchCounter: string);
begin
  FGenderRatio := AGenderRatio;
  FEggGroups := AEggGroups;
  FHatchCounter := AHatchCounter;
  Redraw;
end;

procedure TStatsPanel.LoadDescription(const AText: string);
begin
  SetLength(FFlavorLabels, 0);
  SetLength(FFlavorTexts, 0);
  SetLength(FFlavorOptionRects, 0);
  FFlavorDropdownRect := TRectF.Empty;
  FFlavorDropdownOpen := False;
  FFlavorScrollOffset := 0;
  FSelectedFlavorIdx := -1;
  FDescription := AText;
  Redraw;
end;

procedure TStatsPanel.LoadFlavorOptions(const ALabels, ATexts: TArray<string>;
  const ASelectedText: string);
begin
  FFlavorLabels := ALabels;
  FFlavorTexts := ATexts;
  SetLength(FFlavorOptionRects, Length(ALabels));
  FFlavorDropdownRect := TRectF.Empty;
  FFlavorDropdownOpen := False;
  FFlavorScrollOffset := 0;
  if Length(ATexts) > 0 then
  begin
    FSelectedFlavorIdx := High(ATexts);
    FDescription := ASelectedText;
  end
  else
  begin
    FSelectedFlavorIdx := -1;
    FDescription := '';
  end;
  Redraw;
end;

procedure TStatsPanel.SetFlavorDescription(const AText: string);
begin
  FDescription := AText;
  Redraw;
end;

procedure TStatsPanel.LoadAbilities(const ANames: TArray<string>;
  const AIsHidden: TArray<Boolean>; const AUrls: TArray<string>;
  ASelectedIdx: Integer);
begin
  FAbilityNames := ANames;
  FAbilityIsHidden := AIsHidden;
  FAbilityUrls := AUrls;
  FSelectedAbilityIdx := ASelectedIdx;
  SetLength(FAbilityChipRects, Length(ANames));
  Redraw;
end;

procedure TStatsPanel.LoadAbilityDescription(const AText: string);
begin
  FAbilityDescription := AText;
  Redraw;
end;

procedure TStatsPanel.LoadSpeciesExtra(const AGeneration, AHabitat,
  APastTypes: string);
begin
  FGeneration := AGeneration;
  FHabitat := AHabitat;
  FPastTypes := APastTypes;
  Redraw;
end;

procedure TStatsPanel.LoadSpeciesFlags(const AIsLegendary, AIsMythical: Boolean);
begin
  FIsLegendary := AIsLegendary;
  FIsMythical := AIsMythical;
  Redraw;
end;

procedure TStatsPanel.LoadEffects(const ADefensiveEffects: TArray<TTypeEffect>;
  const ADefenseNote: string);
begin
  FDefensiveEffects := ADefensiveEffects;
  FDefenseNote := ADefenseNote;
  Redraw;
end;

procedure TStatsPanel.ResetMovePool;
begin
  SetLength(FMovePool, 0);
  FActiveMoveTab := mtLevelUp;
  FMovePage[mtLevelUp] := 0;
  FMovePage[mtTM] := 0;
  FMovePage[mtEgg] := 0;
  SetLength(FMovePageRects, 0);
  FMovesLoaded := False;
  FMovesLoading := False;
  FLocationsLoaded := False;
  FLocationsLoading := False;
  Redraw;
end;

procedure TStatsPanel.LoadMovePool(const ASections: TArray<TMovePoolSection>);
begin
  FMovePool := ASections;
  FMovePage[mtLevelUp] := 0;
  FMovePage[mtTM] := 0;
  FMovePage[mtEgg] := 0;
  SetLength(FMovePageRects, 0);
  if GetMoveSectionIndex(mtLevelUp) >= 0 then
    FActiveMoveTab := mtLevelUp
  else if GetMoveSectionIndex(mtTM) >= 0 then
    FActiveMoveTab := mtTM
  else if GetMoveSectionIndex(mtEgg) >= 0 then
    FActiveMoveTab := mtEgg;
  FMovesLoaded := True;
  FMovesLoading := False;
  Redraw;
end;

procedure TStatsPanel.SetMovesLoading(const AValue: Boolean);
begin
  FMovesLoading := AValue;
  if AValue then
    FMovesLoaded := False;
  Redraw;
end;

procedure TStatsPanel.ResetLocations;
begin
  SetLength(FEncounterSections, 0);
  SetLength(FLocationPageRects, 0);
  FLocationsPage := 0;
  FLocationsLoaded := False;
  FLocationsLoading := False;
  Redraw;
end;

procedure TStatsPanel.LoadLocations(const ASections: TArray<TEncounterSection>);
begin
  FEncounterSections := ASections;
  FLocationsLoaded := True;
  FLocationsLoading := False;
  Redraw;
end;

procedure TStatsPanel.SetLocationsLoading(const AValue: Boolean);
begin
  FLocationsLoading := AValue;
  if AValue then
    FLocationsLoaded := False;
  Redraw;
end;

function TStatsPanel.MakeParagraph(const AText: string; AFontSize: Single;
  AColor: TAlphaColor; ABold, AItalic: Boolean; AAlign: TSkTextAlign;
  AMaxLines: Integer): ISkParagraph;
var
  LParaStyle: ISkParagraphStyle;
  LTextStyle: ISkTextStyle;
  LBuilder: ISkParagraphBuilder;
begin
  LParaStyle := TSkParagraphStyle.Create;
  LParaStyle.MaxLines := AMaxLines;
  LParaStyle.TextAlign := AAlign;
  LParaStyle.Ellipsis := '...';

  LTextStyle := TSkTextStyle.Create;
  if FFontFamily <> '' then
    LTextStyle.FontFamilies := [FFontFamily, 'Segoe UI']
  else
    LTextStyle.FontFamilies := ['Segoe UI'];
  LTextStyle.FontSize := AFontSize;
  LTextStyle.Color := AColor;
  LTextStyle.FontStyle := TSkFontStyle.Bold;

  LBuilder := TSkParagraphBuilder.Create(LParaStyle);
  LBuilder.PushStyle(LTextStyle);
  if AText.IsEmpty then
    LBuilder.AddText(' ')
  else
    LBuilder.AddText(AText);
  LBuilder.Pop;
  Result := LBuilder.Build;
end;

function TStatsPanel.AbbreviateStat(const AName: string): string;
begin
  if AName = 'hp' then Result := 'HP'
  else if AName = 'attack' then Result := 'ATK'
  else if AName = 'defense' then Result := 'DEF'
  else if AName = 'special-attack' then Result := 'SP.ATK'
  else if AName = 'special-defense' then Result := 'SP.DEF'
  else if AName = 'speed' then Result := 'SPD'
  else Result := UpperCase(AName);
end;

function TStatsPanel.GetMoveSectionIndex(ATab: TMoveTab): Integer;
var
  I: Integer;
  LTitle: string;
begin
  case ATab of
    mtLevelUp: LTitle := 'LEVEL-UP';
    mtTM: LTitle := 'TM';
  else
    LTitle := 'EGG';
  end;

  for I := 0 to High(FMovePool) do
    if SameText(FMovePool[I].Title, LTitle) then
      Exit(I);
  Result := -1;
end;

class function TStatsPanel.ToAlphaColor(const AColor: TColor): TAlphaColor;
begin
  Result := $FF000000 or (DWORD(GetRValue(AColor)) shl 16) or
    (DWORD(GetGValue(AColor)) shl 8) or DWORD(GetBValue(AColor));
end;

function TStatsPanel.GetMoveTypeColor(const ASection: TMovePoolSection;
  const AIndex: Integer): TAlphaColor;
begin
  Result := $1CFFFFFF;
  if (AIndex < 0) or (AIndex > High(ASection.Types)) then
    Exit;
  if ASection.Types[AIndex].IsEmpty then
    Exit;
  Result := ToAlphaColor(TPokemonController.GetTypeColor(ASection.Types[AIndex]));
end;

function TStatsPanel.SplitLevelMove(const AMoveText: string; out ALevelLabel,
  AMoveName: string): Boolean;
var
  LSepPos: Integer;
begin
  Result := False;
  ALevelLabel := '';
  AMoveName := AMoveText;
  LSepPos := Pos(' ', AMoveText);
  if LSepPos <= 0 then
    Exit;
  ALevelLabel := UpperCase(Copy(AMoveText, 1, LSepPos - 1));
  AMoveName := Trim(Copy(AMoveText, LSepPos + 1, MaxInt));
  Result := ALevelLabel.StartsWith('LV.');
end;

function TStatsPanel.GetAbilityUrl(AIndex: Integer): string;
begin
  if (AIndex >= 0) and (AIndex <= High(FAbilityUrls)) then
    Result := FAbilityUrls[AIndex]
  else
    Result := '';
end;

procedure TStatsPanel.DrawTabs(const ACanvas: ISkCanvas; const APanelRect: TRectF);
var
  LPaint: ISkPaint;
  LTabWidth: Single;
  LTabText: string;
  LTab: TStatsTab;
  LP: ISkParagraph;
begin
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LTabWidth := (APanelRect.Width - TAB_GAP * 2) / 3;

  FTabsRect[stStats] := TRectF.Create(APanelRect.Left, APanelRect.Top,
    APanelRect.Left + LTabWidth, APanelRect.Top + TAB_H);
  FTabsRect[stMoves] := TRectF.Create(FTabsRect[stStats].Right + TAB_GAP,
    APanelRect.Top, FTabsRect[stStats].Right + TAB_GAP + LTabWidth,
    APanelRect.Top + TAB_H);
  FTabsRect[stLocations] := TRectF.Create(FTabsRect[stMoves].Right + TAB_GAP,
    APanelRect.Top, APanelRect.Right, APanelRect.Top + TAB_H);

  for LTab := Low(TStatsTab) to High(TStatsTab) do
  begin
    if LTab = stStats then
      LTabText := 'STATS'
    else if LTab = stMoves then
      LTabText := 'ATAQUES'
    else
      LTabText := 'LOCAIS';

    LPaint.Style := TSkPaintStyle.Fill;
    if LTab = FActiveTab then
      LPaint.Color := $24FFFFFF
    else
      LPaint.Color := $10FFFFFF;
    ACanvas.DrawRoundRect(FTabsRect[LTab], 10, 10, LPaint);

    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 1;
    if LTab = FActiveTab then
      LPaint.Color := FBarColor
    else
      LPaint.Color := $33FFFFFF;
    ACanvas.DrawRoundRect(FTabsRect[LTab], 10, 10, LPaint);

    if LTab = FActiveTab then
      LP := MakeParagraph(LTabText, STATS_FONT_SIZE, FBarColor, True, False,
        TSkTextAlign.Center, 1)
    else
      LP := MakeParagraph(LTabText, STATS_FONT_SIZE, $88FFFFFF, True, False,
        TSkTextAlign.Center, 1);
    LP.Layout(FTabsRect[LTab].Width);
    LP.Paint(ACanvas, FTabsRect[LTab].Left,
      FTabsRect[LTab].Top + (TAB_H - LP.Height) / 2);
  end;
end;

procedure TStatsPanel.DrawMoveTabs(const ACanvas: ISkCanvas;
  const APanelRect: TRectF);
const
  MOVE_TAB_LABELS: array[TMoveTab] of string = ('LEVEL', 'TM', 'EGG');
var
  LPaint: ISkPaint;
  LTabWidth: Single;
  LTab: TMoveTab;
  LP: ISkParagraph;
  LEnabled: Boolean;
begin
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LTabWidth := (APanelRect.Width - TAB_GAP * 2) / 3;

  for LTab := Low(TMoveTab) to High(TMoveTab) do
    FMoveTabsRect[LTab] := TRectF.Create(APanelRect.Left +
      (Ord(LTab) * (LTabWidth + TAB_GAP)), APanelRect.Top,
      APanelRect.Left + (Ord(LTab) * (LTabWidth + TAB_GAP)) + LTabWidth,
      APanelRect.Top + 28);

  for LTab := Low(TMoveTab) to High(TMoveTab) do
  begin
    LEnabled := GetMoveSectionIndex(LTab) >= 0;
    LPaint.Style := TSkPaintStyle.Fill;
    if LTab = FActiveMoveTab then
      LPaint.Color := $20FFFFFF
    else
      LPaint.Color := $0CFFFFFF;
    ACanvas.DrawRoundRect(FMoveTabsRect[LTab], 8, 8, LPaint);

    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 1;
    if not LEnabled then
      LPaint.Color := $22FFFFFF
    else if LTab = FActiveMoveTab then
      LPaint.Color := FBarColor
    else
      LPaint.Color := $33FFFFFF;
    ACanvas.DrawRoundRect(FMoveTabsRect[LTab], 8, 8, LPaint);

    if not LEnabled then
      LP := MakeParagraph(MOVE_TAB_LABELS[LTab], STATS_FONT_SIZE, $55FFFFFF,
        True, False, TSkTextAlign.Center, 1)
    else if LTab = FActiveMoveTab then
      LP := MakeParagraph(MOVE_TAB_LABELS[LTab], STATS_FONT_SIZE, FBarColor,
        True, False, TSkTextAlign.Center, 1)
    else
      LP := MakeParagraph(MOVE_TAB_LABELS[LTab], STATS_FONT_SIZE, $88FFFFFF,
        True, False, TSkTextAlign.Center, 1);
    LP.Layout(FMoveTabsRect[LTab].Width);
    LP.Paint(ACanvas, FMoveTabsRect[LTab].Left,
      FMoveTabsRect[LTab].Top + (FMoveTabsRect[LTab].Height - LP.Height) / 2);
  end;
end;

procedure TStatsPanel.DrawStatsTab(const ACanvas: ISkCanvas;
  const APanelRect: TRectF);
var
  LCount, I, J, LRowCount, LRowEnd, LBadgeIdx, LEffectCol,
    LEffectColCount,
    LVisibleFlavorCount, LFlavorIdx, LFlavorMaxOffset: Integer;
  LBarBg, LBarFill, LBadgeRect, LDropdownListRect,
    LScrollTrackRect, LScrollThumbRect: TRectF;
  LPaint: ISkPaint;
  LStat: TPokemonStat;
  LEffect: TTypeEffect;
  LBarLeft, LBarRight, LBarTop, LRowTop, LFillX: Single;
  LY, LLayoutW, LX, LBadgeW, LBadgeMidY, LThumbHeight, LThumbTop: Single;
  LRowTotalW, LThisW: Single;
  LEffectColW, LEffectColGap, LEffectGroupLeft, LEffectGroupY,
    LEffectRowTop, LEffectGroupH, LEffectMaxGroupH, LDrawBadgeW: Single;
  LTColor: TColor;
  LBadgeLabels: TArray<string>;
  LBadgeWidths: TArray<Single>;
  LBadgeColors: TArray<TAlphaColor>;
  LChipWidths: TArray<Single>;
  LP: ISkParagraph;
  LSectionTitle: string;
  LChipIdx: Integer;
begin
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LCount := Length(FStats);
  if LCount = 0 then
    Exit;

  ACanvas.Save;
  ACanvas.ClipRect(APanelRect);
  LLayoutW := APanelRect.Width - 40;
  LY := APanelRect.Top - FStatsScrollOffset;
  LBarLeft := APanelRect.Left + LABEL_W + 8;
  LBarRight := APanelRect.Right - VAL_W - 6;

  for I := 0 to LCount - 1 do
  begin
    LStat := FStats[I];
    LRowTop := LY + I * ROW_H;
    LBarTop := LRowTop + (ROW_H - BAR_H) / 2;

    LP := MakeParagraph(AbbreviateStat(LStat.Name), STATS_FONT_SIZE, $88FFFFFF,
      True, False, TSkTextAlign.Left, 1);
    LP.Layout(LABEL_W);
    LP.Paint(ACanvas, APanelRect.Left, LRowTop + (ROW_H - LP.Height) / 2);

    LBarBg := TRectF.Create(LBarLeft, LBarTop, LBarRight, LBarTop + BAR_H);
    LPaint.Style := TSkPaintStyle.Fill;
    LPaint.Color := $33FFFFFF;
    ACanvas.DrawRoundRect(LBarBg, BAR_R, BAR_R, LPaint);

    LFillX := LBarLeft + (LBarRight - LBarLeft) * Min(1.0, LStat.Value / MAX_STAT);
    if LFillX > LBarLeft then
    begin
      LBarFill := TRectF.Create(LBarLeft, LBarTop, LFillX, LBarTop + BAR_H);
      LPaint.Color := FBarColor;
      ACanvas.DrawRoundRect(LBarFill, BAR_R, BAR_R, LPaint);
    end;

    LP := MakeParagraph(LStat.Value.ToString, STATS_FONT_SIZE, $FFFFFFFF,
      True, False, TSkTextAlign.Right, 1);
    LP.Layout(VAL_W);
    LP.Paint(ACanvas, APanelRect.Right - VAL_W, LRowTop + (ROW_H - LP.Height) / 2);
  end;

  LRowTop := LY + LCount * ROW_H + 4;
  LP := MakeParagraph('TOTAL', STATS_FONT_SIZE, $55FFFFFF, True, False,
    TSkTextAlign.Left, 1);
  LP.Layout(LABEL_W);
  LP.Paint(ACanvas, APanelRect.Left, LRowTop + (ROW_H - LP.Height) / 2);
  LP := MakeParagraph(FBST.ToString, STATS_FONT_SIZE, FBarColor, True, False,
    TSkTextAlign.Right, 1);
  LP.Layout(VAL_W + 4);
  LP.Paint(ACanvas, APanelRect.Right - VAL_W - 4, LRowTop + (ROW_H - LP.Height) / 2);
  // BST visual bar (normalized to 780 — Mega Mewtwo Y ceiling)
  LBarTop := LRowTop + (ROW_H - BAR_H) / 2;
  LBarBg := TRectF.Create(LBarLeft, LBarTop, LBarRight, LBarTop + BAR_H);
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := $22FFFFFF;
  ACanvas.DrawRoundRect(LBarBg, BAR_R, BAR_R, LPaint);
  LFillX := LBarLeft + (LBarRight - LBarLeft) * Min(1.0, FBST / 780.0);
  if LFillX > LBarLeft then
  begin
    LBarFill := TRectF.Create(LBarLeft, LBarTop, LFillX, LBarTop + BAR_H);
    LPaint.Color := FBarColor and $99FFFFFF;
    ACanvas.DrawRoundRect(LBarFill, BAR_R, BAR_R, LPaint);
  end;

  LY := LY + LCount * ROW_H + 24;

  LP := MakeParagraph('PESO', STATS_FONT_SIZE, $88FFFFFF, True, False,
    TSkTextAlign.Left, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, APanelRect.Left + 20, LY);
  LP := MakeParagraph('ALTURA', STATS_FONT_SIZE, $88FFFFFF, True, False,
    TSkTextAlign.Center, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, APanelRect.Left + 20, LY);
  LP := MakeParagraph('GERAÇÃO', STATS_FONT_SIZE, $88FFFFFF, True, False,
    TSkTextAlign.Right, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, APanelRect.Left + 20, LY);

  LY := LY + 16;
  LP := MakeParagraph(FWeight, STATS_FONT_SIZE, $FFFFFFFF, True, False,
    TSkTextAlign.Left, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, APanelRect.Left + 20, LY);
  LP := MakeParagraph(FHeight, STATS_FONT_SIZE, $FFFFFFFF, True, False,
    TSkTextAlign.Center, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, APanelRect.Left + 20, LY);
  LP := MakeParagraph(FGeneration, STATS_FONT_SIZE, $FFFFFFFF, True, False,
    TSkTextAlign.Right, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, APanelRect.Left + 20, LY);

  LY := LY + 16;

  if FIsLegendary or FIsMythical then
  begin
    var LBadgeText: string;
    var LBadgeColor: TAlphaColor;
    if FIsMythical then
    begin
      LBadgeText := 'MÍTICO';
      LBadgeColor := $FFCC55FF;
    end
    else
    begin
      LBadgeText := 'LENDÁRIO';
      LBadgeColor := $FFFFCC00;
    end;
    LP := MakeParagraph(LBadgeText, STATS_FONT_SIZE, LBadgeColor, True, False,
      TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    var LBadgeW2: Single := LP.LongestLine + 20;
    var LBadgeX: Single := APanelRect.Left + (APanelRect.Width - LBadgeW2) / 2;
    var LBadgeRect2: TRectF := TRectF.Create(LBadgeX, LY, LBadgeX + LBadgeW2,
      LY + 18);
    LPaint.Style := TSkPaintStyle.Fill;
    LPaint.Color := LBadgeColor and $25FFFFFF;
    ACanvas.DrawRoundRect(LBadgeRect2, 5, 5, LPaint);
    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 1;
    LPaint.Color := LBadgeColor and $66FFFFFF;
    ACanvas.DrawRoundRect(LBadgeRect2, 5, 5, LPaint);
    LP.Paint(ACanvas, APanelRect.Left, LY + (18 - LP.Height) / 2);
    LY := LY + 24;
  end
  else
    LY := LY + 4;

  if Length(FAbilityNames) > 0 then
  begin
    LP := MakeParagraph('HABILIDADES', STATS_FONT_SIZE, $88FFFFFF, True, False,
      TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY);
    LY := LY + LP.Height + 6;

    // First pass: measure chip widths
    SetLength(LChipWidths, Length(FAbilityNames));
    for I := 0 to High(FAbilityNames) do
    begin
      var LLabel: string := UpperCase(FAbilityNames[I]);
      if (I <= High(FAbilityIsHidden)) and FAbilityIsHidden[I] then
        LLabel := LLabel + ' [H]';
      LP := MakeParagraph(LLabel, STATS_FONT_SIZE, $FFFFFFFF, True, False,
        TSkTextAlign.Left, 1);
      LP.Layout(220);
      LChipWidths[I] := LP.LongestLine + 14;
    end;

    // Second pass: draw rows centered
    LChipIdx := 0;
    while LChipIdx <= High(FAbilityNames) do
    begin
      LRowTotalW := 0;
      LRowCount := 0;
      J := LChipIdx;
      while J <= High(FAbilityNames) do
      begin
        LThisW := LChipWidths[J];
        if LRowCount > 0 then
          LThisW := LThisW + 6;
        if (LRowTotalW + LThisW > APanelRect.Width) and (LRowCount > 0) then
          Break;
        LRowTotalW := LRowTotalW + LThisW;
        Inc(LRowCount);
        Inc(J);
      end;
      if LRowCount = 0 then
        LRowCount := 1;
      LRowEnd := LChipIdx + LRowCount - 1;

      LX := APanelRect.Left + (APanelRect.Width - LRowTotalW) / 2;
      if LX < APanelRect.Left then
        LX := APanelRect.Left;

      for J := LChipIdx to LRowEnd do
      begin
        if J > LChipIdx then
          LX := LX + 6;
        LBadgeW := LChipWidths[J];
        if J <= High(FAbilityChipRects) then
          FAbilityChipRects[J] := TRectF.Create(LX, LY, LX + LBadgeW, LY + 20);

        var LLabel: string := UpperCase(FAbilityNames[J]);
        if (J <= High(FAbilityIsHidden)) and FAbilityIsHidden[J] then
          LLabel := LLabel + ' [H]';
        LP := MakeParagraph(LLabel, STATS_FONT_SIZE, $FFFFFFFF, True, False,
          TSkTextAlign.Left, 1);
        LP.Layout(Max(20.0, LBadgeW));

        LPaint.Style := TSkPaintStyle.Fill;
        if J = FSelectedAbilityIdx then
          LPaint.Color := FBarColor and $40FFFFFF
        else
          LPaint.Color := $18FFFFFF;
        ACanvas.DrawRoundRect(FAbilityChipRects[J], 5, 5, LPaint);

        LPaint.Style := TSkPaintStyle.Stroke;
        LPaint.StrokeWidth := 1;
        if J = FSelectedAbilityIdx then
          LPaint.Color := FBarColor
        else
          LPaint.Color := $33FFFFFF;
        ACanvas.DrawRoundRect(FAbilityChipRects[J], 5, 5, LPaint);

        LBadgeMidY := (FAbilityChipRects[J].Top + FAbilityChipRects[J].Bottom) / 2;
        LP.Paint(ACanvas, LX + 7, LBadgeMidY - LP.Height / 2);
        LX := LX + LBadgeW;
      end;

      LChipIdx := LRowEnd + 1;
      LY := LY + 26;
    end;
  end;

  if FAbilityDescription <> '' then
  begin
    LP := MakeParagraph(FAbilityDescription, STATS_FONT_SIZE, $99FFFFFF, True,
      False, TSkTextAlign.Center, 3);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY);
    LY := LY + LP.Height + 6;
  end;

  if FHabitat <> '' then
  begin
    LP := MakeParagraph('HABITAT: ' + FHabitat, STATS_FONT_SIZE, $66FFFFFF,
      True, False, TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY);
    LY := LY + LP.Height + 4;
  end;

  if FPastTypes <> '' then
  begin
    LP := MakeParagraph(FPastTypes, STATS_FONT_SIZE, $55FFFFFF,
      True, False, TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY);
    LY := LY + LP.Height + 4;
  end;

  if (FDescription <> '') and
    not ((FGenderRatio <> '') or (FEggGroups <> '') or (FHatchCounter <> '')) then
  begin
    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 1;
    LPaint.Color := $22FFFFFF;
    ACanvas.DrawLine(TPointF.Create(APanelRect.Left + 16, LY),
      TPointF.Create(APanelRect.Right - 16, LY), LPaint);
    LY := LY + 10;
  end;

  if (FGenderRatio <> '') or (FEggGroups <> '') or (FHatchCounter <> '') then
  begin
    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 1;
    LPaint.Color := $22FFFFFF;
    ACanvas.DrawLine(TPointF.Create(APanelRect.Left + 16, LY),
      TPointF.Create(APanelRect.Right - 16, LY), LPaint);
    LY := LY + 10;

    LP := MakeParagraph('BREEDING', STATS_FONT_SIZE, $88FFFFFF, True, False,
      TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY);
    LY := LY + LP.Height + 8;

    LP := MakeParagraph('GÊNERO', STATS_FONT_SIZE, $88FFFFFF, True, False,
      TSkTextAlign.Left, 1);
    LP.Layout(LLayoutW);
    LP.Paint(ACanvas, APanelRect.Left + 20, LY);
    LP := MakeParagraph('GRUPOS DE OVO', STATS_FONT_SIZE, $88FFFFFF, True,
      False, TSkTextAlign.Center, 1);
    LP.Layout(LLayoutW);
    LP.Paint(ACanvas, APanelRect.Left + 20, LY);
    LP := MakeParagraph('PASSOS', STATS_FONT_SIZE, $88FFFFFF, True, False,
      TSkTextAlign.Right, 1);
    LP.Layout(LLayoutW);
    LP.Paint(ACanvas, APanelRect.Left + 20, LY);

    LY := LY + 16;
    LP := MakeParagraph(FGenderRatio, STATS_FONT_SIZE, $FFFFFFFF, True, False,
      TSkTextAlign.Left, 2);
    LP.Layout(LLayoutW);
    LP.Paint(ACanvas, APanelRect.Left + 20, LY);
    LP := MakeParagraph(FEggGroups, STATS_FONT_SIZE, $FFFFFFFF, True, False,
      TSkTextAlign.Center, 2);
    LP.Layout(LLayoutW);
    LP.Paint(ACanvas, APanelRect.Left + 20, LY);
    LP := MakeParagraph(FHatchCounter, STATS_FONT_SIZE, $FFFFFFFF, True, False,
      TSkTextAlign.Right, 2);
    LP.Layout(LLayoutW);
    LP.Paint(ACanvas, APanelRect.Left + 20, LY);
    LY := LY + 26;
  end;

  if FDescription <> '' then
  begin
    if Length(FFlavorLabels) > 1 then
    begin
      FFlavorDropdownRect := TRectF.Create(APanelRect.Left +
        (APanelRect.Width - Min(180, APanelRect.Width)) / 2, LY,
        APanelRect.Left + (APanelRect.Width + Min(180, APanelRect.Width)) / 2,
        LY + 22);
      LPaint.Style := TSkPaintStyle.Fill;
      LPaint.Color := $14FFFFFF;
      ACanvas.DrawRoundRect(FFlavorDropdownRect, 4, 4, LPaint);
      LPaint.Style := TSkPaintStyle.Stroke;
      LPaint.StrokeWidth := 1;
      LPaint.Color := $33FFFFFF;
      ACanvas.DrawRoundRect(FFlavorDropdownRect, 4, 4, LPaint);

      if (FSelectedFlavorIdx >= 0) and (FSelectedFlavorIdx <= High(FFlavorLabels))
      then
        LSectionTitle := UpperCase(FFlavorLabels[FSelectedFlavorIdx])
      else
        LSectionTitle := 'VERSAO';
      LP := MakeParagraph(LSectionTitle, STATS_FONT_SIZE, $FFFFFFFF, True, False,
        TSkTextAlign.Left, 1);
      LP.Layout(FFlavorDropdownRect.Width - 22);
      LBadgeMidY := (FFlavorDropdownRect.Top + FFlavorDropdownRect.Bottom) / 2;
      LP.Paint(ACanvas, FFlavorDropdownRect.Left + 8, LBadgeMidY - LP.Height / 2);

      LP := MakeParagraph('v', STATS_FONT_SIZE, $88FFFFFF, True, False,
        TSkTextAlign.Center, 1);
      LP.Layout(12);
      LP.Paint(ACanvas, FFlavorDropdownRect.Right - 16,
        LBadgeMidY - LP.Height / 2);
      LY := LY + 26;
    end;

    LP := MakeParagraph(FDescription, STATS_FONT_SIZE, $AAFFFFFF, True, False,
      TSkTextAlign.Center, 4);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY);
    LY := LY + LP.Height + 10;
  end;

  if Length(FDefensiveEffects) > 0 then
  begin
    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 1;
    LPaint.Color := $22FFFFFF;
    ACanvas.DrawLine(TPointF.Create(APanelRect.Left + 16, LY),
      TPointF.Create(APanelRect.Right - 16, LY), LPaint);
    LY := LY + 10;

    LSectionTitle := 'EFETIVIDADE DEFENSIVA';
    if not FDefenseNote.IsEmpty then
      LSectionTitle := LSectionTitle + ' (' + FDefenseNote + ')';
    LP := MakeParagraph(LSectionTitle, STATS_FONT_SIZE, $88FFFFFF, True, False,
      TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY);
    LY := LY + LP.Height + 6;

    if APanelRect.Width >= 330 then
      LEffectColCount := 3
    else if APanelRect.Width >= 220 then
      LEffectColCount := 2
    else
      LEffectColCount := 1;
    LEffectColGap := 8;
    LEffectColW := (APanelRect.Width - (LEffectColGap *
      (LEffectColCount - 1))) / LEffectColCount;
    LEffectCol := 0;
    LEffectRowTop := LY;
    LEffectMaxGroupH := 0;

    for I := 0 to High(MULT_LABELS) do
    begin
      SetLength(LBadgeLabels, 0);
      SetLength(LBadgeWidths, 0);
      SetLength(LBadgeColors, 0);
      for LEffect in FDefensiveEffects do
      begin
        if Abs(LEffect.Multiplier - MULT_VALUES[I]) > 0.01 then
          Continue;
        LP := MakeParagraph(UpperCase(LEffect.TypeName), STATS_FONT_SIZE,
          $FFFFFFFF, True, False, TSkTextAlign.Left, 1);
        LP.Layout(220);
        LBadgeW := LP.LongestLine + 12;
        LTColor := TPokemonController.GetTypeColor(LEffect.TypeName);
        SetLength(LBadgeLabels, Length(LBadgeLabels) + 1);
        SetLength(LBadgeWidths, Length(LBadgeWidths) + 1);
        SetLength(LBadgeColors, Length(LBadgeColors) + 1);
        LBadgeLabels[High(LBadgeLabels)] := UpperCase(LEffect.TypeName);
        LBadgeWidths[High(LBadgeWidths)] := LBadgeW;
        LBadgeColors[High(LBadgeColors)] := $FF000000 or
          (DWORD(GetRValue(LTColor)) shl 16) or
          (DWORD(GetGValue(LTColor)) shl 8) or DWORD(GetBValue(LTColor));
      end;
      if Length(LBadgeLabels) = 0 then
        Continue;

      LEffectGroupLeft := APanelRect.Left + (LEffectCol * (LEffectColW +
        LEffectColGap));
      LEffectGroupY := LEffectRowTop;
      LP := MakeParagraph(MULT_LABELS[I], STATS_FONT_SIZE, FBarColor, True,
        False, TSkTextAlign.Center, 1);
      LP.Layout(LEffectColW);
      LP.Paint(ACanvas, LEffectGroupLeft, LEffectGroupY);
      LEffectGroupY := LEffectGroupY + LP.Height + 4;

      LBadgeIdx := 0;
      while LBadgeIdx <= High(LBadgeLabels) do
      begin
        // Measure how many badges fit inside this responsive column.
        LRowTotalW := 0;
        LRowCount := 0;
        J := LBadgeIdx;
        while J <= High(LBadgeLabels) do
        begin
          LThisW := Min(LBadgeWidths[J], LEffectColW);
          if LRowCount > 0 then
            LThisW := LThisW + 4;
          if (LRowTotalW + LThisW > LEffectColW) and (LRowCount > 0) then
            Break;
          LRowTotalW := LRowTotalW + LThisW;
          Inc(LRowCount);
          Inc(J);
        end;
        if LRowCount = 0 then
          LRowCount := 1;
        LRowEnd := LBadgeIdx + LRowCount - 1;

        LX := LEffectGroupLeft + (LEffectColW - LRowTotalW) / 2;
        if LX < LEffectGroupLeft then
          LX := LEffectGroupLeft;
        for J := LBadgeIdx to LRowEnd do
        begin
          if J > LBadgeIdx then
            LX := LX + 4;
          LDrawBadgeW := Min(LBadgeWidths[J], LEffectColW);
          LBadgeRect := TRectF.Create(LX, LEffectGroupY, LX + LDrawBadgeW,
            LEffectGroupY + 16);
          LPaint.Style := TSkPaintStyle.Fill;
          LPaint.Color := LBadgeColors[J];
          ACanvas.DrawRoundRect(LBadgeRect, 4, 4, LPaint);
          LP := MakeParagraph(LBadgeLabels[J], STATS_FONT_SIZE - 0.5, $FFFFFFFF,
            True, False, TSkTextAlign.Center, 1);
          LP.Layout(Max(20.0, LDrawBadgeW));
          LBadgeMidY := (LBadgeRect.Top + LBadgeRect.Bottom) / 2;
          LP.Paint(ACanvas, LX, LBadgeMidY - LP.Height / 2);
          LX := LX + LDrawBadgeW;
        end;

        LBadgeIdx := LBadgeIdx + LRowCount;
        LEffectGroupY := LEffectGroupY + 20;
      end;

      LEffectGroupH := LEffectGroupY - LEffectRowTop;
      if LEffectGroupH > LEffectMaxGroupH then
        LEffectMaxGroupH := LEffectGroupH;

      Inc(LEffectCol);
      if LEffectCol >= LEffectColCount then
      begin
        LEffectCol := 0;
        LEffectRowTop := LEffectRowTop + LEffectMaxGroupH + 8;
        LEffectMaxGroupH := 0;
      end;
    end;

    if LEffectCol = 0 then
      LY := LEffectRowTop
    else
      LY := LEffectRowTop + LEffectMaxGroupH + 2;
  end;

  FStatsContentHeight := Round(LY - APanelRect.Top + FStatsScrollOffset);

  if FFlavorDropdownOpen and (Length(FFlavorLabels) > 1) then
  begin
    for I := 0 to High(FFlavorOptionRects) do
      FFlavorOptionRects[I] := TRectF.Empty;

    LVisibleFlavorCount := Min(FLAVOR_MAX_VISIBLE, Length(FFlavorLabels));
    LFlavorMaxOffset := Max(0, Length(FFlavorLabels) - LVisibleFlavorCount);
    FFlavorScrollOffset := EnsureRange(FFlavorScrollOffset, 0, LFlavorMaxOffset);

    LDropdownListRect := TRectF.Create(FFlavorDropdownRect.Left,
      FFlavorDropdownRect.Bottom + 4, FFlavorDropdownRect.Right,
      FFlavorDropdownRect.Bottom + 8 + (LVisibleFlavorCount * FLAVOR_OPTION_H));

    LPaint.Style := TSkPaintStyle.Fill;
    LPaint.Color := $F0272727;
    ACanvas.DrawRoundRect(LDropdownListRect, 6, 6, LPaint);
    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 1;
    LPaint.Color := $44FFFFFF;
    ACanvas.DrawRoundRect(LDropdownListRect, 6, 6, LPaint);

    for I := 0 to LVisibleFlavorCount - 1 do
    begin
      LFlavorIdx := FFlavorScrollOffset + I;
      FFlavorOptionRects[LFlavorIdx] := TRectF.Create(LDropdownListRect.Left + 4,
        LDropdownListRect.Top + 4 + (I * FLAVOR_OPTION_H),
        LDropdownListRect.Right - 4, LDropdownListRect.Top + 4 +
        ((I + 1) * FLAVOR_OPTION_H));

      LPaint.Style := TSkPaintStyle.Fill;
      if LFlavorIdx = FSelectedFlavorIdx then
        LPaint.Color := $22FFFFFF
      else
        LPaint.Color := $14000000;
      ACanvas.DrawRoundRect(FFlavorOptionRects[LFlavorIdx], 3.5, 3.5, LPaint);

      LPaint.Style := TSkPaintStyle.Stroke;
      LPaint.StrokeWidth := 1;
      if LFlavorIdx = FSelectedFlavorIdx then
        LPaint.Color := FBarColor
      else
        LPaint.Color := $22FFFFFF;
      ACanvas.DrawRoundRect(FFlavorOptionRects[LFlavorIdx], 3.5, 3.5, LPaint);

      LP := MakeParagraph(UpperCase(FFlavorLabels[LFlavorIdx]), STATS_FONT_SIZE,
        $FFFFFFFF, True, False, TSkTextAlign.Left, 1);
      LP.Layout(FFlavorOptionRects[LFlavorIdx].Width - 16);
      LBadgeMidY := (FFlavorOptionRects[LFlavorIdx].Top +
        FFlavorOptionRects[LFlavorIdx].Bottom) / 2;
      LP.Paint(ACanvas, FFlavorOptionRects[LFlavorIdx].Left + 8,
        LBadgeMidY - LP.Height / 2);
    end;

    if LFlavorMaxOffset > 0 then
    begin
      LScrollTrackRect := TRectF.Create(LDropdownListRect.Right - 6,
        LDropdownListRect.Top + 6, LDropdownListRect.Right - 3,
        LDropdownListRect.Bottom - 6);
      LPaint.Style := TSkPaintStyle.Fill;
      LPaint.Color := $22000000;
      ACanvas.DrawRoundRect(LScrollTrackRect, 1.5, 1.5, LPaint);

      LThumbHeight := Max(14.0, LScrollTrackRect.Height *
        (LVisibleFlavorCount / Length(FFlavorLabels)));
      LThumbTop := LScrollTrackRect.Top + ((LScrollTrackRect.Height -
        LThumbHeight) * (FFlavorScrollOffset / LFlavorMaxOffset));
      LScrollThumbRect := TRectF.Create(LScrollTrackRect.Left, LThumbTop,
        LScrollTrackRect.Right, LThumbTop + LThumbHeight);
      LPaint.Color := $77FFFFFF;
      ACanvas.DrawRoundRect(LScrollThumbRect, 1.5, 1.5, LPaint);
    end;
  end;

  ACanvas.Restore;
end;

procedure TStatsPanel.DrawMovesTab(const ACanvas: ISkCanvas;
  const APanelRect: TRectF);
var
  LY, LX, LBadgeW, LBadgeMidY, LRowHeight, LLevelColW, LColumnGap, LColumnW,
    LMoveRectLeft, LMoveRectRight, LPageBtnLeft, LPageBtnTop, LPageBtnW: Single;
  J, LSectionIdx, LRowsPerColumn, LColumns, LColumnIndex, LRowIndex,
    LVisibleMoveCount, LPageCount, LCurrentPage, LStartIndex, LEndIndex,
    LPageIndex, LPageMoveIndex: Integer;
  LPaint: ISkPaint;
  LP: ISkParagraph;
  LBadgeRect, LLevelRect, LMoveRect: TRectF;
  LSection: TMovePoolSection;
  LMoveText, LLevelLabel, LMoveName: string;
  LTypeColor: TAlphaColor;
begin
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LY := APanelRect.Top + 4;

  if FMovesLoading then
  begin
    LP := MakeParagraph('CARREGANDO ATAQUES...', STATS_FONT_SIZE, $88FFFFFF,
      True, False, TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY + 10);
    Exit;
  end;

  if not FMovesLoaded then
  begin
    LP := MakeParagraph('CLIQUE NA ABA PARA CARREGAR O MOVEPOOL.',
      STATS_FONT_SIZE, $88FFFFFF, True, False, TSkTextAlign.Center, 2);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY + 10);
    Exit;
  end;

  if Length(FMovePool) = 0 then
  begin
    LP := MakeParagraph('NENHUM ATAQUE DISPONÍVEL.', STATS_FONT_SIZE,
      $88FFFFFF, True, False, TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY + 10);
    Exit;
  end;

  DrawMoveTabs(ACanvas, TRectF.Create(APanelRect.Left, LY, APanelRect.Right,
    LY + 28));
  LY := LY + 40;

  LSectionIdx := GetMoveSectionIndex(FActiveMoveTab);
  if LSectionIdx < 0 then
  begin
    LP := MakeParagraph('NENHUMA CATEGORIA DISPONÍVEL.', STATS_FONT_SIZE,
      $88FFFFFF, True, False, TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY + 10);
    Exit;
  end;

  LSection := FMovePool[LSectionIdx];

  if (FActiveMoveTab = mtLevelUp) or (FActiveMoveTab = mtTM) or
    (FActiveMoveTab = mtEgg) then
  begin
    if FActiveMoveTab = mtLevelUp then
      LMoveText := 'LISTA POR NIVEL'
    else if FActiveMoveTab = mtTM then
      LMoveText := 'LISTA DE TM'
    else
      LMoveText := 'LISTA DE EGG';

    LP := MakeParagraph(LMoveText, STATS_FONT_SIZE, FBarColor, True,
      False, TSkTextAlign.Left, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY);
    LY := LY + 18;

    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 1;
    LPaint.Color := $22FFFFFF;
    ACanvas.DrawLine(TPointF.Create(APanelRect.Left, LY),
      TPointF.Create(APanelRect.Right, LY), LPaint);
    LY := LY + 10;

    LRowHeight := 24;
    if FActiveMoveTab = mtLevelUp then
      LLevelColW := 56
    else
      LLevelColW := 0;
    LColumnGap := 12;

    if FActiveMoveTab = mtLevelUp then
    begin
      LColumns := 1;
      LRowsPerColumn := Max(1, Trunc((APanelRect.Bottom - LY) / LRowHeight));
      if Length(LSection.Moves) > LRowsPerColumn then
        LColumns := Min(3, Ceil(Length(LSection.Moves) / LRowsPerColumn));
      LRowsPerColumn := Max(1, Ceil(Length(LSection.Moves) / LColumns));
      if LColumns > 1 then
        LColumnW := (APanelRect.Width - (LColumns - 1) * LColumnGap) / LColumns
      else
        LColumnW := APanelRect.Width;
      if LColumnW < 92 then
      begin
        LColumns := Max(1, Min(3, Trunc((APanelRect.Width + LColumnGap) /
          (92 + LColumnGap))));
        LRowsPerColumn := Max(1, Ceil(Length(LSection.Moves) / LColumns));
        if LColumns > 1 then
          LColumnW := (APanelRect.Width - (LColumns - 1) * LColumnGap) / LColumns
        else
          LColumnW := APanelRect.Width;
      end;
      LPageCount := 1;
      SetLength(FMovePageRects, 0);
      LStartIndex := 0;
      LEndIndex := High(LSection.Moves);
    end
    else
    begin
      LColumns := 3;
      LRowsPerColumn := Max(1, Trunc((APanelRect.Bottom - LY - 28) / LRowHeight));
      LColumnW := (APanelRect.Width - (LColumns - 1) * LColumnGap) / LColumns;
      LVisibleMoveCount := LRowsPerColumn * LColumns;
      LPageCount := Max(1, Ceil(Length(LSection.Moves) / LVisibleMoveCount));
      LCurrentPage := EnsureRange(FMovePage[FActiveMoveTab], 0, LPageCount - 1);
      FMovePage[FActiveMoveTab] := LCurrentPage;
      SetLength(FMovePageRects, LPageCount);

      if LPageCount > 1 then
      begin
        LPageBtnW := 26;
        LPageBtnTop := LY;
        LPageBtnLeft := APanelRect.Right - ((LPageBtnW + 6) * LPageCount);
        for LPageIndex := 0 to LPageCount - 1 do
        begin
          FMovePageRects[LPageIndex] := TRectF.Create(LPageBtnLeft +
            LPageIndex * (LPageBtnW + 6), LPageBtnTop,
            LPageBtnLeft + LPageIndex * (LPageBtnW + 6) + LPageBtnW,
            LPageBtnTop + 20);

          LPaint.Style := TSkPaintStyle.Fill;
          if LPageIndex = LCurrentPage then
            LPaint.Color := $20FFFFFF
          else
            LPaint.Color := $0CFFFFFF;
          ACanvas.DrawRoundRect(FMovePageRects[LPageIndex], 4, 4, LPaint);

          LPaint.Style := TSkPaintStyle.Stroke;
          LPaint.StrokeWidth := 1;
          if LPageIndex = LCurrentPage then
            LPaint.Color := FBarColor
          else
            LPaint.Color := $33FFFFFF;
          ACanvas.DrawRoundRect(FMovePageRects[LPageIndex], 4, 4, LPaint);

          LP := MakeParagraph((LPageIndex + 1).ToString, STATS_FONT_SIZE,
            $FFFFFFFF, True, False, TSkTextAlign.Center, 1);
          LP.Layout(FMovePageRects[LPageIndex].Width);
          LP.Paint(ACanvas, FMovePageRects[LPageIndex].Left,
            FMovePageRects[LPageIndex].Top +
            (FMovePageRects[LPageIndex].Height - LP.Height) / 2);
        end;
        LY := LY + 28;
      end;

      LStartIndex := LCurrentPage * LVisibleMoveCount;
      LEndIndex := Min(High(LSection.Moves), LStartIndex + LVisibleMoveCount - 1);
    end;

    for J := LStartIndex to LEndIndex do
    begin
      LMoveText := LSection.Moves[J];
      if FActiveMoveTab = mtLevelUp then
      begin
        if not SplitLevelMove(LMoveText, LLevelLabel, LMoveName) then
        begin
          LLevelLabel := 'MOVE';
          LMoveName := LMoveText;
        end;
      end
      else
      begin
        LLevelLabel := LSection.Title;
        LMoveName := LMoveText;
      end;

      if FActiveMoveTab = mtLevelUp then
        LPageMoveIndex := J
      else
        LPageMoveIndex := J - LStartIndex;

      LColumnIndex := LPageMoveIndex div LRowsPerColumn;
      LRowIndex := LPageMoveIndex mod LRowsPerColumn;
      LX := APanelRect.Left + LColumnIndex * (LColumnW + LColumnGap);

      if FActiveMoveTab = mtLevelUp then
      begin
        LLevelRect := TRectF.Create(LX, LY + (LRowIndex * LRowHeight),
          LX + LLevelColW, LY + (LRowIndex * LRowHeight) + 18);
        LMoveRectLeft := LLevelRect.Right + 6;
        LMoveRectRight := Min(APanelRect.Right, LX + LColumnW);
        LMoveRect := TRectF.Create(LMoveRectLeft, LLevelRect.Top,
          LMoveRectRight, LLevelRect.Bottom);

        LPaint.Style := TSkPaintStyle.Fill;
        LPaint.Color := $14FFFFFF;
        ACanvas.DrawRoundRect(LLevelRect, 3.5, 3.5, LPaint);

        LTypeColor := GetMoveTypeColor(LSection, J);
        if LTypeColor = $1CFFFFFF then
          LPaint.Color := $1CFFFFFF
        else
          LPaint.Color := LTypeColor;
        ACanvas.DrawRoundRect(LMoveRect, 3.5, 3.5, LPaint);

        LP := MakeParagraph(LLevelLabel, STATS_FONT_SIZE, $CCFFFFFF, True,
          False, TSkTextAlign.Center, 1);
        LP.Layout(LLevelRect.Width);
        LP.Paint(ACanvas, LLevelRect.Left,
          LLevelRect.Top + (LLevelRect.Height - LP.Height) / 2);

        LP := MakeParagraph(UpperCase(LMoveName), STATS_FONT_SIZE, $FFFFFFFF,
          True, False, TSkTextAlign.Left, 1);
        LP.Layout(Max(20, LMoveRect.Width - 12));
        LBadgeMidY := (LMoveRect.Top + LMoveRect.Bottom) / 2;
        LP.Paint(ACanvas, LMoveRect.Left + 6, LBadgeMidY - LP.Height / 2);
      end
      else
      begin
        LBadgeRect := TRectF.Create(LX, LY + (LRowIndex * LRowHeight),
          Min(APanelRect.Right, LX + LColumnW),
          LY + (LRowIndex * LRowHeight) + 18);
        LPaint.Style := TSkPaintStyle.Fill;
        LTypeColor := GetMoveTypeColor(LSection, J);
        if LTypeColor = $1CFFFFFF then
          LPaint.Color := $1CFFFFFF
        else
          LPaint.Color := LTypeColor;
        ACanvas.DrawRoundRect(LBadgeRect, 3.5, 3.5, LPaint);

        LBadgeMidY := (LBadgeRect.Top + LBadgeRect.Bottom) / 2;
        LP := MakeParagraph(UpperCase(LMoveName), STATS_FONT_SIZE, $FFFFFFFF,
          True, False, TSkTextAlign.Left, 1);
        LP.Layout(Max(20, LBadgeRect.Width - 12));
        LP.Paint(ACanvas, LBadgeRect.Left + 6, LBadgeMidY - LP.Height / 2);
      end;
    end;
    Exit;
  end;
end;

procedure TStatsPanel.DrawLocationsTab(const ACanvas: ISkCanvas;
  const APanelRect: TRectF);
var
  LY, LX, LPageBtnLeft, LPageBtnTop, LBadgeW, LBadgeMidY: Single;
  I, J, LPageCount, LStartSection, LEndSection,
    LPageIndex, LPageBtnW: Integer;
  LP: ISkParagraph;
  LPaint: ISkPaint;
  LBadgeRect: TRectF;
begin
  LY := APanelRect.Top + 8;

  if FLocationsLoading then
  begin
    LP := MakeParagraph('CARREGANDO LOCALIZACOES...', STATS_FONT_SIZE,
      $88FFFFFF, True, False, TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY + 10);
    Exit;
  end;

  if not FLocationsLoaded then
  begin
    LP := MakeParagraph('CLIQUE NA ABA PARA CARREGAR AS LOCALIZACOES.',
      STATS_FONT_SIZE, $88FFFFFF, True, False, TSkTextAlign.Center, 2);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY + 10);
    Exit;
  end;

  if Length(FEncounterSections) = 0 then
  begin
    LP := MakeParagraph('NENHUMA LOCALIZACAO DISPONIVEL.', STATS_FONT_SIZE,
      $88FFFFFF, True, False, TSkTextAlign.Center, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY + 10);
    Exit;
  end;

  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;

  LPageCount := Max(1, Ceil(Length(FEncounterSections) / LOCATIONS_PER_PAGE));
  FLocationsPage := EnsureRange(FLocationsPage, 0, LPageCount - 1);
  SetLength(FLocationPageRects, LPageCount);

  if LPageCount > 1 then
  begin
    LPageBtnW := 26;
    LPageBtnTop := LY;
    LPageBtnLeft := APanelRect.Right - ((LPageBtnW + 6) * LPageCount);
    for LPageIndex := 0 to LPageCount - 1 do
    begin
      FLocationPageRects[LPageIndex] := TRectF.Create(LPageBtnLeft +
        LPageIndex * (LPageBtnW + 6), LPageBtnTop,
        LPageBtnLeft + LPageIndex * (LPageBtnW + 6) + LPageBtnW,
        LPageBtnTop + 20);

      LPaint.Style := TSkPaintStyle.Fill;
      if LPageIndex = FLocationsPage then
        LPaint.Color := $20FFFFFF
      else
        LPaint.Color := $0CFFFFFF;
      ACanvas.DrawRoundRect(FLocationPageRects[LPageIndex], 4, 4, LPaint);

      LPaint.Style := TSkPaintStyle.Stroke;
      LPaint.StrokeWidth := 1;
      if LPageIndex = FLocationsPage then
        LPaint.Color := FBarColor
      else
        LPaint.Color := $33FFFFFF;
      ACanvas.DrawRoundRect(FLocationPageRects[LPageIndex], 4, 4, LPaint);

      LP := MakeParagraph((LPageIndex + 1).ToString, STATS_FONT_SIZE,
        $FFFFFFFF, True, False, TSkTextAlign.Center, 1);
      LP.Layout(FLocationPageRects[LPageIndex].Width);
      LP.Paint(ACanvas, FLocationPageRects[LPageIndex].Left,
        FLocationPageRects[LPageIndex].Top +
        (FLocationPageRects[LPageIndex].Height - LP.Height) / 2);
    end;
    LY := LY + 28;
  end;

  LStartSection := FLocationsPage * LOCATIONS_PER_PAGE;
  LEndSection := Min(High(FEncounterSections), LStartSection + LOCATIONS_PER_PAGE - 1);

  for I := LStartSection to LEndSection do
  begin
    LP := MakeParagraph(UpperCase(FEncounterSections[I].Title), STATS_FONT_SIZE,
      FBarColor, True, False, TSkTextAlign.Left, 1);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY);
    LY := LY + LP.Height + 6;

    LX := APanelRect.Left;
    for J := 0 to High(FEncounterSections[I].Locations) do
    begin
      LP := MakeParagraph(UpperCase(FEncounterSections[I].Locations[J]),
        STATS_FONT_SIZE, $FFFFFFFF, True, False, TSkTextAlign.Left, 1);
      LP.Layout(220);
      LBadgeW := LP.LongestLine + 12;

      if (LX + LBadgeW > APanelRect.Right) and (LX > APanelRect.Left) then
      begin
        LX := APanelRect.Left;
        LY := LY + 22;
      end;

      LBadgeRect := TRectF.Create(LX, LY, LX + LBadgeW, LY + 18);
      LPaint.Style := TSkPaintStyle.Fill;
      LPaint.Color := $1CFFFFFF;
      ACanvas.DrawRoundRect(LBadgeRect, 3.5, 3.5, LPaint);
      LPaint.Style := TSkPaintStyle.Stroke;
      LPaint.StrokeWidth := 1;
      LPaint.Color := $33FFFFFF;
      ACanvas.DrawRoundRect(LBadgeRect, 3.5, 3.5, LPaint);

      LBadgeMidY := (LBadgeRect.Top + LBadgeRect.Bottom) / 2;
      LP.Paint(ACanvas, LX + 6, LBadgeMidY - LP.Height / 2);
      LX := LX + LBadgeW + 4;
    end;
    LY := LY + 26;

    if I < LEndSection then
    begin
      LPaint.Style := TSkPaintStyle.Stroke;
      LPaint.StrokeWidth := 1;
      LPaint.Color := $22FFFFFF;
      ACanvas.DrawLine(TPointF.Create(APanelRect.Left, LY),
        TPointF.Create(APanelRect.Right, LY), LPaint);
      LY := LY + 10;
    end;
  end;
end;

procedure TStatsPanel.DrawStats(ASender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LPanelRect, LContentRect: TRectF;
  LPaint: ISkPaint;
begin
  LPanelRect := TRectF.Create(ADest.Left + PANEL_PAD, ADest.Top + PANEL_TOP_PAD,
    ADest.Right - PANEL_PAD, ADest.Bottom - PANEL_PAD);

  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := DARK_BG;
  ACanvas.DrawRoundRect(LPanelRect, 16, 16, LPaint);

  DrawTabs(ACanvas, TRectF.Create(LPanelRect.Left + 12, LPanelRect.Top + 12,
    LPanelRect.Right - 12, LPanelRect.Top + 12 + TAB_H));

  LContentRect := TRectF.Create(LPanelRect.Left + 12, LPanelRect.Top + 12 + TAB_H
    + 12, LPanelRect.Right - 12, LPanelRect.Bottom - 12);
  FStatsContentRect := LContentRect;

  if FActiveTab = stStats then
    DrawStatsTab(ACanvas, LContentRect)
  else if FActiveTab = stMoves then
    DrawMovesTab(ACanvas, LContentRect)
  else
    DrawLocationsTab(ACanvas, LContentRect);

  // Scroll indicator (stats tab only)
  if (FActiveTab = stStats) and (FStatsContentHeight > Round(LContentRect.Height)) then
  begin
    var LTrackX: Single := LPanelRect.Right - 6;
    var LTrackTop: Single := LContentRect.Top + 4;
    var LTrackBot: Single := LContentRect.Bottom - 4;
    var LTrackH: Single := LTrackBot - LTrackTop;
    LPaint.Style := TSkPaintStyle.Fill;
    LPaint.Color := $18FFFFFF;
    ACanvas.DrawRoundRect(TRectF.Create(LTrackX, LTrackTop, LTrackX + 3, LTrackBot),
      1.5, 1.5, LPaint);
    var LThumbH: Single := Max(16.0, LTrackH * (LContentRect.Height / FStatsContentHeight));
    var LMaxOff: Single := FStatsContentHeight - LContentRect.Height;
    var LThumbTop: Single := LTrackTop + (LTrackH - LThumbH) * (FStatsScrollOffset / LMaxOff);
    LPaint.Color := $66FFFFFF;
    ACanvas.DrawRoundRect(TRectF.Create(LTrackX, LThumbTop, LTrackX + 3, LThumbTop + LThumbH),
      1.5, 1.5, LPaint);
  end;
end;

procedure TStatsPanel.HandleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LPoint: TPointF;
  LMoveTab: TMoveTab;
  I: Integer;
begin
  if Button <> mbLeft then
    Exit;

  if Assigned(FOnInteract) then
    FOnInteract(Self);

  LPoint := TPointF.Create(X, Y);
  if FTabsRect[stStats].Contains(LPoint) then
  begin
    FActiveTab := stStats;
    Redraw;
    Exit;
  end;

  if FTabsRect[stMoves].Contains(LPoint) then
  begin
    FActiveTab := stMoves;
    if (not FMovesLoaded) and (not FMovesLoading) and Assigned(FOnMovesTabRequested)
    then
    begin
      FMovesLoading := True;
      FOnMovesTabRequested(Self);
    end;
    Redraw;
    Exit;
  end;

  if FTabsRect[stLocations].Contains(LPoint) then
  begin
    FActiveTab := stLocations;
    if (not FLocationsLoaded) and (not FLocationsLoading) and
      Assigned(FOnLocationsTabRequested) then
    begin
      FLocationsLoading := True;
      FOnLocationsTabRequested(Self);
    end;
    Redraw;
    Exit;
  end;

  if FActiveTab = stMoves then
  begin
    for I := 0 to High(FMovePageRects) do
      if FMovePageRects[I].Contains(LPoint) then
      begin
        FMovePage[FActiveMoveTab] := I;
        Redraw;
        Exit;
      end;

    for LMoveTab := Low(TMoveTab) to High(TMoveTab) do
      if FMoveTabsRect[LMoveTab].Contains(LPoint) and
        (GetMoveSectionIndex(LMoveTab) >= 0) then
      begin
        FActiveMoveTab := LMoveTab;
        SetLength(FMovePageRects, 0);
        Redraw;
        Exit;
      end;
  end;

  if FActiveTab = stLocations then
  begin
    for I := 0 to High(FLocationPageRects) do
      if FLocationPageRects[I].Contains(LPoint) then
      begin
        FLocationsPage := I;
        Redraw;
        Exit;
      end;
  end;

  if (FActiveTab = stStats) and (Length(FAbilityNames) > 1) then
    for I := 0 to High(FAbilityChipRects) do
      if FAbilityChipRects[I].Contains(LPoint) and (I <> FSelectedAbilityIdx) then
      begin
        FSelectedAbilityIdx := I;
        Redraw;
        if Assigned(FOnAbilitySelected) then
          FOnAbilitySelected(Self, I);
        Exit;
      end;

  if (FActiveTab = stStats) and (Length(FFlavorLabels) > 1) then
  begin
    if FFlavorDropdownRect.Contains(LPoint) then
    begin
      FFlavorDropdownOpen := not FFlavorDropdownOpen;
      Redraw;
      Exit;
    end;

    if FFlavorDropdownOpen then
      for I := 0 to High(FFlavorOptionRects) do
        if FFlavorOptionRects[I].Contains(LPoint) and (I <= High(FFlavorTexts))
        then
        begin
          FSelectedFlavorIdx := I;
          FFlavorDropdownOpen := False;
          if Assigned(FOnFlavorOptionSelected) then
            FOnFlavorOptionSelected(Self, I)
          else
            FDescription := FFlavorTexts[I];
          Redraw;
          Exit;
        end;

    if FFlavorDropdownOpen then
    begin
      FFlavorDropdownOpen := False;
      Redraw;
      Exit;
    end;
  end;
end;

procedure TStatsPanel.HandleMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  LClientPoint: TPoint;
  LPoint: TPointF;
  LVisibleFlavorCount: Integer;
  LDropdownListRect: TRectF;
  LMaxOffset: Integer;
begin
  if FActiveTab <> stStats then
    Exit;

  if FFlavorDropdownOpen and (Length(FFlavorLabels) > FLAVOR_MAX_VISIBLE) then
  begin
    LClientPoint := ScreenToClient(MousePos);
    LPoint := TPointF.Create(LClientPoint.X, LClientPoint.Y);
    LVisibleFlavorCount := Min(FLAVOR_MAX_VISIBLE, Length(FFlavorLabels));
    LDropdownListRect := TRectF.Create(FFlavorDropdownRect.Left,
      FFlavorDropdownRect.Bottom + 4, FFlavorDropdownRect.Right,
      FFlavorDropdownRect.Bottom + 8 + (LVisibleFlavorCount * FLAVOR_OPTION_H));

    if FFlavorDropdownRect.Contains(LPoint) or LDropdownListRect.Contains(LPoint) then
    begin
      LMaxOffset := Max(0, Length(FFlavorLabels) - LVisibleFlavorCount);
      if WheelDelta < 0 then
        FFlavorScrollOffset := Min(LMaxOffset, FFlavorScrollOffset + 1)
      else if WheelDelta > 0 then
        FFlavorScrollOffset := Max(0, FFlavorScrollOffset - 1);
      Handled := True;
      Redraw;
    end;
    Exit;
  end;

  if not FFlavorDropdownOpen then
  begin
    LMaxOffset := Max(0, FStatsContentHeight - Round(FStatsContentRect.Height));
    if LMaxOffset > 0 then
    begin
      if WheelDelta < 0 then
        FStatsScrollOffset := Min(LMaxOffset, FStatsScrollOffset + 20)
      else
        FStatsScrollOffset := Max(0, FStatsScrollOffset - 20);
      Handled := True;
      Redraw;
    end;
  end;
end;

end.

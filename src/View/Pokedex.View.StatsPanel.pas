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

  TStatsTab = (stStats, stMoves);
  TMoveTab = (mtLevelUp, mtTM, mtEgg);

  TStatsPanel = class(TSkPaintBox)
  private
    FStats: TArray<TPokemonStat>;
    FBarColor: TAlphaColor;
    FWeight: string;
    FHeight: string;
    FAbility: string;
    FGenderRatio: string;
    FEggGroups: string;
    FHatchCounter: string;
    FFontFamily: string;
    FDescription: string;
    FAbilityDescription: string;
    FDefensiveEffects: TArray<TTypeEffect>;
    FMovePool: TArray<TMovePoolSection>;
    FDefenseNote: string;
    FBST: Integer;
    FActiveTab: TStatsTab;
    FTabsRect: array[TStatsTab] of TRectF;
    FActiveMoveTab: TMoveTab;
    FMoveTabsRect: array[TMoveTab] of TRectF;
    FMovesLoaded: Boolean;
    FMovesLoading: Boolean;
    FOnMovesTabRequested: TNotifyEvent;
    FOnInteract: TNotifyEvent;
    procedure DrawStats(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure HandleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function AbbreviateStat(const AName: string): string;
    function MakeParagraph(const AText: string; AFontSize: Single;
      AColor: TAlphaColor; ABold, AItalic: Boolean;
      AAlign: TSkTextAlign = TSkTextAlign.Left;
      AMaxLines: Integer = 1): ISkParagraph;
    procedure DrawTabs(const ACanvas: ISkCanvas; const APanelRect: TRectF);
    procedure DrawMoveTabs(const ACanvas: ISkCanvas; const APanelRect: TRectF);
    procedure DrawStatsTab(const ACanvas: ISkCanvas; const APanelRect: TRectF);
    procedure DrawMovesTab(const ACanvas: ISkCanvas; const APanelRect: TRectF);
    function GetMoveSectionIndex(ATab: TMoveTab): Integer;
    class function ToAlphaColor(const AColor: TColor): TAlphaColor; static;
    function GetMoveTypeColor(const ASection: TMovePoolSection;
      const AIndex: Integer): TAlphaColor;
    function SplitLevelMove(const AMoveText: string; out ALevelLabel,
      AMoveName: string): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadStats(const AStats: TArray<TPokemonStat>);
    procedure LoadInfo(const AWeight, AHeight, AAbility: string);
    procedure LoadBreeding(const AGenderRatio, AEggGroups,
      AHatchCounter: string);
    procedure LoadDescription(const AText: string);
    procedure LoadAbilityDescription(const AText: string);
    procedure LoadEffects(const ADefensiveEffects: TArray<TTypeEffect>;
      const ADefenseNote: string = '');
    procedure ResetMovePool;
    procedure LoadMovePool(const ASections: TArray<TMovePoolSection>);
    procedure SetMovesLoading(const AValue: Boolean);
    property ActiveTab: TStatsTab read FActiveTab;
    property BarColor: TAlphaColor read FBarColor write FBarColor;
    property FontFamily: string read FFontFamily write FFontFamily;
    property OnMovesTabRequested: TNotifyEvent read FOnMovesTabRequested
      write FOnMovesTabRequested;
    property OnInteract: TNotifyEvent read FOnInteract write FOnInteract;
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

constructor TStatsPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBarColor := $FFE25D27;
  FFontFamily := '';
  FGenderRatio := '';
  FEggGroups := '';
  FHatchCounter := '';
  FDescription := '';
  FAbilityDescription := '';
  FDefenseNote := '';
  FActiveTab := stStats;
  FActiveMoveTab := mtLevelUp;
  FMovesLoaded := False;
  FMovesLoading := False;
  SetLength(FStats, 0);
  SetLength(FDefensiveEffects, 0);
  SetLength(FMovePool, 0);
  OnDraw := DrawStats;
  OnMouseDown := HandleMouseDown;
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
  Redraw;
end;

procedure TStatsPanel.LoadInfo(const AWeight, AHeight, AAbility: string);
begin
  FWeight := AWeight;
  FHeight := AHeight;
  FAbility := AAbility;
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
  FDescription := AText;
  Redraw;
end;

procedure TStatsPanel.LoadAbilityDescription(const AText: string);
begin
  FAbilityDescription := AText;
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
  FMovesLoaded := False;
  FMovesLoading := False;
  Redraw;
end;

procedure TStatsPanel.LoadMovePool(const ASections: TArray<TMovePoolSection>);
begin
  FMovePool := ASections;
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
  LTabWidth := (APanelRect.Width - TAB_GAP) / 2;

  FTabsRect[stStats] := TRectF.Create(APanelRect.Left, APanelRect.Top,
    APanelRect.Left + LTabWidth, APanelRect.Top + TAB_H);
  FTabsRect[stMoves] := TRectF.Create(FTabsRect[stStats].Right + TAB_GAP,
    APanelRect.Top, APanelRect.Right, APanelRect.Top + TAB_H);

  for LTab := Low(TStatsTab) to High(TStatsTab) do
  begin
    if LTab = stStats then
      LTabText := 'STATS'
    else
      LTabText := 'APRENDIZAGEM DE ATAQUES';

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
  LCount, I: Integer;
  LBarBg, LBarFill, LBadgeRect, LDividerRect: TRectF;
  LPaint: ISkPaint;
  LStat: TPokemonStat;
  LEffect: TTypeEffect;
  LBarLeft, LBarRight, LBarTop, LRowTop, LFillX: Single;
  LY, LLayoutW, LX, LBadgeW, LBadgeMidY: Single;
  LHasGroup: Boolean;
  LTColor: TColor;
  LBadgeAlpha: TAlphaColor;
  LP: ISkParagraph;
  LSectionTitle: string;
begin
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LCount := Length(FStats);
  if LCount = 0 then
    Exit;

  LLayoutW := APanelRect.Width - 40;
  LY := APanelRect.Top;
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

  LRowTop := LY + LCount * ROW_H + 2;
  LP := MakeParagraph('TOTAL', STATS_FONT_SIZE, $55FFFFFF, True, False,
    TSkTextAlign.Left, 1);
  LP.Layout(LABEL_W);
  LP.Paint(ACanvas, APanelRect.Left, LRowTop);
  LP := MakeParagraph(FBST.ToString, STATS_FONT_SIZE, FBarColor, True, False,
    TSkTextAlign.Right, 1);
  LP.Layout(VAL_W + 4);
  LP.Paint(ACanvas, APanelRect.Right - VAL_W - 4, LRowTop);

  LY := LY + LCount * ROW_H + 20;
  LPaint.Style := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := 1;
  LPaint.Color := $22FFFFFF;
  ACanvas.DrawLine(TPointF.Create(APanelRect.Left + 16, LY),
    TPointF.Create(APanelRect.Right - 16, LY), LPaint);
  LY := LY + 12;

  LP := MakeParagraph('PESO', STATS_FONT_SIZE, $88FFFFFF, True, False,
    TSkTextAlign.Left, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, APanelRect.Left + 20, LY);
  LP := MakeParagraph('ALTURA', STATS_FONT_SIZE, $88FFFFFF, True, False,
    TSkTextAlign.Center, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, APanelRect.Left + 20, LY);
  LP := MakeParagraph('HABILIDADE', STATS_FONT_SIZE, $88FFFFFF, True, False,
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
  LP := MakeParagraph(FAbility, STATS_FONT_SIZE, $FFFFFFFF, True, False,
    TSkTextAlign.Right, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, APanelRect.Left + 20, LY);

  LY := LY + 20;
  if FAbilityDescription <> '' then
  begin
    LP := MakeParagraph(FAbilityDescription, STATS_FONT_SIZE, $99FFFFFF, True,
      False, TSkTextAlign.Center, 3);
    LP.Layout(APanelRect.Width);
    LP.Paint(ACanvas, APanelRect.Left, LY);
    LY := LY + LP.Height + 10;

    if (FDescription <> '') and
      not ((FGenderRatio <> '') or (FEggGroups <> '') or (FHatchCounter <> '')) then
    begin
      LDividerRect := TRectF.Create(APanelRect.Left + 16, LY,
        APanelRect.Right - 16, LY + 1);
      LPaint.Style := TSkPaintStyle.Stroke;
      LPaint.StrokeWidth := 1;
      LPaint.Color := $22FFFFFF;
      ACanvas.DrawLine(TPointF.Create(LDividerRect.Left, LY),
        TPointF.Create(LDividerRect.Right, LY), LPaint);
      LY := LY + 10;
    end;
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

    for I := 0 to High(MULT_LABELS) do
    begin
      LHasGroup := False;
      for LEffect in FDefensiveEffects do
        if Abs(LEffect.Multiplier - MULT_VALUES[I]) < 0.01 then
        begin
          LHasGroup := True;
          Break;
        end;
      if not LHasGroup then
        Continue;

      LP := MakeParagraph(MULT_LABELS[I], STATS_FONT_SIZE, FBarColor, True,
        False, TSkTextAlign.Left, 1);
      LP.Layout(34);
      LP.Paint(ACanvas, APanelRect.Left, LY + 1);
      LX := APanelRect.Left + 34;

      for LEffect in FDefensiveEffects do
      begin
        if Abs(LEffect.Multiplier - MULT_VALUES[I]) > 0.01 then
          Continue;
        LP := MakeParagraph(UpperCase(LEffect.TypeName), STATS_FONT_SIZE,
          $FFFFFFFF, True, False, TSkTextAlign.Left, 1);
        LP.Layout(220);
        LBadgeW := LP.LongestLine + 12;
        if LX + LBadgeW > APanelRect.Right then
        begin
          LX := APanelRect.Left + 34;
          LY := LY + 20;
        end;
        LBadgeRect := TRectF.Create(LX, LY + 2, LX + LBadgeW, LY + 18);
        LTColor := TPokemonController.GetTypeColor(LEffect.TypeName);
        LBadgeAlpha := $FF000000 or (DWORD(GetRValue(LTColor)) shl 16) or
          (DWORD(GetGValue(LTColor)) shl 8) or DWORD(GetBValue(LTColor));
        LPaint.Style := TSkPaintStyle.Fill;
        LPaint.Color := LBadgeAlpha;
        ACanvas.DrawRoundRect(LBadgeRect, 3.5, 3.5, LPaint);
        LBadgeMidY := (LBadgeRect.Top + LBadgeRect.Bottom) / 2;
        LP.Paint(ACanvas, LX + 6, LBadgeMidY - LP.Height / 2);
        LX := LX + LBadgeW + 4;
      end;
      LY := LY + 22;
    end;
  end;

end;

procedure TStatsPanel.DrawMovesTab(const ACanvas: ISkCanvas;
  const APanelRect: TRectF);
var
  LY, LX, LBadgeW, LBadgeMidY, LRowHeight, LLevelColW, LColumnGap, LColumnW,
    LMoveRectLeft, LMoveRectRight: Single;
  J, LSectionIdx, LRowsPerColumn, LColumns, LColumnIndex, LRowIndex: Integer;
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
    LColumns := 1;
    LRowsPerColumn := Max(1, Trunc((APanelRect.Bottom - LY) / LRowHeight));
    if Length(LSection.Moves) > LRowsPerColumn then
      LColumns := Min(4, Ceil(Length(LSection.Moves) / LRowsPerColumn));
    LRowsPerColumn := Max(1, Ceil(Length(LSection.Moves) / LColumns));
    if LColumns > 1 then
      LColumnW := (APanelRect.Width - (LColumns - 1) * LColumnGap) / LColumns
    else
      LColumnW := APanelRect.Width;
    if LColumnW < 92 then
    begin
      LColumns := Max(1, Min(4, Trunc((APanelRect.Width + LColumnGap) /
        (92 + LColumnGap))));
      LRowsPerColumn := Max(1, Ceil(Length(LSection.Moves) / LColumns));
      if LColumns > 1 then
        LColumnW := (APanelRect.Width - (LColumns - 1) * LColumnGap) / LColumns
      else
        LColumnW := APanelRect.Width;
    end;

    for J := 0 to High(LSection.Moves) do
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

      LColumnIndex := J div LRowsPerColumn;
      LRowIndex := J mod LRowsPerColumn;
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

  if FActiveTab = stStats then
    DrawStatsTab(ACanvas, LContentRect)
  else
    DrawMovesTab(ACanvas, LContentRect);
end;

procedure TStatsPanel.HandleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LPoint: TPointF;
  LMoveTab: TMoveTab;
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

  if FActiveTab = stMoves then
    for LMoveTab := Low(TMoveTab) to High(TMoveTab) do
      if FMoveTabsRect[LMoveTab].Contains(LPoint) and
        (GetMoveSectionIndex(LMoveTab) >= 0) then
      begin
        FActiveMoveTab := LMoveTab;
        Redraw;
        Exit;
      end;
  end;

end.

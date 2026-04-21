unit Pokedex.View.StatsPanel;

interface

uses
  System.SysUtils,
  System.Classes,
  System.UITypes,
  System.Math,
  Vcl.Controls,
  System.Skia,
  Vcl.Skia,
  System.Types;

type
  TPokemonStat = record
    Name: string;
    Value: Integer;
  end;

  TStatsPanel = class(TSkPaintBox)
  private
    FStats: TArray<TPokemonStat>;
    FBarColor: TAlphaColor;
    FWeight: string;
    FHeight: string;
    FAbility: string;
    FFontFamily: string;
    procedure DrawStats(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function AbbreviateStat(const AName: string): string;
    function MakeTypeface: ISkTypeface;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadStats(const AStats: TArray<TPokemonStat>);
    procedure LoadInfo(const AWeight, AHeight, AAbility: string);
    property BarColor: TAlphaColor read FBarColor write FBarColor;
    property FontFamily: string read FFontFamily write FFontFamily;
  end;

implementation

const
  MAX_STAT  = 255;
  PANEL_PAD = 12;
  ROW_H     = 26;
  BAR_H     = 8;
  BAR_R     = 4.0;
  LABEL_W   = 52;
  VAL_W     = 32;
  DARK_BG: TAlphaColor = $FF2A2A2A;

constructor TStatsPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBarColor  := $FFE25D27;
  FFontFamily := '';
  SetLength(FStats, 0);
  OnDraw := DrawStats;
end;

procedure TStatsPanel.LoadStats(const AStats: TArray<TPokemonStat>);
begin
  FStats := AStats;
  Redraw;
end;

procedure TStatsPanel.LoadInfo(const AWeight, AHeight, AAbility: string);
begin
  FWeight  := AWeight;
  FHeight  := AHeight;
  FAbility := AAbility;
  Redraw;
end;

function TStatsPanel.MakeTypeface: ISkTypeface;
begin
  if FFontFamily <> '' then
    Result := TSkTypeface.MakeFromName(FFontFamily, TSkFontStyle.Normal)
  else
    Result := TSkTypeface.MakeDefault;
  if Result = nil then
    Result := TSkTypeface.MakeDefault;
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

procedure TStatsPanel.DrawStats(ASender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LCount, I: Integer;
  LPanelRect, LBarBg, LBarFill: TRectF;
  LPaint: ISkPaint;
  LFontLabel, LFontVal, LFontInfo, LFontInfoBold: ISkFont;
  LTypeface: ISkTypeface;
  LStat: TPokemonStat;
  LBarLeft, LBarRight, LBarTop, LFillX, LTextW: Single;
  LText: string;
  LMetrics: TSkFontMetrics;
  LStatsTop, LInfoY, LMidX: Single;
begin
  LCount := Length(FStats);
  if LCount = 0 then
    Exit;

  LPanelRect := TRectF.Create(ADest.Left + PANEL_PAD, ADest.Top + PANEL_PAD,
    ADest.Right - PANEL_PAD, ADest.Bottom - PANEL_PAD);

  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := DARK_BG;
  ACanvas.DrawRoundRect(LPanelRect, 16, 16, LPaint);

  ACanvas.Save;
  ACanvas.ClipRect(LPanelRect, TSkClipOp.Intersect, False);

  LTypeface  := MakeTypeface;
  LFontLabel := TSkFont.Create(LTypeface, 10);
  LFontLabel.Embolden := True;
  LFontVal   := TSkFont.Create(LTypeface, 10);
  LFontInfo     := TSkFont.Create(LTypeface, 9);
  LFontInfoBold := TSkFont.Create(LTypeface, 10);
  LFontInfoBold.Embolden := True;

  LStatsTop  := LPanelRect.Top  + PANEL_PAD;
  LBarLeft   := LPanelRect.Left + PANEL_PAD + LABEL_W + 8;
  LBarRight  := LPanelRect.Right - PANEL_PAD - VAL_W - 6;

  for I := 0 to LCount - 1 do
  begin
    LStat    := FStats[I];
    LBarTop  := LStatsTop + I * ROW_H + (ROW_H - BAR_H) / 2;

    // Stat label
    LPaint.Color := $88FFFFFF;
    LText := AbbreviateStat(LStat.Name);
    LFontLabel.GetMetrics(LMetrics);
    ACanvas.DrawSimpleText(LText,
      LPanelRect.Left + PANEL_PAD,
      LBarTop + BAR_H / 2 - (LMetrics.Ascent + LMetrics.Descent) / 2,
      LFontLabel, LPaint);

    // Background track
    LBarBg := TRectF.Create(LBarLeft, LBarTop, LBarRight, LBarTop + BAR_H);
    LPaint.Color := $33FFFFFF;
    ACanvas.DrawRoundRect(LBarBg, BAR_R, BAR_R, LPaint);

    // Fill
    LFillX := LBarLeft + (LBarRight - LBarLeft) * Min(1.0, LStat.Value / MAX_STAT);
    if LFillX > LBarLeft then
    begin
      LBarFill := TRectF.Create(LBarLeft, LBarTop, LFillX, LBarTop + BAR_H);
      LPaint.Color := FBarColor;
      ACanvas.DrawRoundRect(LBarFill, BAR_R, BAR_R, LPaint);
    end;

    // Value
    LText  := LStat.Value.ToString;
    LFontVal.GetMetrics(LMetrics);
    LTextW := LFontVal.MeasureText(LText, LPaint);
    LPaint.Color := $FFFFFFFF;
    ACanvas.DrawSimpleText(LText,
      LPanelRect.Right - PANEL_PAD - LTextW,
      LBarTop + BAR_H / 2 - (LMetrics.Ascent + LMetrics.Descent) / 2,
      LFontVal, LPaint);
  end;

  // Divider
  LInfoY := LStatsTop + LCount * ROW_H + 6;
  LPaint.Style := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := 1;
  LPaint.Color := $22FFFFFF;
  ACanvas.DrawLine(
    TPointF.Create(LPanelRect.Left + 16, LInfoY),
    TPointF.Create(LPanelRect.Right - 16, LInfoY), LPaint);
  LPaint.Style := TSkPaintStyle.Fill;

  LInfoY := LInfoY + 14;
  LMidX  := LPanelRect.Left + LPanelRect.Width / 2;

  LFontInfo.GetMetrics(LMetrics);

  // PESO — left
  LPaint.Color := $66FFFFFF;
  ACanvas.DrawSimpleText('PESO',
    LPanelRect.Left + 20, LInfoY, LFontInfo, LPaint);
  LPaint.Color := $FFFFFFFF;
  ACanvas.DrawSimpleText(FWeight,
    LPanelRect.Left + 20, LInfoY + 14, LFontInfoBold, LPaint);

  // ALTURA — center
  LPaint.Color := $66FFFFFF;
  LTextW := LFontInfo.MeasureText('ALTURA', LPaint);
  ACanvas.DrawSimpleText('ALTURA',
    LMidX - LTextW / 2, LInfoY, LFontInfo, LPaint);
  LPaint.Color := $FFFFFFFF;
  LTextW := LFontInfoBold.MeasureText(FHeight, LPaint);
  ACanvas.DrawSimpleText(FHeight,
    LMidX - LTextW / 2, LInfoY + 14, LFontInfoBold, LPaint);

  // HABILIDADE — right
  LPaint.Color := $66FFFFFF;
  LTextW := LFontInfo.MeasureText('HABILIDADE', LPaint);
  ACanvas.DrawSimpleText('HABILIDADE',
    LPanelRect.Right - 20 - LTextW, LInfoY, LFontInfo, LPaint);
  LPaint.Color := $FFFFFFFF;
  LTextW := LFontInfoBold.MeasureText(FAbility, LPaint);
  ACanvas.DrawSimpleText(FAbility,
    LPanelRect.Right - 20 - LTextW, LInfoY + 14, LFontInfoBold, LPaint);

  ACanvas.Restore;
end;

end.

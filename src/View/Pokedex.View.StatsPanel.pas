unit Pokedex.View.StatsPanel;

interface

uses
  System.SysUtils,
  System.Classes,
  System.UITypes,
  System.Math,
  Vcl.Controls,
  Vcl.Graphics,
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
    procedure DrawStats(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function AbbreviateStat(const AName: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadStats(const AStats: TArray<TPokemonStat>);
    procedure LoadInfo(const AWeight, AHeight, AAbility: string);
    property BarColor: TAlphaColor read FBarColor write FBarColor;
  end;

implementation

const
  MAX_STAT = 255;
  COLS = 3;
  ARC_STROKE = 7;
  CARD_PAD = 8;
  PANEL_PAD = 10;
  INFO_H = 72;

constructor TStatsPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBarColor := $FFE25D27;
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
  FWeight := AWeight;
  FHeight := AHeight;
  FAbility := AAbility;
  Redraw;
end;

function TStatsPanel.AbbreviateStat(const AName: string): string;
begin
  if AName = 'hp' then
    Result := 'HP'
  else if AName = 'attack' then
    Result := 'ATK'
  else if AName = 'defense' then
    Result := 'DEF'
  else if AName = 'special-attack' then
    Result := 'SP.ATK'
  else if AName = 'special-defense' then
    Result := 'SP.DEF'
  else if AName = 'speed' then
    Result := 'SPD'
  else
    Result := UpperCase(AName);
end;

procedure TStatsPanel.DrawStats(ASender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LCount: Integer;
  LRows: Integer;
  LCellW: Single;
  LCellH: Single;
  LPaint: ISkPaint;
  LFont: ISkFont;
  LFontSm: ISkFont;
  LFontInfo: ISkFont;
  LFontBold: ISkFont;
  LTypeface: ISkTypeface;
  I: Integer;
  LCol, LRow: Integer;
  LCX, LCY: Single;
  LRadius: Single;
  LSweep: Single;
  LRect: TRectF;
  LPanelRect: TRectF;
  LGridRect: TRectF;
  LText: string;
  LBounds: TRectF;
  LStat: TPokemonStat;
begin
  LCount := Length(FStats);
  if LCount = 0 then
    Exit;

  LPanelRect := TRectF.Create(ADest.Left + PANEL_PAD, ADest.Top + PANEL_PAD,
    ADest.Right - PANEL_PAD, ADest.Bottom - PANEL_PAD);

  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := $EE111111;
  ACanvas.DrawRoundRect(LPanelRect, 16, 16, LPaint);

  LTypeface := TSkTypeface.MakeDefault;
  LFontInfo := TSkFont.Create(LTypeface, 11);
  LFontBold := TSkFont.Create(LTypeface, 11);
  LFontBold.Embolden := True;
  LFont := TSkFont.Create(LTypeface, 15);
  LFontSm := TSkFont.Create(LTypeface, 10);
  LFontSm.Embolden := True;

  // Peso / Altura / Habilidade
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := $88FFFFFF;
  ACanvas.DrawSimpleText('PESO', LPanelRect.Left + 16, LPanelRect.Top + 22,
    LFontInfo, LPaint);
  ACanvas.DrawSimpleText('ALTURA', LPanelRect.Left + 16, LPanelRect.Top + 42,
    LFontInfo, LPaint);
  ACanvas.DrawSimpleText('HABILIDADE', LPanelRect.Left + 16,
    LPanelRect.Top + 62, LFontInfo, LPaint);

  LPaint.Color := $FFFFFFFF;
  ACanvas.DrawSimpleText(FWeight, LPanelRect.Left + 110, LPanelRect.Top + 22,
    LFontBold, LPaint);
  ACanvas.DrawSimpleText(FHeight, LPanelRect.Left + 110, LPanelRect.Top + 42,
    LFontBold, LPaint);
  ACanvas.DrawSimpleText(FAbility, LPanelRect.Left + 110, LPanelRect.Top + 62,
    LFontBold, LPaint);

  // Linha divisória
  LPaint.Style := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := 0.5;
  LPaint.Color := $33FFFFFF;
  ACanvas.DrawLine(TPointF.Create(LPanelRect.Left + 16, LPanelRect.Top + INFO_H
    + 2), TPointF.Create(LPanelRect.Right - 16, LPanelRect.Top + INFO_H +
    2), LPaint);

  // Área dos arcos
  LGridRect := TRectF.Create(LPanelRect.Left, LPanelRect.Top + INFO_H + 8,
    LPanelRect.Right, LPanelRect.Bottom);

  LRows := Ceil(LCount / COLS);
  LCellW := LGridRect.Width / COLS;
  LCellH := LGridRect.Height / LRows;

  LPaint.Style := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := ARC_STROKE;
  LPaint.StrokeCap := TSkStrokeCap.Round;

  for I := 0 to LCount - 1 do
  begin
    LStat := FStats[I];
    LCol := I mod COLS;
    LRow := I div COLS;

    LCX := LGridRect.Left + (LCol * LCellW) + (LCellW / 2);
    LCY := LGridRect.Top + (LRow * LCellH) + (LCellH / 2);

    LRadius := (Min(LCellW, LCellH) / 2) - ARC_STROKE - CARD_PAD - 8;

    // Trilho
    LPaint.Color := $33FFFFFF;
    LRect := TRectF.Create(LCX - LRadius, LCY - LRadius, LCX + LRadius,
      LCY + LRadius);
    ACanvas.DrawArc(LRect, -90, 360, False, LPaint);

    // Arco colorido
    LSweep := 360 * (LStat.Value / MAX_STAT);

    if FBarColor = $FF2C2C2C then
      LPaint.Color := $FFFFD700 // dourado — visível sobre preto
    else
      LPaint.Color := FBarColor;

    ACanvas.DrawArc(LRect, -90, LSweep, False, LPaint);

    // Valor numérico centralizado
    LPaint.Style := TSkPaintStyle.Fill;
    LPaint.Color := $FFFFFFFF;
    LText := LStat.Value.ToString;
    LFont.MeasureText(LText, LBounds, LPaint);
    ACanvas.DrawSimpleText(LText, LCX - (LBounds.Width / 2),
      LCY + (LBounds.Height / 3), LFont, LPaint);

    // Label acima do arco na cor do tema
    LPaint.Color := FBarColor;
    LText := AbbreviateStat(LStat.Name);
    LFontSm.MeasureText(LText, LBounds, LPaint);
    ACanvas.DrawSimpleText(LText, LCX - (LBounds.Width / 2),
      LCY - LRadius - ARC_STROKE - 2, LFontSm, LPaint);

    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := ARC_STROKE;
    LPaint.StrokeCap := TSkStrokeCap.Round;
  end;
end;

end.

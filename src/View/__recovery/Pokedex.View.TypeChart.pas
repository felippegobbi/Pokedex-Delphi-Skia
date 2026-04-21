unit Pokedex.View.TypeChart;

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
  System.Types,
  Pokedex.Model.Pokemon,
  Pokedex.Controller.Pokemon,
  WinAPI.Windows;

type
  TTypeChartPanel = class(TSkPaintBox)
  private
    FEffects: TArray<TTypeEffect>;
    FThemeColor: TAlphaColor;
    FFontFamily: string;
    procedure DrawChart(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function MakeTypeface: ISkTypeface;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadEffects(const AEffects: TArray<TTypeEffect>);
    property ThemeColor: TAlphaColor read FThemeColor write FThemeColor;
    property FontFamily: string read FFontFamily write FFontFamily;
  end;

implementation

const
  PANEL_PAD: Integer = 10;
  DARK_BG: TAlphaColor = $FF2A2A2A;
  BADGE_H   = 17;
  BADGE_R   = 3.5;
  BADGE_X   = 5;
  ROW_H     = 23;
  MULT_W    = 34;

constructor TTypeChartPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThemeColor := $FFE25D27;
  FFontFamily := '';
  SetLength(FEffects, 0);
  OnDraw := DrawChart;
end;

procedure TTypeChartPanel.LoadEffects(const AEffects: TArray<TTypeEffect>);
begin
  FEffects := AEffects;
  Redraw;
end;

function TTypeChartPanel.MakeTypeface: ISkTypeface;
begin
  if FFontFamily <> '' then
    Result := TSkTypeface.MakeFromName(FFontFamily, TSkFontStyle.Normal)
  else
    Result := TSkTypeface.MakeDefault;
  if Result = nil then
    Result := TSkTypeface.MakeDefault;
end;

procedure TTypeChartPanel.DrawChart(ASender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
const
  MULT_LABELS: array[0..4] of string  = ('4×', '2×', '½×', '¼×', '0×');
  MULT_VALUES: array[0..4] of Single  = (4.0, 2.0, 0.5, 0.25, 0.0);
var
  LPanelRect: TRectF;
  LPaint: ISkPaint;
  LTypeface: ISkTypeface;
  LFontTitle, LFontMult, LFontBadge: ISkFont;
  LMetrics: TSkFontMetrics;
  LX, LY, LBadgeW, LTextW: Single;
  LEffect: TTypeEffect;
  LBadgeRect: TRectF;
  LTColor: TColor;
  LBadgeAlpha: TAlphaColor;
  LText: string;
  I: Integer;
  LHasGroup: Boolean;
begin
  LPanelRect := TRectF.Create(ADest.Left + PANEL_PAD, ADest.Top + PANEL_PAD,
    ADest.Right - PANEL_PAD, ADest.Bottom - PANEL_PAD);

  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := FThemeColor;
  ACanvas.DrawRect(ADest, LPaint);
  LPaint.Color := DARK_BG;
  ACanvas.DrawRoundRect(LPanelRect, 12, 12, LPaint);

  ACanvas.Save;
  ACanvas.ClipRect(LPanelRect, TSkClipOp.Intersect, False);

  LTypeface  := MakeTypeface;
  LFontTitle := TSkFont.Create(LTypeface, 9);
  LFontTitle.Embolden := True;
  LFontMult  := TSkFont.Create(LTypeface, 11);
  LFontMult.Embolden := True;
  LFontBadge := TSkFont.Create(LTypeface, 8);
  LFontBadge.Embolden := True;

  // Header
  LText := 'EFETIVIDADE';
  LFontTitle.GetMetrics(LMetrics);
  LTextW := LFontTitle.MeasureText(LText, LPaint);
  LPaint.Color := $55FFFFFF;
  ACanvas.DrawSimpleText(LText,
    LPanelRect.Left + (LPanelRect.Width - LTextW) / 2,
    LPanelRect.Top + 14,
    LFontTitle, LPaint);

  LY := LPanelRect.Top + 26;

  if Length(FEffects) = 0 then
  begin
    ACanvas.Restore;
    Exit;
  end;

  LFontMult.GetMetrics(LMetrics);

  for I := 0 to High(MULT_VALUES) do
  begin
    LHasGroup := False;
    for LEffect in FEffects do
      if Abs(LEffect.Multiplier - MULT_VALUES[I]) < 0.01 then
      begin
        LHasGroup := True;
        Break;
      end;
    if not LHasGroup then
      Continue;

    // Multiplier label
    LPaint.Color := FThemeColor;
    ACanvas.DrawSimpleText(MULT_LABELS[I],
      LPanelRect.Left + PANEL_PAD,
      LY + ROW_H / 2 - (LMetrics.Ascent + LMetrics.Descent) / 2,
      LFontMult, LPaint);

    LX := LPanelRect.Left + PANEL_PAD + MULT_W;

    for LEffect in FEffects do
    begin
      if Abs(LEffect.Multiplier - MULT_VALUES[I]) > 0.01 then
        Continue;

      LText   := UpperCase(LEffect.TypeName);
      LTextW  := LFontBadge.MeasureText(LText, LPaint);
      LBadgeW := LTextW + BADGE_X * 2;

      if LX + LBadgeW > LPanelRect.Right - PANEL_PAD then
      begin
        LX := LPanelRect.Left + PANEL_PAD + MULT_W;
        LY := LY + ROW_H;
      end;

      LBadgeRect := TRectF.Create(
        LX,
        LY + (ROW_H - BADGE_H) / 2,
        LX + LBadgeW,
        LY + (ROW_H + BADGE_H) / 2);

      LTColor := TPokemonController.GetTypeColor(LEffect.TypeName);
      LBadgeAlpha := $FF000000
        or (DWORD(GetRValue(LTColor)) shl 16)
        or (DWORD(GetGValue(LTColor)) shl 8)
        or  DWORD(GetBValue(LTColor));

      LPaint.Color := LBadgeAlpha;
      ACanvas.DrawRoundRect(LBadgeRect, BADGE_R, BADGE_R, LPaint);

      LFontBadge.GetMetrics(LMetrics);
      LPaint.Color := $FFFFFFFF;
      ACanvas.DrawSimpleText(LText,
        LX + BADGE_X,
        LBadgeRect.CenterY - (LMetrics.Ascent + LMetrics.Descent) / 2,
        LFontBadge, LPaint);

      LX := LX + LBadgeW + 4;
    end;

    LY := LY + ROW_H;
  end;

  ACanvas.Restore;
end;

end.

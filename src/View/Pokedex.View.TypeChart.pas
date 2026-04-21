unit Pokedex.View.TypeChart;

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
  TTypeChartPanel = class(TSkPaintBox)
  private
    FEffects: TArray<TTypeEffect>;
    FThemeColor: TAlphaColor;
    FFontFamily: string;
    procedure DrawChart(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function MakeParagraph(const AText: string; AFontSize: Single;
      AColor: TAlphaColor; ABold: Boolean;
      AAlign: TSkTextAlign = TSkTextAlign.Left): ISkParagraph;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadEffects(const AEffects: TArray<TTypeEffect>);
    property ThemeColor: TAlphaColor read FThemeColor write FThemeColor;
    property FontFamily: string read FFontFamily write FFontFamily;
  end;

implementation

const
  PANEL_PAD = 14;
  DARK_BG: TAlphaColor = $FF2A2A2A;
  BADGE_H = 17;
  BADGE_R = 3.5;
  BADGE_X = 5;
  ROW_H   = 22;
  MULT_W  = 34;

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

function TTypeChartPanel.MakeParagraph(const AText: string; AFontSize: Single;
  AColor: TAlphaColor; ABold: Boolean; AAlign: TSkTextAlign): ISkParagraph;
var
  LParaStyle: ISkParagraphStyle;
  LTextStyle: ISkTextStyle;
  LBuilder: ISkParagraphBuilder;
begin
  LParaStyle := TSkParagraphStyle.Create;
  LParaStyle.MaxLines  := 1;
  LParaStyle.TextAlign := AAlign;

  LTextStyle := TSkTextStyle.Create;
  if FFontFamily <> '' then
    LTextStyle.FontFamilies := [FFontFamily, 'Segoe UI']
  else
    LTextStyle.FontFamilies := ['Segoe UI'];
  LTextStyle.FontSize := AFontSize;
  LTextStyle.Color    := AColor;
  if ABold then
    LTextStyle.FontStyle := TSkFontStyle.Bold
  else
    LTextStyle.FontStyle := TSkFontStyle.Normal;

  LBuilder := TSkParagraphBuilder.Create(LParaStyle);
  LBuilder.PushStyle(LTextStyle);
  if AText.IsEmpty then
    LBuilder.AddText(' ')
  else
    LBuilder.AddText(AText);
  LBuilder.Pop;
  Result := LBuilder.Build;
end;

procedure TTypeChartPanel.DrawChart(ASender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
const
  MULT_LABELS: array[0..4] of string = ('4x', '2x', '1/2', '1/4', '0x');
  MULT_VALUES: array[0..4] of Single = (4.0, 2.0, 0.5, 0.25, 0.0);
var
  LPanelRect: TRectF;
  LPaint: ISkPaint;
  LX, LY, LBadgeW, LBadgeMidY: Single;
  LEffect: TTypeEffect;
  LBadgeRect: TRectF;
  LTColor: TColor;
  LBadgeAlpha: TAlphaColor;
  LText: string;
  I, LActiveGroups, LTotalRows: Integer;
  LHasGroup: Boolean;
  LP: ISkParagraph;
  LEffectiveRowH, LBadgeH, LFontS, LMultFS: Single;
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

  LP := MakeParagraph('EFETIVIDADE DEFENSIVA', 8, $55FFFFFF, True,
    TSkTextAlign.Center);
  LP.Layout(LPanelRect.Width);
  LP.Paint(ACanvas, LPanelRect.Left, LPanelRect.Top + PANEL_PAD);
  LY := LPanelRect.Top + PANEL_PAD + LP.Height + 6;

  LActiveGroups := 0;
  for I := 0 to High(MULT_VALUES) do
  begin
    for LEffect in FEffects do
      if Abs(LEffect.Multiplier - MULT_VALUES[I]) < 0.01 then
      begin
        Inc(LActiveGroups);
        Break;
      end;
  end;

  // Responsive sizing based on count
  if LActiveGroups > 4 then
  begin
    LEffectiveRowH := 18.5;
    LBadgeH := 14.5;
    LFontS := 7.5;
    LMultFS := 10;
  end
  else
  begin
    LEffectiveRowH := ROW_H;
    LBadgeH := BADGE_H;
    LFontS := 8;
    LMultFS := 11;
  end;

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

    LP := MakeParagraph(MULT_LABELS[I], LMultFS, FThemeColor, True, TSkTextAlign.Left);
    LP.Layout(MULT_W);
    LP.Paint(ACanvas, LPanelRect.Left + PANEL_PAD, LY + (LEffectiveRowH - LP.Height) / 2);

    LX := LPanelRect.Left + PANEL_PAD + MULT_W;

    for LEffect in FEffects do
    begin
      if Abs(LEffect.Multiplier - MULT_VALUES[I]) > 0.01 then
        Continue;

      LText := UpperCase(LEffect.TypeName);
      LP    := MakeParagraph(LText, LFontS, $FFFFFFFF, True, TSkTextAlign.Left);
      LP.Layout(300);
      LBadgeW := LP.LongestLine + BADGE_X * 2 + 2;

      // Wrap check: if badge exceeds right bound, move to next line
      if LX + LBadgeW > LPanelRect.Right - PANEL_PAD then
      begin
        LX := LPanelRect.Left + PANEL_PAD + MULT_W;
        LY := LY + LEffectiveRowH;
      end;

      LBadgeRect := TRectF.Create(
        LX,
        LY + (LEffectiveRowH - LBadgeH) / 2,
        LX + LBadgeW,
        LY + (LEffectiveRowH + LBadgeH) / 2);

      LTColor     := TPokemonController.GetTypeColor(LEffect.TypeName);
      LBadgeAlpha := $FF000000
        or (DWORD(GetRValue(LTColor)) shl 16)
        or (DWORD(GetGValue(LTColor)) shl 8)
        or  DWORD(GetBValue(LTColor));

      LPaint.Color := LBadgeAlpha;
      ACanvas.DrawRoundRect(LBadgeRect, BADGE_R, BADGE_R, LPaint);

      LBadgeMidY := (LBadgeRect.Top + LBadgeRect.Bottom) / 2;
      LP.Paint(ACanvas, LX + BADGE_X + 1, LBadgeMidY - LP.Height / 2);

      LX := LX + LBadgeW + 4;
    end;

    LY := LY + LEffectiveRowH + 2; // Extra space between groups
  end;

  ACanvas.Restore;
end;

end.

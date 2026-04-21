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

  TStatsPanel = class(TSkPaintBox)
  private
    FStats: TArray<TPokemonStat>;
    FBarColor: TAlphaColor;
    FWeight: string;
    FHeight: string;
    FAbility: string;
    FFontFamily: string;
    FDescription: string;
    FAbilityDescription: string;
    FEffects: TArray<TTypeEffect>;
    FBST: Integer;
    procedure DrawStats(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function AbbreviateStat(const AName: string): string;
    function MakeParagraph(const AText: string; AFontSize: Single;
      AColor: TAlphaColor; ABold, AItalic: Boolean;
      AAlign: TSkTextAlign = TSkTextAlign.Left;
      AMaxLines: Integer = 1): ISkParagraph;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadStats(const AStats: TArray<TPokemonStat>);
    procedure LoadInfo(const AWeight, AHeight, AAbility: string);
    procedure LoadDescription(const AText: string);
    procedure LoadAbilityDescription(const AText: string);
    procedure LoadEffects(const AEffects: TArray<TTypeEffect>);
    property BarColor: TAlphaColor read FBarColor write FBarColor;
    property FontFamily: string read FFontFamily write FFontFamily;
  end;

implementation

const
  MULT_LABELS: array[0..4] of string  = ('4x', '2x', '1/2', '1/4', '0x');
  MULT_VALUES: array[0..4] of Single  = (4.0,  2.0,  0.5,  0.25,  0.0);

const
  MAX_STAT  = 180;
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
  FBarColor           := $FFE25D27;
  FFontFamily         := '';
  FDescription        := '';
  FAbilityDescription := '';
  SetLength(FStats, 0);
  OnDraw := DrawStats;
end;

procedure TStatsPanel.LoadStats(const AStats: TArray<TPokemonStat>);
var
  I: Integer;
begin
  FStats := AStats;
  FBST := 0;
  for I := 0 to High(AStats) do
    Inc(FBST, AStats[I].Value);
  Redraw;
end;

procedure TStatsPanel.LoadInfo(const AWeight, AHeight, AAbility: string);
begin
  FWeight  := AWeight;
  FHeight  := AHeight;
  FAbility := AAbility;
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

procedure TStatsPanel.LoadEffects(const AEffects: TArray<TTypeEffect>);
begin
  FEffects := AEffects;
  Redraw;
end;

function TStatsPanel.MakeParagraph(const AText: string; AFontSize: Single;
  AColor: TAlphaColor; ABold, AItalic: Boolean;
  AAlign: TSkTextAlign; AMaxLines: Integer): ISkParagraph;
var
  LParaStyle: ISkParagraphStyle;
  LTextStyle: ISkTextStyle;
  LBuilder: ISkParagraphBuilder;
begin
  LParaStyle := TSkParagraphStyle.Create;
  LParaStyle.MaxLines  := AMaxLines;
  LParaStyle.TextAlign := AAlign;
  LParaStyle.Ellipsis  := '...';

  LTextStyle := TSkTextStyle.Create;
  if FFontFamily <> '' then
    LTextStyle.FontFamilies := [FFontFamily, 'Segoe UI']
  else
    LTextStyle.FontFamilies := ['Segoe UI'];
  LTextStyle.FontSize := AFontSize;
  LTextStyle.Color    := AColor;

  if ABold and AItalic then
    LTextStyle.FontStyle := TSkFontStyle.BoldItalic
  else if ABold then
    LTextStyle.FontStyle := TSkFontStyle.Bold
  else if AItalic then
    LTextStyle.FontStyle := TSkFontStyle.Italic
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
  LPanelRect, LBarBg, LBarFill, LBadgeRect: TRectF;
  LPaint: ISkPaint;
  LStat: TPokemonStat;
  LEffect: TTypeEffect;
  LBarLeft, LBarRight, LBarTop, LRowTop, LFillX: Single;
  LY, LLayoutW, LX, LBadgeW, LBadgeMidY: Single;
  LHasGroup: Boolean;
  LTColor: TColor;
  LBadgeAlpha: TAlphaColor;
  LP: ISkParagraph;
begin
  LPanelRect := TRectF.Create(ADest.Left + PANEL_PAD, ADest.Top + PANEL_PAD,
    ADest.Right - PANEL_PAD, ADest.Bottom - PANEL_PAD);

  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := DARK_BG;
  ACanvas.DrawRoundRect(LPanelRect, 16, 16, LPaint);

  LCount := Length(FStats);
  if LCount = 0 then
    Exit;

  ACanvas.Save;

  LLayoutW  := LPanelRect.Width - 40;
  LY        := LPanelRect.Top + PANEL_PAD;
  LBarLeft  := LPanelRect.Left + PANEL_PAD + LABEL_W + 8;
  LBarRight := LPanelRect.Right - PANEL_PAD - VAL_W - 6;

  for I := 0 to LCount - 1 do
  begin
    LStat   := FStats[I];
    LRowTop := LY + I * ROW_H;
    LBarTop := LRowTop + (ROW_H - BAR_H) / 2;

    LP := MakeParagraph(AbbreviateStat(LStat.Name), 9.5, $88FFFFFF,
      True, False, TSkTextAlign.Left, 1);
    LP.Layout(LABEL_W);
    LP.Paint(ACanvas, LPanelRect.Left + PANEL_PAD,
      LRowTop + (ROW_H - LP.Height) / 2);

    LBarBg := TRectF.Create(LBarLeft, LBarTop, LBarRight, LBarTop + BAR_H);
    LPaint.Color := $33FFFFFF;
    ACanvas.DrawRoundRect(LBarBg, BAR_R, BAR_R, LPaint);

    LFillX := LBarLeft + (LBarRight - LBarLeft) * Min(1.0, LStat.Value / MAX_STAT);
    if LFillX > LBarLeft then
    begin
      LBarFill := TRectF.Create(LBarLeft, LBarTop, LFillX, LBarTop + BAR_H);
      LPaint.Color := FBarColor;
      ACanvas.DrawRoundRect(LBarFill, BAR_R, BAR_R, LPaint);
    end;

    LP := MakeParagraph(LStat.Value.ToString, 9.5, $FFFFFFFF,
      False, False, TSkTextAlign.Right, 1);
    LP.Layout(VAL_W);
    LP.Paint(ACanvas, LPanelRect.Right - PANEL_PAD - VAL_W,
      LRowTop + (ROW_H - LP.Height) / 2);
  end;

  LRowTop := LY + LCount * ROW_H + 2;
  LP := MakeParagraph('TOTAL', 8.5, $55FFFFFF, False, False, TSkTextAlign.Left, 1);
  LP.Layout(LABEL_W);
  LP.Paint(ACanvas, LPanelRect.Left + PANEL_PAD, LRowTop);
  LP := MakeParagraph(FBST.ToString, 9.5, FBarColor, True, False, TSkTextAlign.Right, 1);
  LP.Layout(VAL_W + 4);
  LP.Paint(ACanvas, LPanelRect.Right - PANEL_PAD - VAL_W - 4, LRowTop);

  LY := LY + LCount * ROW_H + 20;
  LPaint.Style       := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := 1;
  LPaint.Color       := $22FFFFFF;
  ACanvas.DrawLine(
    TPointF.Create(LPanelRect.Left + 16, LY),
    TPointF.Create(LPanelRect.Right - 16, LY), LPaint);
  LPaint.Style := TSkPaintStyle.Fill;
  LY := LY + 12;

  LP := MakeParagraph('PESO', 8.5, $66FFFFFF, False, False, TSkTextAlign.Left, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, LPanelRect.Left + 20, LY);

  LP := MakeParagraph('ALTURA', 8.5, $66FFFFFF, False, False, TSkTextAlign.Center, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, LPanelRect.Left + 20, LY);

  LP := MakeParagraph('HABILIDADE', 8.5, $66FFFFFF, False, False, TSkTextAlign.Right, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, LPanelRect.Left + 20, LY);

  LY := LY + 16;

  LP := MakeParagraph(FWeight, 10, $FFFFFFFF, True, False, TSkTextAlign.Left, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, LPanelRect.Left + 20, LY);

  LP := MakeParagraph(FHeight, 10, $FFFFFFFF, True, False, TSkTextAlign.Center, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, LPanelRect.Left + 20, LY);

  LP := MakeParagraph(FAbility, 10, $FFFFFFFF, True, False, TSkTextAlign.Right, 1);
  LP.Layout(LLayoutW);
  LP.Paint(ACanvas, LPanelRect.Left + 20, LY);

  LY := LY + 20;

  if FAbilityDescription <> '' then
  begin
    LP := MakeParagraph(FAbilityDescription, 9, $99FFFFFF,
      True, False, TSkTextAlign.Center, 3);
    LP.Layout(LPanelRect.Width - 2 * PANEL_PAD);
    LP.Paint(ACanvas, LPanelRect.Left + PANEL_PAD, LY);
    LY := LY + LP.Height + 10;

    if FDescription <> '' then
    begin
      LPaint.Style       := TSkPaintStyle.Stroke;
      LPaint.StrokeWidth := 1;
      LPaint.Color       := $18FFFFFF;
      ACanvas.DrawLine(
        TPointF.Create(LPanelRect.Left + 24, LY),
        TPointF.Create(LPanelRect.Right - 24, LY), LPaint);
      LPaint.Style := TSkPaintStyle.Fill;
      LY := LY + 10;
    end;
  end;

  if FDescription <> '' then
  begin
    LP := MakeParagraph(FDescription, 10.5, $AAFFFFFF,
      False, True, TSkTextAlign.Center, 5);
    LP.Layout(LPanelRect.Width - 2 * PANEL_PAD);
    LP.Paint(ACanvas, LPanelRect.Left + PANEL_PAD, LY);
    LY := LY + LP.Height;
  end;

  if Length(FEffects) > 0 then
  begin
    LY := LY + 14;

    LPaint.Style       := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 1;
    LPaint.Color       := $22FFFFFF;
    ACanvas.DrawLine(
      TPointF.Create(LPanelRect.Left + 16, LY),
      TPointF.Create(LPanelRect.Right - 16, LY), LPaint);
    LPaint.Style := TSkPaintStyle.Fill;
    LY := LY + 10;

    LP := MakeParagraph('EFETIVIDADE DEFENSIVA', 8, $55FFFFFF,
      False, False, TSkTextAlign.Center, 1);
    LP.Layout(LPanelRect.Width);
    LP.Paint(ACanvas, LPanelRect.Left, LY);
    LY := LY + LP.Height + 6;

    for I := 0 to High(MULT_LABELS) do
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

      LP := MakeParagraph(MULT_LABELS[I], 10, FBarColor,
        True, False, TSkTextAlign.Left, 1);
      LP.Layout(34);
      LP.Paint(ACanvas, LPanelRect.Left + PANEL_PAD,
        LY + (20 - LP.Height) / 2);

      LX := LPanelRect.Left + PANEL_PAD + 34;

      for LEffect in FEffects do
      begin
        if Abs(LEffect.Multiplier - MULT_VALUES[I]) > 0.01 then
          Continue;

        LP := MakeParagraph(UpperCase(LEffect.TypeName), 7.5,
          $FFFFFFFF, True, False, TSkTextAlign.Left, 1);
        LP.Layout(300);
        LBadgeW := LP.LongestLine + 10 + 2;

        if LX + LBadgeW > LPanelRect.Right - PANEL_PAD then
        begin
          LX := LPanelRect.Left + PANEL_PAD + 34;
          LY := LY + 20;
        end;

        LBadgeRect := TRectF.Create(
          LX, LY + 2, LX + LBadgeW, LY + 18);

        LTColor     := TPokemonController.GetTypeColor(LEffect.TypeName);
        LBadgeAlpha := $FF000000
          or (DWORD(GetRValue(LTColor)) shl 16)
          or (DWORD(GetGValue(LTColor)) shl 8)
          or  DWORD(GetBValue(LTColor));
        LPaint.Color := LBadgeAlpha;
        ACanvas.DrawRoundRect(LBadgeRect, 3.5, 3.5, LPaint);

        LBadgeMidY := (LBadgeRect.Top + LBadgeRect.Bottom) / 2;
        LP.Paint(ACanvas, LX + 5 + 1, LBadgeMidY - LP.Height / 2);

        LX := LX + LBadgeW + 4;
      end;

      LY := LY + 22;
    end;
  end;

  ACanvas.Restore;
end;

end.

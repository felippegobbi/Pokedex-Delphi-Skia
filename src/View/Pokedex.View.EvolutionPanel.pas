unit Pokedex.View.EvolutionPanel;

interface

uses
  System.SysUtils,
  System.Classes,
  System.UITypes,
  System.Math,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  Vcl.Controls,
  System.Skia,
  Vcl.Skia,
  System.Types,
  Pokedex.Model.Pokemon;

type
  TEvolutionPanel = class(TSkPaintBox)
  private
    FNodes: TArray<TEvolutionNode>;
    FImages: TArray<ISkImage>;
    FNodeRects: TArray<TRectF>;
    FThemeColor: TAlphaColor;
    FFontFamily: string;
    FGeneration: Integer;
    FOnNodeClick: TProc<Integer>;
    FScrollOffset: Single;
    FMaxScroll: Single;
    procedure DrawEvolution(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure LoadSpriteAsync(const AIndex: Integer; const AUrl: string;
      const AGen: Integer);
    procedure HandleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    function FormatTrigger(const ATrigger: TEvolutionTrigger): string;
    function FormatItemName(const AName: string): string;
    function MakeTypeface: ISkTypeface;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadChain(const ANodes: TArray<TEvolutionNode>);
    property ThemeColor: TAlphaColor read FThemeColor write FThemeColor;
    property FontFamily: string read FFontFamily write FFontFamily;
    property OnNodeClick: TProc<Integer> read FOnNodeClick write FOnNodeClick;
  end;

implementation

const
  PANEL_PAD = 8;
  SCROLL_STEP = 60;
  MIN_ROW_H = 60.0;
  DARK_BG: TAlphaColor = $FF2A2A2A;
  GRAYSCALE_MATRIX: TSkColorMatrix = (
    M11: 0.299; M12: 0.587; M13: 0.114; M14: 0; M15: 0;
    M21: 0.299; M22: 0.587; M23: 0.114; M24: 0; M25: 0;
    M31: 0.299; M32: 0.587; M33: 0.114; M34: 0; M35: 0;
    M41: 0; M42: 0; M43: 0; M44: 1; M45: 0);

{ TEvolutionPanel }

constructor TEvolutionPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThemeColor   := $FFE25D27;
  FFontFamily   := '';
  FGeneration   := 0;
  FScrollOffset := 0;
  FMaxScroll    := 0;
  SetLength(FNodes, 0);
  SetLength(FImages, 0);
  SetLength(FNodeRects, 0);
  OnDraw      := DrawEvolution;
  OnMouseDown := HandleMouseDown;
  Cursor      := crHandPoint;
end;

procedure TEvolutionPanel.LoadChain(const ANodes: TArray<TEvolutionNode>);
var
  I, LGen: Integer;
begin
  FNodes        := ANodes;
  FScrollOffset := 0;
  Inc(FGeneration);
  LGen := FGeneration;
  SetLength(FImages, Length(ANodes));
  SetLength(FNodeRects, Length(ANodes));
  for I := 0 to High(FImages) do
    FImages[I] := nil;
  Redraw;
  for I := 0 to High(FNodes) do
    if not FNodes[I].SpriteUrl.IsEmpty then
      LoadSpriteAsync(I, FNodes[I].SpriteUrl, LGen);
end;

procedure TEvolutionPanel.LoadSpriteAsync(const AIndex: Integer;
  const AUrl: string; const AGen: Integer);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      LHttp: TNetHTTPClient;
      LStream: TMemoryStream;
      LBytes: TBytes;
      LImage: ISkImage;
    begin
      LImage := nil;
      LHttp  := TNetHTTPClient.Create(nil);
      LStream := TMemoryStream.Create;
      try
        try
          LHttp.Get(AUrl, LStream);
          if LStream.Size > 0 then
          begin
            SetLength(LBytes, LStream.Size);
            LStream.Position := 0;
            LStream.Read(LBytes[0], LStream.Size);
            LImage := TSkImage.MakeFromEncoded(LBytes);
          end;
        except
          LImage := nil;
        end;
      finally
        LHttp.Free;
        LStream.Free;
      end;
      TThread.Synchronize(TThread.CurrentThread, TThreadProcedure(
        procedure
        begin
          if AGen <> FGeneration then
            Exit;
          if AIndex < Length(FImages) then
          begin
            FImages[AIndex] := LImage;
            Redraw;
          end;
        end));
    end).Start;
end;

function TEvolutionPanel.MakeTypeface: ISkTypeface;
begin
  if FFontFamily <> '' then
    Result := TSkTypeface.MakeFromName(FFontFamily, TSkFontStyle.Normal)
  else
    Result := TSkTypeface.MakeDefault;
  if Result = nil then
    Result := TSkTypeface.MakeDefault;
end;

function TEvolutionPanel.FormatItemName(const AName: string): string;
var
  LParts: TArray<string>;
  I: Integer;
begin
  if AName.IsEmpty then
    Exit('');
  LParts := AName.Split(['-']);
  for I := 0 to High(LParts) do
    if LParts[I].Length > 0 then
      LParts[I] := LParts[I].Substring(0, 1).ToUpper + LParts[I].Substring(1);
  Result := string.Join(' ', LParts);
end;

function TEvolutionPanel.FormatTrigger(
  const ATrigger: TEvolutionTrigger): string;
begin
  Result := '';
  if ATrigger.TriggerType = 'use-item' then
    Result := FormatItemName(ATrigger.ItemName)
  else if ATrigger.TriggerType = 'trade' then
  begin
    if not ATrigger.HeldItem.IsEmpty then
      Result := 'Troca c/ ' + FormatItemName(ATrigger.HeldItem)
    else
      Result := 'Troca'
  end
  else if ATrigger.TriggerType = 'level-up' then
  begin
    if ATrigger.MinLevel > 0 then
      Result := 'Nv.' + ATrigger.MinLevel.ToString
    else if ATrigger.MinHappiness > 0 then
    begin
      if ATrigger.TimeOfDay = 'day' then
        Result := 'Amizade (Dia)'
      else if ATrigger.TimeOfDay = 'night' then
        Result := 'Amizade (Noite)'
      else
        Result := 'Amizade'
    end
    else if not ATrigger.KnownMoveType.IsEmpty then
      Result := 'Mov. ' + FormatItemName(ATrigger.KnownMoveType)
    else if ATrigger.TimeOfDay = 'day' then
      Result := 'Level (Dia)'
    else if ATrigger.TimeOfDay = 'night' then
      Result := 'Level (Noite)'
    else
      Result := 'Level Up'
  end
  else if ATrigger.TriggerType = 'shed' then
    Result := 'Nv.20 + slot'
  else if not ATrigger.TriggerType.IsEmpty then
    Result := FormatItemName(ATrigger.TriggerType);
end;

procedure TEvolutionPanel.CMMouseWheel(var Message: TCMMouseWheel);
begin
  if FMaxScroll > 0 then
  begin
    FScrollOffset := Max(0, Min(FMaxScroll,
      FScrollOffset - (Message.WheelDelta / 120) * SCROLL_STEP));
    Redraw;
    Message.Result := 1;
  end;
end;

procedure TEvolutionPanel.HandleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  LPoint: TPointF;
begin
  if Button <> mbLeft then
    Exit;
  if not Assigned(FOnNodeClick) then
    Exit;
  LPoint := TPointF.Create(X, Y);
  for I := 0 to High(FNodeRects) do
    if FNodeRects[I].Contains(LPoint) and (I < Length(FNodes)) then
    begin
      FOnNodeClick(FNodes[I].PokemonId);
      Exit;
    end;
end;

procedure TEvolutionPanel.DrawEvolution(ASender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LCount, I, J, S, LIdx: Integer;
  LMaxStage, LNumStages, LMaxRows: Integer;
  LPanelRect: TRectF;
  LUsableH, LColW, LRowH, LImgSize, LContentH: Single;
  LPaint: ISkPaint;
  LTypeface: ISkTypeface;
  LFontName, LFontTrigger: ISkFont;
  LMetrics: TSkFontMetrics;
  LCounts, LStageCounter: TArray<Integer>;
  LCx, LCy: TArray<Single>;
  LTrunkDrawn: TArray<Boolean>;
  LImgRect: TRectF;
  LGrayFilter: ISkColorFilter;
  LText: string;
  LTW: Single;
  LPCx, LPCy, LNCx, LNCy, LXMid: Single;
  LMinCY, LMaxCY: Single;
  LSibCount, LParentIdx: Integer;
  LScrollTrackH, LThumbH, LThumbY: Single;
begin
  LCount := Length(FNodes);
  if LCount = 0 then
    Exit;

  LPanelRect := TRectF.Create(ADest.Left + PANEL_PAD, ADest.Top + PANEL_PAD,
    ADest.Right - PANEL_PAD, ADest.Bottom - PANEL_PAD);
  LUsableH := LPanelRect.Height;

  // ── Layout: stages e linhas ──────────────────────────────────────────────

  LMaxStage := 0;
  for I := 0 to LCount - 1 do
    if FNodes[I].Stage > LMaxStage then
      LMaxStage := FNodes[I].Stage;
  LNumStages := LMaxStage + 1;

  SetLength(LCounts, LNumStages);
  for I := 0 to LNumStages - 1 do
    LCounts[I] := 0;
  for I := 0 to LCount - 1 do
    Inc(LCounts[FNodes[I].Stage]);

  LMaxRows := 1;
  for I := 0 to LNumStages - 1 do
    if LCounts[I] > LMaxRows then
      LMaxRows := LCounts[I];

  if LMaxRows <= 4 then
    LRowH := Max(MIN_ROW_H, LUsableH / LMaxRows)
  else
    LRowH := 72.0;

  LImgSize  := Min(48.0, Max(28.0, LRowH - 28.0));
  LContentH := LMaxRows * LRowH;

  FMaxScroll := Max(0.0, LContentH - LUsableH);
  if FScrollOffset > FMaxScroll then FScrollOffset := FMaxScroll;
  if FScrollOffset < 0 then FScrollOffset := 0;

  LColW := LPanelRect.Width / LNumStages;

  // ── Posições dos nós ─────────────────────────────────────────────────────

  SetLength(LCx, LCount);
  SetLength(LCy, LCount);
  SetLength(LStageCounter, LNumStages);
  for I := 0 to LNumStages - 1 do
    LStageCounter[I] := 0;

  for I := 0 to LCount - 1 do
  begin
    S    := FNodes[I].Stage;
    LIdx := LStageCounter[S];
    Inc(LStageCounter[S]);

    LCx[I] := LPanelRect.Left + S * LColW + LColW / 2;
    // Distribui os nós do stage uniformemente na altura total do conteúdo
    LCy[I] := LPanelRect.Top + (LIdx + 0.5) * (LContentH / LCounts[S])
      - FScrollOffset;
  end;

  SetLength(FNodeRects, LCount);
  for I := 0 to LCount - 1 do
    FNodeRects[I] := TRectF.Create(
      LCx[I] - LImgSize / 2, LCy[I] - LImgSize / 2,
      LCx[I] + LImgSize / 2, LCy[I] + LImgSize / 2);

  // ── Fundo arredondado ────────────────────────────────────────────────────

  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style     := TSkPaintStyle.Fill;
  LPaint.Color     := DARK_BG;
  ACanvas.DrawRoundRect(LPanelRect, 12, 12, LPaint);

  ACanvas.Save;
  ACanvas.ClipRect(LPanelRect, TSkClipOp.Intersect, False);

  // ── Fontes ───────────────────────────────────────────────────────────────

  LTypeface   := MakeTypeface;
  LFontName   := TSkFont.Create(LTypeface, 9);
  LFontName.Embolden := True;
  LFontName.GetMetrics(LMetrics);
  LFontTrigger := TSkFont.Create(LTypeface, 8);

  LGrayFilter := TSkColorFilter.MakeMatrix(GRAYSCALE_MATRIX);

  // ── Conexões (linhas + galhos) ────────────────────────────────────────────

  LPaint.Style       := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := 1.5;
  LPaint.Color       := $55FFFFFF;

  SetLength(LTrunkDrawn, LCount);
  for I := 0 to LCount - 1 do LTrunkDrawn[I] := False;

  for I := 0 to LCount - 1 do
  begin
    if FNodes[I].Stage = 0 then
      Continue;

    // Encontra o pai
    LParentIdx := -1;
    for J := 0 to LCount - 1 do
      if FNodes[J].PokemonId = FNodes[I].ParentId then
      begin
        LParentIdx := J;
        Break;
      end;
    if LParentIdx = -1 then
      Continue;

    // Conta irmãos (nós com mesmo pai)
    LSibCount := 0;
    for J := 0 to LCount - 1 do
      if FNodes[J].ParentId = FNodes[I].ParentId then
        Inc(LSibCount);

    LPCx := LCx[LParentIdx]; LPCy := LCy[LParentIdx];
    LNCx := LCx[I];          LNCy := LCy[I];
    LXMid := (LPCx + LNCx) / 2;

    if LSibCount = 1 then
    begin
      // Linha direta pai → filho
      ACanvas.DrawLine(TPointF.Create(LPCx, LPCy),
        TPointF.Create(LNCx, LNCy), LPaint);
    end
    else
    begin
      // Estilo árvore: tronco vertical + galhos horizontais
      if not LTrunkDrawn[LParentIdx] then
      begin
        // Faixa Y de todos os filhos deste pai
        LMinCY := LNCy; LMaxCY := LNCy;
        for J := 0 to LCount - 1 do
          if FNodes[J].ParentId = FNodes[I].ParentId then
          begin
            if LCy[J] < LMinCY then LMinCY := LCy[J];
            if LCy[J] > LMaxCY then LMaxCY := LCy[J];
          end;
        // Horizontal: pai → tronco
        ACanvas.DrawLine(TPointF.Create(LPCx, LPCy),
          TPointF.Create(LXMid, LPCy), LPaint);
        // Tronco vertical
        ACanvas.DrawLine(TPointF.Create(LXMid, LMinCY),
          TPointF.Create(LXMid, LMaxCY), LPaint);
        LTrunkDrawn[LParentIdx] := True;
      end;
      // Galho horizontal → filho
      ACanvas.DrawLine(TPointF.Create(LXMid, LNCy),
        TPointF.Create(LNCx - LImgSize / 2 - 2, LNCy), LPaint);
    end;
  end;

  // ── Texto de gatilho (acima de cada filho) ────────────────────────────────

  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := $BBFFFFFF;
  for I := 0 to LCount - 1 do
  begin
    if FNodes[I].Stage = 0 then
      Continue;
    LText := FormatTrigger(FNodes[I].Trigger);
    if LText.IsEmpty then
      Continue;
    LTW := LFontTrigger.MeasureText(LText, LPaint);
    ACanvas.DrawSimpleText(LText, LCx[I] - LTW / 2,
      LCy[I] - LImgSize / 2 - LMetrics.Descent - 2,
      LFontTrigger, LPaint);
  end;

  // ── Sprites e nomes ───────────────────────────────────────────────────────

  for I := 0 to LCount - 1 do
  begin
    LImgRect := TRectF.Create(
      LCx[I] - LImgSize / 2, LCy[I] - LImgSize / 2,
      LCx[I] + LImgSize / 2, LCy[I] + LImgSize / 2);

    LPaint.Style := TSkPaintStyle.Fill;

    if (I < Length(FImages)) and Assigned(FImages[I]) then
    begin
      if FNodes[I].IsActive then
        LPaint.ColorFilter := nil
      else
        LPaint.ColorFilter := LGrayFilter;
      ACanvas.DrawImageRect(FImages[I], LImgRect,
        TSkSamplingOptions.Create(TSkFilterMode.Linear, TSkMipmapMode.None),
        LPaint);
      LPaint.ColorFilter := nil;
    end
    else
    begin
      LPaint.ColorFilter := nil;
      if FNodes[I].IsActive then
        LPaint.Color := FThemeColor
      else
        LPaint.Color := $33FFFFFF;
      ACanvas.DrawCircle(LCx[I], LCy[I], LImgSize / 2 - 2, LPaint);
    end;

    // Nome abaixo do sprite
    LPaint.Style       := TSkPaintStyle.Fill;
    LPaint.ColorFilter := nil;
    if FNodes[I].IsActive then
      LPaint.Color := FThemeColor
    else
      LPaint.Color := $99FFFFFF;
    LText := FNodes[I].Name;
    LTW   := LFontName.MeasureText(LText, LPaint);
    ACanvas.DrawSimpleText(LText, LCx[I] - LTW / 2,
      LCy[I] + LImgSize / 2 - LMetrics.Ascent + 2,
      LFontName, LPaint);
  end;

  // ── Indicador de scroll ───────────────────────────────────────────────────

  if FMaxScroll > 0 then
  begin
    LPaint.Style := TSkPaintStyle.Fill;
    LPaint.Color := $55FFFFFF;
    LScrollTrackH := LPanelRect.Height - 8;
    LThumbH := Max(20.0, LScrollTrackH * (LUsableH / LContentH));
    LThumbY := LPanelRect.Top + 4 +
      (FScrollOffset / FMaxScroll) * (LScrollTrackH - LThumbH);
    ACanvas.DrawRoundRect(
      TRectF.Create(LPanelRect.Right - 5, LThumbY,
        LPanelRect.Right - 2, LThumbY + LThumbH),
      2, 2, LPaint);
  end;

  ACanvas.Restore;
end;

end.

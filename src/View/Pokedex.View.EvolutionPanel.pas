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
    procedure DrawEvolution(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure LoadSpriteAsync(const AIndex: Integer; const AUrl: string;
      const AGen: Integer);
    procedure HandleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function FormatTrigger(const ATrigger: TEvolutionTrigger): string;
    function FormatItemName(const AName: string): string;
    function MakeParagraph(const AText: string; AFontSize: Single;
      AColor: TAlphaColor; ABold: Boolean): ISkParagraph;
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
  // Fan layout: evolutions in vertical columns on each side of root
  FAN_SPRITE_INSET  = 75.0;   // sprite column from panel edge
  FAN_BRACKET_INSET = 235.0;  // vertical bracket bar from panel edge
  FAN_IMG_SIZE      = 36.0;   // sprite size for fan evolutions
  DARK_BG: TAlphaColor = $FF2A2A2A;
  GRAYSCALE_MATRIX: TSkColorMatrix = (
    M11: 0.299; M12: 0.587; M13: 0.114; M14: 0; M15: 0;
    M21: 0.299; M22: 0.587; M23: 0.114; M24: 0; M25: 0;
    M31: 0.299; M32: 0.587; M33: 0.114; M34: 0; M35: 0;
    M41: 0; M42: 0; M43: 0; M44: 1; M45: 0);

constructor TEvolutionPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThemeColor := $FFE25D27;
  FFontFamily := '';
  FGeneration := 0;
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
  FNodes := ANodes;
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
      LImage  := nil;
      LHttp   := TNetHTTPClient.Create(nil);
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

function TEvolutionPanel.MakeParagraph(const AText: string; AFontSize: Single;
  AColor: TAlphaColor; ABold: Boolean): ISkParagraph;
var
  LParaStyle: ISkParagraphStyle;
  LTextStyle: ISkTextStyle;
  LBuilder: ISkParagraphBuilder;
begin
  LParaStyle := TSkParagraphStyle.Create;
  LParaStyle.MaxLines  := 2;
  LParaStyle.TextAlign := TSkTextAlign.Center;
  LParaStyle.Ellipsis  := '...';

  LTextStyle := TSkTextStyle.Create;
  if FFontFamily <> '' then
    LTextStyle.FontFamilies := [FFontFamily, 'Segoe UI']
  else
    LTextStyle.FontFamilies := ['Segoe UI'];
  LTextStyle.FontSize  := AFontSize;
  LTextStyle.Color     := AColor;
  if ABold then
    LTextStyle.FontStyle := TSkFontStyle.Bold
  else
    LTextStyle.FontStyle := TSkFontStyle.Normal;

  LBuilder := TSkParagraphBuilder.Create(LParaStyle);
  LBuilder.PushStyle(LTextStyle);
  LBuilder.AddText(AText);
  LBuilder.Pop;
  Result := LBuilder.Build;
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
      Result := 'Troca';
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
        Result := 'Amizade';
    end
    else if not ATrigger.KnownMoveType.IsEmpty then
      Result := 'Mov. ' + FormatItemName(ATrigger.KnownMoveType)
    else if ATrigger.TimeOfDay = 'day' then
      Result := 'Level (Dia)'
    else if ATrigger.TimeOfDay = 'night' then
      Result := 'Level (Noite)'
    else
      Result := 'Level Up';
  end
  else if ATrigger.TriggerType = 'shed' then
    Result := 'Nv.20 + slot'
  else if not ATrigger.TriggerType.IsEmpty then
    Result := FormatItemName(ATrigger.TriggerType);
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
  LCount, I, J, S: Integer;
  LMaxStage, LNumStages: Integer;
  LUsableW, LUsableH: Single;
  LColW, LRowH, LLeafSlotW: Single;
  LImgSize, LTextW: Single;
  LNameFontSize, LTriggerFontSize, LMaxImgV: Single;
  LPanelRect: TRectF;
  LPaint: ISkPaint;
  LIsLeaf: TArray<Boolean>;
  LLeafCount, LLeafAssigned, LSibCount, LParentIdx: Integer;
  LCx, LCy: TArray<Single>;
  LTrunkDrawn: TArray<Boolean>;
  LGrayFilter: ISkColorFilter;
  LImgRect: TRectF;
  LParagraph: ISkParagraph;
  LText: string;
  LMidY, LMinCX, LMaxCX: Single;
  LNameColor: TAlphaColor;
  LUseHorizontal: Boolean;
  LRootIsActive: Boolean;
  LRootIdx: Integer;
  LUseCenterFan: Boolean;
  LHalfCount, LRightCount: Integer;
  LLeftIdx, LRightIdx: Integer;
  LSpriteX_L, LSpriteX_R: Single;
  LBracketX_L, LBracketX_R: Single;
  LMinYL, LMaxYL, LMinYR, LMaxYR: Single;
begin
  LCount := Length(FNodes);
  if LCount = 0 then
    Exit;

  LPanelRect := TRectF.Create(ADest.Left + PANEL_PAD, ADest.Top + PANEL_PAD,
    ADest.Right - PANEL_PAD, ADest.Bottom - PANEL_PAD);
  LUsableW := LPanelRect.Width;
  LUsableH := LPanelRect.Height;

  LMaxStage := 0;
  for I := 0 to LCount - 1 do
    if FNodes[I].Stage > LMaxStage then
      LMaxStage := FNodes[I].Stage;
  LNumStages := LMaxStage + 1;

  SetLength(LIsLeaf, LCount);
  LLeafCount := 0;
  for I := 0 to LCount - 1 do
  begin
    LIsLeaf[I] := True;
    for J := 0 to LCount - 1 do
      if FNodes[J].ParentId = FNodes[I].PokemonId then
      begin
        LIsLeaf[I] := False;
        Break;
      end;
    if LIsLeaf[I] then
      Inc(LLeafCount);
  end;
  if LLeafCount = 0 then
    LLeafCount := 1;

  LUseHorizontal := (LLeafCount <= 1);

  LRootIsActive := False;
  LRootIdx      := -1;
  for I := 0 to LCount - 1 do
    if (FNodes[I].Stage = 0) and FNodes[I].IsActive then
    begin
      LRootIsActive := True;
      LRootIdx      := I;
      Break;
    end;
  LUseCenterFan := (not LUseHorizontal) and LRootIsActive
    and (LLeafCount >= 4) and (LMaxStage = 1);

  SetLength(LCx, LCount);
  SetLength(LCy, LCount);
  LColW      := 0;
  LRowH      := 0;
  LLeafSlotW := 0;
  LSpriteX_L := 0; LSpriteX_R := 0;
  LBracketX_L := 0; LBracketX_R := 0;
  LHalfCount := 0; LRightCount := 0;
  LLeftIdx := 0; LRightIdx := 0;

  if LUseHorizontal then
  begin
    LColW    := LUsableW / LNumStages;
    LImgSize := Max(48.0, Min(96.0, LColW * 0.42));
    LTextW   := Min(140.0, LColW - 8.0);
    for I := 0 to LCount - 1 do
    begin
      LCx[I] := LPanelRect.Left + (FNodes[I].Stage + 0.5) * LColW;
      LCy[I] := LPanelRect.Top + LUsableH / 2;
    end;
  end
  else if LUseCenterFan then
  begin
    LHalfCount  := LLeafCount div 2;
    LRightCount := LLeafCount - LHalfCount;
    LImgSize    := FAN_IMG_SIZE;
    LTextW      := 64.0;

    LSpriteX_L  := LPanelRect.Left  + FAN_SPRITE_INSET;
    LBracketX_L := LPanelRect.Left  + FAN_BRACKET_INSET;
    LBracketX_R := LPanelRect.Right - FAN_BRACKET_INSET;
    LSpriteX_R  := LPanelRect.Right - FAN_SPRITE_INSET;

    LCx[LRootIdx] := LPanelRect.Left + LUsableW / 2;
    LCy[LRootIdx] := LPanelRect.Top  + LUsableH / 2;

    LLeftIdx  := 0;
    LRightIdx := 0;
    for I := 0 to LCount - 1 do
      if FNodes[I].Stage > 0 then
      begin
        if LLeftIdx < LHalfCount then
        begin
          LCx[I] := LSpriteX_L;
          LCy[I] := LPanelRect.Top + (LLeftIdx + 0.5) * (LUsableH / LHalfCount);
          Inc(LLeftIdx);
        end
        else
        begin
          LCx[I] := LSpriteX_R;
          LCy[I] := LPanelRect.Top + (LRightIdx + 0.5) * (LUsableH / LRightCount);
          Inc(LRightIdx);
        end;
      end;
  end
  else
  begin
    LRowH      := LUsableH / LNumStages;
    LLeafSlotW := LUsableW / LLeafCount;
    LMaxImgV   := Max(36.0, 72.0 - LLeafCount * 4.0);
    LImgSize   := Max(28.0, Min(LMaxImgV, Min(LRowH * 0.55, LLeafSlotW * 0.55)));
    LTextW     := Min(120.0, LLeafSlotW - 8.0);

    for I := 0 to LCount - 1 do
      LCy[I] := LPanelRect.Top + (FNodes[I].Stage + 0.5) * LRowH;

    LLeafAssigned := 0;
    for I := 0 to LCount - 1 do
      if LIsLeaf[I] then
      begin
        LCx[I] := LPanelRect.Left + (LLeafAssigned + 0.5) * LLeafSlotW;
        Inc(LLeafAssigned);
      end;

    for S := LMaxStage - 1 downto 0 do
      for I := 0 to LCount - 1 do
        if FNodes[I].Stage = S then
        begin
          var LSum: Single      := 0;
          var LChildCount: Integer := 0;
          for J := 0 to LCount - 1 do
            if FNodes[J].ParentId = FNodes[I].PokemonId then
            begin
              LSum := LSum + LCx[J];
              Inc(LChildCount);
            end;
          if LChildCount > 0 then
            LCx[I] := LSum / LChildCount
          else
            LCx[I] := LPanelRect.Left + LUsableW / 2;
        end;
  end;

  LNameFontSize    := Max(8.0, Min(14.0, LImgSize * 0.20));
  LTriggerFontSize := Max(8.0, Min(11.0, LImgSize * 0.16));

  SetLength(FNodeRects, LCount);
  for I := 0 to LCount - 1 do
    FNodeRects[I] := TRectF.Create(
      LCx[I] - LImgSize / 2, LCy[I] - LImgSize / 2,
      LCx[I] + LImgSize / 2, LCy[I] + LImgSize / 2);

  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style     := TSkPaintStyle.Fill;

  LPaint.Color := FThemeColor;
  ACanvas.DrawRect(ADest, LPaint);

  LPaint.Color := DARK_BG;
  ACanvas.DrawRoundRect(LPanelRect, 12, 12, LPaint);

  ACanvas.Save;
  ACanvas.ClipRect(LPanelRect, TSkClipOp.Intersect, False);

  LGrayFilter := TSkColorFilter.MakeMatrix(GRAYSCALE_MATRIX);

  LPaint.Style       := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := 1.5;
  LPaint.Color       := $55FFFFFF;
  LMidY  := 0;
  LMinCX := 0;
  LMaxCX := 0;

  if LUseCenterFan then
  begin
    LMinYL := MaxSingle; LMaxYL := -MaxSingle;
    LMinYR := MaxSingle; LMaxYR := -MaxSingle;
    for I := 0 to LCount - 1 do
      if FNodes[I].Stage > 0 then
      begin
        if LCx[I] < LCx[LRootIdx] then
        begin
          if LCy[I] < LMinYL then LMinYL := LCy[I];
          if LCy[I] > LMaxYL then LMaxYL := LCy[I];
        end
        else
        begin
          if LCy[I] < LMinYR then LMinYR := LCy[I];
          if LCy[I] > LMaxYR then LMaxYR := LCy[I];
        end;
      end;

    if LMinYL < MaxSingle then
      ACanvas.DrawLine(TPointF.Create(LBracketX_L, LMinYL),
        TPointF.Create(LBracketX_L, LMaxYL), LPaint);
    for I := 0 to LCount - 1 do
      if (FNodes[I].Stage > 0) and (LCx[I] < LCx[LRootIdx]) then
        ACanvas.DrawLine(TPointF.Create(LCx[I] + LImgSize / 2, LCy[I]),
          TPointF.Create(LBracketX_L, LCy[I]), LPaint);
    ACanvas.DrawLine(TPointF.Create(LBracketX_L, LCy[LRootIdx]),
      TPointF.Create(LCx[LRootIdx] - LImgSize / 2, LCy[LRootIdx]), LPaint);

    if LMinYR < MaxSingle then
      ACanvas.DrawLine(TPointF.Create(LBracketX_R, LMinYR),
        TPointF.Create(LBracketX_R, LMaxYR), LPaint);
    for I := 0 to LCount - 1 do
      if (FNodes[I].Stage > 0) and (LCx[I] >= LCx[LRootIdx]) then
        ACanvas.DrawLine(TPointF.Create(LBracketX_R, LCy[I]),
          TPointF.Create(LCx[I] - LImgSize / 2, LCy[I]), LPaint);
    ACanvas.DrawLine(TPointF.Create(LCx[LRootIdx] + LImgSize / 2, LCy[LRootIdx]),
      TPointF.Create(LBracketX_R, LCy[LRootIdx]), LPaint);
  end
  else if LUseHorizontal then
  begin
    for I := 0 to LCount - 1 do
    begin
      if FNodes[I].Stage = 0 then
        Continue;
      LParentIdx := -1;
      for J := 0 to LCount - 1 do
        if FNodes[J].PokemonId = FNodes[I].ParentId then
        begin
          LParentIdx := J;
          Break;
        end;
      if LParentIdx = -1 then
        Continue;
      ACanvas.DrawLine(
        TPointF.Create(LCx[LParentIdx] + LImgSize / 2, LCy[LParentIdx]),
        TPointF.Create(LCx[I]          - LImgSize / 2, LCy[I]),
        LPaint);
    end;
  end
  else
  begin
    SetLength(LTrunkDrawn, LCount);
    for I := 0 to LCount - 1 do
      LTrunkDrawn[I] := False;

    for I := 0 to LCount - 1 do
    begin
      if FNodes[I].Stage = 0 then
        Continue;
      LParentIdx := -1;
      for J := 0 to LCount - 1 do
        if FNodes[J].PokemonId = FNodes[I].ParentId then
        begin
          LParentIdx := J;
          Break;
        end;
      if LParentIdx = -1 then
        Continue;

      LSibCount := 0;
      for J := 0 to LCount - 1 do
        if FNodes[J].ParentId = FNodes[I].ParentId then
          Inc(LSibCount);

      LMidY := (LCy[LParentIdx] + LCy[I]) / 2;

      if LSibCount = 1 then
      begin
        ACanvas.DrawLine(
          TPointF.Create(LCx[LParentIdx], LCy[LParentIdx] + LImgSize / 2),
          TPointF.Create(LCx[I],          LCy[I]          - LImgSize / 2),
          LPaint);
      end
      else
      begin
        if not LTrunkDrawn[LParentIdx] then
        begin
          LMinCX := LCx[I];
          LMaxCX := LCx[I];
          for J := 0 to LCount - 1 do
            if FNodes[J].ParentId = FNodes[I].ParentId then
            begin
              if LCx[J] < LMinCX then LMinCX := LCx[J];
              if LCx[J] > LMaxCX then LMaxCX := LCx[J];
            end;
          ACanvas.DrawLine(
            TPointF.Create(LCx[LParentIdx], LCy[LParentIdx] + LImgSize / 2),
            TPointF.Create(LCx[LParentIdx], LMidY), LPaint);
          ACanvas.DrawLine(
            TPointF.Create(LMinCX, LMidY),
            TPointF.Create(LMaxCX, LMidY), LPaint);
          LTrunkDrawn[LParentIdx] := True;
        end;
        ACanvas.DrawLine(
          TPointF.Create(LCx[I], LMidY),
          TPointF.Create(LCx[I], LCy[I] - LImgSize / 2), LPaint);
      end;
    end;
  end;

  for I := 0 to LCount - 1 do
  begin
    if FNodes[I].Stage = 0 then
      Continue;
    if LUseCenterFan then
      Continue; // no vertical room for trigger text in bracket fan
    LText := FormatTrigger(FNodes[I].Trigger);
    if LText.IsEmpty then
      Continue;
    LParagraph := MakeParagraph(LText, LTriggerFontSize, $BBFFFFFF, False);
    LParagraph.Layout(LTextW);
    LParagraph.Paint(ACanvas,
      LCx[I] - LTextW / 2,
      LCy[I] - LImgSize / 2 - LParagraph.Height - 1);
  end;

  LPaint.Style := TSkPaintStyle.Fill;

  for I := 0 to LCount - 1 do
  begin
    LImgRect := FNodeRects[I];

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

    if FNodes[I].IsActive then
      LNameColor := FThemeColor
    else
      LNameColor := $AAFFFFFF;

    LParagraph := MakeParagraph(FNodes[I].Name, LNameFontSize, LNameColor, True);
    LParagraph.Layout(LTextW);
    LParagraph.Paint(ACanvas, LCx[I] - LTextW / 2, LCy[I] + LImgSize / 2 + 2);
  end;

  ACanvas.Restore;
end;

end.

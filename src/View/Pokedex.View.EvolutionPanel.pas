unit Pokedex.View.EvolutionPanel;

interface

uses
  System.SysUtils,
  System.Classes,
  System.UITypes,
  System.Math,
  Winapi.Windows,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  Vcl.Controls,
  System.Skia,
  Vcl.Skia,
  System.Types,
  Pokedex.Model.Pokemon;

type
  TEvolutionImageState = (eisIdle, eisLoading, eisLoaded, eisFailed);

  TEvolutionPanel = class(TSkPaintBox)
  private
    FFullNodes: TArray<TEvolutionNode>;
    FFullImages: TArray<ISkImage>;
    FFullStates: TArray<TEvolutionImageState>;
    FPageIdxs: TArray<Integer>;
    FNodeRects: TArray<TRectF>;
    FThemeColor: TAlphaColor;
    FFontFamily: string;
    FGeneration: Integer;
    FOnNodeClick: TProc<Integer>;
    FEvoPage: Integer;
    FEvoPageTotal: Integer;
    FArrowLeftRect: TRectF;
    FArrowRightRect: TRectF;
    FHoveredArrow: Integer; // 0=none, 1=left, 2=right
    FIsDestroying: Boolean;
    procedure ComputePageIdxs;
    procedure DrawEvolution(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure LoadSpriteAsync(const AIndex: Integer; const AUrl: string;
      const AGen: Integer);
    procedure HandleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HandleMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    function FormatTrigger(const ATrigger: TEvolutionTrigger): string;
    function FormatItemName(const AName: string): string;
    function CapitalizeName(const AName: string): string;
    function GetHighlightColor: TAlphaColor;
    function MakeParagraph(const AText: string; AFontSize: Single;
      AColor: TAlphaColor; ABold: Boolean): ISkParagraph;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadChain(const ANodes: TArray<TEvolutionNode>);
    property ThemeColor: TAlphaColor read FThemeColor write FThemeColor;
    property FontFamily: string read FFontFamily write FFontFamily;
    property OnNodeClick: TProc<Integer> read FOnNodeClick write FOnNodeClick;
  end;

implementation

const
  PANEL_PAD = 8;
  FAN_SPRITE_INSET = 75.0;
  FAN_BRACKET_INSET = 235.0;
  FAN_IMG_SIZE = 36.0;
  DARK_BG: TAlphaColor = $FF2A2A2A;
  HTTP_TIMEOUT_MS = 10000;
  EVO_PAGE_SIZE = 2;
  GRAYSCALE_MATRIX: TSkColorMatrix = (M11: 0.299; M12: 0.587; M13: 0.114;
    M14: 0; M15: 0; M21: 0.299; M22: 0.587; M23: 0.114; M24: 0; M25: 0;
    M31: 0.299; M32: 0.587; M33: 0.114; M34: 0; M35: 0; M41: 0; M42: 0; M43: 0;
    M44: 1; M45: 0);

constructor TEvolutionPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThemeColor := $FFE25D27;
  FFontFamily := '';
  FGeneration := 0;
  FEvoPage := 0;
  FEvoPageTotal := 0;
  FArrowLeftRect := TRectF.Empty;
  FArrowRightRect := TRectF.Empty;
  SetLength(FFullNodes, 0);
  SetLength(FFullImages, 0);
  SetLength(FFullStates, 0);
  SetLength(FPageIdxs, 0);
  SetLength(FNodeRects, 0);
  OnDraw := DrawEvolution;
  OnMouseDown := HandleMouseDown;
  OnMouseMove := HandleMouseMove;
  Cursor := crHandPoint;
end;

destructor TEvolutionPanel.Destroy;
begin
  FIsDestroying := True;
  // Clear arrays
  SetLength(FFullNodes, 0);
  SetLength(FFullImages, 0);
  SetLength(FFullStates, 0);
  SetLength(FPageIdxs, 0);
  SetLength(FNodeRects, 0);
  inherited Destroy;
end;

procedure TEvolutionPanel.ComputePageIdxs;
var
  I, J, LLeafCount, LLeafStart, LLeafEnd, LLeafIdx: Integer;
  LIsLeaf: TArray<Boolean>;
  LLeafOrder: TArray<Integer>;
  LIncluded: TArray<Boolean>;
  LFullCount: Integer;
  LParId: Integer;
  LFound: Boolean;
begin
  LFullCount := Length(FFullNodes);
  if LFullCount = 0 then
  begin
    SetLength(FPageIdxs, 0);
    FEvoPageTotal := 0;
    Exit;
  end;

  // Build LIsLeaf for full nodes
  SetLength(LIsLeaf, LFullCount);
  LLeafCount := 0;
  for I := 0 to LFullCount - 1 do
  begin
    LIsLeaf[I] := True;
    for J := 0 to LFullCount - 1 do
      if FFullNodes[J].ParentId = FFullNodes[I].PokemonId then
      begin
        LIsLeaf[I] := False;
        Break;
      end;
    if LIsLeaf[I] then
      Inc(LLeafCount);
  end;

  // No pagination for simple chains (<=2 leaves)
  if LLeafCount <= 2 then
  begin
    FEvoPageTotal := 0;
    SetLength(FPageIdxs, LFullCount);
    for I := 0 to LFullCount - 1 do
      FPageIdxs[I] := I;
    Exit;
  end;

  // Collect leaf order
  SetLength(LLeafOrder, 0);
  for I := 0 to LFullCount - 1 do
    if LIsLeaf[I] then
    begin
      SetLength(LLeafOrder, Length(LLeafOrder) + 1);
      LLeafOrder[High(LLeafOrder)] := I;
    end;

  FEvoPageTotal := Ceil(LLeafCount / EVO_PAGE_SIZE);
  FEvoPage := EnsureRange(FEvoPage, 0, FEvoPageTotal - 1);
  LLeafStart := FEvoPage * EVO_PAGE_SIZE;
  LLeafEnd := Min(High(LLeafOrder), LLeafStart + EVO_PAGE_SIZE - 1);

  // Build included set: stage-0 nodes + selected leaves + their ancestors
  SetLength(LIncluded, LFullCount);
  for I := 0 to LFullCount - 1 do
    LIncluded[I] := FFullNodes[I].Stage = 0;

  for LLeafIdx := LLeafStart to LLeafEnd do
  begin
    I := LLeafOrder[LLeafIdx];
    LIncluded[I] := True;
    LParId := FFullNodes[I].ParentId;
    while LParId > 0 do
    begin
      LFound := False;
      for J := 0 to LFullCount - 1 do
        if FFullNodes[J].PokemonId = LParId then
        begin
          LIncluded[J] := True;
          LParId := FFullNodes[J].ParentId;
          LFound := True;
          Break;
        end;
      if not LFound then
        Break;
    end;
  end;

  SetLength(FPageIdxs, 0);
  for I := 0 to LFullCount - 1 do
    if LIncluded[I] then
    begin
      SetLength(FPageIdxs, Length(FPageIdxs) + 1);
      FPageIdxs[High(FPageIdxs)] := I;
    end;
end;

procedure TEvolutionPanel.LoadChain(const ANodes: TArray<TEvolutionNode>);
var
  I, LGen: Integer;
begin
  FFullNodes := ANodes;
  FEvoPage := 0;
  Inc(FGeneration);
  LGen := FGeneration;
  SetLength(FFullImages, Length(ANodes));
  SetLength(FFullStates, Length(ANodes));
  for I := 0 to High(FFullImages) do
  begin
    FFullImages[I] := nil;
    if FFullNodes[I].SpriteUrl.IsEmpty then
      FFullStates[I] := eisFailed
    else
      FFullStates[I] := eisLoading;
  end;
  ComputePageIdxs;
  Redraw;
  for I := 0 to High(FFullNodes) do
    if not FFullNodes[I].SpriteUrl.IsEmpty then
      LoadSpriteAsync(I, FFullNodes[I].SpriteUrl, LGen);
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
      LHttp := TNetHTTPClient.Create(nil);
      LStream := TMemoryStream.Create;
      try
        LHttp.ConnectionTimeout := HTTP_TIMEOUT_MS;
        LHttp.ResponseTimeout := HTTP_TIMEOUT_MS;
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
          if FIsDestroying then Exit;
          if AGen <> FGeneration then
            Exit;
          if AIndex < Length(FFullImages) then
          begin
            FFullImages[AIndex] := LImage;
            if Assigned(LImage) then
              FFullStates[AIndex] := eisLoaded
            else
              FFullStates[AIndex] := eisFailed;
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
  LParaStyle.MaxLines := 2;
  LParaStyle.TextAlign := TSkTextAlign.Center;
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

function TEvolutionPanel.CapitalizeName(const AName: string): string;
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
  Result := string.Join('-', LParts);
end;

function TEvolutionPanel.GetHighlightColor: TAlphaColor;
var
  LR, LG, LB, LLum, LBoost: Integer;
begin
  LR := GetRValue(FThemeColor and $00FFFFFF);
  LG := GetGValue(FThemeColor and $00FFFFFF);
  LB := GetBValue(FThemeColor and $00FFFFFF);
  LLum := Round(0.2126 * LR + 0.7152 * LG + 0.0722 * LB);
  if LLum >= 120 then
    Exit(FThemeColor);

  LBoost := 120 - LLum;
  LR := Min(255, LR + LBoost);
  LG := Min(255, LG + LBoost);
  LB := Min(255, LB + LBoost);
  Result := $FF000000 or (DWORD(LR) shl 16) or (DWORD(LG) shl 8) or DWORD(LB);
end;

function TEvolutionPanel.FormatTrigger(const ATrigger
  : TEvolutionTrigger): string;
begin
  Result := '';
  if ATrigger.TriggerType = 'use-item' then
    Result := UpperCase(FormatItemName(ATrigger.ItemName))
  else if ATrigger.TriggerType = 'trade' then
  begin
    if not ATrigger.HeldItem.IsEmpty then
      Result := 'TROCA COM ' + UpperCase(FormatItemName(ATrigger.HeldItem))
    else
      Result := 'TROCA';
  end
  else if ATrigger.TriggerType = 'level-up' then
  begin
    if ATrigger.MinLevel > 0 then
      Result := 'N'#205'VEL ' + ATrigger.MinLevel.ToString
    else if ATrigger.MinHappiness > 0 then
    begin
      if ATrigger.TimeOfDay = 'day' then
        Result := 'AMIZADE (DIA)'
      else if ATrigger.TimeOfDay = 'night' then
        Result := 'AMIZADE (NOITE)'
      else
        Result := 'AMIZADE';
    end
    else if not ATrigger.KnownMoveType.IsEmpty then
      Result := 'MOVE ' + UpperCase(FormatItemName(ATrigger.KnownMoveType))
    else if ATrigger.TimeOfDay = 'day' then
      Result := 'LEVEL UP (DIA)'
    else if ATrigger.TimeOfDay = 'night' then
      Result := 'LEVEL UP (NOITE)'
    else
      Result := 'LEVEL UP';
  end
  else if ATrigger.TriggerType = 'shed' then
    Result := 'N'#205'VEL 20 + SLOT'
  else if not ATrigger.TriggerType.IsEmpty then
    Result := UpperCase(FormatItemName(ATrigger.TriggerType));
end;

procedure TEvolutionPanel.HandleMouseDown(Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  LPoint: TPointF;
begin
  if Button <> mbLeft then
    Exit;
  LPoint := TPointF.Create(X, Y);

  // Navigation arrow clicks
  if FEvoPageTotal > 1 then
  begin
    if FArrowLeftRect.Contains(LPoint) and (FEvoPage > 0) then
    begin
      Dec(FEvoPage);
      ComputePageIdxs;
      Redraw;
      Exit;
    end;
    if FArrowRightRect.Contains(LPoint) and (FEvoPage < FEvoPageTotal - 1) then
    begin
      Inc(FEvoPage);
      ComputePageIdxs;
      Redraw;
      Exit;
    end;
  end;

  // Node clicks — FNodeRects maps to FPageIdxs → FFullNodes
  if not Assigned(FOnNodeClick) then
    Exit;
  for I := 0 to High(FNodeRects) do
    if FNodeRects[I].Contains(LPoint) and (I < Length(FPageIdxs)) then
    begin
      var
      LOrigIdx := FPageIdxs[I];
      if LOrigIdx < Length(FFullNodes) then
        FOnNodeClick(FFullNodes[LOrigIdx].PokemonId);
      Exit;
    end;
end;

procedure TEvolutionPanel.HandleMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  LPoint: TPointF;
  LNewHovered: Integer;
begin
  LNewHovered := 0;
  LPoint := TPointF.Create(X, Y);

  if FEvoPageTotal > 1 then
  begin
    if FArrowLeftRect.Contains(LPoint) and (FEvoPage > 0) then
      LNewHovered := 1
    else if FArrowRightRect.Contains(LPoint) and (FEvoPage < FEvoPageTotal - 1) then
      LNewHovered := 2;
  end;

  if LNewHovered <> FHoveredArrow then
  begin
    FHoveredArrow := LNewHovered;
    Redraw;
  end;
end;

procedure TEvolutionPanel.DrawEvolution(ASender: TObject;
const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LCount, I, J: Integer;
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
  LHighlightColor: TAlphaColor;
  LOrigIdx: Integer;
  LUsePaginatedHorizontal: Boolean;
  LNonRootIdxs: array [0 .. 1] of Integer;
  LNonRootCount: Integer;
begin
  LCount := Length(FPageIdxs);
  if LCount = 0 then
    Exit;

  LPanelRect := TRectF.Create(ADest.Left + PANEL_PAD, ADest.Top + PANEL_PAD,
    ADest.Right - PANEL_PAD, ADest.Bottom - PANEL_PAD);
  LUsableW := LPanelRect.Width;
  LUsableH := LPanelRect.Height;

  LMaxStage := 0;
  for I := 0 to LCount - 1 do
  begin
    LOrigIdx := FPageIdxs[I];
    if FFullNodes[LOrigIdx].Stage > LMaxStage then
      LMaxStage := FFullNodes[LOrigIdx].Stage;
  end;
  LNumStages := LMaxStage + 1;

  SetLength(LIsLeaf, LCount);
  LLeafCount := 0;
  for I := 0 to LCount - 1 do
  begin
    LIsLeaf[I] := True;
    for J := 0 to LCount - 1 do
      if FFullNodes[FPageIdxs[J]].ParentId = FFullNodes[FPageIdxs[I]].PokemonId
      then
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
  LRootIdx := -1;
  for I := 0 to LCount - 1 do
    if (FFullNodes[FPageIdxs[I]].Stage = 0) and FFullNodes[FPageIdxs[I]].IsActive
    then
    begin
      LRootIsActive := True;
      LRootIdx := I;
      Break;
    end;
  LUseCenterFan := (not LUseHorizontal) and LRootIsActive and (LLeafCount >= 4)
    and (LMaxStage = 1);
  LUsePaginatedHorizontal := (FEvoPageTotal > 1) and (LMaxStage = 1);
  if LUsePaginatedHorizontal then
  begin
    LUseHorizontal := False;
    LUseCenterFan := False;
  end;

  // Find root for layouts that need it
  if LRootIdx = -1 then
    for I := 0 to LCount - 1 do
      if FFullNodes[FPageIdxs[I]].Stage = 0 then
      begin
        LRootIdx := I;
        Break;
      end;

  SetLength(LCx, LCount);
  SetLength(LCy, LCount);
  LRowH := 0;
  LLeafSlotW := 0;
  LSpriteX_L := 0;
  LSpriteX_R := 0;
  LBracketX_L := 0;
  LBracketX_R := 0;
  LHalfCount := 0;
  LRightCount := 0;
  LLeftIdx := 0;
  LRightIdx := 0;

  if LUsePaginatedHorizontal then
  begin
    LImgSize := Max(60.0, Min(96.0, Min(LUsableH * 0.55, LUsableW * 0.22)));
    LTextW := Min(120.0, LUsableW / 3 - 8);
    LNonRootCount := 0;
    LNonRootIdxs[0] := -1;
    LNonRootIdxs[1] := -1;
    for I := 0 to LCount - 1 do
    begin
      if FFullNodes[FPageIdxs[I]].Stage = 0 then
      begin
        LCx[I] := LPanelRect.Left + LUsableW / 2;
        LCy[I] := LPanelRect.Top + LUsableH / 2;
      end
      else
      begin
        if LNonRootCount < 2 then
          LNonRootIdxs[LNonRootCount] := I;
        Inc(LNonRootCount);
      end;
    end;
    if LNonRootCount = 1 then
    begin
      I := LNonRootIdxs[0];
      LCx[I] := LPanelRect.Left + LUsableW * 0.78;
      LCy[I] := LPanelRect.Top + LUsableH / 2;
    end
    else if LNonRootCount >= 2 then
    begin
      I := LNonRootIdxs[0];
      LCx[I] := LPanelRect.Left + LUsableW * 0.18;
      LCy[I] := LPanelRect.Top + LUsableH / 2;
      I := LNonRootIdxs[1];
      LCx[I] := LPanelRect.Left + LUsableW * 0.82;
      LCy[I] := LPanelRect.Top + LUsableH / 2;
    end;
  end
  else if LUseHorizontal then
  begin
    LColW := LUsableW / LNumStages;
    LImgSize := Max(48.0, Min(96.0, LColW * 0.42));
    LTextW := Min(140.0, LColW - 8.0);
    for I := 0 to LCount - 1 do
    begin
      LCx[I] := LPanelRect.Left + (FFullNodes[FPageIdxs[I]].Stage +
        0.5) * LColW;
      LCy[I] := LPanelRect.Top + LUsableH / 2;
    end;
  end
  else if LUseCenterFan then
  begin
    LHalfCount := LLeafCount div 2;
    LRightCount := LLeafCount - LHalfCount;
    LImgSize := FAN_IMG_SIZE;
    LTextW := 64.0;

    LSpriteX_L := LPanelRect.Left + FAN_SPRITE_INSET;
    LBracketX_L := LPanelRect.Left + FAN_BRACKET_INSET;
    LBracketX_R := LPanelRect.Right - FAN_BRACKET_INSET;
    LSpriteX_R := LPanelRect.Right - FAN_SPRITE_INSET;

    LCx[LRootIdx] := LPanelRect.Left + LUsableW / 2;
    LCy[LRootIdx] := LPanelRect.Top + LUsableH / 2;

    LLeftIdx := 0;
    LRightIdx := 0;
    for I := 0 to LCount - 1 do
      if FFullNodes[FPageIdxs[I]].Stage > 0 then
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
          LCy[I] := LPanelRect.Top + (LRightIdx + 0.5) *
            (LUsableH / LRightCount);
          Inc(LRightIdx);
        end;
      end;
  end
  else
  begin
    LRowH := LUsableH / LNumStages;
    LLeafSlotW := LUsableW / LLeafCount;
    LMaxImgV := Max(28.0, 72.0 - LLeafCount * 5.0);
    LImgSize := Max(24.0, Min(LMaxImgV, Min(LRowH * 0.55, LLeafSlotW * 0.70)));
    LTextW := Min(120.0, LLeafSlotW - 6.0);

    for I := 0 to LCount - 1 do
      LCy[I] := LPanelRect.Top + (FFullNodes[FPageIdxs[I]].Stage + 0.5) * LRowH;

    LLeafAssigned := 0;
    for I := 0 to LCount - 1 do
      if LIsLeaf[I] then
      begin
        LCx[I] := LPanelRect.Left + (LLeafAssigned + 0.5) * LLeafSlotW;
        Inc(LLeafAssigned);
      end;

    for var S := LMaxStage - 1 downto 0 do
      for I := 0 to LCount - 1 do
        if FFullNodes[FPageIdxs[I]].Stage = S then
        begin
          var
            LSum: Single := 0;
          var
            LChildCount: Integer := 0;
          for J := 0 to LCount - 1 do
            if FFullNodes[FPageIdxs[J]].ParentId = FFullNodes[FPageIdxs[I]].PokemonId
            then
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

  LNameFontSize := Max(8.0, Min(14.0, LImgSize * 0.22));
  LTriggerFontSize := Max(7.0, Min(11.0, LImgSize * 0.18));

  SetLength(FNodeRects, LCount);
  for I := 0 to LCount - 1 do
    FNodeRects[I] := TRectF.Create(LCx[I] - LImgSize / 2, LCy[I] - LImgSize / 2,
      LCx[I] + LImgSize / 2, LCy[I] + LImgSize / 2);

  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Fill;
  LPaint.Color := FThemeColor;
  ACanvas.DrawRect(ADest, LPaint);
  LPaint.Color := DARK_BG;
  ACanvas.DrawRoundRect(LPanelRect, 12, 12, LPaint);

  // Navigation arrows (drawn on outer border, before clip)
  if FEvoPageTotal > 1 then
  begin
    var
      LArrowW: Single := 18;
    var
      LArrowH: Single := 26;
    var
      LArrowPad: Single := 8;
    var
      LArrowMidY: Single := ADest.Top + ADest.Height / 2;
    FArrowLeftRect := TRectF.Create(ADest.Left + LArrowPad,
      LArrowMidY - LArrowH / 2, ADest.Left + LArrowPad + LArrowW,
      LArrowMidY + LArrowH / 2);
    FArrowRightRect := TRectF.Create(ADest.Right - LArrowPad - LArrowW,
      LArrowMidY - LArrowH / 2, ADest.Right - LArrowPad,
      LArrowMidY + LArrowH / 2);

    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.StrokeWidth := 2.5;
    // Left chevron "<" — hidden on first page
    if FEvoPage > 0 then
    begin
      if FHoveredArrow = 1 then
        LPaint.Color := $DDFFFFFF
      else
        LPaint.Color := $AAFFFFFF;
      ACanvas.DrawLine(TPointF.Create(FArrowLeftRect.Right - 4,
        FArrowLeftRect.Top + 4), TPointF.Create(FArrowLeftRect.Left + 5,
        LArrowMidY), LPaint);
      ACanvas.DrawLine(TPointF.Create(FArrowLeftRect.Left + 5, LArrowMidY),
        TPointF.Create(FArrowLeftRect.Right - 4, FArrowLeftRect.Bottom -
        4), LPaint);
    end;
    // Right chevron ">" — hidden on last page
    if FEvoPage < FEvoPageTotal - 1 then
    begin
      if FHoveredArrow = 2 then
        LPaint.Color := $DDFFFFFF
      else
        LPaint.Color := $AAFFFFFF;
      ACanvas.DrawLine(TPointF.Create(FArrowRightRect.Left + 4,
        FArrowRightRect.Top + 4), TPointF.Create(FArrowRightRect.Right - 5,
        LArrowMidY), LPaint);
      ACanvas.DrawLine(TPointF.Create(FArrowRightRect.Right - 5, LArrowMidY),
        TPointF.Create(FArrowRightRect.Left + 4, FArrowRightRect.Bottom -
        4), LPaint);
    end;

    // Page indicator "1/4" — inside the dark panel, bottom-right
    LParagraph := MakeParagraph(Format('%d/%d', [FEvoPage + 1, FEvoPageTotal]),
      10, $DDFFFFFF, True);
    LParagraph.Layout(54);
    LParagraph.Paint(ACanvas, LPanelRect.Right - 58, LPanelRect.Bottom - 18);
  end
  else
  begin
    FArrowLeftRect := TRectF.Empty;
    FArrowRightRect := TRectF.Empty;
  end;

  ACanvas.Save;
  ACanvas.ClipRect(LPanelRect, TSkClipOp.Intersect, False);
  LGrayFilter := TSkColorFilter.MakeMatrix(GRAYSCALE_MATRIX);
  LHighlightColor := GetHighlightColor;

  LPaint.Style := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := 1.5;
  LPaint.Color := $55FFFFFF;

  if LUsePaginatedHorizontal then
  begin
    // Horizontal arrows: left evo ← root → right evo
    for I := 0 to LCount - 1 do
    begin
      if FFullNodes[FPageIdxs[I]].Stage = 0 then
        Continue;
      if LRootIdx = -1 then
        Continue;
      if LCx[I] < LCx[LRootIdx] then
        ACanvas.DrawLine(TPointF.Create(LCx[I] + LImgSize / 2, LCy[I]),
          TPointF.Create(LCx[LRootIdx] - LImgSize / 2, LCy[LRootIdx]), LPaint)
      else
        ACanvas.DrawLine(TPointF.Create(LCx[LRootIdx] + LImgSize / 2,
          LCy[LRootIdx]), TPointF.Create(LCx[I] - LImgSize / 2, LCy[I]
          ), LPaint);
    end;
  end
  else if LUseCenterFan then
  begin
    LMinYL := MaxSingle;
    LMaxYL := -MaxSingle;
    LMinYR := MaxSingle;
    LMaxYR := -MaxSingle;
    for I := 0 to LCount - 1 do
      if FFullNodes[FPageIdxs[I]].Stage > 0 then
      begin
        if LCx[I] < LCx[LRootIdx] then
        begin
          if LCy[I] < LMinYL then
            LMinYL := LCy[I];
          if LCy[I] > LMaxYL then
            LMaxYL := LCy[I];
        end
        else
        begin
          if LCy[I] < LMinYR then
            LMinYR := LCy[I];
          if LCy[I] > LMaxYR then
            LMaxYR := LCy[I];
        end;
      end;

    if LMinYL < MaxSingle then
      ACanvas.DrawLine(TPointF.Create(LBracketX_L, LMinYL),
        TPointF.Create(LBracketX_L, LMaxYL), LPaint);
    for I := 0 to LCount - 1 do
      if (FFullNodes[FPageIdxs[I]].Stage > 0) and (LCx[I] < LCx[LRootIdx]) then
        ACanvas.DrawLine(TPointF.Create(LCx[I] + LImgSize / 2, LCy[I]),
          TPointF.Create(LBracketX_L, LCy[I]), LPaint);
    ACanvas.DrawLine(TPointF.Create(LBracketX_L, LCy[LRootIdx]),
      TPointF.Create(LCx[LRootIdx] - LImgSize / 2, LCy[LRootIdx]), LPaint);

    if LMinYR < MaxSingle then
      ACanvas.DrawLine(TPointF.Create(LBracketX_R, LMinYR),
        TPointF.Create(LBracketX_R, LMaxYR), LPaint);
    for I := 0 to LCount - 1 do
      if (FFullNodes[FPageIdxs[I]].Stage > 0) and (LCx[I] >= LCx[LRootIdx]) then
        ACanvas.DrawLine(TPointF.Create(LBracketX_R, LCy[I]),
          TPointF.Create(LCx[I] - LImgSize / 2, LCy[I]), LPaint);
    ACanvas.DrawLine(TPointF.Create(LCx[LRootIdx] + LImgSize / 2, LCy[LRootIdx]
      ), TPointF.Create(LBracketX_R, LCy[LRootIdx]), LPaint);
  end
  else if LUseHorizontal then
  begin
    for I := 0 to LCount - 1 do
    begin
      if FFullNodes[FPageIdxs[I]].Stage = 0 then
        Continue;
      LParentIdx := -1;
      for J := 0 to LCount - 1 do
        if FFullNodes[FPageIdxs[J]].PokemonId = FFullNodes[FPageIdxs[I]].ParentId
        then
        begin
          LParentIdx := J;
          Break;
        end;
      if LParentIdx = -1 then
        Continue;
      ACanvas.DrawLine(TPointF.Create(LCx[LParentIdx] + LImgSize / 2,
        LCy[LParentIdx]), TPointF.Create(LCx[I] - LImgSize / 2, LCy[I]
        ), LPaint);
    end;
  end
  else
  begin
    SetLength(LTrunkDrawn, LCount);
    for I := 0 to LCount - 1 do
      LTrunkDrawn[I] := False;
    for I := 0 to LCount - 1 do
    begin
      if FFullNodes[FPageIdxs[I]].Stage = 0 then
        Continue;
      LParentIdx := -1;
      for J := 0 to LCount - 1 do
        if FFullNodes[FPageIdxs[J]].PokemonId = FFullNodes[FPageIdxs[I]].ParentId
        then
        begin
          LParentIdx := J;
          Break;
        end;
      if LParentIdx = -1 then
        Continue;
      LSibCount := 0;
      for J := 0 to LCount - 1 do
        if FFullNodes[FPageIdxs[J]].ParentId = FFullNodes[FPageIdxs[I]].ParentId
        then
          Inc(LSibCount);

      LMidY := (LCy[LParentIdx] + LCy[I]) / 2;
      if LSibCount = 1 then
        ACanvas.DrawLine(TPointF.Create(LCx[LParentIdx],
          LCy[LParentIdx] + LImgSize / 2), TPointF.Create(LCx[I],
          LCy[I] - LImgSize / 2), LPaint)
      else
      begin
        if not LTrunkDrawn[LParentIdx] then
        begin
          LMinCX := LCx[I];
          LMaxCX := LCx[I];
          for J := 0 to LCount - 1 do
            if FFullNodes[FPageIdxs[J]].ParentId = FFullNodes[FPageIdxs[I]].ParentId
            then
            begin
              if LCx[J] < LMinCX then
                LMinCX := LCx[J];
              if LCx[J] > LMaxCX then
                LMaxCX := LCx[J];
            end;
          ACanvas.DrawLine(TPointF.Create(LCx[LParentIdx],
            LCy[LParentIdx] + LImgSize / 2), TPointF.Create(LCx[LParentIdx],
            LMidY), LPaint);
          ACanvas.DrawLine(TPointF.Create(LMinCX, LMidY),
            TPointF.Create(LMaxCX, LMidY), LPaint);
          LTrunkDrawn[LParentIdx] := True;
        end;
        ACanvas.DrawLine(TPointF.Create(LCx[I], LMidY),
          TPointF.Create(LCx[I], LCy[I] - LImgSize / 2), LPaint);
      end;
    end;
  end;

  // Trigger labels
  for I := 0 to LCount - 1 do
  begin
    if FFullNodes[FPageIdxs[I]].Stage = 0 then
      Continue;
    if LUseCenterFan then
      Continue;
    LText := FormatTrigger(FFullNodes[FPageIdxs[I]].Trigger);
    if LText.IsEmpty then
      Continue;
    LParagraph := MakeParagraph(LText, LTriggerFontSize, $CCFFFFFF, True);
    LParagraph.Layout(LTextW);
    LParagraph.Paint(ACanvas, LCx[I] - LTextW / 2, LCy[I] - LImgSize / 2 -
      LParagraph.Height - 2);
  end;

  // Sprites and names
  LPaint.Style := TSkPaintStyle.Fill;
  for I := 0 to LCount - 1 do
  begin
    LOrigIdx := FPageIdxs[I];
    LImgRect := FNodeRects[I];
    if (LOrigIdx < Length(FFullImages)) and Assigned(FFullImages[LOrigIdx]) then
    begin
      if FFullNodes[LOrigIdx].IsActive then
        LPaint.ColorFilter := nil
      else
        LPaint.ColorFilter := LGrayFilter;

      ACanvas.DrawImageRect(FFullImages[LOrigIdx], LImgRect,
        TSkSamplingOptions.Create(TSkFilterMode.Linear,
        TSkMipmapMode.None), LPaint);
      LPaint.ColorFilter := nil;
      if FFullNodes[LOrigIdx].IsActive then
      begin
        LPaint.Style := TSkPaintStyle.Stroke;
        LPaint.StrokeWidth := 2;
        LPaint.Color := LHighlightColor;
        ACanvas.DrawCircle(LCx[I], LCy[I], LImgSize / 2 - 1, LPaint);
        LPaint.Style := TSkPaintStyle.Fill;
      end;
    end
    else
    begin
      LPaint.Style := TSkPaintStyle.Stroke;
      LPaint.StrokeWidth := 1.5;
      if FFullNodes[LOrigIdx].IsActive then
        LPaint.Color := $66FFFFFF
      else
        LPaint.Color := $33FFFFFF;
      ACanvas.DrawCircle(LCx[I], LCy[I], LImgSize / 2 - 2, LPaint);

      if (LOrigIdx < Length(FFullStates)) and
        (FFullStates[LOrigIdx] = eisLoading) then
        LText := 'CARREGANDO...'
      else
        LText := 'SEM SPRITE';
      LParagraph := MakeParagraph(LText, Max(6.5, LTriggerFontSize - 0.5),
        $99FFFFFF, True);
      LParagraph.Layout(Max(56.0, LTextW));
      LParagraph.Paint(ACanvas, LCx[I] - Max(56.0, LTextW) / 2,
        LCy[I] - LParagraph.Height / 2);
      LPaint.Style := TSkPaintStyle.Fill;
    end;

    if FFullNodes[LOrigIdx].IsActive then
      LNameColor := LHighlightColor
    else
      LNameColor := $AAFFFFFF;
    LParagraph := MakeParagraph(CapitalizeName(FFullNodes[LOrigIdx].Name),
      LNameFontSize, LNameColor, True);
    LParagraph.Layout(LTextW);
    LParagraph.Paint(ACanvas, LCx[I] - LTextW / 2, LCy[I] + LImgSize / 2 + 2);
  end;

  // Subtle shadow hint for large families — omit when paginated (content is complete)
  if (Length(FFullNodes) > 5) and not LUsePaginatedHorizontal then
  begin
    LPaint.Style := TSkPaintStyle.Fill;
    LPaint.Shader := TSkShader.MakeGradientLinear
      (TPointF.Create(LPanelRect.Right - 36, LPanelRect.Top),
      TPointF.Create(LPanelRect.Right, LPanelRect.Top), [$00000000, $CC000000],
      nil, TSkTileMode.Clamp);
    ACanvas.DrawRect(LPanelRect, LPaint);
    LPaint.Shader := nil;
  end;

  ACanvas.Restore;
end;

end.

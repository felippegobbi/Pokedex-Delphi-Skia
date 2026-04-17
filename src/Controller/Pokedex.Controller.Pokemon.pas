unit Pokedex.Controller.Pokemon;

interface

uses
  Pokedex.Model.Pokemon,
  REST.Json,
  System.SysUtils,
  System.Classes,
  System.UITypes,
  VCL.Graphics,
  System.Generics.Collections,
  Pokedex.Service.Interfaces;

type
  TPokemonController = class
  private
    FService: IPokemonService;
    class var FTypeColors: TDictionary<string, TColor>;
    class var FSpeciesColors: TDictionary<string, TColor>;
    class procedure InitializeColorMaps;
    class constructor Create;
    class destructor Destroy;

  public
    constructor Create(const AService: IPokemonService);
    function ExecuteGetPokemon(const AIdOrName: string): TPokemon;
    function DownloadFile(const AUrl: string): TMemoryStream;
    function GetEvolutionChain(const AUrl: string): TArray<TEvolutionNode>;
    class function FormatMetric(const AValue: Integer;
      const AUnit: string): string;
    class function GetCryUrl(const AId: Integer): string;
    class function GetColorByString(const AColorName: string): TColor;
    class function GetTypeColor(const ATypeName: string): TColor;

  const
    BLACK_COLOR = $002C2C2C;
    BLUE_COLOR = $00F09068;
    BROWN_COLOR = $005090A8;
    GRAY_COLOR = $00A8A8A8;
    GREEN_COLOR = $0078C850;
    PINK_COLOR = $00B8A0F8;
    PURPLE_COLOR = $00A04070;
    RED_COLOR = $005050F0;
    WHITE_COLOR = clWhite;
    YELLOW_COLOR = $0030D0F8;
  end;

implementation

uses
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Json;

class constructor TPokemonController.Create;
begin
  InitializeColorMaps;
end;

constructor TPokemonController.Create(const AService: IPokemonService);
begin
  FService := AService;
end;

class destructor TPokemonController.Destroy;
begin
  FTypeColors.Free;
  FSpeciesColors.Free;
end;

function TPokemonController.DownloadFile(const AUrl: string): TMemoryStream;
var
  LHttp: TNetHTTPClient;
begin
  Result := nil;
  LHttp := TNetHTTPClient.Create(nil);
  try
    try
      Result := TMemoryStream.Create;
      LHttp.Get(AUrl, Result);
      Result.Position := 0;
    except
      FreeAndNil(Result);
    end;
  finally
    LHttp.Free;
  end;
end;

function TPokemonController.GetEvolutionChain(const AUrl: string)
  : TArray<TEvolutionNode>;
var
  LJson: string;
  LRoot: TJSONObject;
  LRootVal: TJSONValue;

  // Lê um campo que pode ser TJSONObject ou TJSONNull sem causar EInvalidCast
  function SafeObj(AParent: TJSONObject; const AKey: string): TJSONObject;
  var
    LVal: TJSONValue;
  begin
    LVal := AParent.GetValue(AKey);
    if Assigned(LVal) and (LVal is TJSONObject) then
      Result := TJSONObject(LVal)
    else
      Result := nil;
  end;

  procedure CollectNodes(ALink: TJSONObject; AStage, AParentId: Integer);
  var
    LSpecies: TJSONObject;
    LNode: TEvolutionNode;
    LParts: TArray<string>;
    LDetailsVal, LEvolvesToVal: TJSONValue;
    LDetails: TJSONArray;
    LDetail: TJSONObject;
    LEvolvesTo: TJSONArray;
    LVal: TJSONValue;
    LObj: TJSONObject;
    I: Integer;
  begin
    LSpecies := SafeObj(ALink, 'species');
    if not Assigned(LSpecies) then
      Exit;

    LParts := LSpecies.GetValue<string>('url').TrimRight(['/'])
      .Split(['/']);

    LNode.Name      := LSpecies.GetValue<string>('name');
    LNode.PokemonId := StrToIntDef(LParts[High(LParts)], 0);
    LNode.IsActive  := False;
    LNode.SpriteUrl :=
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/'
      + LNode.PokemonId.ToString + '.png';
    LNode.Stage    := AStage;
    LNode.ParentId := AParentId;

    LNode.Trigger.TriggerType    := '';
    LNode.Trigger.MinLevel       := 0;
    LNode.Trigger.MinHappiness   := 0;
    LNode.Trigger.ItemName       := '';
    LNode.Trigger.HeldItem       := '';
    LNode.Trigger.TimeOfDay      := '';
    LNode.Trigger.KnownMoveType  := '';

    // evolution_details: pode ser [] ou [{item: null, held_item: null, ...}]
    LDetailsVal := ALink.GetValue('evolution_details');
    if Assigned(LDetailsVal) and (LDetailsVal is TJSONArray) then
    begin
      LDetails := TJSONArray(LDetailsVal);
      if (LDetails.Count > 0) and (LDetails.Items[0] is TJSONObject) then
      begin
        LDetail := TJSONObject(LDetails.Items[0]);

        LObj := SafeObj(LDetail, 'trigger');
        if Assigned(LObj) then
          LNode.Trigger.TriggerType := LObj.GetValue<string>('name');

        LVal := LDetail.GetValue('min_level');
        if Assigned(LVal) and not (LVal is TJSONNull) then
          LNode.Trigger.MinLevel := StrToIntDef(LVal.Value, 0);

        LVal := LDetail.GetValue('min_happiness');
        if Assigned(LVal) and not (LVal is TJSONNull) then
          LNode.Trigger.MinHappiness := StrToIntDef(LVal.Value, 0);

        // Campos que chegam como null quando não aplicáveis
        LObj := SafeObj(LDetail, 'item');
        if Assigned(LObj) then
          LNode.Trigger.ItemName := LObj.GetValue<string>('name');

        LObj := SafeObj(LDetail, 'held_item');
        if Assigned(LObj) then
          LNode.Trigger.HeldItem := LObj.GetValue<string>('name');

        LVal := LDetail.GetValue('time_of_day');
        if Assigned(LVal) and not (LVal is TJSONNull) then
          LNode.Trigger.TimeOfDay := LVal.Value;

        LObj := SafeObj(LDetail, 'known_move_type');
        if Assigned(LObj) then
          LNode.Trigger.KnownMoveType := LObj.GetValue<string>('name');
      end;
    end;

    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := LNode;

    // evolves_to: percorre todos os filhos (branching como Eevee)
    LEvolvesToVal := ALink.GetValue('evolves_to');
    if not (Assigned(LEvolvesToVal) and (LEvolvesToVal is TJSONArray)) then
      Exit;

    LEvolvesTo := TJSONArray(LEvolvesToVal);
    for I := 0 to LEvolvesTo.Count - 1 do
      if LEvolvesTo.Items[I] is TJSONObject then
        CollectNodes(TJSONObject(LEvolvesTo.Items[I]),
          AStage + 1, LNode.PokemonId);
  end;

begin
  SetLength(Result, 0);
  LJson := FService.GetEvolutionChainJSON(AUrl);
  if LJson.IsEmpty then
    Exit;

  LRootVal := TJSONObject.ParseJSONValue(LJson);
  if not (Assigned(LRootVal) and (LRootVal is TJSONObject)) then
  begin
    LRootVal.Free;
    Exit;
  end;
  LRoot := TJSONObject(LRootVal);
  try
    CollectNodes(SafeObj(LRoot, 'chain'), 0, 0);
  finally
    LRoot.Free;
  end;
end;

function TPokemonController.ExecuteGetPokemon(const AIdOrName: string)
  : TPokemon;
var
  LContent, LSpeciesContent: string;
begin
  Result := nil;
  try
    LContent := FService.GetPokemonJSON(AIdOrName);

    if (not LContent.IsEmpty) and (LContent.StartsWith('{')) then
    begin
      Result := TJson.JsonToObject<TPokemon>(LContent);

      if Assigned(Result) and Assigned(Result.Species) then
      begin
        LSpeciesContent := FService.GetSpeciesJSON(Result.Species.Url);
        if not LSpeciesContent.IsEmpty then
          Result.SpeciesData := TJson.JsonToObject<TPokemonSpecies>
            (LSpeciesContent);
      end;
    end;
  except
    on E: Exception do
    begin
      if Assigned(Result) then
        FreeAndNil(Result);
    end;
  end;
end;


class function TPokemonController.FormatMetric(const AValue: Integer;
  const AUnit: string): string;
begin
  Result := FormatFloat('0.0', AValue / 10) + ' ' + AUnit;
end;

class function TPokemonController.GetColorByString(const AColorName
  : string): TColor;
begin
  if not FSpeciesColors.TryGetValue(AColorName.ToLower, Result) then
    Result := clBtnFace;
end;

class function TPokemonController.GetCryUrl(const AId: Integer): string;
begin
  Result := 'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/'
    + AId.ToString + '.ogg';
end;

class function TPokemonController.GetTypeColor(const ATypeName: string): TColor;
begin
  if not FTypeColors.TryGetValue(ATypeName.ToLower, Result) then
    Result := $00A8A8A8;
end;

class procedure TPokemonController.InitializeColorMaps;
begin
  FTypeColors := TDictionary<string, TColor>.Create;
  FTypeColors.Add('fire', RED_COLOR);
  FTypeColors.Add('water', $00F09068);
  FTypeColors.Add('grass', $0071C278);
  FTypeColors.Add('electric', YELLOW_COLOR);
  FTypeColors.Add('ice', $00D0F098);
  FTypeColors.Add('fighting', $003030C0);
  FTypeColors.Add('poison', $00A040A0);
  FTypeColors.Add('ground', $005090E0);
  FTypeColors.Add('flying', $00D090A8);
  FTypeColors.Add('psychic', $009858F8);
  FTypeColors.Add('bug', $0020A8A8);
  FTypeColors.Add('rock', $004088B8);
  FTypeColors.Add('ghost', PURPLE_COLOR);
  FTypeColors.Add('dragon', $00F18A70);
  FTypeColors.Add('dark', BROWN_COLOR);
  FTypeColors.Add('steel', $00D1B8B8);
  FTypeColors.Add('fairy', PINK_COLOR);
  FTypeColors.Add('normal', GRAY_COLOR);

  FSpeciesColors := TDictionary<string, TColor>.Create;
  FSpeciesColors.Add('black', BLACK_COLOR);
  FSpeciesColors.Add('blue', BLUE_COLOR);
  FSpeciesColors.Add('brown', BROWN_COLOR);
  FSpeciesColors.Add('gray', GRAY_COLOR);
  FSpeciesColors.Add('green', GREEN_COLOR);
  FSpeciesColors.Add('pink', PINK_COLOR);
  FSpeciesColors.Add('purple', PURPLE_COLOR);
  FSpeciesColors.Add('red', RED_COLOR);
  FSpeciesColors.Add('white', WHITE_COLOR);
  FSpeciesColors.Add('yellow', YELLOW_COLOR);

end;

end.

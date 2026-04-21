unit Pokedex.Controller.Pokemon;

interface

uses
  Pokedex.Model.Pokemon,
  REST.Json,
  System.SysUtils,
  Winapi.Windows,
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
    function GetTypeEffectiveness(const ATypeNames: TArray<string>)
      : TArray<TTypeEffect>;
    function GetAbilityDescription(const AName: string): string;
    class function FilterEvolutionChain(const AChain: TArray<TEvolutionNode>;
      const AActivePokemonId: Integer): TArray<TEvolutionNode>;
    class function FormatMetric(const AValue: Integer;
      const AUnit: string): string;
    class function GetCryUrl(const AId: Integer): string;
    class function GetColorByString(const AColorName: string): TColor;
    class function GetTypeColor(const ATypeName: string): TColor;
    class function GetPreferredLanguage: string;
    class function GetSystemLanguage: string;
    class function Translate(const AText, AToLang: string): string;
    class function RandomPokemonId: Integer;

  const
    BLACK_COLOR = $002C2C2C;
    POKEMON_MAX_ID = 1025;
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
  System.NetEncoding,
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

    LParts := LSpecies.GetValue<string>('url').TrimRight(['/']).Split(['/']);

    LNode.Name := LSpecies.GetValue<string>('name');
    LNode.PokemonId := StrToIntDef(LParts[High(LParts)], 0);
    LNode.IsActive := False;
    LNode.SpriteUrl :=
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/'
      + LNode.PokemonId.ToString + '.png';
    LNode.Stage := AStage;
    LNode.ParentId := AParentId;

    LNode.Trigger.TriggerType := '';
    LNode.Trigger.MinLevel := 0;
    LNode.Trigger.MinHappiness := 0;
    LNode.Trigger.ItemName := '';
    LNode.Trigger.HeldItem := '';
    LNode.Trigger.TimeOfDay := '';
    LNode.Trigger.KnownMoveType := '';

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
        if Assigned(LVal) and not(LVal is TJSONNull) then
          LNode.Trigger.MinLevel := StrToIntDef(LVal.Value, 0);

        LVal := LDetail.GetValue('min_happiness');
        if Assigned(LVal) and not(LVal is TJSONNull) then
          LNode.Trigger.MinHappiness := StrToIntDef(LVal.Value, 0);

        // Campos que chegam como null quando não aplicáveis
        LObj := SafeObj(LDetail, 'item');
        if Assigned(LObj) then
          LNode.Trigger.ItemName := LObj.GetValue<string>('name');

        LObj := SafeObj(LDetail, 'held_item');
        if Assigned(LObj) then
          LNode.Trigger.HeldItem := LObj.GetValue<string>('name');

        LVal := LDetail.GetValue('time_of_day');
        if Assigned(LVal) and not(LVal is TJSONNull) then
          LNode.Trigger.TimeOfDay := LVal.Value;

        LObj := SafeObj(LDetail, 'known_move_type');
        if Assigned(LObj) then
          LNode.Trigger.KnownMoveType := LObj.GetValue<string>('name');
      end;
    end;

    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := LNode;

    LEvolvesToVal := ALink.GetValue('evolves_to');
    if not(Assigned(LEvolvesToVal) and (LEvolvesToVal is TJSONArray)) then
      Exit;

    LEvolvesTo := TJSONArray(LEvolvesToVal);
    for I := 0 to LEvolvesTo.Count - 1 do
      if LEvolvesTo.Items[I] is TJSONObject then
        CollectNodes(TJSONObject(LEvolvesTo.Items[I]), AStage + 1,
          LNode.PokemonId);
  end;

begin
  SetLength(Result, 0);
  LJson := FService.GetEvolutionChainJSON(AUrl);
  if LJson.IsEmpty then
    Exit;

  LRootVal := TJSONObject.ParseJSONValue(LJson);
  if not(Assigned(LRootVal) and (LRootVal is TJSONObject)) then
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

    if LContent.IsEmpty or not LContent.StartsWith('{') then
      raise EPokemonParseError.Create('Resposta inv'#225'lida da API');

    Result := TJson.JsonToObject<TPokemon>(LContent);
    if not Assigned(Result) then
      raise EPokemonParseError.Create
        ('N'#227'o foi poss'#237'vel processar os dados do Pok'#233'mon');

    if Assigned(Result.Species) then
      try
        LSpeciesContent := FService.GetSpeciesJSON(Result.Species.Url);
        if not LSpeciesContent.IsEmpty then
          Result.SpeciesData := TJson.JsonToObject<TPokemonSpecies>
            (LSpeciesContent);
      except
        on EPokemonError do;
        // species data is non-critical; partial result is acceptable
      end;
  except
    on E: EPokemonError do
    begin
      FreeAndNil(Result);
      raise;
    end;
    on E: Exception do
    begin
      FreeAndNil(Result);
      raise EPokemonParseError.Create(E.Message);
    end;
  end;
end;

class function TPokemonController.FilterEvolutionChain
  (const AChain: TArray<TEvolutionNode>; const AActivePokemonId: Integer)
  : TArray<TEvolutionNode>;
var
  I: Integer;
  LChain: TArray<TEvolutionNode>;
  LActiveIdx: Integer;
  LInclude: TArray<Integer>;
  LParentId: Integer;
  LFound: Boolean;

  procedure AddInclude(AId: Integer);
  var
    J: Integer;
  begin
    for J := 0 to High(LInclude) do
      if LInclude[J] = AId then
        Exit;
    SetLength(LInclude, Length(LInclude) + 1);
    LInclude[High(LInclude)] := AId;
  end;

  function InInclude(AId: Integer): Boolean;
  var
    J: Integer;
  begin
    for J := 0 to High(LInclude) do
      if LInclude[J] = AId then
        Exit(True);
    Result := False;
  end;

  procedure AddSubtree(AParentId: Integer);
  var
    J: Integer;
  begin
    for J := 0 to High(LChain) do
      if LChain[J].ParentId = AParentId then
      begin
        AddInclude(LChain[J].PokemonId);
        AddSubtree(LChain[J].PokemonId);
      end;
  end;

begin
  SetLength(LChain, Length(AChain));
  for I := 0 to High(AChain) do
  begin
    LChain[I] := AChain[I];
    LChain[I].IsActive := LChain[I].PokemonId = AActivePokemonId;
  end;

  LActiveIdx := -1;
  for I := 0 to High(LChain) do
    if LChain[I].IsActive then
    begin
      LActiveIdx := I;
      Break;
    end;

  if LActiveIdx < 0 then
  begin
    Result := LChain;
    Exit;
  end;

  SetLength(LInclude, 0);
  AddInclude(LChain[LActiveIdx].PokemonId);

  LParentId := LChain[LActiveIdx].ParentId;
  while LParentId <> 0 do
  begin
    AddInclude(LParentId);
    LFound := False;
    for I := 0 to High(LChain) do
      if LChain[I].PokemonId = LParentId then
      begin
        LParentId := LChain[I].ParentId;
        LFound := True;
        Break;
      end;
    if not LFound then
      Break;
  end;

  AddSubtree(LChain[LActiveIdx].PokemonId);

  SetLength(Result, 0);
  for I := 0 to High(LChain) do
    if InInclude(LChain[I].PokemonId) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := LChain[I];
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

function TPokemonController.GetTypeEffectiveness(const ATypeNames
  : TArray<string>): TArray<TTypeEffect>;
const
  ALL_TYPES: array [0 .. 17] of string = ('normal', 'fire', 'water', 'electric',
    'grass', 'ice', 'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
    'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy');
var
  LMap: TDictionary<string, Single>;
  LJson, LTypeName: string;
  LRoot: TJSONValue;
  LObj, LRelObj: TJSONObject;
  I, LCount: Integer;
  LPair: TPair<string, Single>;
  LTmp: TTypeEffect;
  J: Integer;

  procedure ApplyMult(const AKey: string; AMult: Single);
  var
    LArr2: TJSONArray;
    LItem2: TJSONValue;
    LName2: string;
    LVal: Single;
  begin
    LArr2 := TJSONArray(LRelObj.GetValue(AKey));
    if not Assigned(LArr2) then
      Exit;
    for LItem2 in LArr2 do
      if LItem2 is TJSONObject then
      begin
        LName2 := TJSONObject(LItem2).GetValue<string>('name');
        if LMap.TryGetValue(LName2, LVal) then
          LMap[LName2] := LVal * AMult;
      end;
  end;

begin
  SetLength(Result, 0);
  LMap := TDictionary<string, Single>.Create;
  try
    for LTypeName in ALL_TYPES do
      LMap.Add(LTypeName, 1.0);

    for I := 0 to High(ATypeNames) do
    begin
      try
        LJson := FService.GetTypeJSON('https://pokeapi.co/api/v2/type/' +
          LowerCase(ATypeNames[I]));
        LRoot := TJSONObject.ParseJSONValue(LJson);
        if not(Assigned(LRoot) and (LRoot is TJSONObject)) then
        begin
          if Assigned(LRoot) then
            LRoot.Free;
          Continue;
        end;
        LObj := TJSONObject(LRoot);
        try
          LRelObj := TJSONObject(LObj.GetValue('damage_relations'));
          if Assigned(LRelObj) then
          begin
            ApplyMult('double_damage_from', 2.0);
            ApplyMult('half_damage_from', 0.5);
            ApplyMult('no_damage_from', 0.0);
          end;
        finally
          LObj.Free;
        end;
      except
        // type data is non-critical, continue with partial result
      end;
    end;

    LCount := 0;
    for LPair in LMap do
      if Abs(LPair.Value - 1.0) > 0.01 then
        Inc(LCount);
    SetLength(Result, LCount);
    LCount := 0;
    for LPair in LMap do
      if Abs(LPair.Value - 1.0) > 0.01 then
      begin
        Result[LCount].TypeName := LPair.Key;
        Result[LCount].Multiplier := LPair.Value;
        Inc(LCount);
      end;

    // Sort by multiplier descending (insertion sort, max 17 elements)
    for I := 1 to High(Result) do
    begin
      LTmp := Result[I];
      J := I - 1;
      while (J >= 0) and (Result[J].Multiplier < LTmp.Multiplier) do
      begin
        Result[J + 1] := Result[J];
        Dec(J);
      end;
      Result[J + 1] := LTmp;
    end;

  finally
    LMap.Free;
  end;
end;

function TPokemonController.GetAbilityDescription(const AName: string): string;
var
  LJson: string;
  LRoot: TJSONValue;
  LObj: TJSONObject;
  LArr: TJSONArray;
  LEntry, LLangObj: TJSONValue;
  LLang, LBackupEn: string;
begin
  Result := '';
  if AName.IsEmpty then
    Exit;
  try
    LJson := FService.GetTypeJSON('https://pokeapi.co/api/v2/ability/' +
      LowerCase(AName));
    LRoot := TJSONObject.ParseJSONValue(LJson);
    if not(Assigned(LRoot) and (LRoot is TJSONObject)) then
    begin
      if Assigned(LRoot) then
        LRoot.Free;
      Exit;
    end;
    LObj := TJSONObject(LRoot);
    try
      LArr := TJSONArray(LObj.GetValue('flavor_text_entries'));
      if not Assigned(LArr) then
        Exit;
      LLang := GetPreferredLanguage;
      LBackupEn := '';
      for LEntry in LArr do
        if LEntry is TJSONObject then
        begin
          LLangObj := TJSONObject(LEntry).GetValue('language');
          if not(Assigned(LLangObj) and (LLangObj is TJSONObject)) then
            Continue;
          if TJSONObject(LLangObj).GetValue<string>('name') = LLang then
            Result := TJSONObject(LEntry).GetValue<string>('flavor_text')
          else if TJSONObject(LLangObj).GetValue<string>('name') = 'en' then
            LBackupEn := TJSONObject(LEntry).GetValue<string>('flavor_text');
        end;
      if Result.IsEmpty then
        Result := LBackupEn;
      Result := Result.Replace(#10, ' ').Replace(#12, ' ').Replace(#13, ' ');
    finally
      LObj.Free;
    end;
  except
    Result := '';
  end;
end;

class function TPokemonController.GetSystemLanguage: string;
var
  LLocaleName: array [0 .. LOCALE_NAME_MAX_LENGTH - 1] of Char;
begin
  if GetUserDefaultLocaleName(LLocaleName, LOCALE_NAME_MAX_LENGTH) > 0 then
    Result := string(LLocaleName).Split(['-'])[0].ToLower
  else
    Result := 'en';
end;

class function TPokemonController.Translate(const AText,
  AToLang: string): string;
var
  LHttp: TNetHTTPClient;
  LUrl: string;
  LRoot: TJSONValue;
  LRespDataVal: TJSONValue;
  LTranslated: string;
begin
  Result := AText;
  if AText.IsEmpty or (AToLang = 'en') then
    Exit;
  LHttp := TNetHTTPClient.Create(nil);
  try
    try
      LUrl := 'https://api.mymemory.translated.net/get?q=' +
        TNetEncoding.URL.Encode(AText.Trim) + '&langpair=en|' + AToLang;
      LRoot := TJSONObject.ParseJSONValue(LHttp.Get(LUrl).ContentAsString);
      if Assigned(LRoot) and (LRoot is TJSONObject) then
      try
        LRespDataVal := TJSONObject(LRoot).GetValue('responseData');
        if Assigned(LRespDataVal) and (LRespDataVal is TJSONObject) then
        begin
          LTranslated := TJSONObject(LRespDataVal).GetValue<string>(
            'translatedText', AText);
          if not LTranslated.StartsWith('MYMEMORY WARNING') then
            Result := LTranslated;
        end;
      finally
        LRoot.Free;
      end;
    except
      Result := AText;
    end;
  finally
    LHttp.Free;
  end;
end;

class function TPokemonController.GetPreferredLanguage: string;
var
  LLocaleName: array [0 .. LOCALE_NAME_MAX_LENGTH - 1] of Char;
  LLocale, LPrimary: string;
begin
  Result := 'en';
  if GetUserDefaultLocaleName(LLocaleName, LOCALE_NAME_MAX_LENGTH) = 0 then
    Exit;
  LLocale := string(LLocaleName);
  LPrimary := LLocale.Split(['-'])[0].ToLower;
  if LPrimary = 'fr' then
    Result := 'fr'
  else if LPrimary = 'de' then
    Result := 'de'
  else if LPrimary = 'es' then
    Result := 'es'
  else if LPrimary = 'it' then
    Result := 'it'
  else if LPrimary = 'ja' then
    Result := 'ja'
  else if LPrimary = 'ko' then
    Result := 'ko'
  else if LPrimary = 'zh' then
  begin
    if LLocale.StartsWith('zh-Hant', True) or LLocale.StartsWith('zh-TW', True)
      or LLocale.StartsWith('zh-HK', True) then
      Result := 'zh-Hant'
    else
      Result := 'zh-Hans';
  end;
end;

class function TPokemonController.RandomPokemonId: Integer;
begin
  Result := Random(POKEMON_MAX_ID) + 1;
end;

end.

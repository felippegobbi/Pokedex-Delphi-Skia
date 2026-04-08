unit Pokedex.Controller.Pokemon;

interface

uses
  Pokedex.Model.Pokemon,
  Pokedex.Service.API,
  REST.Json,
  System.SysUtils,
  System.Classes,
  System.UITypes,
  VCL.Graphics,
  System.Generics.Collections;

type
  TPokemonController = class
  private
    class var FTypeColors: TDictionary<string, TColor>;
    class var FSpeciesColors: TDictionary<string, TColor>;
    class procedure InitializeColorMaps;
  public
    class function ExecuteGetPokemon(const AIdOrName: string): TPokemon;
    class function DownloadImage(const AUrl: string): TMemoryStream;
    class function FormatMetric(const AValue: Integer;
      const AUnit: string): string;
    class function GetColorByString(const AColorName: string): TColor;
    class procedure FillAutoCompleteList(AList: TStrings);
    class function GetTypeColor(const ATypeName: string): TColor;
    class constructor Create;
    class destructor Destroy;
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

class destructor TPokemonController.Destroy;
begin
  FTypeColors.Free;
  FSpeciesColors.Free;
end;

class function TPokemonController.DownloadImage(const AUrl: string)
  : TMemoryStream;
var
  LHttp: TNetHTTPClient;
begin
  Result := TMemoryStream.Create;
  LHttp := TNetHTTPClient.Create(nil);
  try
    try
      LHttp.Get(AUrl, Result);
      Result.Position := 0;
    except
      Result.Free;
      Result := nil;
    end;
  finally
    LHttp.Free;
  end;
end;

class function TPokemonController.ExecuteGetPokemon(const AIdOrName: string)
  : TPokemon;
var
  LContent, LSpeciesContent: string;
begin
  Result := nil;
  try
    LContent := dmPokeService.GetPokemonJSON(AIdOrName);

    if (not LContent.IsEmpty) and (LContent.StartsWith('{')) then
    begin
      Result := TJson.JsonToObject<TPokemon>(LContent);

      if Assigned(Result) and Assigned(Result.Species) then
      begin
        LSpeciesContent := dmPokeService.GetSpeciesJSON(Result.Species.Url);
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

class procedure TPokemonController.FillAutoCompleteList(AList: TStrings);
var
  LContent: string;
  LJSONObject, LItem: TJsonObject;
  LResults: TJSONArray;
  I: Integer;
begin
  LContent := dmPokeService.GetAllPokemonName;

  if LContent.IsEmpty then
    exit;

  LJSONObject := TJsonObject.ParseJSONValue(LContent) as TJsonObject;

  try
    if Assigned(LJSONObject) then
    begin
      LResults := LJSONObject.GetValue<TJSONArray>('results');
      AList.BeginUpdate;
      try
        AList.Clear;
        for I := 0 to LResults.Count - 1 do
        begin
          LItem := LResults.Items[I] as TJsonObject;
          AList.Add(LItem.GetValue<string>('name'));
        end;
      finally
        AList.EndUpdate;
      end;
    end;
  finally
    LJSONObject.Free;
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

class function TPokemonController.GetTypeColor(const ATypeName: string): TColor;
begin
  if not FTypeColors.TryGetValue(ATypeName.ToLower, Result) then
    Result := $00A8A8A8;
end;

class procedure TPokemonController.InitializeColorMaps;
begin
  FTypeColors := TDictionary<string, TColor>.Create;
  FTypeColors.Add('fire', $0044A1F0);
  FTypeColors.Add('water', $00F09068);
  FTypeColors.Add('grass', $0071C278);
  FTypeColors.Add('electric', $0048D0F8);
  FTypeColors.Add('ice', $00D0F098);
  FTypeColors.Add('fighting', $003030C0);
  FTypeColors.Add('poison', $00A040A0);
  FTypeColors.Add('ground', $005090E0);
  FTypeColors.Add('flying', $00D090A8);
  FTypeColors.Add('psychic', $009858F8);
  FTypeColors.Add('bug', $0020A8A8);
  FTypeColors.Add('rock', $004088B8);
  FTypeColors.Add('ghost', $00A06070);
  FTypeColors.Add('dragon', $00F18A70);
  FTypeColors.Add('dark', $004F7070);
  FTypeColors.Add('steel', $00D1B8B8);
  FTypeColors.Add('fairy', $00D090A8);
  FTypeColors.Add('normal', $00A8A8A8);

  FSpeciesColors := TDictionary<string, TColor>.Create;
  FSpeciesColors.Add('black', $002C2C2C);
  FSpeciesColors.Add('blue', $00F09068);
  FSpeciesColors.Add('brown', $005090A8);
  FSpeciesColors.Add('gray', $00A8A8A8);
  FSpeciesColors.Add('green', $0078C850);
  FSpeciesColors.Add('pink', $00B8A0F8);
  FSpeciesColors.Add('purple', $00A04070);
  FSpeciesColors.Add('red', $005050F0);
  FSpeciesColors.Add('white', clWhite);
  FSpeciesColors.Add('yellow', $0030D0F8);
end;

end.

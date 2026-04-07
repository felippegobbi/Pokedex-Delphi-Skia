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
  public
    class function ExecuteGetPokemon(const AIdOrName: string): TPokemon;
    class function DownloadImage(const AUrl: string): TMemoryStream;
    class function FormatMetric(const AValue: Integer;
      const AUnit: string): string;
    class function GetColorByString(const AColorName: string): TColor;
    class procedure FillAutoCompleteList(AList: TStrings);
  end;

implementation

uses
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Json;

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

      // Cascata: Se temos o Pokémon, buscamos a espécie para a descrição
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

  LJSONObject := TJSONObject.ParseJSONValue(LContent) as TJSONObject;

  try
    if Assigned(LJSONObject) then
    begin
      LResults := LJSONObject.GetValue<TJSONArray>('results');
      AList.BeginUpdate;
      try
        AList.Clear;
        for I := 0 to LResults.Count - 1 do
        begin
          LItem := LResults.Items[I] as TJSONObject;
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
  if AColorName = 'black' then
    exit($002C2C2C);
  if AColorName = 'blue' then
    exit($00F09068);
  if AColorName = 'brown' then
    exit($005090A8);
  if AColorName = 'gray' then
    exit($00A8A8A8);
  if AColorName = 'green' then
    exit($0078C850);
  if AColorName = 'pink' then
    exit($00B8A0F8);
  if AColorName = 'purple' then
    exit($00A04070);
  if AColorName = 'red' then
    exit($005050F0);
  if AColorName = 'white' then
    exit(clWhite);
  if AColorName = 'yellow' then
    exit($0030D0F8);

  Result := clBtnFace;
end;

end.

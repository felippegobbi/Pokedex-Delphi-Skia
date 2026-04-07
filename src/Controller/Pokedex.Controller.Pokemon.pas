unit Pokedex.Controller.Pokemon;

interface

uses
  Pokedex.Model.Pokemon,
  Pokedex.Service.API,
  REST.Json,
  System.SysUtils,
  System.Classes;

type
  TPokemonController = class
  public
    class function ExecuteGetPokemon(const AIdOrName: string): TPokemon;
    class function DownloadImage(const AUrl: string): TMemoryStream;
    class function FormatMetric(const AValue: Integer;
      const AUnit: string): string;
  end;

implementation

uses
  System.Net.HttpClient,
  System.Net.HttpClientComponent;

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

class function TPokemonController.FormatMetric(const AValue: Integer;
  const AUnit: string): string;
begin
  Result := FormatFloat('0.0', AValue / 10) + ' ' + AUnit;
end;

end.

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
  LContent: string;
begin
  Result := nil;
  try
    LContent := dmPokeService.GetPokemonJSON(AIdOrName);

    if (not LContent.IsEmpty) and (LContent.StartsWith('{')) then
    begin
      try
        Result := TJson.JsonToObject<TPokemon>(LContent);
      except
        Result := nil;
      end;
    end;

  except
    on E: Exception do
      Result := nil;
  end;
end;

class function TPokemonController.FormatMetric(const AValue: Integer;
  const AUnit: string): string;
begin
  Result := FormatFloat('0.0', AValue / 10) + ' ' + AUnit;
end;

end.

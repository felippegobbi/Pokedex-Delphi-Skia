unit Pokedex.Controller.Pokemon;

interface

uses
  Pokedex.Model.Pokemon,
  Pokedex.Service.API,
  REST.Json,
  System.SysUtils,
  System.Classes,
  System.UITypes,
  VCL.Graphics;

type
  TPokemonController = class
  public
    class function ExecuteGetPokemon(const AIdOrName: string): TPokemon;
    class function DownloadImage(const AUrl: string): TMemoryStream;
    class function FormatMetric(const AValue: Integer;
      const AUnit: string): string;
    class function GetColorByString(const AColorName: string): TColor;
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

class function TPokemonController.GetColorByString(const AColorName
  : string): TColor;
begin
  if AColorName = 'black' then
    Exit($002C2C2C);
  if AColorName = 'blue' then
    Exit($00F09068);
  if AColorName = 'brown' then
    Exit($005090A8);
  if AColorName = 'gray' then
    Exit($00A8A8A8);
  if AColorName = 'green' then
    Exit($0078C850);
  if AColorName = 'pink' then
    Exit($00B8A0F8);
  if AColorName = 'purple' then
    Exit($00A04070);
  if AColorName = 'red' then
    Exit($005050F0);
  if AColorName = 'white' then
    Exit(clWhite);
  if AColorName = 'yellow' then
    Exit($0030D0F8);

  Result := clBtnFace;
end;

end.

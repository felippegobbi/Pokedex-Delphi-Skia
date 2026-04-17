unit Pokedex.Service.API;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClientComponent,
  System.Net.HttpClient,
  Pokedex.Service.Interfaces;

type
  TdmPokeService = class(TDataModule, IPokemonService)
  public
    function GetPokemonJSON(const AIdOrName: string): string;
    function GetSpeciesJSON(const AUrl: string): string;
    function GetEvolutionChainJSON(const AUrl: string): string;
  end;

var
  dmPokeService: TdmPokeService;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

const
  BASE_URL = 'https://pokeapi.co/api/v2';

function TdmPokeService.GetPokemonJSON(const AIdOrName: string): string;
var
  LHttp: TNetHTTPClient;
  LResponse: IHTTPResponse;
begin
  Result := '';
  LHttp := TNetHTTPClient.Create(nil);
  try
    try
      LResponse := LHttp.Get(BASE_URL + '/pokemon/' + LowerCase(Trim(AIdOrName)));
      if LResponse.StatusCode = 200 then
        Result := LResponse.ContentAsString;
    except
      Result := '';
    end;
  finally
    LHttp.Free;
  end;
end;

function TdmPokeService.GetSpeciesJSON(const AUrl: string): string;
var
  LHttp: TNetHTTPClient;
  LResponse: IHTTPResponse;
begin
  Result := '';
  LHttp := TNetHTTPClient.Create(nil);
  try
    try
      LResponse := LHttp.Get(AUrl);
      if LResponse.StatusCode = 200 then
        Result := LResponse.ContentAsString;
    except
      Result := '';
    end;
  finally
    LHttp.Free;
  end;
end;

function TdmPokeService.GetEvolutionChainJSON(const AUrl: string): string;
var
  LHttp: TNetHTTPClient;
  LResponse: IHTTPResponse;
begin
  Result := '';
  LHttp := TNetHTTPClient.Create(nil);
  try
    try
      LResponse := LHttp.Get(AUrl);
      if LResponse.StatusCode = 200 then
        Result := LResponse.ContentAsString;
    except
      Result := '';
    end;
  finally
    LHttp.Free;
  end;
end;

end.

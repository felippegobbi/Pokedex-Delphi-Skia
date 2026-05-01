unit Pokedex.Service.API;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClientComponent,
  System.Net.HttpClient,
  Pokedex.Service.Interfaces,
  Pokedex.Constants;

type
  TdmPokeService = class(TDataModule, IPokemonService)
  private
    function DoGet(const AUrl: string): string;
  public
    function GetPokemonJSON(const AIdOrName: string): string;
    function GetSpeciesJSON(const AUrl: string): string;
    function GetEvolutionChainJSON(const AUrl: string): string;
    function GetTypeJSON(const AUrl: string): string;
    function GetEncountersJSON(const AIdOrName: string): string;
  end;

var
  dmPokeService: TdmPokeService;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}


function TdmPokeService.DoGet(const AUrl: string): string;
var
  LHttp: TNetHTTPClient;
  LResponse: IHTTPResponse;
begin
  LHttp := TNetHTTPClient.Create(nil);
  try
    LHttp.ConnectionTimeout := HTTP_TIMEOUT_MS;
    LHttp.ResponseTimeout := HTTP_TIMEOUT_MS;
    try
      LResponse := LHttp.Get(AUrl);
    except
      on E: Exception do
        raise EPokemonNetworkError.Create(E.Message);
    end;
    case LResponse.StatusCode of
      200: Result := LResponse.ContentAsString;
      404: raise EPokemonNotFound.Create('Pok'#233'mon n'#227'o encontrado');
    else
      raise EPokemonNetworkError.CreateFmt('Erro HTTP %d', [LResponse.StatusCode]);
    end;
  finally
    LHttp.Free;
  end;
end;

function TdmPokeService.GetPokemonJSON(const AIdOrName: string): string;
begin
  Result := DoGet(POKEAPI_POKEMON + LowerCase(Trim(AIdOrName)));
end;

function TdmPokeService.GetSpeciesJSON(const AUrl: string): string;
begin
  Result := DoGet(AUrl);
end;

function TdmPokeService.GetEvolutionChainJSON(const AUrl: string): string;
begin
  Result := DoGet(AUrl);
end;

function TdmPokeService.GetTypeJSON(const AUrl: string): string;
begin
  Result := DoGet(AUrl);
end;

function TdmPokeService.GetEncountersJSON(const AIdOrName: string): string;
begin
  Result := DoGet(POKEAPI_POKEMON + LowerCase(Trim(AIdOrName)) + '/encounters');
end;

end.

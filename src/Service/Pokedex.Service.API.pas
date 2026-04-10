unit Pokedex.Service.API;

interface

uses
  System.SysUtils,
  System.Classes,
  System.net.HttpClientComponent,
  System.net.HttpClient,
  REST.Types,
  REST.Client,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  Pokedex.Service.Interfaces;

type
  TdmPokeService = class(TDataModule, IPokemonService)
    RESTClientPoke: TRESTClient;
    ReqPokemonById: TRESTRequest;
    ResPokemonJSON: TRESTResponse;
  public
    function GetPokemonJSON(const AIdOrName: string): string;
    function GetSpeciesJSON(const AUrl: string): string;
    function GetAllPokemonName: string;
  end;

var
  dmPokeService: TdmPokeService;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

function TdmPokeService.GetAllPokemonName: string;
begin
  Result := '';

  try
    RESTClientPoke.BaseURL := 'https://pokeapi.co/api/v2';
    ReqPokemonById.Resource := 'pokemon?limit=2000';
    ReqPokemonById.Execute;

    if ResPokemonJSON.StatusCode = 200 then
      Result := ResPokemonJSON.Content;
  except
    Result := '';
  end;
end;

function TdmPokeService.GetPokemonJSON(const AIdOrName: string): string;
begin
  Result := '';
  RESTClientPoke.BaseURL := 'https://pokeapi.co/api/v2';

  try
    ReqPokemonById.Resource := 'pokemon/' + LowerCase(Trim(AIdOrName));
    ReqPokemonById.Execute;

    if ResPokemonJSON.StatusCode = 200 then
      Result := ResPokemonJSON.Content;
  except
    Result := '';
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

end.

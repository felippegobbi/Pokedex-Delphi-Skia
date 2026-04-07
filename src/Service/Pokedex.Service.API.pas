unit Pokedex.Service.API;

interface

uses
  System.SysUtils,
  System.Classes,
  REST.Types,
  REST.Client,
  Data.Bind.Components,
  Data.Bind.ObjectScope;

type
  TdmPokeService = class(TDataModule)
    RESTClientPoke: TRESTClient;
    ReqPokemonById: TRESTRequest;
    ResPokemonJSON: TRESTResponse;
  public
    function GetPokemonJSON(const AIdOrName: string): string;
    function GetSpeciesJSON(const AUrl: string): string;
  end;

var
  dmPokeService: TdmPokeService;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

function TdmPokeService.GetPokemonJSON(const AIdOrName: string): string;
begin
  Result := '';
  try
    ReqPokemonById.Resource := 'pokemon/' + LowerCase(Trim(AIdOrName));
    ReqPokemonById.Execute;

    if ResPokemonJSON.StatusCode = 200 then
      Result := ResPokemonJSON.Content;
  except
    // Se der 404 ou erro de rede, retorna vazio para o Controller tratar
    Result := '';
  end;
end;

function TdmPokeService.GetSpeciesJSON(const AUrl: string): string;
begin
  Result := '';

  try
    RESTClientPoke.BaseURL := AUrl;
    ReqPokemonById.Resource := '';
    ReqPokemonById.Params.Clear;
    ReqPokemonById.Execute;

    if ResPokemonJSON.StatusCode = 200 then
      Result := ResPokemonJSON.Content;
  except
    Result := '';
  end;
end;

end.

unit Pokedex.Controller.Pokemon;

interface

uses
  Pokedex.Model.Pokemon, Pokedex.Service.API, REST.Json, System.SysUtils;

type
  TPokemonController = class
  public
    // Função estática para facilitar a chamada sem gerenciar memória da classe agora
    class function ExecuteGetPokemon(const AIdOrName: string): TPokemon;
  end;

implementation

class function TPokemonController.ExecuteGetPokemon(const AIdOrName: string): TPokemon;
begin
  // 1. Configura e dispara o serviço (que está no DataModule)
  dmPokeService.ReqPokemonById.Resource := 'pokemon/' + LowerCase(AIdOrName);
  dmPokeService.ReqPokemonById.Execute;

  // 2. Converte o JSON bruto do Response diretamente para o nosso Objeto Model
  Result := TJson.JsonToObject<TPokemon>(dmPokeService.ResPokemonJSON.Content);
end;

end.

unit Pokedex.Service.Interfaces;

interface

uses
  System.SysUtils;

type
  EPokemonError        = class(Exception);
  EPokemonNotFound     = class(EPokemonError);
  EPokemonNetworkError = class(EPokemonError);
  EPokemonParseError   = class(EPokemonError);

  IPokemonService = interface
    ['{FA6D0EA6-79BE-46F2-9DD9-B75CF289E59F}']
    function GetPokemonJSON(const AIdOrName: string): string;
    function GetSpeciesJSON(const AUrl: string): string;
    function GetEvolutionChainJSON(const AUrl: string): string;
  end;

implementation

end.

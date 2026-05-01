unit Pokedex.Constants;

interface

const
  // PokeAPI
  POKEAPI_BASE    = 'https://pokeapi.co/api/v2';
  POKEAPI_POKEMON = POKEAPI_BASE + '/pokemon/';
  POKEAPI_TYPE    = POKEAPI_BASE + '/type/';
  POKEAPI_ABILITY = POKEAPI_BASE + '/ability/';

  // GitHub raw assets
  SPRITES_BASE = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/';
  CRIES_BASE   = 'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/';

  // Translation
  MYMEMORY_URL = 'https://api.mymemory.translated.net/get';

  // HTTP
  HTTP_TIMEOUT_MS = 10000;

  // Storage
  HISTORY_FILE   = 'recent_searches.txt';
  FAVORITES_FILE = 'favorites.txt';
  HISTORY_MAX    = 10;

  // App
  POKEMON_MAX_ID = 1025;

implementation

end.

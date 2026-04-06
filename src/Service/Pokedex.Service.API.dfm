object dmPokeService: TdmPokeService
  Height = 480
  Width = 640
  object RESTClientPoke: TRESTClient
    BaseURL = 'https://pokeapi.co/api/v2'
    Params = <>
    SynchronizedEvents = False
    Left = 48
    Top = 16
  end
  object ReqPokemonById: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTClientPoke
    Params = <>
    Response = ResPokemonJSON
    SynchronizedEvents = False
    Left = 48
    Top = 72
  end
  object ResPokemonJSON: TRESTResponse
    Left = 48
    Top = 128
  end
end

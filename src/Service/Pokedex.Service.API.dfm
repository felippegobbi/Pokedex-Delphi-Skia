object DataModule1: TDataModule1
  Height = 480
  Width = 640
  object RESTClientPoke: TRESTClient
    BaseURL = 'https://pokeapi.co/api/v2/pokemon/1'
    Params = <>
    SynchronizedEvents = False
    Left = 32
    Top = 16
  end
  object ReqPokemon: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTClientPoke
    Params = <>
    Response = ResPokemon
    SynchronizedEvents = False
    Left = 32
    Top = 72
  end
  object ResPokemon: TRESTResponse
    Left = 32
    Top = 128
  end
end

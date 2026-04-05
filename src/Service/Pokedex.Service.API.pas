unit Pokedex.Service.API;

interface

uses
  System.SysUtils, System.Classes, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope;

type
  TDataModule1 = class(TDataModule)
    RESTClientPoke: TRESTClient;
    ReqPokemon: TRESTRequest;
    ResPokemon: TRESTResponse;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.

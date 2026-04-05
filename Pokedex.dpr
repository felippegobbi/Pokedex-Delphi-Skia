program Pokedex;

uses
  Vcl.Forms,
  Pokedex.View.Main in 'Pokedex.View.Main.pas' {PokedexView},
  Pokedex.Service.API in 'Pokedex.Service.API.pas' {DataModule1: TDataModule},
  Pokedex.Controller.Pokemon in 'Pokedex.Controller.Pokemon.pas',
  Pokedex.Model.Pokemon in 'src\Model\Pokedex.Model.Pokemon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TPokedexView, PokedexView);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.

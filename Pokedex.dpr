program Pokedex;

uses
  Vcl.Forms,
  Pokedex.Model.Pokemon in 'src\Model\Pokedex.Model.Pokemon.pas',
  Pokedex.Controller.Pokemon in 'src\Controller\Pokedex.Controller.Pokemon.pas',
  Pokedex.Service.API in 'src\Service\Pokedex.Service.API.pas' {dmPokeService: TDataModule},
  Pokedex.Service.Interfaces in 'src\Service\Pokedex.Service.Interfaces.pas',
  Pokedex.Constants in 'src\Pokedex.Constants.pas',
  Pokedex.Service.Storage in 'src\Service\Pokedex.Service.Storage.pas',
  Pokedex.View.EvolutionPanel in 'src\View\Pokedex.View.EvolutionPanel.pas',
  Pokedex.View.Main in 'src\View\Pokedex.View.Main.pas' {PokedexView},
  Pokedex.View.StatsPanel in 'src\View\Pokedex.View.StatsPanel.pas',
  Pokedex.Audio.Bass in 'src\Audio\Pokedex.Audio.Bass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmPokeService, dmPokeService);
  Application.CreateForm(TPokedexView, PokedexView);
  PokedexView.Initialize(dmPokeService);
  Application.Run;
end.

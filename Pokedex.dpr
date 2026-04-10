program Pokedex;

uses
  Vcl.Forms,
  Pokedex.Model.Pokemon in 'src\Model\Pokedex.Model.Pokemon.pas',
  Pokedex.Controller.Pokemon in 'src\Controller\Pokedex.Controller.Pokemon.pas',
  Pokedex.Service.API in 'src\Service\Pokedex.Service.API.pas' {dmPokeService: TDataModule},
  Pokedex.View.Main in 'src\View\Pokedex.View.Main.pas' {PokedexView},
  Pokedex.Service.Interfaces in 'src\Service\Pokedex.Service.Interfaces.pas',
  Pokedex.View.StatsPanel in 'src\View\Pokedex.View.StatsPanel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmPokeService, dmPokeService);
  Application.CreateForm(TPokedexView, PokedexView);
  Application.Run;
end.

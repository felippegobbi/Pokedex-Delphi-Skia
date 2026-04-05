unit Pokedex.View.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, Vcl.ExtCtrls, Vcl.StdCtrls,
  System.Skia, Vcl.Skia;

type
  TPokedexView = class(TForm)
    pnlTopContainer: TPanel;
    edtSearchInput: TEdit;
    btnSearchAction: TButton;
    pnlImage: TPanel;
    lblDisplayName: TLabel;
    memDebugLog: TMemo;
    imgPokemonDisplay: TSkAnimatedImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PokedexView: TPokedexView;

implementation

{$R *.dfm}

uses Pokedex.Service.API;

end.

unit Pokedex.Model.Pokemon;

interface

uses
  System.Generics.Collections,
  Rest.Json.Types,
  System.SysUtils;

type
  TApiResource = class
  private
    [JSONName('name')]
    FName: string;
    [JSONName('url')]
    FUrl: string;
  public
    property Name: string read FName write FName;
    property Url: string read FUrl write FUrl;
  end;

  TAbility = class
  private
    [JSONName('ability')]
    FAbility: TApiResource;
  public
    property Ability: TApiResource read FAbility write FAbility;
    constructor Create;
    destructor Destroy; override;
  end;

  TNamedResource = class
  private
    [JSONName('name')]
    FName: string;
  public
    property Name: string read FName write FName;
  end;

  TPokemonType = class
  private
    [JSONName('type')]
    FType: TNamedResource;
  public
    property &Type: TNamedResource read FType write FType;
    constructor Create;
    destructor Destroy; override;
  end;

  TSprites = class
  private
    [JSONName('front_default')]
    FFrontDefault: string;
  public
    property FrontDefault: string read FFrontDefault write FFrontDefault;
  end;

  TStatEntry = class
  private
    [JSONName('base_stat')]
    FBaseStat: Integer;
    [JSONName('stat')]
    FStat: TApiResource;
  public
    destructor Destroy; override;
    property BaseStat: Integer read FBaseStat write FBaseStat;
    property Stat: TApiResource read FStat write FStat;
  end;

  TFlavorText = class
  private
    [JSONName('flavor_text')]
    FText: string;
    [JSONName('language')]
    FLanguage: TApiResource;
  public
    property Text: string read FText write FText;
    property Language: TApiResource read FLanguage write FLanguage;
  end;

  TPokemonSpecies = class
  private
    [JSONName('flavor_text_entries')]
    FFlavorEntries: TArray<TFlavorText>;
    [JSONName('evolution_chain')]
    FEvolutionChain: TApiResource;
    [JSONName('color')]
    FColor: TApiResource;
  public
    property FlavorEntries: TArray<TFlavorText> read FFlavorEntries
      write FFlavorEntries;
    property EvolutionChain: TApiResource read FEvolutionChain
      write FEvolutionChain;
    property Color: TApiResource read FColor write FColor;

    function GetDescription: string;
  end;

  TPokemon = class
  private
    [JSONName('id')]
    FId: Integer;
    [JSONName('name')]
    FName: string;
    [JSONName('weight')]
    FWeight: Integer;
    [JSONName('height')]
    FHeight: Integer;
    [JSONName('sprites')]
    FSprites: TSprites;
    [JSONName('abilities')]
    FAbilities: TArray<TAbility>;
    [JSONName('types')]
    FTypes: TArray<TPokemonType>;
    [JSONName('species')]
    FSpecies: TApiResource;
    [JSONName('stats')]
    FStats: TArray<TStatEntry>;
    FSpeciesData: TPokemonSpecies;
    function GetSpriteUrl: string;

  public
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Weight: Integer read FWeight write FWeight;
    property Height: Integer read FHeight write FHeight;
    property Sprites: TSprites read FSprites write FSprites;
    property Abilities: TArray<TAbility> read FAbilities write FAbilities;
    property Types: TArray<TPokemonType> read FTypes write FTypes;
    property Species: TApiResource read FSpecies write FSpecies;
    property SpeciesData: TPokemonSpecies read FSpeciesData write FSpeciesData;
    property Stats: TArray<TStatEntry> read FStats write FStats;
    property SpriteUrl: string read GetSpriteUrl;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TPokemon }
constructor TPokemon.Create;
begin
  FSprites := TSprites.Create;
end;

destructor TPokemon.Destroy;
var
  I: Integer;
  LStat: TStatEntry;
begin
  FreeAndNil(FSprites);
  FreeAndNil(FSpecies);
  FreeAndNil(FSpeciesData);

  for I := 0 to Length(FAbilities) - 1 do
    FAbilities[I].Free;

  for I := 0 to Length(FTypes) - 1 do
    FTypes[I].Free;

  for LStat in FStats do
    LStat.Free;

  inherited;
end;

function TPokemon.GetSpriteUrl: string;
begin
  if Assigned(FSprites) then
    Result := FSprites.FrontDefault
  else
    Result := '';
end;

{ TAbility }
constructor TAbility.Create;
begin
  FAbility := TApiResource.Create;
end;

destructor TAbility.Destroy;
begin
  FAbility.Free;
  inherited;
end;

{ TPokemonType }
constructor TPokemonType.Create;
begin
  FType := TNamedResource.Create;
end;

destructor TPokemonType.Destroy;
begin
  FType.Free;
  inherited;
end;

{ TPokemonSpecies }

function TPokemonSpecies.GetDescription: string;
var
  LEntry: TFlavorText;
  LBackupEn: string;
begin
  Result := '';
  LBackupEn := '';

  for LEntry in FFlavorEntries do
  begin
    if (LEntry.Language.Name = 'pt-BR') or (LEntry.Language.Name = 'pt') then
    begin
      Result := LEntry.Text;
      Break;
    end;

    if LEntry.Language.Name = 'en' then
      LBackupEn := LEntry.Text;
  end;

  if Result = '' then
    Result := LBackupEn;

  Result := Result.Replace(#10, ' ').Replace(#12, ' ').Replace(#13, ' ');
end;

{ TStatEntry }

destructor TStatEntry.Destroy;
begin
  if Assigned(FStat) then
    FStat.Free;

  inherited;
end;

end.

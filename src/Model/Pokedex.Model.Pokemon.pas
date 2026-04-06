unit Pokedex.Model.Pokemon;

interface

uses
  System.Generics.Collections,
  Rest.Json.Types;

type
  TAbilityInfo = class
  private
    [JSONName('name')]
    FName: string;
  public
    property Name: string read FName write FName;
  end;

  TAbility = class
  private
    [JSONName('ability')]
    FAbility: TAbilityInfo;
  public
    property Ability: TAbilityInfo read FAbility write FAbility;
    constructor Create;
    destructor Destroy; override;
  end;

  TTypeInfo = class
  private
    [JSONName('name')]
    FName: string;
  public
    property Name: string read FName write FName;
  end;

  TPokemonType = class
  private
    [JSONName('type')]
    FType: TTypeInfo;
  public
    property &Type: TTypeInfo read FType write FType;
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
  public
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Weight: Integer read FWeight write FWeight;
    property Height: Integer read FHeight write FHeight;
    property Sprites: TSprites read FSprites write FSprites;
    property Abilities: TArray<TAbility> read FAbilities write FAbilities;
    property Types: TArray<TPokemonType> read FTypes write FTypes;

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
begin
  FSprites.Free;
  for I := 0 to Length(FAbilities) - 1 do
    FAbilities[I].Free;
  for I := 0 to Length(FTypes) - 1 do
    FTypes[I].Free;
  inherited;
end;

{ TAbility }
constructor TAbility.Create;
begin
  FAbility := TAbilityInfo.Create;
end;

destructor TAbility.Destroy;
begin
  FAbility.Free;
  inherited;
end;

{ TPokemonType }
constructor TPokemonType.Create;
begin
  FType := TTypeInfo.Create;
end;

destructor TPokemonType.Destroy;
begin
  FType.Free;
  inherited;
end;

end.

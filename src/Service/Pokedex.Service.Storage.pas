unit Pokedex.Service.Storage;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs;

type
  TStorageService = class
  private
    FHistory: TStringList;
    FFavorites: TStringList;
    FLock: TCriticalSection;
    function FilePath(const AFileName: string): string;
    procedure Load(AList: TStringList; const AFileName: string);
    procedure Save(AList: TStringList; const AFileName: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddToHistory(const ASearch: string);
    function GetHistory: TArray<string>;
    procedure ToggleFavorite(const AId: Integer);
    function IsFavorite(const AId: Integer): Boolean;
    function GetFavorites: TArray<string>;
  end;

implementation

uses
  System.IOUtils,
  Pokedex.Constants;

constructor TStorageService.Create;
begin
  FLock := TCriticalSection.Create;
  FHistory := TStringList.Create;
  FHistory.Duplicates := dupIgnore;
  FHistory.Sorted := False;
  FFavorites := TStringList.Create;
  Load(FHistory, HISTORY_FILE);
  Load(FFavorites, FAVORITES_FILE);
end;

destructor TStorageService.Destroy;
begin
  FLock.Enter;
  try
    Save(FHistory, HISTORY_FILE);
    Save(FFavorites, FAVORITES_FILE);
    FHistory.Free;
    FFavorites.Free;
  finally
    FLock.Leave;
  end;
  FLock.Free;
  inherited;
end;

function TStorageService.FilePath(const AFileName: string): string;
begin
  Result := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), AFileName);
end;

procedure TStorageService.Load(AList: TStringList; const AFileName: string);
var
  LPath: string;
begin
  LPath := FilePath(AFileName);
  if TFile.Exists(LPath) then
    AList.LoadFromFile(LPath);
end;

procedure TStorageService.Save(AList: TStringList; const AFileName: string);
begin
  try
    AList.SaveToFile(FilePath(AFileName));
  except
    // I/O failure is non-critical; app continues normally
  end;
end;

procedure TStorageService.AddToHistory(const ASearch: string);
var
  LIdx: Integer;
begin
  if ASearch.Trim.IsEmpty then
    Exit;
  FLock.Enter;
  try
    LIdx := FHistory.IndexOf(ASearch.ToLower);
    if LIdx >= 0 then
      FHistory.Delete(LIdx);
    FHistory.Insert(0, ASearch.ToLower);
    while FHistory.Count > HISTORY_MAX do
      FHistory.Delete(FHistory.Count - 1);
    Save(FHistory, HISTORY_FILE);
  finally
    FLock.Leave;
  end;
end;

function TStorageService.GetHistory: TArray<string>;
var
  I: Integer;
begin
  FLock.Enter;
  try
    SetLength(Result, FHistory.Count);
    for I := 0 to FHistory.Count - 1 do
      Result[I] := FHistory[I];
  finally
    FLock.Leave;
  end;
end;

procedure TStorageService.ToggleFavorite(const AId: Integer);
var
  LIdx: Integer;
begin
  FLock.Enter;
  try
    LIdx := FFavorites.IndexOf(AId.ToString);
    if LIdx >= 0 then
      FFavorites.Delete(LIdx)
    else
      FFavorites.Add(AId.ToString);
    Save(FFavorites, FAVORITES_FILE);
  finally
    FLock.Leave;
  end;
end;

function TStorageService.IsFavorite(const AId: Integer): Boolean;
begin
  FLock.Enter;
  try
    Result := FFavorites.IndexOf(AId.ToString) >= 0;
  finally
    FLock.Leave;
  end;
end;

function TStorageService.GetFavorites: TArray<string>;
var
  I: Integer;
begin
  FLock.Enter;
  try
    SetLength(Result, FFavorites.Count);
    for I := 0 to FFavorites.Count - 1 do
      Result[I] := FFavorites[I];
  finally
    FLock.Leave;
  end;
end;

end.

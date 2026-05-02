unit Pokedex.Audio.TTS;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  System.SyncObjs;

type
  ITTSEngine = interface
    ['{8F3E2A1B-C5D6-4E7F-90AB-123456789012}']
    procedure Speak(const AText: string; AOnDone: TProc);
    procedure Stop;
    function IsSpeaking: Boolean;
  end;

  TSapiTTSEngine = class(TInterfacedObject, ITTSEngine)
  private
    FSpeechObj: OleVariant;
    FIsSpeaking: Boolean;
    FGeneration: Integer;
    FLock: TCriticalSection;
    FSilent: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Speak(const AText: string; AOnDone: TProc);
    procedure Stop;
    function IsSpeaking: Boolean;
  end;

implementation

uses
  System.Win.ComObj,
  Winapi.Windows,
  Winapi.ActiveX;

const
  SVSFDefault          = 0;
  SVSFlagsAsync        = 1;
  SVSFPurgeBeforeSpeak = 2;

function CleanTTSText(const AText: string): string;
var
  I: Integer;
  C: Char;
begin
  SetLength(Result, Length(AText));
  for I := 1 to Length(AText) do
  begin
    C := AText[I];
    if (C < #32) or (C = #127) then
      Result[I] := ' '
    else
      Result[I] := C;
  end;
  Result := Trim(Result);
end;

{ TSapiTTSEngine }

constructor TSapiTTSEngine.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  try
    FSpeechObj := CreateOleObject('SAPI.SpVoice');
    FSpeechObj.Rate := 1;
  except
    FSilent := True;
  end;
end;

destructor TSapiTTSEngine.Destroy;
begin
  if not FSilent and not VarIsEmpty(FSpeechObj) then
  begin
    try
      FSpeechObj.Speak(' ', SVSFlagsAsync or SVSFPurgeBeforeSpeak);
    except
    end;
  end;
  FLock.Free;
  inherited;
end;

procedure TSapiTTSEngine.Speak(const AText: string; AOnDone: TProc);
var
  LText: string;
  LGen: Integer;
begin
  if FSilent or VarIsEmpty(FSpeechObj) or AText.IsEmpty then
    Exit;
  LText := CleanTTSText(AText);
  if LText.IsEmpty then
    Exit;
  FLock.Enter;
  try
    try
      FSpeechObj.Speak(' ', SVSFlagsAsync or SVSFPurgeBeforeSpeak);
    except
    end;
    Inc(FGeneration);
    LGen := FGeneration;
    FIsSpeaking := True;
  finally
    FLock.Leave;
  end;
  TThread.CreateAnonymousThread(
    procedure
    var
      LIsValid: Boolean;
    begin
      CoInitialize(nil);
      try
        try
          FSpeechObj.Speak(LText, SVSFDefault);
        except
        end;
        FLock.Enter;
        try
          LIsValid := FGeneration = LGen;
          if LIsValid then
            FIsSpeaking := False;
        finally
          FLock.Leave;
        end;
        if LIsValid and Assigned(AOnDone) then
          TThread.Synchronize(nil, TThreadProcedure(AOnDone));
      finally
        CoUninitialize;
      end;
    end).Start;
end;

procedure TSapiTTSEngine.Stop;
begin
  if FSilent or VarIsEmpty(FSpeechObj) then
    Exit;
  FLock.Enter;
  try
    try
      FSpeechObj.Speak(' ', SVSFlagsAsync or SVSFPurgeBeforeSpeak);
    except
    end;
    Inc(FGeneration);
    FIsSpeaking := False;
  finally
    FLock.Leave;
  end;
end;

function TSapiTTSEngine.IsSpeaking: Boolean;
begin
  FLock.Enter;
  Result := FIsSpeaking;
  FLock.Leave;
end;

end.

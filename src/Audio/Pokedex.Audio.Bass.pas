unit Pokedex.Audio.Bass;

interface

uses
  Winapi.Windows;

const
  BASS_DLL = 'bass.dll';
  BASS_UNICODE = $80000000;

function BASS_Init(device: LongInt; freq, flags: LongWord; win: HWND;
  clsid: Pointer): LongBool; stdcall; external BASS_DLL;

function BASS_StreamCreateFile(mem: LongBool; f: Pointer; offset, length: Int64;
  flags: LongWord): LongWord; stdcall; external BASS_DLL;

function BASS_ChannelPlay(handle: LongWord; restart: LongBool): LongBool;
  stdcall; external BASS_DLL;

function BASS_Free: LongBool; stdcall; external BASS_DLL;

function BASS_ChannelStop(handle: LongWord): LongBool; stdcall;
  external BASS_DLL;

function BASS_StreamFree(handle: LongWord): LongBool; stdcall;
  external BASS_DLL;

implementation

end.

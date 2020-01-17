unit udebug;

interface

uses windows,sysutils;

const
  SYMOPT_CASE_INSENSITIVE  = $00000001;
  {$EXTERNALSYM SYMOPT_CASE_INSENSITIVE}
  SYMOPT_UNDNAME           = $00000002;
  {$EXTERNALSYM SYMOPT_UNDNAME}
  SYMOPT_DEFERRED_LOADS    = $00000004;
  {$EXTERNALSYM SYMOPT_DEFERRED_LOADS}
  SYMOPT_NO_CPP            = $00000008;
  {$EXTERNALSYM SYMOPT_NO_CPP}
  SYMOPT_LOAD_LINES        = $00000010;
  {$EXTERNALSYM SYMOPT_LOAD_LINES}
  SYMOPT_OMAP_FIND_NEAREST = $00000020;
  {$EXTERNALSYM SYMOPT_OMAP_FIND_NEAREST}
  SYMOPT_LOAD_ANYTHING         = $00000040;
  {$EXTERNALSYM SYMOPT_LOAD_ANYTHING}
  SYMOPT_IGNORE_CVREC          = $00000080;
  {$EXTERNALSYM SYMOPT_IGNORE_CVREC}
  SYMOPT_NO_UNQUALIFIED_LOADS  = $00000100;
  {$EXTERNALSYM SYMOPT_NO_UNQUALIFIED_LOADS}
  SYMOPT_FAIL_CRITICAL_ERRORS  = $00000200;
  {$EXTERNALSYM SYMOPT_FAIL_CRITICAL_ERRORS}
  SYMOPT_EXACT_SYMBOLS         = $00000400;
  {$EXTERNALSYM SYMOPT_EXACT_SYMBOLS}
  SYMOPT_ALLOW_ABSOLUTE_SYMBOLS = $00000800;
  {$EXTERNALSYM SYMOPT_ALLOW_ABSOLUTE_SYMBOLS}
  SYMOPT_IGNORE_NT_SYMPATH      = $00001000;
  {$EXTERNALSYM SYMOPT_IGNORE_NT_SYMPATH}
  SYMOPT_INCLUDE_32BIT_MODULES = $00002000;
  {$EXTERNALSYM SYMOPT_INCLUDE_32BIT_MODULES}
  SYMOPT_PUBLICS_ONLY          = $00004000;
  {$EXTERNALSYM SYMOPT_PUBLICS_ONLY}
  SYMOPT_NO_PUBLICS            = $00008000;
  {$EXTERNALSYM SYMOPT_NO_PUBLICS}
  SYMOPT_AUTO_PUBLICS          = $00010000;
  {$EXTERNALSYM SYMOPT_AUTO_PUBLICS}
  SYMOPT_NO_IMAGE_SEARCH       = $00020000;
  {$EXTERNALSYM SYMOPT_NO_IMAGE_SEARCH}
  SYMOPT_SECURE                = $00040000;
  {$EXTERNALSYM SYMOPT_SECURE}

  SYMOPT_DEBUG             = DWORD($80000000);
  {$EXTERNALSYM SYMOPT_DEBUG}

const
  //DbgHelpDll   = 'C:\windows\system32\dbghelp.dll';
  DbgHelpDll   = 'dbghelp.dll';
  SYMFLAG_FUNCTION = $00000800 or $200; // fonction ou export table

type
  _MODLOAD_DATA = record
    ssize: DWORD;                  // size of this struct
    ssig: DWORD;                   // signature identifying the passed data
    data: POINTER;                   // pointer to passed data
    size: DWORD;                   // size of passed data
    flags: DWORD;                  // options
  end;
  {$EXTERNALSYM _MODLOAD_DATA}
  MODLOAD_DATA = _MODLOAD_DATA;
  {$EXTERNALSYM MODLOAD_DATA}
  PMODLOAD_DATA = ^MODLOAD_DATA;
  {$EXTERNALSYM PMODLOAD_DATA}
  TModLoadData = MODLOAD_DATA;
  PModLoadData = PMODLOAD_DATA;

type
  TSYMBOL_INFO = record
    SizeOfStruct: DWORD; // 10 DWORD 5 uint64 256 AnsiChar => 336
    TypeIndex: DWORD;
    Reserved_1, Reserved_2: uint64;
    Index: DWORD;
    Size: DWORD;
    ModBase: int64;
    Flags: DWORD; // SYMFLAG_FUNCTION
    Value: Int64;
    Address: int64;
    Registre: DWORD;
    Scope: DWORD;
    Tag: DWORD;
    NameLen: DWORD;
    MaxNameLen: DWORD; //256
    Name: array[0..255] of Char;   // AnsiChar
  end;
  SYMBOL_INFO=TSYMBOL_INFO ;

function SymLoadModuleEx(hProcess, hFile: THANDLE; ImageName, ModuleName: PAnsiChar; BaseOfDll: INT64;
  DllSize: DWORD; Data: PMODLOAD_DATA; Flag: DWORD): INT64; stdcall; external DbgHelpDll;

function SymInitialize(aHandle: HMODULE; aUserSearchPath: PChar;
  aInvadeProcess: Boolean): Boolean; stdcall; external DbgHelpDll
{$IFDEF UNICODE}
  name 'SymInitializeW'
{$ELSE}
  name 'SymInitialize'
{$ENDIF};

function SymSetOptions(SymOptions: DWORD): DWORD; stdcall;external DbgHelpDll;

function SymFromName(hProcess: THANDLE; Name: pchar; Symbol: pointer): BOOL; stdcall;external DbgHelpDll;

function SymFromAddr(aHandle: HMODULE;
  aAdress: int64;
  aDisplacement: DWORD;
  aSymbolInfo: Pointer): Boolean; stdcall; external DbgHelpDll
{$IFDEF UNICODE}
  name 'SymFromAddrW'
{$ELSE}
  name 'SymFromAddr'
{$ENDIF};

function SymCleanup(aHandle: HMODULE): Boolean; stdcall; external DbgHelpDll;

function _SymFromName(dllname,symbol:string;var address:int64):boolean;
function _SymFromAddr(dllname:string;address:int64;var name:string):boolean;

implementation

function _SymFromAddr(dllname:string;address:int64;var name:string):boolean;
var
  Hprocess: HMODULE;
  i            : cardinal;
  Deplacement  : dword;
  SymbolInfo   : udebug.SYMBOL_INFO; //TSYMBOL_INFO;
  //Result       : string;
  symbase:int64; //dword64
begin
result:=false;
  Hprocess := getcurrentprocess;
     //une fonction quelconque,l'adresse peut être supérieur jusqu'à la prochaine fonction


  SymSetOptions(SYMOPT_UNDNAME or SYMOPT_DEBUG or SYMOPT_DEFERRED_LOADS or SYMOPT_PUBLICS_ONLY);
  //SymSetOptions(SYMOPT_UNDNAME or SYMOPT_DEBUG or SYMOPT_DEFERRED_LOADS);

  SetEnvironmentVariable('_NT_SYMBOL_PATH', 'SRV*C:\\WINDOWS\\TEMP*http://msdl.microsoft.com/download/symbols');
//
if not SymInitialize(hProcess, nil, TRUE) then
	begin
		raise exception.create('Error with SymInitialize : '+inttostr( GetLastError()));
		//CloseHandle(hProcess);
		exit;
	end;
//
SymBase:=SymLoadModuleEx(hProcess, 0, pchar(dllname), nil, 0 , 0, nil, 0);
if (SymBase=0) or (GetLastError()<>ERROR_SUCCESS) then
	begin
		raise exception.create('Error with SymLoadModuleEx : '+inttostr(GetLastError()));
		SymCleanup(GetCurrentProcess());
		//CloseHandle(hProcess);
		exit;
	end;
//
  i := SizeOf(udebug.SYMBOL_INFO);
  zeromemory(@SymbolInfo, i);
  SymbolInfo.MaxNameLen := 256;
  SymbolInfo.SizeOfStruct :=  I - Length(SymbolInfo.Name) * SizeOf(SymbolInfo.Name[0]); // 88
  Deplacement := 0;
  if udebug.SymFromAddr(Hprocess, address, Deplacement, @SymbolInfo) then
    // mettre le handle du processus
  begin
    {
    if (SymbolInfo.Flags and SYMFLAG_FUNCTION) = 0 then
    begin
      raise exception.create('le symbole retourné n''est pas une fonction');
      Exit;
    end;
    }
    {SetLength(Result, SymbolInfo.NameLen);
    for i := 0 to SymbolInfo.NameLen do} name := SymbolInfo.Name;
    result:=false;
  end
  else begin
    i := GetLastError;
    raise exception.create('infos pas retournées ; erreur ' + IntToStr(i));
  end;
  if not SymCleanup(Hprocess) then
    raise exception.create('symboles pas nettoyés');

end;

function _SymFromName(dllname,symbol:string;var address:int64):boolean;
var
hprocess:thandle;
symbase:int64; //dword64
//dllname:string;
i            : cardinal;
Deplacement  : dword;
SymbolInfo   : udebug.SYMBOL_INFO;
begin
result:=false;
hprocess:=getcurrentprocess;

//SymSetOptions(SYMOPT_UNDNAME or SYMOPT_DEBUG or SYMOPT_DEFERRED_LOADS or SYMOPT_PUBLICS_ONLY);
SymSetOptions(SYMOPT_UNDNAME or SYMOPT_DEBUG or SYMOPT_DEFERRED_LOADS );

SetEnvironmentVariable('_NT_SYMBOL_PATH', 'SRV*C:\\WINDOWS\\TEMP*http://msdl.microsoft.com/download/symbols');
//
if not SymInitialize(hProcess, nil, TRUE) then
	begin
		raise exception.create('Error with SymInitialize : '+inttostr( GetLastError()));
		//CloseHandle(hProcess);
		exit;
	end;
//
SymBase:=udebug.SymLoadModuleEx(hProcess, 0, pchar(dllname), nil, 0 , 0, nil, 0);
if (SymBase=0) or (GetLastError()<>ERROR_SUCCESS) then
	begin
		raise exception.create('Error with SymLoadModuleEx : '+inttostr(GetLastError()));
		SymCleanup(GetCurrentProcess());
		//CloseHandle(hProcess);
		exit;
	end;
//
i := SizeOf(udebug.SYMBOL_INFO);
  zeromemory(@SymbolInfo, i);
  SymbolInfo.MaxNameLen := 256;
  SymbolInfo.SizeOfStruct :=  I - Length(SymbolInfo.Name) * SizeOf(SymbolInfo.Name[0]); // 88
  Deplacement := 0;
//
//case sensitive...
//if not udebug.SymFromName(hProcess, 'AddAtomA', @SymbolInfo) then
if not SymFromName(hProcess, pchar(symbol), @SymbolInfo) then
//if not udebug.SymFromName(hProcess, 'SpInitialize', @SymbolInfo) then
//if not udebug.SymFromName(hProcess, 'g_fParameter_UseLogonCredential', @SymbolInfo) then
	begin
		raise exception.create('Error with SymFromName : ' + inttostr(getLastError()));

		//CloseHandle(hProcess);
		//HeapFree(GetProcessHeap(), 0, Symbol);
		SymCleanup(GetCurrentProcess());
		exit;
	end;

//showmessage(inttohex(SymbolInfo.Address,sizeof(int64) ));
address :=SymbolInfo.Address ;
result:=true;

SymCleanup(GetCurrentProcess());

end;

end.
 

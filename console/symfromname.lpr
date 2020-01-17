program symfromname;

uses windows,sysutils,udebug in '..\udebug.pas';

function _symfromname(dllname,symbol:string):boolean;
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

if not SymInitialize(hProcess, nil, TRUE) then

	begin
		raise exception.create('Error with SymInitialize : '+inttostr( GetLastError()));
		//CloseHandle(hProcess);
		exit;
	end;

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
//if not udebug.SymFromName(hProcess, 'SpAcceptCredentials', @SymbolInfo) then
//if not udebug.SymFromName(hProcess, 'SpInitialize', @SymbolInfo) then
//if not udebug.SymFromName(hProcess, 'g_fParameter_UseLogonCredential', @SymbolInfo) then
if not udebug.SymFromName(hProcess, pchar(symbol), @SymbolInfo) then
	begin
		raise exception.create('Error with SymFromName : ' + inttostr(getLastError()));

		//CloseHandle(hProcess);
		//HeapFree(GetProcessHeap(), 0, Symbol);
		SymCleanup(GetCurrentProcess());
		exit;
	end;

writeln(inttohex(SymbolInfo.Address,sizeof(int64) ));

SymCleanup(GetCurrentProcess());
result:=true;

end;


begin

  try
  _symfromname('c:\windows\system32\wdigest.dll','SpAcceptCredentials');

  except
    on e:exception do writeln(e.message);
  end;

end.


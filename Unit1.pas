unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,{JwaImageHlp,}udebug;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Hmod, Hprocessus: HMODULE;
  P            : Pointer;
  i            : cardinal;
  Deplacement  : dword;
  SymbolInfo   : udebug.SYMBOL_INFO; //TSYMBOL_INFO;
  Result       : string;
begin
  Hprocessus := getcurrentprocess;
  Hmod := LoadLibrary('kernel32.dll'); //une dll quelconque
  if Hmod = 0 then
  begin
    ShowMessage('librairie pas chargée');
    FreeLibrary(Hmod);
    Exit;
  end;
  //P := nil;
  P := GetProcAddress(Hmod, 'AddAtomA');
    //une fonction quelconque,l'adresse peut être supérieur jusqu'à la prochaine fonction
 
  if not Assigned(P) then
  begin
    ShowMessage('fonction pas chargée');
    FreeLibrary(Hmod);
    Exit;
  end;

  SymSetOptions(SYMOPT_UNDNAME or SYMOPT_DEBUG or SYMOPT_DEFERRED_LOADS or SYMOPT_PUBLICS_ONLY);

  SetEnvironmentVariable('_NT_SYMBOL_PATH', 'SRV*C:\\WINDOWS\\TEMP*http://msdl.microsoft.com/download/symbols');

  if not SymInitialize(Hprocessus, nil, true) then
  begin
    ShowMessage('symboles pas initialisés');
    FreeLibrary(Hmod);
    Exit;
  end;
  i := SizeOf(udebug.SYMBOL_INFO);
  zeromemory(@SymbolInfo, i);
  SymbolInfo.MaxNameLen := 256;
  SymbolInfo.SizeOfStruct :=  I - Length(SymbolInfo.Name) * SizeOf(SymbolInfo.Name[0]); // 88
  Deplacement := 0;
  if udebug.SymFromAddr(Hprocessus, int64(p), Deplacement, @SymbolInfo) then
    // mettre le handle du processus
  begin
    if (SymbolInfo.Flags and SYMFLAG_FUNCTION) = 0 then
    begin
      ShowMessage('le symbole retourné n''est pas une fonction');
      FreeLibrary(Hmod);
      Exit;
    end;
    {SetLength(Result, SymbolInfo.NameLen);
    for i := 0 to SymbolInfo.NameLen do} Result := SymbolInfo.Name;
    ShowMessage(Result);
  end
  else begin
    i := GetLastError;
    ShowMessage('infos pas retournées ; erreur ' + IntToStr(i));
  end;
  if not SymCleanup(Hprocessus) then
    ShowMessage('symboles pas nettoyés');
  FreeLibrary(Hmod);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
hprocess:thandle;
symbase:int64; //dword64
dllname:string;
i            : cardinal;
Deplacement  : dword;
SymbolInfo   : udebug.SYMBOL_INFO;
begin
hprocess:=getcurrentprocess;

//SymSetOptions(SYMOPT_UNDNAME or SYMOPT_DEBUG or SYMOPT_DEFERRED_LOADS or SYMOPT_PUBLICS_ONLY);
SymSetOptions(SYMOPT_UNDNAME or SYMOPT_DEBUG or SYMOPT_DEFERRED_LOADS );

SetEnvironmentVariable('_NT_SYMBOL_PATH', 'SRV*C:\\WINDOWS\\TEMP*http://msdl.microsoft.com/download/symbols');

if not SymInitialize(hProcess, nil, TRUE) then

	begin
		showmessage('Error with SymInitialize : '+inttostr( GetLastError()));
		//CloseHandle(hProcess);
		exit;
	end;

//dllname:='kernel32.dll';
dllname:='wdigest.dll';
SymBase:=udebug.SymLoadModuleEx(hProcess, 0, pchar(dllname), nil, 0 , 0, nil, 0);
if (SymBase=0) or (GetLastError()<>ERROR_SUCCESS) then
	begin
		showmessage('Error with SymLoadModuleEx : '+inttostr(GetLastError()));

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
if not udebug.SymFromName(hProcess, 'SpAcceptCredentials', @SymbolInfo) then
//if not udebug.SymFromName(hProcess, 'SpInitialize', @SymbolInfo) then
//if not udebug.SymFromName(hProcess, 'g_fParameter_UseLogonCredential', @SymbolInfo) then
	begin
		showmessage('Error with SymFromName : ' + inttostr(getLastError()));

		//CloseHandle(hProcess);
		//HeapFree(GetProcessHeap(), 0, Symbol);
		SymCleanup(GetCurrentProcess());
		exit;
	end;

showmessage(inttohex(SymbolInfo.Address,sizeof(int64) ));

SymCleanup(GetCurrentProcess());

end;

end.
 
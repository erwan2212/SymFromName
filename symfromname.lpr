program symfromname;

uses windows,sysutils,udebug;

var
address,hmod:int64;
//Header: PIMAGE_NT_HEADERS;
name:string;

begin

  try

    if paramcount<>2 then exit;
    writeln('dllname:'+paramstr(1));
    writeln('symbol:'+paramstr(2));
    //
    hmod:=0;
    hmod:=LoadLibrary (pchar(paramstr(1)));
    //writeln(inttohex(hmod,sizeof(hmod)));
    //
    //g_fParameter_UseLogonCredential
    //if udebug._symfromname('c:\windows\system32\wdigest.dll','SpAcceptCredentials',address)
    if udebug._symfromname(paramstr(1),paramstr(2),address)
     then
     begin
       writeln('Relative Address:'+inttohex(address,sizeof(address)));
       if hmod>0 then writeln('Virtual Address:'+inttohex(hmod+address,sizeof(address)));
     end
     else writeln('failed');

    {
    if udebug._SymFromAddr (paramstr(1),address,name)
       then writeln(name)
       else writeln('failed');
    }

  except
    on e:exception do writeln(e.message);
  end;

end.


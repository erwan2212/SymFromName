program symfromname;

uses windows,sysutils,udebug;

{$define _WIN64}

var
hmod:handle;
address:nativeuint;
//Header: PIMAGE_NT_HEADERS;
name:string;
//
pbase:pointer;
pDOSHeader: PIMAGEDOSHEADER;
pNTHeader: PIMAGE_NT_HEADERS64; //PIMAGENTHEADERS;
//
buffer:array [0..15] of byte;
read:ptruint;
i:byte;

function makeptr(a:pointer;b:nativeuint):pointer;
begin
  result:=pointer(nativeuint(a)+b);
end;

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
    if _symfromname(paramstr(1),paramstr(2),address)
     then
     begin
       writeln('Relative Address:'+inttohex(address,sizeof(address)));

       if hmod>0 then
          begin
          writeln('Virtual Address:'+inttohex(hmod+address,sizeof(address)));

          {//signature, in memory, which you can get in hex view in IDA
          pbase:=pointer(hmod+address);
          if ReadProcessMemory (getcurrentprocess,pbase,@buffer[0],16,read) then
               for i:=0 to 15 do write(inttohex(buffer[i],1));
          }
          {//use cff explorer to check dos header / nt header->optional headers
          pBase := Pointer(hmod);
          if pBase = nil then exit;
          pDOSHeader  := PIMAGEDOSHEADER(MakePtr(pBase, 0));
          pNTHeader  := PIMAGE_NT_HEADERS64(MakePtr(pDOSHeader, pDOSHeader^._lfanew));
          writeln(inttohex(pNTHeader^.OptionalHeader.ImageBase,sizeof(pNTHeader^.OptionalHeader.ImageBase))) ;
          }
          end;
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


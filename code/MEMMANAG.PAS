unit MemManag; {�������� �����, ����訢��� 8 �� � �� ����᪨ ��।����}
               {�� getmem, �� freemem ������ �� �����������}
interface

procedure GetMemD(var p:pointer;size:dword);
procedure FreeMemD(p:pointer;size:dword);

implementation

function getfreeDPMImem:longint;assembler; {᪮�쪮 ����� ᢮����� � ��⥬�}
asm
   push es
   push ss
   pop es
   sub esp,30h
   mov edi,esp
   mov ax,500h
   int 31h
   mov eax,[esp]
   add esp,30h
   pop es
end;

function getDPMImem(size:longint;var handle:longint):pointer;assembler;
asm                              {�����騩 GetMem}
   mov ax,501h
   mov bx,word ptr size+2
   mov cx,word ptr size
   int 31h
   mov eax,0
   jc @@err
   mov eax,[handle]
   mov [eax],di
   mov [eax+2],si
   mov ax,bx
   shl eax,16
   mov ax,cx
 @@err:
end;

function freeDPMImem(handle:longint):boolean;assembler;
asm                              {�����騩 FreeMem}
   mov ax,502h
   mov si,word ptr handle+2
   mov di,word ptr handle
   int 31h
   mov eax,0
   jc @@err
   inc eax
 @@err:
end;

const
   MaxMemory = 8*1024*1024; {��।���� �� 8 �� �����}
   MemAllocated : dword = 0; {㦥 ��।������� ������}
   MemDisposed  : dword = 0; {᪮�쪮 ����� ��ᨫ� �᢮������}
   NumGetmem    : word  = 0; {᪮�쪮 ࠧ ���頫��� � getmem}
   NumFreemem   : word  = 0; {᪮�쪮 ࠧ ���頫��� � freemem}

var
   FirstMemory : longint;  {᪮�쪮 ����� �뫮 �� ��砫� ࠡ���}
   buf      : pointer;     {���� ���� ��砫� ��।������� �����}
   bufhandl : longint;     {奭�� ��।�������� ��᪠ �����}
   fsize    : longint;     {ࠧ��� ����}
   ExitSave:Pointer;       {���� ��ன �ணࠬ�� ��室� � DOS }
   bufAddr  : dword absolute buf; {��� ���᫥��� ���� �� ���� � ᬥ饭��}

procedure GetMemD(var p:pointer;size:dword);
begin
{   write('GetMemD: size: ',size:7,', total: ',MemAllocated:7);}
   p := ptr(bufAddr + MemAllocated);
   MemAllocated := (MemAllocated + size + 3) and $FFFFFFFC; {� ��ࠢ��������}
   inc(NumGetMem);
   if MemAllocated > MaxMemory then begin
      writeln('Allocated memory exceed ',MaxMemory div 1024,' Kb');
      halt;
   end;
{   writeln(', called: ',NumGetmem:5);}
end;

procedure FreeMemD(p:pointer;size:dword);
begin
{   write('FreeMemD: size: ',size:7,', total: ',MemDisposed:7,'/',MemAllocated-MemDisposed:7);}
   MemDisposed := (MemDisposed + size + 3) and $FFFFFFFC; {� ��ࠢ��������}
   inc(NumFreeMem);
{   writeln(', called: ',NumFreemem:5,' ',NumGetmem-NumFreemem:5);}
end;

procedure MyExit;  { �������⥫쭠� ��楤�� �� ��室� � DOS }
begin
   writeln('���樠������ ����� MemManag');
   ExitProc:=ExitSave;
   freeDPMImem(bufhandl);
   writeln('   MemManager * �뫮 ����襭�:         ',MemAllocated div 1024 :6,' Kb');
   writeln('   MemManager * �뫮 �����饭�:        ',MemDisposed div 1024 :6,' Kb');
   writeln('   MemManager * �뫮 ���饭�� GetMem$:  ',NumGetmem:5);
   writeln('   MemManager * �뫮 ���饭�� FreeMem$: ',NumFreemem:5);
   writeln('   MemManager * �⠫� � ��⥬�:        ',GetFreeDPMIMem div 1024 :6,' Kb');
end;

begin  { ���� ���樠����樨 }
   writeln('���樠������ MemManag (��砫�)');
   ExitSave:=ExitProc;  {��८�।������ ��楤��� ��室�}
   ExitProc:=@MyExit;
   FirstMemory := GetFreeDPMIMem;
   if FirstMemory < MaxMemory then begin
      writeln('* * * * * * * * * * * * * * * *');
      writeln('*  �������筮 �����: ',FirstMemory div 1024,'kb');
      writeln('* * * * * * * * * * * * * * * *');
      halt;
   end;
   writeln('MemMamager : �뫮 ',FirstMemory div 1024,' Kb');
   fsize := MaxMemory;
   buf:=getDPMImem(fsize,bufhandl);
   if buf=NIL then begin
      writeln('H������筮 �����.');
      halt;
   end;
   writeln('���� ����: ',bufAddr,' (',dword(addr(bufAddr)),')');
   writeln('���樠������ MemManag (�����)');
end.

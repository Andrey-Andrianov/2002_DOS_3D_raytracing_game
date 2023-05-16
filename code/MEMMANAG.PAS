unit MemManag; {менеджер памяти, запрашивает 8 Мб и ее статически распределяет}
               {по getmem, при freemem память НЕ ОСВОБОЖДАЕТ}
interface

procedure GetMemD(var p:pointer;size:dword);
procedure FreeMemD(p:pointer;size:dword);

implementation

function getfreeDPMImem:longint;assembler; {сколько памяти свободно в системе}
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
asm                              {настоящий GetMem}
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
asm                              {настоящий FreeMem}
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
   MaxMemory = 8*1024*1024; {распределяет до 8 Мб памяти}
   MemAllocated : dword = 0; {уже распределенная память}
   MemDisposed  : dword = 0; {сколько памяти просили освободить}
   NumGetmem    : word  = 0; {сколько раз обращались к getmem}
   NumFreemem   : word  = 0; {сколько раз обращались к freemem}

var
   FirstMemory : longint;  {сколько памяти было до начала работы}
   buf      : pointer;     {адрес буфера начала распределенной памяти}
   bufhandl : longint;     {хендл распределенного куска памяти}
   fsize    : longint;     {размер буфера}
   ExitSave:Pointer;       {адрес старой программы выхода в DOS }
   bufAddr  : dword absolute buf; {для вычисления адреса из базы и смещения}

procedure GetMemD(var p:pointer;size:dword);
begin
{   write('GetMemD: size: ',size:7,', total: ',MemAllocated:7);}
   p := ptr(bufAddr + MemAllocated);
   MemAllocated := (MemAllocated + size + 3) and $FFFFFFFC; {с выравниванием}
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
   MemDisposed := (MemDisposed + size + 3) and $FFFFFFFC; {с выравниванием}
   inc(NumFreeMem);
{   writeln(', called: ',NumFreemem:5,' ',NumGetmem-NumFreemem:5);}
end;

procedure MyExit;  { дополнительная процедура при выходе в DOS }
begin
   writeln('Деициализация модуля MemManag');
   ExitProc:=ExitSave;
   freeDPMImem(bufhandl);
   writeln('   MemManager * было запрошено:         ',MemAllocated div 1024 :6,' Kb');
   writeln('   MemManager * было возвращено:        ',MemDisposed div 1024 :6,' Kb');
   writeln('   MemManager * было обращений GetMem$:  ',NumGetmem:5);
   writeln('   MemManager * было обращений FreeMem$: ',NumFreemem:5);
   writeln('   MemManager * стало в системе:        ',GetFreeDPMIMem div 1024 :6,' Kb');
end;

begin  { блок инициализации }
   writeln('Инициализация MemManag (начало)');
   ExitSave:=ExitProc;  {переопределение процедуры выхода}
   ExitProc:=@MyExit;
   FirstMemory := GetFreeDPMIMem;
   if FirstMemory < MaxMemory then begin
      writeln('* * * * * * * * * * * * * * * *');
      writeln('*  Недостаточно памяти: ',FirstMemory div 1024,'kb');
      writeln('* * * * * * * * * * * * * * * *');
      halt;
   end;
   writeln('MemMamager : было ',FirstMemory div 1024,' Kb');
   fsize := MaxMemory;
   buf:=getDPMImem(fsize,bufhandl);
   if buf=NIL then begin
      writeln('Hедостаточно памяти.');
      halt;
   end;
   writeln('Адрес буфера: ',bufAddr,' (',dword(addr(bufAddr)),')');
   writeln('Инициализация MemManag (конец)');
end.

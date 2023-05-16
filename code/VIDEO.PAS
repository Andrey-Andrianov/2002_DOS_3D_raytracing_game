unit video;
interface
type
  scrtype = array[0..399,0..639]of byte;

var
  np  : ^scrtype;

{procedure setcolor( c, r, g, b : byte );}
{procedure bmpp2(files:string);}
procedure setvesamode(mode:word);
procedure setvesabank(bank,window:word);
procedure closevesamode;
procedure putpixel(x,y,color : word);
procedure GraphCls;
procedure movebyffer;

implementation

uses crt;

const
  lenlineb : word = 640;
  activbank : byte = 0;

var
  i,j : word;

procedure setcolor( c, r, g, b : byte );
begin
  port[$3c8] := c;
  port[$3c9] := r;
  port[$3c9] := g;
  port[$3c9] := b;
end;

procedure setpal;
var
  x : integer;
begin
  for x := 1 to 32 do
    begin
      setcolor(x,   x*2-1, 0,     0    );
      setcolor(x+32, 63,   x*2-1, 0    );
      setcolor(x+64, 63,   63,    x*2-1);
      setcolor(x+96, 63,   63,    63   );
    end;
    port[$60] := 0;
end;

procedure bmpp2(files : string);
type
  bitmapfileneader = record
    ch1 : char;
    ch2 : char;
    dword : longint;
    ch3 : word;
    ch4 : word;
    dword2 : longint;
  end;
  bitmapinfoheader = record
    dword : longint;
    long1 : longint;
    long2 : longint;
    word1 : word;
    word2 : word;
    word3 : longint;
    dword2 : longint;
    long3 : longint;
    long4 : longint;
    dword3 : longint;
    dword4 : longint;
  end;
  rgbquad = record
    byte1 : byte;
    byte2 : byte;
    byte3 : byte;
    byte4 : byte;
  end;
var
  c : bitmapfileneader;
  c1: bitmapinfoheader;
  i,j : integer;
  aaa : array [0..255] of rgbquad;
  f : file;
  p : array[0..767]of byte;
begin
  assign(f,{'aaa001p.bmp'}{'cat.bmp'}files);
  reset(f,1);
  blockread(f,c,sizeof(c));
  blockread(f,c1,sizeof(c1));
  blockread(f,aaa,sizeof(aaa));
  for i := 0 to 255 do begin
    aaa[i].byte1 := aaa[i].byte1 div 4;
    aaa[i].byte2 := aaa[i].byte2 div 4;
    aaa[i].byte3 := aaa[i].byte3 div 4;
  end;
  for j := 0 to 255 do
    setcolor(j,aaa[j].byte3,aaa[j].byte2,aaa[j].byte1);
  fillchar(np^,sizeof(np^),0);
  for j := c1.long2-1 downto 0 do
    blockread(f,np^[j],c1.long1);
  close(f);
end;



procedure setvesamode(mode:word);
begin
  asm
    mov ax , $4F02
    mov bx , mode
    int $10
  end;
end;

procedure setvesabank(bank,window:word);
begin
  asm
    mov ax , $4F05
    mov bx , window
    mov dx , bank
    int $10
  end;
  activbank := bank;
end;

procedure closevesamode;
begin
  asm
    mov ax , $0003
    int $10
  end;
end;

procedure putpixel(x,y,color : word);
var
  bank,offs : word;
begin
  asm
    xor bx , bx
    mov ax , y
    mul lenlineb
    add ax , x
    adc dx , bx
    mov bank , dx
    mov offs , ax
  end;
  if activbank <> bank then begin
    setvesabank(bank,0);
    activbank := bank;
  end;
  mem[$A000:offs] := lo(color);
end;

{procedure fon;
{begin
{  for i := 0 to 7 do begin
{    setvesabank(i,0);
{    fillchar(mem[$a000:0],60000,i + 1);
{    fillchar(mem[$a000:60000],5536,i + 1);
{  end;
{  for i := 0 to 599 do begin
{    putpixel(i,i,128);
{    putpixel(799 - i,i,128);
{  end;
{end;}

procedure GraphCls;
var
  i : integer;
begin
  for i := 0 to {4}2 do begin
    setvesabank(i,0);
    fillchar(mem[$a000:0],65536,0);
  end;
  setvesabank(3,0);
  fillchar(mem[$a000:0],{65536}59392,0);
end;

{procedure pricel(x,y : integer; c : byte);
{begin
 { for i := 0 to 799 do begin
{    putpixel(i,300,15);
 { end;
{  for i := 0 to 599 do begin
{    putpixel(400,i,15);
{  end;
{end;}

procedure movebyffer;
var
  i : integer;
begin
  for i := 0 to {4}2 do begin
    setvesabank(i,0);
    move(np^[(i*65536) div {800}640,(i*65536) mod {800}640],mem[$a000:0],65536);
  end;
  setvesabank(3,0);
  move(np^[(3*65536) div 640,(3*65536) mod 640],mem[$a000:0],59392);
end;

end.
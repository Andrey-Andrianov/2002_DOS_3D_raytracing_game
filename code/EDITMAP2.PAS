{$M 65520,0,655360}
uses crt;
type
  scrtype = array[0..199,0..319]of byte;
  tectype = array[0..127,0..127] of byte;
  monstr = record
    x : longint;
    y : longint;
    n : integer;
  end;

var
  scr : ^scrtype;
  tectyries : tectype;
  i,j : integer;
  map : array[0..127,0..127] of integer;
  num_key,num_char : byte;
  regim : byte;
  pozx,pozy:byte;
  x,y : integer;
  thing : integer;
  names : array[1..250]of string[13];
  monstrs : array[1..200]of monstr;
  kolmonstrs : longint;
  b : boolean;
  f : text;

procedure setcolor( c, r, g, b : byte );
begin
  port[$3c8] := c;
  port[$3c9] := r;
  port[$3c9] := g;
  port[$3c9] := b;
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
{  fillchar(^,sizeof(np^),0);}
  for j := c1.long2-1 downto 0 do
    blockread(f,tectyries[j],c1.long1);
  close(f);
end;

Procedure WaitKey;
begin
  asm
    mov ax,0
    int 16h
    mov Num_Key,ah
    mov Num_Char,al
  end;
end;

procedure tec(n1,n2:integer);
var
  i,j : integer;
  n : integer;
begin
  asm
    mov ax , $0013
    int $10
  end;
  n := n1;
  repeat
    bmpp2('pich\' + names[n]);
    for j := 0 to 127 do
      move(tectyries[j],scr^[j+10,10],128);
    waitkey;
    case num_key of
      77: if (n < n2) and (names[n+1]<>'-') then inc(n); {вправо}
      75: if (n > n1) and (names[n-1]<>'-') then dec(n); {влево}
    end;
  until num_key = 28;
  thing := n;
end;

procedure tec2;
var
  i,j : integer;
  n : byte;
  s : string;
begin
  asm
    mov ax , $0013
    int $10
  end;
  n := 1;
  repeat
    str(n,s);
    fillchar(scr^,sizeof(scr^),0);
    fillchar(tectyries,sizeof(tectyries),0);
    bmpp2('pich\' + 'ob' + {char(n+byte('0'))}s + '.bmp');
    for j := 0 to 127 do
      move(tectyries[j],scr^[j+10,10],128);
    waitkey;
    case num_key of
      77: if (n < 40) then inc(n); {вправо}
      75: if (n > 1) then dec(n); {влево}
    end;
  until num_key = 28;
  thing := n;
end;

procedure colorbar(x1,y1,x2,y2:integer;col:byte);
var
  i,j : integer;
begin
  for j := y1 to y2 do
    for i := x1 to x2 do
      scr^[j,i] := col;
end;

procedure cursor;
var
  i,j : integer;
begin
  for i := 0 to 2 do begin
    scr^[5+y*3,5+x*3+i] := 15;
    scr^[5+y*3+2,5+x*3+i] := 15;
  end;
  for j := 0 to 2 do begin
    scr^[5+y*3+j,5+x*3] := 15;
    scr^[5+y*3+j,5+x*3+2] := 15;
  end;
end;

procedure reg1;
var
  i,j : integer;
begin
  for i := 0 to 193 do begin
    scr^[4,4+i] := 15;
    scr^[4+193,4+i] := 15;
  end;
  for i := 0 to 193 do begin
    scr^[4+i,4] := 15;
    scr^[4+i,4+193] := 15;
  end;
  for j := 0 to 63 do
    for i := 0 to 63 do
      case map[i+pozx,j+pozy] of
        1      : colorbar(5+i*3,5+j*3,7+(i)*3,7+(j)*3,0);
        3..34  : colorbar(5+i*3,5+j*3,7+(i)*3,7+(j)*3,14);
        35..50 : colorbar(5+i*3,5+j*3,7+(i)*3,7+(j)*3,12);
        51..250: colorbar(5+i*3,5+j*3,7+(i)*3,7+(j)*3,10);
        else     colorbar(5+i*3,5+j*3,7+(i)*3,7+(j)*3,5);
      end;
  for i := 1 to kolmonstrs do
    scr^[6+((monstrs[i].y div 128)-pozy)*3,6+((monstrs[i].x div 128)-pozx)*3] := 12;
end;

procedure reg2;
var
  i,j : integer;
begin
  for i := 0 to 193 do begin
    scr^[4,4+i] := 15;
    scr^[4+193,4+i] := 15;
  end;
  for i := 0 to 193 do begin
    scr^[4+i,4] := 15;
    scr^[4+i,4+193] := 15;
  end;
  for j := 0 to 63 do
    for i := 0 to 63 do
      if map[i+pozx,j+pozy]<=255 then
        colorbar(5+i*3,5+j*3,7+(i)*3,7+(j)*3,map[i+pozx,j+pozy]);
  for i := 1 to kolmonstrs do
    scr^[6+((monstrs[i].y div 128)-pozy)*3,6+((monstrs[i].x div 128)-pozx)*3] := 12;
end;

procedure save;
var
  i,j : integer;
  f : file;
  f2: text;
  s : string;
  map2 : array[0..127,0..127]of integer;
begin
  asm
    mov ax , $0003
    int $10
  end;
  for j := 0 to 127 do
    for i := 0 to 127 do
      map2[j,i] := map[i,j];
  writeln('   Save');
  writeln('Introduce file name');
  readln(s);
  assign(f,'maps\' + s + '.mdt');
  rewrite(f,1);
  blockwrite(f,map2,sizeof(map2));
{  blockwrite(f,kolmonstrs,sizeof(kolmonstrs));
  blockwrite(f,monstrs,sizeof(monstrs));}
  close(f);
  assign(f2,'maps\' + s + '.mzl');
  rewrite(f2);
  writeln(f2,kolmonstrs);
  for i := 1 to kolmonstrs do begin
    writeln(f2,monstrs[i].x);
    writeln(f2,monstrs[i].y);
    writeln(f2,monstrs[i].n);
  end;
  close(f2);
  asm
    mov ax , $0013
    int $10
  end;
  fillchar(scr^,sizeof(scr^),1);
end;

procedure load;
var
  i,j : integer;
  f : file;
  f2: text;
  s : string;
  map2 : array[0..127,0..127]of integer;
begin
  asm
    mov ax , $0003
    int $10
  end;
  writeln('   Load');
  writeln('Introduce file name');
  readln(s);
  assign(f,'maps\' + s + '.mdt');
  reset(f,1);
  blockread(f,map2,sizeof(map2));
{  blockread(f,kolmonstrs,sizeof(kolmonstrs));
  blockread(f,monstrs,sizeof(monstrs));}
  close(f);
  assign(f2,'maps\' + s + '.mzl');
  reset(f2);
  readln(f2,kolmonstrs);
  for i := 1 to kolmonstrs do begin
    readln(f2,monstrs[i].x);
    readln(f2,monstrs[i].y);
    readln(f2,monstrs[i].n);
  end;
  close(f2);
  for j := 0 to 127 do
    for i := 0 to 127 do
      map[j,i] := map2[i,j];
  asm
    mov ax , $0013
    int $10
  end;
  fillchar(scr^,sizeof(scr^),1);
end;

begin
  assign(f,'tectyres.dat');
  reset(f);
  for j := 1 to 250 do
    readln(f,i,names[j]);
  for j := 1 to 250 do begin
    for i := 1 to length(names[j]) do
      names[j,i] := names[j,i+1];
    names[j,0] := char(byte(names[j,0])-1);
  end;
  close(f);
  kolmonstrs := 0;
  regim := 1;
  pozx := 0;
  pozy := 0;
  thing := 51;
  x := 0;
  y:= 0;
  scr := ptr(SegA000,0);
  for j := 0 to 127 do
    for i := 0 to 127 do
      map[i,j] := 1;
  for i := 0 to 127 do begin
    map[i,0] := 51;
    map[i,127] := 51;
  end;
  for i := 0 to 127 do begin
    map[0,i] := 51;
    map[127,i] := 51;
  end;
  asm
    mov ax , $0013
    int $10
  end;
  fillchar(scr^,sizeof(scr^),1);
  repeat
    case regim of
      1: reg1;
      2: reg2;
      4: reg1;
      5: reg1;
    end;
    cursor;
    waitkey;
    case num_key of
      1 : regim := 0;
      60: save;                      {F2}
      61: load;                      {F3}
      83: if pozx > 0 then dec(pozx);{Delete}
      81: if pozx < 64 then inc(pozx);{Page Down}
      71: if pozy > 0 then dec(pozy);{Home}
      79: if pozy < 64 then inc(pozy);{End}
      72: if y > 0 then dec(y); {вверх}
      80: if y < 63 then inc(y); {вниз}
      77: if x < 63 then inc(x); {вправо}
      75: if x > 0 then dec(x); {влево}
      28: begin                 {Enter}
            case regim of
              1..2: map[x+pozx,y+pozy] := thing;
              4   : begin
                      inc(kolmonstrs);
                      monstrs[kolmonstrs].n := thing;
                      monstrs[kolmonstrs].x := (x+pozx)*128+64;
                      monstrs[kolmonstrs].y := (y+pozy)*128+64;
                    end;
              5   : begin
                     b := false;
                     for i := 1 to kolmonstrs do
                       if (monstrs[i].x = (x+pozx)*128+64) and (monstrs[i].y = (y+pozy)*128+64) then begin
                         b := true;
                         for j := i to kolmonstrs do
                           monstrs[j] := monstrs[j+1];
                         break;
                       end;
                       if b then
                         dec(kolmonstrs);
                    end;
            end;
          end;
      2 : begin                 {1}
            regim := 1;
          end;
      3 : begin                 {2}
            regim := 2;
          end;
      11: begin                 {0}
            i := regim;
            regim := 3;
            asm
              mov ax , $0003
              int $10
            end;
{            writeln('Что ставить?');
            writeln('  1 - полы');
            writeln('  2 - двери');
            writeln('  3 - рубильники');
            writeln('  4 - стены');
            writeln('  5 - обьекты');
            writeln('  6 - уничтожить обьект');
            writeln('  Esc - назад');}
            writeln('What set?');
            writeln('  1 - floors');
            writeln('  2 - doors');
            writeln('  3 - knife-switch');
            writeln('  4 - walls');
            writeln('  5 - objects');
            writeln('  6 - delete objects');
            writeln('  Esc - back');
            repeat
              waitkey;
              case num_key of
                1 : begin    {Esc}
                      regim := i;
                    end;
                2 : begin    {1}
{                      thing := 1;}
                      tec(1,1);
                      regim := i;
                    end;
                3 : begin    {2}
{                      thing := 3;}
                      tec(3,34);
                      regim := i;
                    end;
                4 : begin    {3}
{                      thing := 35;}
                      tec(35,50);
                      regim := i;
                    end;
                5 : begin    {4}
{                      thing := 51;}
                      tec(51,250);
                      regim := i;
                    end;
                6 : begin    {5}
{                      thing := 1;}
                      tec2;
                      regim := 4;
                    end;
                7 : begin    {6}
{                      thing := 1;}
                      tec2;
                      regim := 5;
                    end;
              end;
            until (regim = i) or (regim = 4) or (regim = 5);
            asm
              mov ax , $0013
              int $10
            end;
            fillchar(scr^,sizeof(scr^),1);
          end;
    end;
  until regim = 0;
  asm
    mov ax , $0003
    int $10
  end;
end.
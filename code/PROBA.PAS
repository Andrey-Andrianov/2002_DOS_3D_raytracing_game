uses memmanag,crt,video,mouse4;
{$R-}
type
{  scrtype = array[0..199,0..319] of byte;}
  tectype = array[0..{6}{16}250,0..127,0..127] of byte;
  pich_mon = array[0{..127,0..127}..16383] of byte;
  rayl = record
    l : single;
    ny : longint;
    j : longint;
  end;
  door = record
    x : integer;
    y : integer;
    f : integer;
    t : integer;
  end;
  pich_m = record
    rx: byte;
    ry: byte;
    rb: boolean;
  end;
  monstr = record
    x : longint;
    y : longint;
    n : integer;
  end;


const
  razmsten = 2;

var
  map : array[0..127,0..127]of integer;
  floor_s : array[1..160{80}] of single;
  line_a : array[0..{299}599] of single;
  rays : array[0..{299}599] of rayl;
  doors : array[1..64]of door;
  koldoors : integer;
  monstrs : array[1..200]of monstr;
  kolmonstrs : integer;
  i,j,i1,j1 : longint;
  tectyries : ^tectype;
  pich_mons : array [1..100] of ^pich_mon;
  pich_ms : array [1..100] of pich_m;
{  scr : ^scrtype;
{  np : ^scrtype;}
  aobz : single;
  napr : single;
  rastmon : single;
  rastmons : single;
  maxl : single;
  nmaxl : integer;
                           drazmon : single;
  mx,my,oldmx,oldmy : longint;
  num_key,num_char : byte;
  EXITS : BOOLEAN;
  f : text;
  tt1,tt2,tt3,tt4,tt5,tt6,tt7,tt8,tt9,tt10,dt1,dt2,dt3,dt4,dt5,dt6,dt7,dt8,dt9,dt10,dt11,dt12,kol,ttt3,ttt4,tt_1,tt_2,tt_3,tt_4,dt_1,dt_2 : longint;
  names : array[1..250]of string[15];
  xmouse2,ymouse2,key : word;
  dxmouse,dymouse : single;

procedure ClearKeyBuffer;   {чистит буфер клавиатуры}
begin
   asm
      @p0: mov ah,01h
           int 16h      {смотрим буфер клавиатуры}
           jz @p1       {если пуст, на выход}
           mov ah,0h
           int 16h      {усли не пуст, читаем из него символ}
           jmp @p0      {и повторяем проверку до исчерпания буфера}
       @p1:
   end;
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

function tan(x:single):single;
begin
  tan := sin(x) / cos(x);
end;

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

procedure bmpp2(files : string; number,arrs: integer);
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
  case arrs of
    0:for j := c1.long2-1 downto 0 do
        blockread(f,tectyries^[number,j],c1.long1);
    1:begin
        pich_ms[number].rb := true;
        pich_ms[number].rx := c1.long1;
        pich_ms[number].ry := c1.long2;
        getmemd(pich_mons[number],{sizeof(pich_mons[i]^)}pich_ms[number].rx*pich_ms[number].ry);
        for j := c1.long2-1 downto 0 do
          blockread(f,pich_mons[number]^[j*pich_ms[number].rx],c1.long1);
      end;
  end;
  close(f);
end;

procedure floor;
type
  arbyte = array[0..sizeof(tectype)-1]of byte;
var
{  rastmons,s : single;}
  x,y,x2,y2,dxx,dyy{,ypr},p1,p3 : longint;
  k:single;
  i,j : {integer}longint;
{  f : text;    }
  n : integer;
  arr : ^arbyte absolute tectyries;
  npp : ^arbyte absolute np;
  const1,const2{,const4} : longint;
begin
  tt8 := memd[$046c];
{  arr := pointer(tectyries);}

{ const1 := 3*16384; {пол}
{ const2 := 6*16384; {потолок}
 for n := {81}nmaxl to {160}320 do begin
  tt3 := memd[$046c];
  x := round(((frac((mx + floor_s[n-{80}160]*cos(napr))/128))*128)*16384)and $001FFFFF;{модуль убрать}
  y := round(((frac((my + floor_s[n-{80}160]*sin(napr))/128))*128)*16384)and $001FFFFF;
  x2 := x;
  y2 := y;
  k := (floor_s[n-{80}160]) / rastmons{*0.5}{*300/160};
  dxx := round((k * cos(napr - 0.5*Pi){}*40/64/3)*16384){/128{*0.003255208{};
  dyy := round((k * sin(napr - 0.5*Pi){}*40/64/3)*16384){/128{*0.003255208{};
{  np^[n+20,320] := tectyries^[6,x shr 14,y shr 14];    {пол}
{  np^[20+320-n,320] := tectyries^[6,x shr 14,y shr 14];    {потолок}
  tt4 := memd[$046c];
  dt1 := tt4 - tt3 +dt1;
  p1 := (n+{10}20)*{320}640 +20{+ {161}{321};
  p3 := ({170}340-n)*{320}640+20{ + {161}{321};
  x := (x - dxx*{299}300)and $001FFFFF;
  y := (y - dyy*{299}300)and $001FFFFF;
{  for i := 0 to 599 do begin
{    x := (x + dx)and $001FFFFF;
{    y := (y + dy)and $001FFFFF;
{    npp^[p1] := arr^[6*16384+((x shr 7)and $00ff80)+(y shr 14)]; {пол}
{    npp^[p3] := arr^[6*16384+((x shr 7)and $00ff80)+(y shr 14)];   {потолок}
{    inc(p1);
{    inc(p3);
{  end;}
  const1 := 1*16384;
  const2 := 2*16384;
  tt5 := memd[$046c];
  asm
        push ECX
        push ESI
        push EDI
        push EDX
        push EBX

        MOV i , 600
        mov ecx , x
        mov edi , y

        mov esi , p1
        add esi , npp

        mov edx , p3
        add edx , npp

        mov eax , arr
        add const1 , eax
        add const2 , eax

        align 4        {выравнивание}
  @l1:  add ecx , dxx              {x := (x + dx)and $001FFFFF;}
        add edi , dyy              {y := (y + dy)and $001FFFFF;}
        and edi , $001FFFFF
        mov ebx , ecx              {(x shr 7)}
        shr ebx , 7
        and ebx , $003f80          {((x and $001FFFFF) shr 7) and $00ff80}
        mov eax , edi              {(y shr 14)}
        shr eax , 14
        add ebx , eax              {((x shr 7)and $00ff80)+(y shr 14)}
        add ebx , const1           {3*16384+((x shr 7)and $00ff80)+(y shr 14)}
        mov al , [ebx]             {вывод точки пола}
        mov [esi] , al
{        add ebx , (2*16384 - 1*16384){6*16384+((x shr 7)and $00ff80)+(y shr 14)}
        mov al , [ebx+16384]             {вывод точки потолка}
        mov [edx] , al
        inc esi                    {inc(p1)}
        inc edx                    {inc(p3)}
        dec i
        jnz @l1



        pop EBX
        pop EDX
        pop EDI
        pop ESI
        pop ECX
  end;
  tt6 := memd[$046c];
  dt2 := dt2 + tt6 - tt5;
 end;
 tt9 := memd[$046c];
 dt10 := dt10 + tt9 - tt8;
end;

procedure ray(a:single;nx:longint);
var
  {x,y,}l,k{,rx} : single;
  ny,i,j,i1,i2,rx,tx,p1,xx,yy,ttx,tty,dx,dy : longint;
  t1,t2,t3,t4 : longint;
  t5,t6{,ttx,tty} : single;
  ex : boolean;
begin
  tt3 := memd[$046c];
{  x := mx;
{  y := my;}
  ex := true;
  dx := round(cos(a)*128);
  dy := round(sin(a)*128);
  xx := mx shl 14;
  yy := my shl 14;
  if dx > 0 then
    ttx := 129*16384{+1}
  else
    ttx := -1*16384;
  if dy > 0 then
    tty := 129*16384{+1}
  else
    tty := -1*16384;
  while ex{(map[yy shr 21,xx shr 21] = 1)} do BEGIN
    if dx <> 0 then begin
      t1 := (ttx - (xx {mod}and $1fffff{128})) div dx;
    end else begin
      t1 := $fffffff;
    end;
    if dy <> 0 then begin
      t3 := (tty - (yy {mod}and $1fffff{128})) div dy;
    end else begin
      t3 := {10000}$fffffff;
    end;
    if (t3<t1) then begin
      xx := xx + t3*dx;
      yy := yy + t3*dy;{}
      rays[nx].ny := 127 - ((xx shr 14) mod 128);
      case map[yy shr 21,xx shr 21] of
        1      :;
        3..34  :begin
                  for i := 1 to koldoors do
                    if (doors[i].x = (xx shr 21)) and (doors[i].y = (yy shr 21)) then begin
                      if (rays[nx].ny < doors[i].f+1) or (rays[nx].ny > 128-doors[i].f-1) then begin
                        ex := false;
                        if rays[nx].ny > 64 then
                          rays[nx].ny := rays[nx].ny - (64 - doors[i].f)
                        else
                          rays[nx].ny := rays[nx].ny + (64 - doors[i].f)
                      end;
                      break;
                    end;
{                  ex := false;  }
                end;
        35..250:ex := false;
      end;
    end else begin
      xx := xx + t1*dx;
      yy := yy + t1*dy;{}
      rays[nx].ny := ((yy shr 14) mod 128);
      case map[yy shr 21,xx shr 21] of
        1      :;
        3..34  :begin
                  for i := 1 to koldoors do
                    if (doors[i].x = (xx shr 21)) and (doors[i].y = (yy shr 21)) then begin
                      if (rays[nx].ny < doors[i].f+1) or (rays[nx].ny > 128-doors[i].f-1) then begin
                        ex := false;
                        if rays[nx].ny > 64 then
                          rays[nx].ny := rays[nx].ny - (64 - doors[i].f)
                        else
                          rays[nx].ny := rays[nx].ny + (64 - doors[i].f)
                      end;
                      break;
                    end;
{                  ex := false;}
                end;
        35..250:ex := false;
      end;
    end;
{    xx := round(x);
{    yy := round(y);}
  END;
  xx := xx shr 14;
  yy := yy shr 14;
{  if ((round(x+1) mod 128) =0) or ((round(x-1) mod 128) =0) or ((round(x) mod 128) =0) then
{    rays[nx].ny := (round(y) mod 128)
{  else
{    rays[nx].ny := 128 - (round(x) mod 128);}
  rays[nx].l := (sqrt(sqr(mx-xx) + sqr(my-yy)))/128*razmsten*cos(abs(a-napr));
  rays[nx].j :=map[(yy) div 128,(xx) div 128] shl 14 + (rays[nx].ny shl 7);
  if maxl < rays[nx].l then
    maxl := rays[nx].l;
  tt4 := memd[$046c];
  dt3 := tt4 - tt3 + dt3;
end;

procedure line(a:single;nx:longint);
type
  arbyte = array[0..sizeof(tectype)-1]of byte;
var
  dx,dy,x,y,l,k{,rx} : single;
  b : boolean;
  ny,i,j,i1,i2,rx,tx,p1 : longint;
  t1,t2,t3,t4,t5,t6 : single;
  arr : ^arbyte absolute tectyries;
  npp : ^arbyte absolute np;
begin
      tt7 := memd[$046c];

      k := (rastmon / (rays[nx].l)){*300/160};

      rx := round(64 / round({150}300*k)*16384);
      tx := 0;
      if ({150}300*k) < {80}160.5 then begin
        i1 := {90}180-round({150}300*k);
        i2 := {90}180+round({150}300*k) - 1;
      end else begin
        i1 := {10}20;
        i2 := {170}340;
        tx := round(64 * ({round}({150}300*k) - {80}160)/{round}({150}300*k)*16384);
      end;
      p1 := i1*{320}640 + {10}20+nx;
      j := rays[nx].j;
      tt6 := memd[$046c];
      asm
        push ECX
        push ESI
        push EDI
        push EDX
        push EBX

        MOV ecx , i2
        sub ecx , i1
        add ecx , 1

        mov esi , p1
        add esi , npp

        mov edi , j
        add edi , arr

        mov edx , tx

        align 4        {выравнивание}
  @l1:  mov ebx , edx
        shr ebx , 14
        mov al , [edi + ebx]
        add edx , rx
        mov [esi] , al
        add esi , 640
        dec ecx
        jnz @l1
        pop EBX
        pop EDX
        pop EDI
        pop ESI
        pop ECX
      end;
{      for i := i1 to i2 do begin
{        npp^[p1] := arr^[j+(tx shr 14)];{текстура повернута 0.5*Pi}
{        inc(tx,rx);
{        inc(p1,640);
{      end;}
      tt5 := memd[$046c];
  dt4 := dt4 + tt5 -tt7;
  dt5 := dt5 + tt5 -tt6;

end;

procedure monst;
type
  arbyte = array[0..sizeof(tectype)-1]of byte;
var
  i,j,l,ny1,i1,i2,i3,i4,tx,tx2,rx{,rx2} : longint;
  k,k2,s,p,s_a,t_a,c_a,kof : single;
  x2,y2,x3,y3 : single;
  d1,d2,d3,d4 : single;
  t_2,t_3,a_2,a_3,r_2,r_3 : single;
  i_2,i_3 : longint;
  a_1,t_1,d5,d6 : single;
  tx_0,tx2_shr_14,sel_pich_ms,p1 : longint;
  npp : ^arbyte absolute np;
begin
  for l := 1 to kolmonstrs do
   if monstrs[l].n <> 0 then begin
                                tt_1 := memd[$046c];
     k := sqrt(sqr(mx-monstrs[l].x) + sqr(my-monstrs[l].y))/128*razmsten;
     x2 := monstrs[l].x;
     y2 := monstrs[l].y;
     d1 := x2 - mx;
     d2 := y2 - my;
     if (d2 = 0) and (d1 < 0) then d2 := 1;{*}
     if d1 <> 0 then begin t_2 := d2 / d1; a_2 := arctan(abs(t_2)) end;
     if (d1<0) and (d2>0) then a_2 := Pi - a_2;
     if (d1<0) and (d2<0) then a_2 := Pi + a_2;
     if (d1>0) and (d2<0) then a_2 := {2*Pi} - a_2;
     if (d1 = 0) and (d2 > 0) then a_2 := 0.5*Pi;
     if (d1 = 0) and (d2 < 0) then a_2 := 1.5*Pi;

     k := k*cos(abs(napr-a_2));
                                tt_2 := memd[$046c];
                                dt_1 := dt_1 + tt_2 - tt_1;
     if  (k <= maxl) and (k/cos(abs(napr-a_2)) > 60/128) then begin
       kof := (rastmon / k);

                                tt_1 := memd[$046c];
       x2 := monstrs[l].x - {64}((pich_ms[monstrs[l].n].rx div 2))*cos(napr + 0.5*Pi);
       y2 := monstrs[l].y - {64}((pich_ms[monstrs[l].n].rx div 2))*sin(napr + 0.5*Pi);
       x3 := monstrs[l].x + {64}((pich_ms[monstrs[l].n].rx div 2))*cos(napr + 0.5*Pi);
       y3 := monstrs[l].y + {64}((pich_ms[monstrs[l].n].rx div 2))*sin(napr + 0.5*Pi);
       d1 := x2 - mx;
       d2 := y2 - my;
       d3 := x3 - mx;
       d4 := y3 - my;
       if d1 <> 0 then begin t_2 := d2 / d1; a_2 := arctan(abs(t_2)) end;
       if (d1<0) and (d2>0) then a_2 := Pi - a_2;
       if (d1<0) and (d2<0) then a_2 := Pi + a_2;
       if (d1>0) and (d2<0) then a_2 := {2*Pi} - a_2;
       if d3 <> 0 then begin t_3 := d4 / d3; a_3 := arctan(abs(t_3)) end;
       if (d3<0) and (d4>0) then a_3 := Pi - a_3;
       if (d3<0) and (d4<0) then a_3 := Pi + a_3;
       if (d3>0) and (d4<0) then a_3 := {2*Pi} - a_3;
       if (d1 = 0) and (d2 > 0) then a_2 := 0.5*Pi;
       if (d1 = 0) and (d2 < 0) then a_2 := 1.5*Pi;
       if (d3 = 0) and (d4 > 0) then a_3 := 0.5*Pi;
       if (d3 = 0) and (d4 < 0) then a_3 := 1.5*Pi;

{    if (abs(napr - a_2) <= 0.25*Pi) or (abs(napr - a_3) <= 0.25*Pi) then begin*}
       i_2 := 0;
       r_2 := abs(a_2 - line_a[0]-napr);
       for j := 0 to 599 do
         if abs(a_2 - line_a[j]-napr) < r_2 then begin
           r_2 := abs(a_2 - line_a[j]-napr);
           i_2 := j;
         end;
       for j := 0 to 599 do
         if abs(2*Pi + a_2 - line_a[j]-napr) < r_2 then begin
           r_2 := abs(2*Pi + a_2 - line_a[j]-napr);
           i_2 := j;
         end;
       i_3 := 0;
       r_3 := abs(a_3 - line_a[0]-napr);
       for j := 0 to 599 do
         if abs(a_3 - line_a[j]-napr) < r_3 then begin
           r_3 := abs(a_3 - line_a[j]-napr);
           i_3 := j;
         end;
       for j := 0 to 599 do
         if abs(2*Pi + a_3 - line_a[j]-napr) < r_3 then begin
           r_3 := abs(2*Pi + a_3 - line_a[j]-napr);
           i_3 := j;
         end;
                                tt_2 := memd[$046c];
                                dt_1 := dt_1 + tt_2 - tt_1;

       if (i_2-i_3 <> 0) then{*}
         if ((i_2-i_3 <> 599) and (kof <> 1)) or ((i_2-i_3 = 599) and (kof = 1)) then begin{*}
                                tt_1 := memd[$046c];
           rx := round(64 / round(300*kof)*16384);
           if (300*kof)*((pich_ms[monstrs[l].n].ry-1)/128) < 160.5 then begin
             i1 := 180-round(300*kof*((pich_ms[monstrs[l].n].ry-1)/128));
             i2 := 180+round(300*kof*((pich_ms[monstrs[l].n].ry-1)/128)) - 1;
           end else begin
             i1 := 20;
             i2 := 340;
           end;
           if i_2 >= i_3 then begin
             i3 :=  i_3;
             i4 :=  i_2;
           end else begin
             i3 :=  i_2;
             i4 :=  i_3;
           end;
           tx2 := 0;
           if i3 <> 0 then begin
             i4 := i3 + round({127}((pich_ms[monstrs[l].n].rx{ div 2})-1)*16384 / (rx) -1) ;
           end;
           if i4 >= 600 then i4 := 599;

           if (i3 =0) then begin
             tx2 := round({128}((pich_ms[monstrs[l].n].rx{ div 2}))*16384 - (i4-i3+1)*rx -1);
             if tx2 < 0 then tx2 := 0;
           end;
           if (300*kof)*((pich_ms[monstrs[l].n].ry-1)/128) >= 160.5 then
             tx_0 := round(64 * ((300*kof) - 160)/(300*kof)*16384)
           else
             tx_0 := 0;
           for i := i3 to i4 do begin
             if k <= rays[i].l then begin
               p1 := i1*640 + i + 20;
               tx2_shr_14 := tx2 shr 14;
               tx := tx_0;
               for j := i1 to i2 do begin
                 sel_pich_ms := (tx shr 14)*pich_ms[monstrs[l].n].rx + (tx2_shr_14);
                 if pich_mons[monstrs[l].n]^[sel_pich_ms] <> 255 then
                   npp^[p1] := pich_mons[monstrs[l].n]^[sel_pich_ms];
                 inc(tx,rx);
                 inc(p1,640);
               end;
             end;
             inc(tx2,rx);
           end;
                                tt_2 := memd[$046c];
                                dt_2 := dt_2 + tt_2 - tt_1;

         end;{*}
       end;
     end;
end;

procedure loadmap;
var
  i,j : integer;
  f : file;
  f2 : text;
begin
  assign(f,'maps\' + 'map1' + '.mdt');
  reset(f,1);
  blockread(f,map,sizeof(map));
  close(f);
  assign(f2,'maps\' + 'map1' + '.mzl');
  reset(f2);
  readln(f2,kolmonstrs);
  for i := 1 to kolmonstrs do begin
    readln(f2,monstrs[i].x);
    readln(f2,monstrs[i].y);
    readln(f2,monstrs[i].n);
  end;
  close(f2);
  koldoors := 0;
  for j := 0 to 127 do
    for i := 0 to 127 do
      if (map[j,i] >= 3) and (map[j,i] <= 34) then begin
        inc(koldoors);
        doors[koldoors].x := i;
        doors[koldoors].y := j;
        doors[koldoors].f := 64;
        doors[koldoors].t := 64;
      end;
end;

function step(y,x:integer):boolean;
var
  i,j : integer;
begin
  case map[y,x] of
    1      :step := true;
    35..250:step := false;
    3..34  :begin
              for i := 1 to koldoors do
                if (doors[i].x = x) and (doors[i].y = y) then begin
                  if doors[i].f <= 32 then
                    step := true
                  else
                    step := false;
                  break;
                end;
            end;
  end;
end;

procedure getmemobjs;
var
  i,j : integer;
  s : string;
begin
  for i := 1 to 40 do begin
    str(i,s);
    bmpp2('pich\' + 'ob' + s + '.bmp',i,1);
  end;
{  bmpp2('pich\mon1.bmp',1,1);
{  bmpp2('pich\mon2.bmp',2,1);
{  bmpp2('pich\mon3.bmp',3,1);}
end;

begin
  asm
    mov ax , 0013h
    int 10h
  end;
  initmouse;
  asm
    mov ax , 0003h
    int 10h
  end;
  dt1 := 0;  dt2 := 0; dt3 := 0; dt4 := 0; dt5 := 0; dt6 := 0; dt7 := 0; dt8 := 0; dt9 := 0; dt10 := 0; dt11 := 0; dt12 := 0; dt_1 := 0; dt_2 := 0;
  EXITS := FALSE;
  aobz := 0.5 * Pi;
  loadmap;
{  napr := 0.5*Pi;
{  mx := 192;
{  my := 192;{}
{  napr := 1*Pi;
{  mx := 252;
{  my := 192;{}
  napr := 0.25*Pi;
  mx := 192;
  my := 192;  {}
  oldmx := mx;
  oldmy := my;
  rastmon := 0.5*razmsten / tan(0.5*aobz);
  drazmon := tan(0.5*aobz)/{150}300;
  rastmons := rastmon/razmsten*128;
  for i := 1 to {80}160 do
    floor_s[i] := (64*rastmons)/(64/{150}300*(i)){0.5};
  for j := 1 to {150}300 do
    line_a[j-1] := arctan(drazmon*({150}300-j)/rastmon);{}
  for j := 1 to {149}300{299} do
    line_a[j+{150}300-1] := -arctan(drazmon*(j)/rastmon);{}

  for i := 1 to 100 do
    pich_ms[i].rb := false;

  getmemd(np,sizeof(np^));
  getmemd(tectyries,sizeof(tectyries^));
  getmemobjs;
{  bmpp2('pich\mon1.bmp',1,1);
{  bmpp2('pich\mon2.bmp',2,1);
{  bmpp2('pich\mon3.bmp',3,1);}

{  for i := 1 to 100 do
{    getmemd(pich_mons[i],sizeof(pich_mons[i]^));}
{  scr := ptr(SegA000,0);
{  asm
{    mov ax , $0013
{    int 10h
{  end;}
  setvesamode($100);
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
  for j := 1 to 250 do
    if names[j] <> '-' then
      bmpp2('pich\' + names[j],j,0);
{  bmpp2('pich\mon1.bmp',1,1);
{  bmpp2('pich\mon2.bmp',2,1);
{  bmpp2('pich\mon3.bmp',3,1);}

  for j := 1 to 250 do begin
    for j1 := 0 to 127 do
      for i1 := 0 to 127 do
        tectyries^[0,j1,i1] := tectyries^[j,i1,j1];
    tectyries^[j] := tectyries^[0];
  end;{}

  fillchar(np^,sizeof(np^),0);

  for i := 0 to 255 do
    np^[398,i+32] := i;

  tt1 := memd[$046c];
  kol := 0;
{  initmouse;}
  dxmouse := 0;
  dymouse := 0;
{  key := mouseposition(xmouse1,ymouse1);}
  key := 0;

{  assign(f,'a.m');
{  rewrite(f);}

  setmouseposition(14,14);
  repeat
    inc(kol);
    maxl := 0;
    for j := 0 to {299}599 do
      ray(napr + line_a[j],j);
    ttt3 := memd[$046c];
    nmaxl := {80}161;
    for j := {80}160 downto 1 do
      if floor_s[j]/128*razmsten > maxl then begin
        nmaxl := {80}160 + j;
        break;
      end;
    floor;
    ttt4 := memd[$046c];
    dt6 := dt6 + (ttt4 - ttt3);
    for j := 0 to 599 do
      line(napr + line_a[j],j);
    ttt3 := memd[$046c];
    dt7 := dt7 +  ttt3 - ttt4;
    monst;
{    move(np^,scr^,sizeof(np^));}
    movebyffer;
    ttt4 := memd[$046c];
    dt8 := dt8 +  ttt4 - ttt3;
    for i := 1 to koldoors do begin
      if (doors[i].t < 64) and (doors[i].t > 0) then begin
        if doors[i].f > 0 then dec(doors[i].f,4);
        dec(doors[i].t,1);
      end;
      if (doors[i].t < 64) and (doors[i].t <= 0) then begin
       if (((mx) div 128) <> doors[i].x) or (((my) div 128) <>doors[i].y) then begin
        if doors[i].f < 64 then inc(doors[i].f,4);
        dec(doors[i].t,4);
       end else begin
         doors[i].f := 0;
         doors[i].t := 48;
       end;
      end;
      if doors[i].t = -64 then doors[i].t := 64;
    end;
    for i := 1 to kolmonstrs do begin
      if (monstrs[i].x + 64 >= mx) and (monstrs[i].x - 64 <= mx) and (monstrs[i].y + 64 >= my) and (monstrs[i].y - 64 <= my) then
        monstrs[i].n := 0;
    end;{*****************************************************************}
    if (keypressed) or (dxmouse<>0) or (dymouse<>0) then begin
{      if dymouse < 32 then begin}
      napr := napr - dxmouse;
      if napr > 2*Pi then napr := napr - 2*Pi;
      if napr < 0 then napr := napr + 2*Pi;
      if dymouse > 16 then dymouse := 16;
      if dymouse < -16 then dymouse := -16;
      my := my - round(dymouse*sin(napr));
      mx := mx - round(dymouse*cos(napr));
{      end;}
      if keypressed then begin
        waitkey;
        ClearKeyBuffer;
       case num_key of
        1:EXITS := TRUE;
        75:begin
             napr := napr + 0.1;
             if napr > 2*Pi then
               napr := napr - 2*Pi;
           end;
        77:begin
             napr := napr - 0.1;
             if napr < 0 then
               napr := napr + 2*Pi;
           end;
        72:begin
             my := my + round(8*sin(napr));
             mx := mx + round(8*cos(napr));
           end;
        80:begin
             my := my - round(8*sin(napr));
             mx := mx - round(8*cos(napr));
           end;
        57:begin
             if (map[round(my+50*sin(napr)) div 128,round(mx+50*cos(napr)) div 128] >= 3) and (map[round(my+50*sin(napr)) div 128,round(mx+50*cos(napr)) div 128] <= 34) then begin
               for i := 1 to koldoors do
                 if (doors[i].y = round(my+50*sin(napr)) div 128) and (doors[i].x = round(mx+50*cos(napr)) div 128) then begin
                   if doors[i].f = 64 then begin
                     dec(doors[i].f,4);
                     dec(doors[i].t,1);
                   end;
                   break;
                 end;
{               map[round(my+50*sin(napr)) div 128,round(mx+50*cos(napr)) div 128] := 1;}
             end;
           end;
       end;
      end;
    end;
    if (not step((my) div 128,(mx+25) div 128)) or (not step((my) div 128,(mx-25) div 128)) or (not step((my+25) div 128,(mx) div 128)) or (not step((my-25) div 128,(mx) div 128)) then begin
      if (step((oldmy) div 128,(mx+25) div 128)) and (step((oldmy) div 128,(mx-25) div 128)) and (step((oldmy+25) div 128,(mx) div 128)) and (step((oldmy-25) div 128,(mx) div 128)) then
        my := oldmy
      else if (step((my) div 128,(oldmx+25) div 128)) and (step((my) div 128,(oldmx-25) div 128)) and (step((my+25) div 128,(oldmx) div 128)) and (step((my-25) div 128,(oldmx) div 128)) then
        mx := oldmx
      else begin
        my := oldmy;
        mx := oldmx;
      end;
    end;
    oldmx := mx;
    oldmy := my;
    ttt3 := memd[$046c];
    dt9 := dt9 +  ttt3 - ttt4;
    key := mouseposition(xmouse2,ymouse2);
    setmouseposition(14,14);
    dxmouse := ((xmouse2 - 105)*Pi/1200);
    dymouse := ((ymouse2 - 105));
{    if 1 <> 0 then begin
{      writeln(f,xmouse2);
{      sound(440);
{      delay(1);
{      nosound;
{    end;}
{    xmouse1 := xmouse2;
{    ymouse1 := ymouse2;}

  until (EXITS) {or (kol = 50)};
{  close(f);    }
  tt2 := memd[$046c];
{  asm
{    mov ax , $0003
{    int 10h
{  end;}
  closevesamode;
{  freememd(pich_mons,sizeof(pich_mons^));}
  for i := 1 to 100 do
    if pich_ms[i].rb then
      freememd(pich_mons[i],{sizeof(pich_mons[i]^)}pich_ms[i].rx*pich_ms[i].ry);
  freememd(tectyries,sizeof(tectyries^));
  freememd(np,sizeof(np^));
{  writeln('пол',t2-t1);
{  writeln('стены',t4-t3);
{  writeln('кадр',t5-t1);
{  writeln('кадр/сек',t8*18/(t7-t6));}
  writeln('');
  writeln('Всего ',tt2-tt1,'          ',(tt2-tt1)/18:5:5,' sec');
  writeln('пол1 ',dt1,'           ',100*dt1/(tt2-tt1):5:5,'%');
  writeln('пол2 ',dt2,'           ',100*dt2/(tt2-tt1):5:5,'%');
  writeln('стены1 ',dt3,'           ',100*dt3/(tt2-tt1):5:5,'%');
  writeln('стены2 ',dt4,'           ',100*dt4/(tt2-tt1):5:5,'%');
  writeln('стены3 вн цикл ',dt5,'           ',100*dt5/(tt2-tt1):5:5,'%');
  writeln('остальное ',tt2-tt1-dt4-dt3-dt2-dt1,'           ',100*(tt2-tt1-dt4-dt3-dt2-dt1)/(tt2-tt1):5:5,'%');
  writeln('кадр/сек ',kol/(tt2-tt1)*18:5:5,'%');
  writeln('kol ',kol);
  writeln('пол ',dt6);
  writeln('стены ',dt7);
  writeln('экран ',dt8);
  writeln('клав ',dt9);
  writeln('пол3 ',dt10);
  writeln('dt_1 ',dt_1);
  writeln('dt_2 ',dt_2);
  writeln(pich_mons[1]^[1]);
{  writeln('nmaxl2 ',(320 - nmaxl+1));
{  writeln('кол-во проходов вн цикл за посл кадр ',(320-nmaxl+1)*600);}
{  readln;}
end.
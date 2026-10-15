$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# PACK AND BOOT SHAPES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {id:'packsand',  name:'Sand Pack',      how:'level:3',     kind:'pack'},
'@ @'
  {id:'packsand',  name:'Sand Pack',      how:'level:3',     kind:'pack'},
  // v28.12 (cosm5), HIS ORDER (2026-10-15): "player cosmetics still need major improvements". PACK SHAPES: four packs that change the outline of your back,
  // not only its colour. They wear the scheme secondary like the canvas pack and carry the accent.
  {id:'packroll',  name:'Bedroll Pack',   how:'runs:11',     kind:'pack'},
  {id:'packradio', name:'Radio Pack',     how:'extracts:5',  kind:'pack'},
  {id:'packfuel',  name:'Fuel Can Pack',  how:'extracts:10', kind:'pack'},
  {id:'packframe', name:'Frame Pack',     how:'level:4',     kind:'pack'},
'@

SubRx @'
  {id:'sneakbred', name:'Bred High-Tops',    how:'level:5',     kind:'boots'},
'@ @'
  {id:'sneakbred', name:'Bred High-Tops',    how:'level:5',     kind:'boots'},
  // v28.12 (cosm5): BOOT SHAPES: shin guards over the lower leg, tall laced gaiters to the knee.
  {id:'bootshin',  name:'Shin Guards',       how:'runs:13',     kind:'boots'},
  {id:'bootgaiter',name:'Tall Gaiters',      how:'extracts:15', kind:'boots'},
'@

SubRx @'
var PACKCOL={packbrown:'#5c4a34',packolive:'#3a5a2c',packblack:'#1e2228',packrust:'#6a3a2a',packsand:'#8a7a52'};
'@ @'
var PACKCOL={packbrown:'#5c4a34',packolive:'#3a5a2c',packblack:'#1e2228',packrust:'#6a3a2a',packsand:'#8a7a52',
             packroll:'#5c4a34',packradio:'#5c4a34',packfuel:'#5c4a34',packframe:'#5c4a34'};   // v28.12 (cosm5): the shapes start from the canvas colour, so a scheme paints them
// v28.12 (cosm5): what a pack shape adds to the outline. px is the pack centre, pw its width; the base pack is drawn first.
function drawPackExtra(id,px,ty,fl,pw,sch){
  var A=sch?sch.a:'#c8a24a', bx, ax;
  if(id==='packroll'){
    wc.fillStyle=INK; rrF(px-pw/2-2.6,ty-26.8,pw+5.2,5.6,2.8);
    wc.fillStyle='#8a7a5a'; rrF(px-pw/2-2.0,ty-26.3,pw+4.0,4.6,2.3);
    wc.fillStyle='#ad9c7c'; wc.fillRect(px-pw/2-1.4,ty-26.1,pw+2.8,1.0);
    wc.fillStyle='#3a2e20'; wc.fillRect(px-pw/2+0.2,ty-26.4,1.0,5.0); wc.fillRect(px+pw/2-1.2,ty-26.4,1.0,5.0);
    wc.fillStyle=A; wc.fillRect(px-0.9,ty-26.4,1.8,5.0);
  } else if(id==='packradio'){
    ax=px+pw/2-0.4;
    wc.fillStyle=INK; wc.fillRect(ax-0.7,ty-40.0,1.4,13.0);
    wc.fillStyle=INK; rrF(px-pw/2-1.6,ty-29.2,pw+3.2,8.6,1.8);
    wc.fillStyle='#38443f'; rrF(px-pw/2-1.0,ty-28.7,pw+2.0,7.6,1.3);
    wc.fillStyle='#566560'; wc.fillRect(px-pw/2-0.8,ty-28.5,pw+1.6,1.3);
    wc.fillStyle='#202a26'; wc.fillRect(px-pw/2-0.6,ty-23.6,pw+1.2,0.9);
    wc.fillStyle=A; wc.fillRect(px-pw/2+0.0,ty-26.4,1.6,1.6); wc.fillStyle='#d8e0dc'; wc.fillRect(px+0.7,ty-26.4,1.6,1.6);
    wc.fillStyle=A; wc.fillRect(ax-1.1,ty-41.2,2.2,2.2);
  } else if(id==='packfuel'){
    bx=px-fl*(pw/2+3.6);
    wc.fillStyle=INK; rrF(bx-3.8,ty-21.8,7.6,10.4,1.8); wc.fillRect(bx-1.4,ty-23.6,2.8,2.4);
    wc.fillStyle='#8a3a2a'; rrF(bx-3.2,ty-21.2,6.4,9.2,1.3);
    wc.fillStyle='#b25a44'; wc.fillRect(bx-2.8,ty-21.0,5.6,1.3);
    wc.fillStyle='#5a2418'; wc.fillRect(bx-3.2,ty-16.4,6.4,0.9);
    wc.fillStyle=A; wc.fillRect(bx-1.0,ty-23.3,2.0,1.5);
    wc.fillStyle='#5a2418'; wc.fillRect(bx-0.6,ty-19.6,1.2,2.4);
  } else if(id==='packframe'){
    wc.fillStyle=INK; rrF(px-pw/2-2.4,ty-30.2,pw+4.8,10.6,2.4);
    wc.fillStyle=sch?sch.pack:'#4a5a3a'; rrF(px-pw/2-1.8,ty-29.7,pw+3.6,9.6,1.9);
    wc.fillStyle='rgba(255,255,255,.16)'; wc.fillRect(px-pw/2-1.4,ty-29.5,pw+2.8,1.2);
    wc.fillStyle='#2a2f26'; wc.fillRect(px-pw/2-1.8,ty-25.2,pw+3.6,0.9);
    wc.fillStyle=INK; rrF(px-pw/2-4.4,ty-20.6,3.2,6.6,1.2); rrF(px+pw/2+1.2,ty-20.6,3.2,6.6,1.2);
    wc.fillStyle=sch?sch.pack:'#4a5a3a'; rrF(px-pw/2-3.9,ty-20.1,2.2,5.6,0.9); rrF(px+pw/2+1.7,ty-20.1,2.2,5.6,0.9);
    wc.fillStyle=A; wc.fillRect(px-pw/2-1.8,ty-29.7,pw+3.6,1.0);
  }
}
'@

SubRx @'
sneakbred:['#14161b','#1f2227','#c41e1e','#c41e1e']};
'@ @'
sneakbred:['#14161b','#1f2227','#c41e1e','#c41e1e']};
BOOTCOL.bootshin=BOOTCOL.bootblack;   // v28.12 (cosm5): the shin guards start from black boots, so a scheme paints them
BOOTCOL.bootgaiter=['#4a4234','#6a5c44'];
'@

SubRx @'
  var _PKC=PACKCOL[st.hero?cosWorn('pack'):(st.pack||'packbrown')]||PACKCOL.packbrown;   // v10.34
'@ @'
  var _PKID=st.hero?cosWorn('pack'):(st.pack||'packbrown');   // v28.12 (cosm5)
  var _PKC=PACKCOL[_PKID]||PACKCOL.packbrown;   // v10.34
'@

SubRx @'
wc.fillRect(x-fl*9-pw/2+leanX+0.6,ty-20.4,pw-1.2,1.2); }
'@ @'
wc.fillRect(x-fl*9-pw/2+leanX+0.6,ty-20.4,pw-1.2,1.2); }
  if(/^pack(roll|radio|fuel|frame)$/.test(_PKID)) drawPackExtra(_PKID,x-fl*9+leanX,ty,fl,pw,_SCH);   // v28.12 (cosm5)
'@

SubRx @'
  var _BT=OUTF?OUTF.boots:(BOOTCOL[st.hero?cosWorn('boots'):(st.boots||'bootblack')]||BOOTCOL.bootblack);   // v10.54
'@ @'
  var _BTID=st.hero?cosWorn('boots'):(st.boots||'bootblack');   // v28.12 (cosm5)
  var _BT=OUTF?OUTF.boots:(BOOTCOL[_BTID]||BOOTCOL.bootblack);   // v10.54
'@

SubRx @'
  if(_SCH&&!_BT[2]){ wc.fillStyle=_SCH.a;
'@ @'
  if(!OUTF&&_BTID==='bootshin'){   // v28.12 (cosm5): shin guards, a plate over the front of each lower leg
    wc.fillStyle=INK; rrF(x-6.8+swing2*.5,ty-10.2-liftB*.5,5.2,5.6,1.4); rrF(x+1.4+swing*.5,ty-10.2-liftA*.5,5.2,5.6,1.4);
    wc.fillStyle='#69747e'; rrF(x-6.2+swing2*.5,ty-9.7-liftB*.5,4.0,4.6,1.0); rrF(x+2.0+swing*.5,ty-9.7-liftA*.5,4.0,4.6,1.0);
    wc.fillStyle='#8f9ba6'; wc.fillRect(x-6.0+swing2*.5,ty-9.6-liftB*.5,3.6,1.0); wc.fillRect(x+2.2+swing*.5,ty-9.6-liftA*.5,3.6,1.0);
    wc.fillStyle=_SCH?_SCH.a:'#c8a24a'; wc.fillRect(x-6.0+swing2*.5,ty-6.6-liftB*.5,3.6,0.9); wc.fillRect(x+2.2+swing*.5,ty-6.6-liftA*.5,3.6,0.9);
  } else if(!OUTF&&_BTID==='bootgaiter'){   // v28.12 (cosm5): tall laced gaiters up to the knee, wider than the trouser leg
    wc.fillStyle=INK; rrF(x-7.0+swing2*.5,ty-10.8-liftB*.5,5.8,7.4,1.5); rrF(x+1.2+swing*.5,ty-10.8-liftA*.5,5.8,7.4,1.5);
    wc.fillStyle=_BT[0]; rrF(x-6.4+swing2*.5,ty-10.3-liftB*.5,4.6,6.4,1.1); rrF(x+1.8+swing*.5,ty-10.3-liftA*.5,4.6,6.4,1.1);
    wc.fillStyle=_BT[1]; wc.fillRect(x-6.4+swing2*.5,ty-10.3-liftB*.5,1.4,6.4); wc.fillRect(x+1.8+swing*.5,ty-10.3-liftA*.5,1.4,6.4);
    wc.fillStyle='#d8cfb4'; wc.fillRect(x-4.4+swing2*.5,ty-9.4-liftB*.5,0.8,0.8); wc.fillRect(x-4.4+swing2*.5,ty-7.8-liftB*.5,0.8,0.8); wc.fillRect(x+3.8+swing*.5,ty-9.4-liftA*.5,0.8,0.8); wc.fillRect(x+3.8+swing*.5,ty-7.8-liftA*.5,0.8,0.8);
    wc.fillStyle=_SCH?_SCH.a:'#c8a24a'; wc.fillRect(x-6.4+swing2*.5,ty-10.3-liftB*.5,4.6,1.0); wc.fillRect(x+1.8+swing*.5,ty-10.3-liftA*.5,4.6,1.0);
  }
  if(_SCH&&!_BT[2]){ wc.fillStyle=_SCH.a;
'@

SubRx @'
c.kind==='scheme'||c.kind==='fit'||c.kind==='tattoo'||c.kind==='face'
'@ @'
c.kind==='pack'||c.kind==='boots'||c.kind==='scheme'||c.kind==='fit'||c.kind==='tattoo'||c.kind==='face'
'@

SubRx @'
var VER='28.11';
'@ @'
var VER='28.12';
'@

$pat = "(?m)^  now:'v28\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.12: Four new pack shapes and two boot shapes in FASHION: bedroll, radio, fuel can, frame pack, shin guards, tall gaiters. Check 28.12 fails on v28.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

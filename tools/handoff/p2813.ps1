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

# THE BODY LAYER: VESTS AND SHOULDER PADS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {id:'schgilded',  name:'Gilded',         how:'board:1',    kind:'scheme'}
];
'@ @'
  {id:'schgilded',  name:'Gilded',         how:'board:1',    kind:'scheme'},
  // v28.13 (cosm4), HIS ORDER (2026-10-15): "player cosmetics still need major improvements". BODY LAYER: the VEST over the plate carrier and the
  // SHOULDER pads, two racks that change the chest and the shoulders of the silhouette. Plate Carrier and No Pads are the old look.
  {id:'vestplate', name:'Plate Carrier',  how:'always',      kind:'vest'},
  {id:'vestband',  name:'Bandolier',      how:'runs:6',      kind:'vest'},
  {id:'vestharn',  name:'Light Harness',  how:'level:2',     kind:'vest'},
  {id:'vestutil',  name:'Utility Vest',   how:'extracts:4',  kind:'vest'},
  {id:'vestheavy', name:'Heavy Plates',   how:'extracts:9',  kind:'vest'},
  {id:'padsnone',  name:'No Pads',        how:'always',      kind:'pads'},
  {id:'padsround', name:'Round Pads',     how:'runs:8',      kind:'pads'},
  {id:'padsspike', name:'Spiked Pads',    how:'extracts:7',  kind:'pads'},
  {id:'padsbig',   name:'Big Pauldron',   how:'warden:1',    kind:'pads'}
];
'@

SubRx @'
outfit:'cosOutfit',scheme:'cosScheme'};
'@ @'
outfit:'cosOutfit',scheme:'cosScheme',vest:'cosVest',pads:'cosPads'};
'@

SubRx @'
outfit:'outnone',scheme:'schstd'};
'@ @'
outfit:'outnone',scheme:'schstd',vest:'vestplate',pads:'padsnone'};
'@

SubRx @'
function outfitOf(st){
'@ @'
// v28.13 (cosm4): THE VEST. drawn over the plate carrier of a body that wears one: a bandolier with brass cartridges across the chest, a
// light harness that takes the plate off and leaves cross straps, a utility vest with big front pockets and a radio on the shoulder, heavy
// plates that stand wider than the torso. W is the half width of the chest of the body build. Colours come from the scheme when it has one.
function drawVest(id,b,cx,ty,cc,sch,fl){
  var W=(b==='broad')?8.4:(b==='curved'?6.2:5.4), A=sch?sch.a:'#c8a24a', i, t, px, py, x1, y1, x2, y2, HP, py0;
  if(id==='vestband'){
    x1=cx-W+0.9; y1=ty-22.0; x2=cx+W-0.9; y2=ty-12.8;
    wc.lineCap='butt'; wc.strokeStyle=INK; wc.lineWidth=4.2; wc.beginPath(); wc.moveTo(x1,y1); wc.lineTo(x2,y2); wc.stroke();
    wc.strokeStyle='#6a5236'; wc.lineWidth=2.6; wc.beginPath(); wc.moveTo(x1,y1); wc.lineTo(x2,y2); wc.stroke();
    wc.strokeStyle='#8a6e48'; wc.lineWidth=0.8; wc.beginPath(); wc.moveTo(x1,y1-0.8); wc.lineTo(x2,y2-0.8); wc.stroke();
    for(i=0;i<5;i++){ t=0.14+i*0.18; px=x1+(x2-x1)*t; py=y1+(y2-y1)*t; wc.fillStyle=INK; wc.fillRect(px-1.3,py-1.7,2.6,3.4); wc.fillStyle='#d8b04a'; wc.fillRect(px-0.8,py-1.2,1.6,2.4); wc.fillStyle='#fff0b0'; wc.fillRect(px-0.8,py-1.2,1.6,0.7); }
    wc.fillStyle=INK; wc.fillRect(x1-0.9,y1-1.1,3.0,3.0); wc.fillStyle=A; wc.fillRect(x1-0.4,y1-0.6,2.0,2.0);
  } else if(id==='vestharn'){
    wc.fillStyle=cc; rrF(cx-W+0.4,ty-21.4,2*W-0.8,9.8,2.0);
    wc.fillStyle=litHex(cc,.2,true); wc.fillRect(cx-W+0.6,ty-21.2,2*W-1.2,1.6);
    wc.fillStyle=darkHex(cc,.34); wc.fillRect(cx-W+0.6,ty-13.4,2*W-1.2,1.4);
    wc.lineCap='butt'; wc.strokeStyle=INK; wc.lineWidth=3.0;
    wc.beginPath(); wc.moveTo(cx-W+1.2,ty-21.4); wc.lineTo(cx+W-1.2,ty-13.0); wc.moveTo(cx+W-1.2,ty-21.4); wc.lineTo(cx-W+1.2,ty-13.0); wc.stroke();
    wc.strokeStyle=darkHex(cc,.5); wc.lineWidth=1.7;
    wc.beginPath(); wc.moveTo(cx-W+1.2,ty-21.4); wc.lineTo(cx+W-1.2,ty-13.0); wc.moveTo(cx+W-1.2,ty-21.4); wc.lineTo(cx-W+1.2,ty-13.0); wc.stroke();
    wc.fillStyle=INK; wc.fillRect(cx-1.7,ty-18.5,3.4,3.4); wc.fillStyle=A; wc.fillRect(cx-1.1,ty-17.9,2.2,2.2);
    rigPouch(cx-W+0.6,ty-14.4,2.8,3.0); rigPouch(cx+W-3.4,ty-14.4,2.8,3.0);
  } else if(id==='vestutil'){
    wc.fillStyle=INK; rrF(cx-W-2.4,ty-17.4,6.6,6.6,1.6); rrF(cx+W-4.2,ty-17.4,6.6,6.6,1.6);
    wc.fillStyle='#4a4f3a'; rrF(cx-W-1.8,ty-16.9,5.4,5.6,1.2); rrF(cx+W-3.6,ty-16.9,5.4,5.6,1.2);
    wc.fillStyle='#62684c'; wc.fillRect(cx-W-1.6,ty-16.8,5.0,1.4); wc.fillRect(cx+W-3.4,ty-16.8,5.0,1.4);
    wc.fillStyle='#2e3224'; wc.fillRect(cx-W-1.6,ty-14.6,5.0,0.8); wc.fillRect(cx+W-3.4,ty-14.6,5.0,0.8);
    wc.fillStyle=A; wc.fillRect(cx-W-0.5,ty-13.6,2.8,0.9); wc.fillRect(cx+W-2.3,ty-13.6,2.8,0.9);
    px=cx-fl*(W+3.2);
    wc.fillStyle=INK; rrF(px-1.9,ty-28.4,3.8,7.2,1.2); wc.fillRect(px-0.6,ty-35.2,1.2,7.2);
    wc.fillStyle='#39414a'; rrF(px-1.3,ty-27.8,2.6,6.0,0.8); wc.fillStyle=A; wc.fillRect(px-1.1,ty-35.8,2.2,1.6);
  } else if(id==='vestheavy'){
    HP=W+2.4; py0=ty-21.8;
    wc.fillStyle=INK; rrF(cx-HP-0.9,py0-0.9,2*HP+1.8,10.6,3);
    wc.fillStyle='#46505a'; rrF(cx-HP,py0,2*HP,8.8,2.4);
    wc.fillStyle='#707b87'; rrF(cx-HP+0.6,py0,2*HP-1.2,2.6,1.5);
    wc.fillStyle='#2d343b'; wc.fillRect(cx-HP+0.6,py0+6.6,2*HP-1.2,1.6); wc.fillRect(cx-0.6,py0+2.6,1.2,4.2);
    wc.fillStyle=A; wc.fillRect(cx-HP+1.0,py0+4.4,2*HP-2.0,1.0);
    wc.fillStyle='#9aa6b2'; wc.fillRect(cx-HP+0.9,py0+1.0,0.9,0.9); wc.fillRect(cx+HP-1.8,py0+1.0,0.9,0.9);
  }
}
// v28.13 (cosm4): THE SHOULDERS. Round pads, spiked pads and one big pauldron on the shoulder away from the gun, drawn over the shoulder caps
// (the team colour stays visible as the rim). Only on a body in cloth: armour 2 and up keeps its own steel pauldrons so the tier still reads.
function drawPads(id,b,cx,ty,fl,sch){
  var sx=(b==='broad')?9.6:(b==='curved'?6.7:8.4), y0=ty-23.4, s, px, A=sch?sch.a:'#c8a24a';
  if(id==='padsround'||id==='padsspike'){
    for(s=-1;s<=1;s+=2){
      px=cx+s*(sx+1.4);
      if(id==='padsspike'){
        wc.fillStyle=INK; wc.beginPath(); wc.moveTo(px-3.4,y0+0.8); wc.lineTo(px+s*1.8,y0-8.8); wc.lineTo(px+3.4,y0+0.8); wc.closePath(); wc.fill();
        wc.fillStyle='#aab6c2'; wc.beginPath(); wc.moveTo(px-2.2,y0+0.6); wc.lineTo(px+s*1.6,y0-7.2); wc.lineTo(px+2.2,y0+0.6); wc.closePath(); wc.fill();
      }
      wc.fillStyle=INK; wc.beginPath(); wc.ellipse(px,y0+2.4,5.6,4.7,0,0,6.2832); wc.fill();
      wc.fillStyle='#4e5963'; wc.beginPath(); wc.ellipse(px,y0+2.4,4.9,4.0,0,0,6.2832); wc.fill();
      wc.fillStyle='#8896a3'; wc.beginPath(); wc.ellipse(px-0.7,y0+1.2,3.4,2.1,0,0,6.2832); wc.fill();
      wc.strokeStyle=A; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(px,y0+2.4,4.2,3.3,0,0.3,2.9); wc.stroke();
    }
  } else if(id==='padsbig'){
    px=cx-fl*(sx+2.0);
    wc.fillStyle=INK; wc.beginPath(); wc.ellipse(px,y0+2.6,7.6,6.0,0,0,6.2832); wc.fill();
    wc.fillStyle='#4a545e'; wc.beginPath(); wc.ellipse(px,y0+2.6,6.9,5.3,0,0,6.2832); wc.fill();
    wc.fillStyle='#6d7985'; wc.beginPath(); wc.ellipse(px-0.6,y0+1.4,5.6,3.4,0,0,6.2832); wc.fill();
    wc.fillStyle='#98a5b1'; wc.beginPath(); wc.ellipse(px-1.4,y0+0.4,3.4,1.5,0,0,6.2832); wc.fill();
    wc.strokeStyle='#2f363d'; wc.lineWidth=1.0; wc.beginPath(); wc.arc(px,y0+2.6,4.6,0.5,2.6); wc.stroke();
    wc.fillStyle=A; wc.fillRect(px-5.6,y0+3.4,11.2,1.3);
  }
}
function outfitOf(st){
'@

SubRx @'
drawRigPC(_BLD||'lean',x+leanX,ty,cc,_JG.c,_JG.h,!!(OUTF&&OUTF.norig),_SCH);
'@ @'
drawRigPC(_BLD||'lean',x+leanX,ty,cc,_JG.c,_JG.h,!!(OUTF&&OUTF.norig),_SCH);
  var _VID=OUTF?'vestplate':(st.hero?cosWorn('vest'):(st.vest||'vestplate'));   // v28.13 (cosm4)
  if(_PC&&_VID!=='vestplate'&&!(OUTF&&OUTF.norig)) drawVest(_VID,_BLD,x+leanX,ty,cc,_SCH,fl);
'@

SubRx @'
  // HEALING, ABOVE HER HEAD, v5.44, his note. A shrinking arc and the seconds
'@ @'
  var _PDS=OUTF?'padsnone':(st.hero?cosWorn('pads'):(st.pads||'padsnone'));   // v28.13 (cosm4)
  if(_PDS!=='padsnone'&&(st.bulk||0)<2) drawPads(_PDS,_BLD,x+leanX,ty,fl,_SCH);
  // HEALING, ABOVE HER HEAD, v5.44, his note. A shrinking arc and the seconds
'@

SubRx @'
'gloves','pack','patch','tattoo','outfit','build','scheme'];
'@ @'
'gloves','pack','patch','tattoo','outfit','build','scheme','vest','pads'];
'@

SubRx @'
build:lk.build,scheme:lk.scheme});
'@ @'
build:lk.build,scheme:lk.scheme,vest:lk.vest,pads:lk.pads});
'@

SubRx @'
build:lk.build,scheme:lk.scheme,own:g});
'@ @'
build:lk.build,scheme:lk.scheme,vest:lk.vest,pads:lk.pads,own:g});
'@

SubRx @'
'tattoo','outfit','scheme'];
'@ @'
'tattoo','outfit','scheme','vest','pads'];
'@

SubRx @'
'fit','face','tattoo','patch','scheme'].map(
'@ @'
'fit','face','tattoo','patch','scheme','vest','pads'].map(
'@

SubRx @'
['scheme','COLOUR SCHEME'],['build','BUILD']
'@ @'
['scheme','COLOUR SCHEME'],['build','BUILD'],['vest','VEST'],['pads','SHOULDERS']
'@

SubRx @'
c.kind==='scheme'||c.kind==='fit'||c.kind==='tattoo'||c.kind==='face'
'@ @'
c.kind==='vest'||c.kind==='pads'||c.kind==='scheme'||c.kind==='fit'||c.kind==='tattoo'||c.kind==='face'
'@

SubRx @'
slot==='tattoo'||slot==='scheme'){   // v10.54: outfit
'@ @'
slot==='tattoo'||slot==='scheme'||slot==='vest'||slot==='pads'){   // v10.54: outfit
'@

SubRx @'
  // v5.83: the BODY ARMOUR slot is gone with rigs.
'@ @'
  h+=slot('vest','VEST',(cosFind(cosWorn('vest'))||{name:'Plate Carrier'}).name,'\u25A4');   // v28.13 (cosm4)
  h+=slot('pads','SHOULDERS',(cosFind(cosWorn('pads'))||{name:'No Pads'}).name,'\u25D6');
  // v5.83: the BODY ARMOUR slot is gone with rigs.
'@

SubRx @'
var VER='28.12';
'@ @'
var VER='28.13';
'@

$pat = "(?m)^  now:'v28\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.13: Two new racks in FASHION: vests (bandolier, harness, utility, heavy plates) and shoulder pads (round, spiked, big pauldron). Check 28.13 fails on v28.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

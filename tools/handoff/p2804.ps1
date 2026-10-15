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

# THE COLOUR SCHEME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {id:'jersey',    name:'Number 23 Jersey', how:'level:4', kind:'fit'}
];
'@ @'
  {id:'jersey',    name:'Number 23 Jersey', how:'level:4', kind:'fit'},
  // v28.04 (cosm1), HIS ORDER (2026-10-15): "player cosmetics still need major improvements". THE COLOUR SCHEME: primary, secondary and
  // accent, worn as one preset. The ten plain clothing colours became schemes of their own (the same colour as the primary, so an old
  // save keeps its colour: cosWorn maps an old clothing id to its scheme), and nine new ones are earned. Standard Issue is the old look.
  {id:'schstd',     name:'Standard Issue', how:'always',     kind:'scheme'},
  {id:'schmoss',    name:'Moss Green',     how:'always',     kind:'scheme'},
  {id:'schrust',    name:'Rust',           how:'always',     kind:'scheme'},
  {id:'schoxblood', name:'Oxblood',        how:'always',     kind:'scheme'},
  {id:'schsand',    name:'Sand',           how:'always',     kind:'scheme'},
  {id:'schash',     name:'Ash Grey',       how:'always',     kind:'scheme'},
  {id:'schindigo',  name:'Indigo',         how:'always',     kind:'scheme'},
  {id:'schteal',    name:'Teal',           how:'always',     kind:'scheme'},
  {id:'schdrab',    name:'Olive Drab',     how:'always',     kind:'scheme'},
  {id:'schcharcoal',name:'Charcoal',       how:'always',     kind:'scheme'},
  {id:'schbone',    name:'Bone',           how:'always',     kind:'scheme'},
  {id:'schember',   name:'Ember',          how:'runs:2',     kind:'scheme'},
  {id:'schfrost',   name:'Frost',          how:'runs:4',     kind:'scheme'},
  {id:'schverdant', name:'Verdant',        how:'extracts:2', kind:'scheme'},
  {id:'schcrimson', name:'Crimson',        how:'runs:12',    kind:'scheme'},
  {id:'schroyal',   name:'Royal',          how:'extracts:6', kind:'scheme'},
  {id:'schdune',    name:'Dune',           how:'level:3',    kind:'scheme'},
  {id:'schtoxic',   name:'Toxic',          how:'runs:20',    kind:'scheme'},
  {id:'schnight',   name:'Nightshade',     how:'warden:1',   kind:'scheme'},
  {id:'schgilded',  name:'Gilded',         how:'board:1',    kind:'scheme'}
];
'@

SubRx @'
outfit:'cosOutfit'};
'@ @'
outfit:'cosOutfit',scheme:'cosScheme'};
'@

SubRx @'
outfit:'outnone'};
'@ @'
outfit:'outnone',scheme:'schstd'};
'@

SubRx @'
function outfitOf(st){
'@ @'
// v28.04 (cosm1): the three colours of each preset, primary (coat, sleeves, trousers), secondary (the plate carrier, the pack, the boots)
// and accent (the trim: a band on the gun arm, a stripe on the plate, the pack flap, the boot collar). Dark ground first: the primary is
// a mid tone that holds against the dark floor, the secondary a near black of the same family, the accent the one bright note.
var SCHEMES={
  schmoss:    {p:'#5b7350',s:'#2b3326',a:'#d9c25a'},
  schrust:    {p:'#875040',s:'#2e2220',a:'#e8a03a'},
  schoxblood: {p:'#6b3448',s:'#241620',a:'#e0788c'},
  schsand:    {p:'#907c56',s:'#3a3324',a:'#ebe5cc'},
  schash:     {p:'#565a61',s:'#202226',a:'#c9d1d8'},
  schindigo:  {p:'#464f87',s:'#1c2038',a:'#9ec5ff'},
  schteal:    {p:'#31706c',s:'#14282a',a:'#5fe0c8'},
  schdrab:    {p:'#6b6b44',s:'#2a2a1c',a:'#c8d060'},
  schcharcoal:{p:'#3a3d44',s:'#16171a',a:'#ff7a3a'},
  schbone:    {p:'#b5ac93',s:'#4a4434',a:'#b8452f'},
  schember:   {p:'#a8501f',s:'#2a2224',a:'#ffb52e'},
  schfrost:   {p:'#4a7f9f',s:'#1a2733',a:'#c4f0ff'},
  schverdant: {p:'#4d8a3e',s:'#1f2a1a',a:'#e4f06a'},
  schcrimson: {p:'#a02a36',s:'#201618',a:'#ff7e6e'},
  schroyal:   {p:'#4a4fb0',s:'#1a1b30',a:'#ffd25a'},
  schdune:    {p:'#b39560',s:'#3a2f20',a:'#fff0c8'},
  schtoxic:   {p:'#2f3338',s:'#15171a',a:'#8dff2e'},
  schnight:   {p:'#7a45b0',s:'#221833',a:'#ff63c3'},
  schgilded:  {p:'#2a5a58',s:'#101c1c',a:'#ffd24a'}
};
var _SCHD={};
// The colours a body wears, or null: Standard Issue (the clothing colour as it always was), a suit, the jersey, a body with no scheme
// (the crowd, the pillagers, the Peddler). A hero reads its own rack; anyone else reads st.scheme, which came over the link.
function schemeOf(st){
  var id, S, D;
  if(!st||typeof st!=='object') return null;
  if(st.hero){ if(outfitOf(st)||cosWorn('fit')==='jersey') return null; id=cosWorn('scheme'); }
  else { if(st.outfit&&st.outfit!=='outnone') return null; id=st.scheme; }
  S=id?SCHEMES[id]:null; if(!S) return null;
  D=_SCHD[id]; if(D) return D;
  D=_SCHD[id]={id:id,p:S.p,s:S.s,a:S.a,arm:darkHex(S.p,.16),trs:darkHex(S.p,.34),plate:S.s,plateHi:litHex(S.s,.26),plateLo:darkHex(S.s,.38),
    pack:litHex(S.s,.14),boots:[S.s,litHex(S.s,.14)]};
  return D;
}
function outfitOf(st){
'@

SubRx @'
  var want=(typeof P!=='undefined'&&P)?P[COSKEY[kind]]:null;
'@ @'
  var want=(typeof P!=='undefined'&&P)?P[COSKEY[kind]]:null;
  if(kind==='scheme'&&(want===undefined||want===null)&&typeof P!=='undefined'&&P&&P.cosFit&&P.cosFit!=='slate') want='sch'+P.cosFit;   // v28.04 (cosm1): an old save keeps its colour
'@

SubRx @'
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@ @'
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
  // v28.04 (cosm1): THE SLEEVE FOLLOWS THE CLOTHES. Your own gun arm was always navy while everyone else wore their clothing colour; the hero
  // sleeve is now the clothing colour too, or the scheme primary, so the biggest shape on the body shows what you wear.
  var _SCH=schemeOf(st);
  if(_SCH) coat=_SCH.arm;
  else if(st&&st.hero&&!outfitOf(st)) coat=(FITCOL[cosWorn('fit')]||FITCOL.slate)[1];
'@

SubRx @'
  var cc=iv>0?'#2a6a5e':(OUTF?OUTF.coat:(st.hero?((FITCOL[cosWorn('fit')]||FITCOL.slate)[1]):coat)),cLo=darkHex(cc,.42),cHi=litHex(cc,.20,true);
'@ @'
  var cc=iv>0?'#2a6a5e':(OUTF?OUTF.coat:(_SCH?_SCH.p:(st.hero?((FITCOL[cosWorn('fit')]||FITCOL.slate)[1]):coat))),cLo=darkHex(cc,.42),cHi=litHex(cc,.20,true);
'@

SubRx @'
:darkHex(cc,.50);
'@ @'
:(_SCH?_SCH.trs:darkHex(cc,.50));
'@

SubRx @'
  var _BT=OUTF?OUTF.boots:(BOOTCOL[st.hero?cosWorn('boots'):(st.boots||'bootblack')]||BOOTCOL.bootblack);   // v10.54
'@ @'
  var _BT=OUTF?OUTF.boots:(BOOTCOL[st.hero?cosWorn('boots'):(st.boots||'bootblack')]||BOOTCOL.bootblack);   // v10.54
  if(_SCH&&_BT===BOOTCOL.bootblack) _BT=_SCH.boots;   // v28.04 (cosm1): boots left at the default wear the secondary
'@

SubRx @'
  if(_LSX!==1) wc.restore();   // v23.xx (spr16): end of the Broad legs
'@ @'
  if(_SCH&&!_BT[2]){ wc.fillStyle=_SCH.a; wc.fillRect(x-6.4+swing2*.5,ty-6.5-liftB,4.8,1.0); wc.fillRect(x+1.6+swing*.5,ty-6.5-liftA,4.8,1.0); }   // v28.04 (cosm1): the accent collar
  if(_LSX!==1) wc.restore();   // v23.xx (spr16): end of the Broad legs
'@

SubRx @'
  wc.fillStyle=PACKCOL[st.hero?cosWorn('pack'):(st.pack||'packbrown')]||PACKCOL.packbrown;   // v10.34
  rrF(x-fl*9-pw/2+leanX,ty-21,pw,9,2);
'@ @'
  var _PKC=PACKCOL[st.hero?cosWorn('pack'):(st.pack||'packbrown')]||PACKCOL.packbrown;   // v10.34
  if(_SCH&&_PKC===PACKCOL.packbrown) _PKC=_SCH.pack;   // v28.04 (cosm1): a pack left at the default wears the secondary
  wc.fillStyle=_PKC;
  rrF(x-fl*9-pw/2+leanX,ty-21,pw,9,2);
  if(_SCH){ wc.fillStyle=_SCH.a; wc.fillRect(x-fl*9-pw/2+leanX+0.6,ty-20.4,pw-1.2,1.2); }   // v28.04 (cosm1): the accent flap
'@

SubRx @'
drawRigPC(_BLD||'lean',x+leanX,ty,cc,_JG.c,_JG.h,!!(OUTF&&OUTF.norig));
'@ @'
drawRigPC(_BLD||'lean',x+leanX,ty,cc,_JG.c,_JG.h,!!(OUTF&&OUTF.norig),_SCH);
'@

SubRx @'
function drawRigPC(b,cx,ty,cc,jc,jh,norig){
'@ @'
function drawRigPC(b,cx,ty,cc,jc,jh,norig,sch){
'@

SubRx @'
  wc.save(); torsoPathPC(b,cx,ty,jh); wc.clip();
'@ @'
  if(sch){ rg=sch.plate; rgHi=sch.plateHi; rgLo=sch.plateLo; }   // v28.04 (cosm1): the carrier is the secondary
  wc.save(); torsoPathPC(b,cx,ty,jh); wc.clip();
'@

SubRx @'
wc.fillRect(cx-R.w/2,ty+R.y,0.6,R.h-0.6);
'@ @'
wc.fillRect(cx-R.w/2,ty+R.y,0.6,R.h-0.6);
    if(sch){ wc.fillStyle=sch.a; wc.fillRect(cx-R.w/2+0.9,ty+R.y+1.4,R.w-2.4,0.9); }   // v28.04 (cosm1): the accent stripe across the plate
'@

SubRx @'
wc.fillStyle=RIG_BUCKLE; wc.fillRect(cx-0.8,ty-15.5,1.6,1.3);
'@ @'
wc.fillStyle=RIG_BUCKLE; wc.fillRect(cx-0.8,ty-15.5,1.6,1.3);
    if(sch){ wc.fillStyle=sch.a; wc.fillRect(cx-6.5,ty-15.5,13,0.8); }   // v28.04 (cosm1): her belt in the accent
'@

SubRx @'
  wc.fillStyle=INK; wc.fillRect(gx-0.5,-0.1,4.4,4.4); wc.fillStyle=hc; wc.fillRect(gx,0.4,3.4,3.4);
'@ @'
  var _sc=schemeOf(st);
  if(_sc){ wc.fillStyle=INK; wc.fillRect(gx-3.4,-aw-0.2,2.8,2*aw+0.4); wc.fillStyle=_sc.a; wc.fillRect(gx-3.0,-aw,2.0,2*aw); }   // v28.04 (cosm1): the accent cuff, the biggest trim on the body
  wc.fillStyle=INK; wc.fillRect(gx-0.5,-0.1,4.4,4.4); wc.fillStyle=hc; wc.fillRect(gx,0.4,3.4,3.4);
'@

SubRx @'
'gloves','pack','patch','tattoo','outfit','build'];
'@ @'
'gloves','pack','patch','tattoo','outfit','build','scheme'];
'@

SubRx @'
tattoo:lk.tattoo,outfit:lk.outfit,build:lk.build});
'@ @'
tattoo:lk.tattoo,outfit:lk.outfit,build:lk.build,scheme:lk.scheme});
'@

SubRx @'
tattoo:lk.tattoo,outfit:lk.outfit,build:lk.build,own:g});
'@ @'
tattoo:lk.tattoo,outfit:lk.outfit,build:lk.build,scheme:lk.scheme,own:g});
'@

SubRx @'
'tattoo','outfit'];
'@ @'
'tattoo','outfit','scheme'];
'@

SubRx @'
'fit','face','tattoo','patch'].map(
'@ @'
'fit','face','tattoo','patch','scheme'].map(
'@

SubRx @'
var GROUPS=[['outfit','OUTFIT'],['build','BUILD']
'@ @'
var GROUPS=[['outfit','OUTFIT'],['scheme','COLOUR SCHEME'],['build','BUILD']
'@

SubRx @'
COSMETICS.filter(function(c){ return c.kind===g[0]; }).forEach(function(c){
'@ @'
COSMETICS.filter(function(c){ return c.kind===g[0]&&!(c.kind==='fit'&&c.id!=='jersey'); }).forEach(function(c){   // v28.04 (cosm1): the plain clothing colours are schemes now; only the jersey stays in CLOTHING
'@

SubRx @'
      P[COSKEY[kind]||'cosHat']=id;
'@ @'
      P[COSKEY[kind]||'cosHat']=id;
      if(kind==='scheme'&&P.cosFit&&P.cosFit!=='slate') P.cosFit='slate';   // v28.04 (cosm1): a scheme is the clothes, so an older clothing colour or the jersey steps aside
'@

SubRx @'
if(c.kind==='fit'||c.kind==='tattoo'||c.kind==='face'
'@ @'
if(c.kind==='scheme'||c.kind==='fit'||c.kind==='tattoo'||c.kind==='face'
'@

SubRx @'
slot==='tattoo'){   // v10.54: outfit
'@ @'
slot==='tattoo'||slot==='scheme'){   // v10.54: outfit
'@

SubRx @'
  h+=slot('fit','CLOTHING',(cosFind(cosWorn('fit'))||{name:'Slate'}).name,
          '<span style="width:14px;height:14px;border-radius:3px;display:inline-block;background:'+ft[1]+'"></span>');
'@ @'
  h+=slot('scheme','COLOURS',(cosFind(cosWorn('scheme'))||{name:'Standard Issue'}).name,   // v28.04 (cosm1): the colour scheme replaces the clothing slot
          '<span style="display:inline-flex;gap:1px">'+(function(){ var _d=schemeOf({hero:1}), _c=_d?[_d.p,_d.s,_d.a]:[ft[1],ft[0],'#8a96a1']; return _c.map(function(c){ return '<i style="display:block;width:5px;height:14px;background:'+c+'"></i>'; }).join(''); })()+'</span>');
'@

SubRx @'
var VER='28.03';
'@ @'
var VER='28.04';
'@

$pat = "(?m)^  now:'v28\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.04: A new COLOURS rack in FASHION: a three-colour scheme for your coat, plate, pack and trim. Check 28.04 fails on v28.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

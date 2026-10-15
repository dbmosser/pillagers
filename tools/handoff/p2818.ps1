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

# OUTFIT SETS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function cosOwned(c){
  if(!c) return false;
'@ @'
// v28.18 (cosm6), HIS ORDER (2026-10-15): "outfit sets: a handful of complete looks built from the layers". A SET is five or six pieces worn in one
// click: the scheme, the headgear, the vest, the shoulders, the pack, the boots and the gloves. It keeps your face, hair, skin and build. A set
// is owned when every piece in it is owned, and a locked set names the first piece you still need and how to earn it. They are not on the worn
// list (nothing reads a set once it is on): wearing one writes its pieces to the racks, and you change any piece after.
var COSSETS=[
  {id:'setscav',  name:'Scavenger', kind:'set', how:'set', parts:{scheme:'schdrab',   hat:'band',      vest:'vestplate', pads:'padsnone',  pack:'packbrown', boots:'boottan',   gloves:'glovetan'}},
  {id:'setraid',  name:'Raider',    kind:'set', how:'set', parts:{scheme:'schcrimson',hat:'tachelm',   vest:'vestband',  pads:'padsround', pack:'packblack', boots:'bootblack', gloves:'gloveblack'}},
  {id:'seteng',   name:'Engineer',  kind:'set', how:'set', parts:{scheme:'schember',  hat:'hardhat',   vest:'vestutil',  pads:'padsnone',  pack:'packradio', boots:'bootolive', gloves:'glovetan'}},
  {id:'setrecon', name:'Recon',     kind:'set', how:'set', parts:{scheme:'schverdant',hat:'boonie',    vest:'vestharn',  pads:'padsnone',  pack:'packframe', boots:'bootgaiter',gloves:'glovegrey'}},
  {id:'setheavy', name:'Heavy',     kind:'set', how:'set', parts:{scheme:'schtoxic',  hat:'heavyhelm', vest:'vestheavy', pads:'padsbig',   pack:'packfuel',  boots:'bootshin',  gloves:'gloveblack'}}
];
function setOwned(c){ var k, p; if(!c||!c.parts) return false; for(k in c.parts){ p=cosFind(c.parts[k]); if(!p||!cosOwned(p)) return false; } return true; }
function setNeed(c){ var k, p; if(!c||!c.parts) return ''; for(k in c.parts){ p=cosFind(c.parts[k]); if(p&&!cosOwned(p)) return 'needs '+p.name+': '+cosNeed(p); } return 'unlocked'; }
function setWorn(c){ var k; if(!c||!c.parts) return false; for(k in c.parts) if(cosWorn(k)!==c.parts[k]) return false; return cosWorn('outfit')==='outnone'; }
function setApply(c){ var k; if(!c||!c.parts) return false; for(k in c.parts) if(COSKEY[k]) P[COSKEY[k]]=c.parts[k]; P[COSKEY.outfit]='outnone'; return true; }
// The tile picture: your own operator with the whole set on, painted the way the one-piece previews are (measured, then painted to fill the tile).
function setPreviewURL(c){
  var key, hit, cv2, x2, keepW, keepOwned, keep={}, k, ck, q, ids={}, par=c&&c.parts, dd, up, dn, s1;
  if(!par||typeof drawOp!=='function'||typeof P==='undefined'||!P) return '';
  prevCacheGuard(); q=prevQ(); key='set:'+c.id+'|q'+q+'|'+cosLookKey(); hit=COSPREV[key]; if(hit!==undefined) return hit;
  cv2=document.createElement('canvas'); cv2.width=Math.round(128*q); cv2.height=Math.round(128*q); x2=cv2.getContext('2d');
  if(!x2) return '';
  keepW=wc; keepOwned=cosOwned;
  for(k in par){ ck=COSKEY[k]; if(ck){ keep[ck]=P[ck]; ids[par[k]]=1; } }
  keep[COSKEY.outfit]=P[COSKEY.outfit];
  try{
    wc=x2; P[COSKEY.outfit]='outnone';
    for(k in par){ ck=COSKEY[k]; if(ck) P[ck]=par[k]; }
    cosOwned=function(cc){ return (cc&&ids[cc.id])?true:keepOwned(cc); };
    cosPreviewPaint(x2,1.4,96);
    dd=prevRows(x2);
    if(dd.bot>=0&&dd.top>0&&dd.bot<127){ up=(96-dd.top)/1.4; dn=(dd.bot-96)/1.4; if(up+dn>4){ s1=Math.max(1.6,Math.min(3.6,112/(up+dn))); cosPreviewPaint(x2,s1,8+up*s1); } }
  }catch(_d){}
  finally{ wc=keepW; cosOwned=keepOwned; for(ck in keep){ if(keep[ck]===undefined) delete P[ck]; else P[ck]=keep[ck]; } }
  try{ hit=cv2.toDataURL(); }catch(_u){ hit=''; }
  COSPREV[key]=hit;
  return hit;
}
function cosOwned(c){
  if(c&&c.how==='set') return setOwned(c);   // v28.18 (cosm6)
  if(!c) return false;
'@

SubRx @'
function cosNeed(c){

'@ @'
function cosNeed(c){
  if(c&&c.how==='set') return setNeed(c);   // v28.18 (cosm6)

'@

SubRx @'
function cosFind(id){
  for(var i=0;i<COSMETICS.length;i++) if(COSMETICS[i].id===id) return COSMETICS[i];
'@ @'
function cosFind(id){
  for(var i=0;i<COSMETICS.length;i++) if(COSMETICS[i].id===id) return COSMETICS[i];
  for(i=0;i<COSSETS.length;i++) if(COSSETS[i].id===id) return COSSETS[i];   // v28.18 (cosm6)
'@

SubRx @'
function cosSwatch(c){
'@ @'
function cosSwatch(c){
  if(c.kind==='set'){   // v28.18 (cosm6): the whole set on your own operator
    var _spv=setPreviewURL(c);
    if(_spv) return '<img alt="" style="width:64px;height:64px;display:block;margin:0 auto 2px;border-radius:6px;background:rgba(0,0,0,.18)" src="'+_spv+'">';
  }
'@

SubRx @'
var GROUPS=[['outfit','OUTFIT'],
'@ @'
var GROUPS=[['set','SETS'],['outfit','OUTFIT'],
'@

SubRx @'
COSMETICS.filter(function(c){ return c.kind===g[0]&&!(c.kind==='fit'
'@ @'
(g[0]==='set'?COSSETS:COSMETICS).filter(function(c){ return c.kind===g[0]&&!(c.kind==='fit'
'@

SubRx @'
var own=cosOwned(c), on=(cosWorn(g[0])===c.id);
'@ @'
var own=cosOwned(c), on=(g[0]==='set')?setWorn(c):(cosWorn(g[0])===c.id);
'@

SubRx @'
      P[COSKEY[kind]||'cosHat']=id;
'@ @'
      if(kind==='set') setApply(c); else P[COSKEY[kind]||'cosHat']=id;   // v28.18 (cosm6): a set writes all its pieces
'@

SubRx @'
var VER='28.17';
'@ @'
var VER='28.18';
'@

$pat = "(?m)^  now:'v28\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.18: A new SETS rack in FASHION: Scavenger, Raider, Engineer, Recon and Heavy, each worn in one click. Check 28.18 fails on v28.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

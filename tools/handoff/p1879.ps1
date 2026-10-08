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

# AN OUTFIT TILE SHOWS THE OUTFIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function cosSwatch(c){
  if(c.kind==='outfit'){   // v10.54: the suit's coat, or the plain tile for your own clothes
'@ @'
// v18.79, SEEN ON THE 4K FASHION SCREENSHOT (2026-10-07): AN OUTFIT TILE SHOWS THE OUTFIT. The outfit rack showed a coloured
// square with a dot for every suit, so the Skeleton, the Machine and the Trooper all looked like the same placeholder. Each tile
// now shows your own operator wearing that outfit, painted by drawOp exactly as the YOUR OPERATOR figure is (your skin, build and
// hair), with the outfit swapped in for the one draw and everything put back after. A locked outfit is shown as well, so you can
// see what you are working toward. Painted once per look and kept (OUTPREV), so redrawing the racks costs nothing.
var OUTPREV={};
function outfitPreviewURL(id){
  var k, key, hit, cv2, x2, keepW, keepO, keepOwned;
  if(typeof drawOp!=='function'||typeof P==='undefined'||!P) return '';
  k=COSKEY.outfit;
  key=id+'|'+['skin','build','hair','cut','hat','eyes','beard','pack','boots','gloves','fit','face'].map(function(s){ try{ return cosWorn(s); }catch(_w){ return ''; } }).join(',');
  hit=OUTPREV[key]; if(hit!==undefined) return hit;
  cv2=document.createElement('canvas'); cv2.width=128; cv2.height=128; x2=cv2.getContext('2d');
  if(!x2) return '';
  keepW=wc; keepO=P[k]; keepOwned=cosOwned;
  try{
    P[k]=id; cosOwned=function(c){ return (c&&c.id===id)?true:keepOwned(c); };
    x2.translate(64,122); x2.scale(2.2,2.2); wc=x2;
    drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}});
  }catch(_d){}
  finally{ wc=keepW; cosOwned=keepOwned; if(keepO===undefined) delete P[k]; else P[k]=keepO; }
  try{ hit=cv2.toDataURL(); }catch(_u){ hit=''; }
  OUTPREV[key]=hit;
  return hit;
}
function cosSwatch(c){
  if(c.kind==='outfit'){   // v10.54: the suit's coat, or the plain tile for your own clothes
    var _opv=outfitPreviewURL(c.id);
    if(_opv) return '<img alt="" style="width:64px;height:64px;display:block;margin:0 auto 2px" src="'+_opv+'">';   // v18.79: the outfit itself
'@

SubRx @'
var VER='18.78';
'@ @'
var VER='18.79';
'@

$pat = "(?m)^  now:'v18\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.79: The FASHION outfit tiles show your operator wearing each outfit. Check 18.79 fails on v18.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

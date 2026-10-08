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

# THE OTHER FASHION RACKS SHOW THE LOOK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function cosSwatch(c){
'@ @'
// v18.82, SEEN ON THE FASHION SCREENSHOT (2026-10-07): THE OTHER RACKS SHOW THE LOOK TOO. After the outfits (v18.79), BUILD was
// three grey blocks and FACE and TATTOO were typed marks (--, /, a dot). Each of those tiles, and HAT, BEARD and HAIRSTYLE, now
// shows your own operator with that one piece swapped in, painted by drawOp like the outfits: the body pieces (build, fit,
// tattoo) as the whole figure, the head pieces (face, hat, beard, hairstyle) as a head and shoulders close-up. The figure is
// measured once per look (COSPREV box), so a click on the racks repaints them quickly; every preview is kept until the look
// changes. Colour swatches (skin, hair colour, eyes) stay as they are: a colour reads best as a colour.
var COSPREV={};
function cosLookKey(){ return ['outfit','skin','build','hair','cut','hat','eyes','beard','pack','boots','gloves','fit','face','tattoo','patch'].map(function(s){ try{ return cosWorn(s); }catch(_w){ return ''; } }).join(','); }
function cosPreviewPaint(x2,s,ty){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,128,128); x2.translate(64,ty); x2.scale(s,s); drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); }
function cosPreviewBox(cv2,x2){
  var lk=cosLookKey(), b=COSPREV['box|'+lk], dd, yy, xx, top=999, bot=-1;
  if(b) return b;
  cosPreviewPaint(x2,1.4,96);
  try{ dd=x2.getImageData(0,0,128,128).data; }catch(_g){ return {up:30,dn:2}; }
  for(yy=0;yy<128;yy++){ for(xx=0;xx<128;xx++){ if(dd[(yy*128+xx)*4+3]>40){ if(yy<top) top=yy; bot=yy; break; } } }
  b=(bot<0)?{up:30,dn:2}:{up:(96-top)/1.4,dn:Math.max(0,(bot-96)/1.4)};
  COSPREV['box|'+lk]=b;
  return b;
}
function cosPreviewURL(kind,id){
  var key, hit, cv2, x2, keepW, keepV, keepOwned, ck=COSKEY[kind], b, s, hh;
  if(!ck||typeof drawOp!=='function'||typeof P==='undefined'||!P) return '';
  key=kind+':'+id+'|'+cosLookKey(); hit=COSPREV[key]; if(hit!==undefined) return hit;
  cv2=document.createElement('canvas'); cv2.width=128; cv2.height=128; x2=cv2.getContext('2d');
  if(!x2) return '';
  keepW=wc; keepV=P[ck]; keepOwned=cosOwned;
  try{
    wc=x2;
    b=cosPreviewBox(cv2,x2);
    P[ck]=id; cosOwned=function(c){ return (c&&c.id===id)?true:keepOwned(c); };
    if(kind==='face'||kind==='hat'||kind==='beard'||kind==='cut'){
      hh=Math.max(6,(b.up+b.dn)*0.42); s=Math.max(2,Math.min(7,104/hh));
      cosPreviewPaint(x2,s,14+b.up*s);
    } else {
      s=Math.max(1.6,Math.min(3.6,112/Math.max(4,b.up+b.dn)));
      cosPreviewPaint(x2,s,8+b.up*s);
    }
  }catch(_d){}
  finally{ wc=keepW; cosOwned=keepOwned; if(keepV===undefined) delete P[ck]; else P[ck]=keepV; }
  try{ hit=cv2.toDataURL(); }catch(_u){ hit=''; }
  COSPREV[key]=hit;
  return hit;
}
function cosSwatch(c){
  if(c.kind==='fit'||c.kind==='tattoo'||c.kind==='face'||c.kind==='hat'||c.kind==='beard'||c.kind==='cut'){   // v18.82: the piece on you (not BUILD: a build is not drawn from the rack in this view, so its previews were all alike)
    var _cpv=cosPreviewURL(c.kind,c.id);
    if(_cpv) return '<img alt="" style="width:64px;height:64px;display:block;margin:0 auto 2px;border-radius:6px;background:rgba(0,0,0,.18)" src="'+_cpv+'">';
  }
'@

SubRx @'
var VER='18.81';
'@ @'
var VER='18.82';
'@

$pat = "(?m)^  now:'v18\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.82: Every FASHION piece shows what it looks like on your operator before you wear it. Check 18.82 fails on v18.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

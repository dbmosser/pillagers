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

# THE FASHION PREVIEWS ARE SHARP AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  key=id+'|'+['skin','build','hair','cut','hat','eyes','beard','pack','boots','gloves','fit','face'].map(function(s){ try{ return cosWorn(s); }catch(_w){ return ''; } }).join(',');
  hit=OUTPREV[key]; if(hit!==undefined) return hit;
  cv2=document.createElement('canvas'); cv2.width=128; cv2.height=128; x2=cv2.getContext('2d');
'@ @'
  var q=prevQ();   // v19.17: painted at the size it is shown
  key=id+'|q'+q+'|'+['skin','build','hair','cut','hat','eyes','beard','pack','boots','gloves','fit','face'].map(function(s){ try{ return cosWorn(s); }catch(_w){ return ''; } }).join(',');
  hit=OUTPREV[key]; if(hit!==undefined) return hit;
  cv2=document.createElement('canvas'); cv2.width=Math.round(128*q); cv2.height=Math.round(128*q); x2=cv2.getContext('2d');
'@

SubRx @'
var _paint=function(s,ty){ x2.setTransform(1,0,0,1,0,0);
'@ @'
var _paint=function(s,ty){ x2.setTransform(q,0,0,q,0,0);
'@

SubRx @'
      try{ dd=x2.getImageData(0,0,128,128).data; }catch(_g){ return; }
      for(yy=0;yy<128;yy++){ for(xx=0;xx<128;xx++){ if(dd[(yy*128+xx)*4+3]>40){ if(yy<top) top=yy; bot=yy; break; } } }
'@ @'
      try{ dd=prevRows(x2); }catch(_g){ return; } top=dd.top; bot=dd.bot;
'@

SubRx @'
function cosPreviewPaint(x2,s,ty){ x2.setTransform(1,0,0,1,0,0);
'@ @'
function cosPreviewPaint(x2,s,ty){ var q=x2.canvas.width/128; x2.setTransform(q,0,0,q,0,0);
'@

SubRx @'
  try{ dd=x2.getImageData(0,0,128,128).data; }catch(_g){ return {up:30,dn:2}; }
  for(yy=0;yy<128;yy++){ for(xx=0;xx<128;xx++){ if(dd[(yy*128+xx)*4+3]>40){ if(yy<top) top=yy; bot=yy; break; } } }
'@ @'
  try{ dd=prevRows(x2); }catch(_g){ return {up:30,dn:2}; } top=dd.top; bot=dd.bot;
'@

SubRx @'
  key=kind+':'+id+'|'+cosLookKey(); hit=COSPREV[key]; if(hit!==undefined) return hit;
  cv2=document.createElement('canvas'); cv2.width=128; cv2.height=128; x2=cv2.getContext('2d');
'@ @'
  var q=prevQ();   // v19.17: painted at the size it is shown
  key=kind+':'+id+'|q'+q+'|'+cosLookKey(); hit=COSPREV[key]; if(hit!==undefined) return hit;
  cv2=document.createElement('canvas'); cv2.width=Math.round(128*q); cv2.height=Math.round(128*q); x2=cv2.getContext('2d');
'@

SubRx @'
function cosLookKey(){ return ['outfit','skin','build','hair','cut','hat','eyes','beard','pack','boots','gloves','fit','face','tattoo','patch'].map(function(s){ try{ return cosWorn(s); }catch(_w){ return ''; } }).join(','); }
'@ @'
function cosLookKey(){ return ['outfit','skin','build','hair','cut','hat','eyes','beard','pack','boots','gloves','fit','face','tattoo','patch'].map(function(s){ try{ return cosWorn(s); }catch(_w){ return ''; } }).join(','); }
// v19.17, from the review (2026-10-07): the previews were painted at 128 pixels and shown 64 wide under the menu zoom, about 158 screen
// pixels at 4K and up to 267 at the biggest menu size, so they came out soft beside the stash icons. They are now painted at the size
// they are shown (in quarter steps, at most three times), still laid out on the same 128 grid, so nothing moves; at 1080p nothing changes.
function prevQ(){ var z=1, d=1, q; try{ z=menuScale(); }catch(_z){} try{ d=window.devicePixelRatio||1; }catch(_d){} q=Math.ceil(64*z*d/128*4)/4; return (q>1)?Math.min(3,q):1; }
// The rows a preview canvas has paint in, in its 128 grid, whatever size it is painted at.
function prevRows(x2){ var c=x2.canvas, w=c.width, h=c.height, q=w/128, dd=x2.getImageData(0,0,w,h).data, yy, xx, top=999, bot=-1;
  for(yy=0;yy<h;yy++){ for(xx=0;xx<w;xx++){ if(dd[(yy*w+xx)*4+3]>40){ if(yy<top) top=yy; bot=yy; break; } } }
  return (bot<0)?{top:999,bot:-1}:{top:Math.floor(top/q),bot:Math.floor(bot/q)}; }
'@

SubRx @'
var VER='19.16';
'@ @'
var VER='19.17';
'@

$pat = "(?m)^  now:'v19\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.17: FASHION pictures are crisp on a 4K screen. Check 19.17 fails on v19.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

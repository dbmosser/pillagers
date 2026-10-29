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

# CACHE NAMES CLEAR THE SCREEN EDGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(CACHETAGS.length<48) CACHETAGS.push({t:ct.tag,x:ct.x,y:ct.y-lift-d2-26});
'@ @'
      if(CACHETAGS.length<48) CACHETAGS.push({t:ct.tag,x:ct.x,y:ct.y-lift-d2-26,cache:1}); // v28.xx (cw-cx-cachetagspace): a named cache gets the shared panel and screen margin.
'@

SubRx @'
      var _cm=wc.measureText(_cg.t), _cw=_cm.width, _ca=_cm.actualBoundingBoxAscent||wlPx(), _cd=_cm.actualBoundingBoxDescent||wlPx()*0.25;
      if(!_cg.always&&wlUnder(_cg.x-_cw/2,_cg.y-_ca-2,_cw,_ca+_cd+4)) continue;
      var _ctop=wlTagPlace(_cg.x-_cw/2-2,_cg.y-_ca-2,_cw+4,_ca+_cd+4);
      if(_ctop===null) continue;
      var _cy=_ctop+_ca+2;
      wc.fillStyle=INK; wc.fillText(_cg.t,_cg.x+1,_cy+1); wc.fillStyle=_cg.c||'#e6b4ff'; wc.fillText(_cg.t,_cg.x,_cy);
'@ @'
      // v28.xx (cw-cx-cachetagspace): the critic on the fixed overlap found the cache name too close to the edge and weak on busy ground. Keep its own panel, distinct from the extraction destination.
      var _cm=wc.measureText(_cg.t), _cw=_cm.width, _ca=_cm.actualBoundingBoxAscent||wlPx(), _cd=_cm.actualBoundingBoxDescent||wlPx()*0.25;
      var _cp=_cg.cache?8:2, _cx=_cg.x, _ch=_ca+_cd+_cp*2;
      if(_cg.cache){var _margin=24*Math.max(1,hudRes())/WTX.z;_cx=clamp(_cx,WTX.ox+_margin+_cw/2+_cp,WTX.ox+W/WTX.z-_margin-_cw/2-_cp);}
      if(!_cg.always&&wlUnder(_cx-_cw/2-_cp,_cg.y-_ca-_cp,_cw+_cp*2,_ch)) continue;
      var _ctop=wlTagPlace(_cx-_cw/2-_cp,_cg.y-_ca-_cp,_cw+_cp*2,_ch);
      if(_ctop===null) continue;
      var _cy=_ctop+_ca+_cp;
      if(_cg.cache) uiPanel(wc,_cx-_cw/2-_cp,_ctop,_cw+_cp*2,_ch,null);
      wc.fillStyle=INK; wc.fillText(_cg.t,_cx+1,_cy+1); wc.fillStyle=_cg.cache?UIC.tx_1:(_cg.c||'#e6b4ff'); wc.fillText(_cg.t,_cx,_cy);
'@

SubRx @'
var VER='36.12';
'@ @'
var VER='36.13';
'@

$pat = "(?m)^  now:'v36\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.13: Cache names sit on a readable panel inside the screen margin. The extraction chip still keeps its own space. Check 36.13 fails on v36.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

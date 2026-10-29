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

# ADS STATION LABELS STAY WHOLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(CACHETAGS.length<48) CACHETAGS.push({t:SW.done?'seal broken':('the seal  '+Math.round(pctW*100)+'%'),x:swx,y:swy-60,f:TYPE.label,c:SW.done?'#ffc04a':'#8fd0ff',always:1});
'@ @'
    if(CACHETAGS.length<48) CACHETAGS.push({station:1,t:SW.done?'seal broken':('the seal  '+Math.round(pctW*100)+'%'),x:swx,y:swy-60,f:TYPE.label,c:SW.done?'#ffc04a':'#8fd0ff',always:1});
'@

SubRx @'
    if(!G.nearForge&&CACHETAGS.length<48) CACHETAGS.push({t:F.name||'the forge',x:fx,y:fy-84,f:TYPE.label,c:FORGE_GOLD});
'@ @'
    if(!G.nearForge&&CACHETAGS.length<48) CACHETAGS.push({station:1,t:F.name||'the forge',x:fx,y:fy-84,f:TYPE.label,c:FORGE_GOLD});
'@

SubRx @'
      if(_cg.cache){var _margin=24*Math.max(1,hudRes())/WTX.z;_cx=clamp(_cx,WTX.ox+_margin+_cw/2+_cp,WTX.ox+W/WTX.z-_margin-_cw/2-_cp);}
'@ @'
      // v28.xx (cw-cx-adsstationtags): the ADS critic found half a forge/seal name at the edge. Use the existing cache margin for these station names, without pulling wholly offscreen names into view.
      if(_cg.station&&((_cx+_cw/2+_cp-WTX.ox)*WTX.z<0||(_cx-_cw/2-_cp-WTX.ox)*WTX.z>W)) continue;
      if(_cg.cache||_cg.station){var _margin=24*Math.max(1,hudRes())/WTX.z;_cx=clamp(_cx,WTX.ox+_margin+_cw/2+_cp,WTX.ox+W/WTX.z-_margin-_cw/2-_cp);}
'@

SubRx @'
      if(_cg.cache) uiPanel(wc,_cx-_cw/2-_cp,_ctop,_cw+_cp*2,_ch,null);
'@ @'
      if(_cg.cache||_cg.station) uiPanel(wc,_cx-_cw/2-_cp,_ctop,_cw+_cp*2,_ch,null); // v28.xx (cw-cx-adsstationtags): the existing shared plate keeps station text readable on bright ground.
'@

SubRx @'
var VER='36.29';
'@ @'
var VER='36.30';
'@

$pat = "(?m)^  now:'v36\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.30: forge and seal names stay whole at the edge while aiming Check 36.30 fails on v36.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

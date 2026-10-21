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

# RAID START LABEL BACKING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.font=L.font; ctx.fillStyle=L.fs; ctx.textAlign=L.ta; ctx.textBaseline=L.tb; ctx.globalAlpha=L.ga;
'@ @'
    ctx.font=L.font; ctx.fillStyle=L.fs; ctx.textAlign=L.ta; ctx.textBaseline=L.tb; ctx.globalAlpha=L.ga;
    // v28.xx (cw-cx-mapstart-plates): critic P1, preserve every label and separate it from map linework with 4px side padding.
    if(mapFirstOn()){
      var plate=mapLabelRect(L,g.dx,g.dy);
      ctx.save(); ctx.setTransform(1,0,0,1,0,0); ctx.fillStyle='rgba(11,12,13,.8)';
      ctx.fillRect(plate.l-4*_mz,plate.t-3*_mz,plate.r-plate.l+8*_mz,plate.b-plate.t+6*_mz); ctx.restore();
    }
'@

SubRx @'
      ctx.font=nameFont; ctx.fillStyle=row.done?UIC.ok:UIC.tx_2; ctx.textAlign='left'; ctx.fillText(mapFit(row.name,maxW),c.x+q,mid);
'@ @'
      ctx.font=nameFont; ctx.fillStyle=row.done?UIC.ok:(mapFirstOn()?UIC.tx_1:UIC.tx_2); ctx.textAlign='left'; ctx.fillText(mapFit(row.name,maxW),c.x+q,mid);
      if(mapFirstOn()&&row.rule==='holding'){ ctx.fillStyle=UIC.ok; ctx.fillRect(c.x+Math.round(8*z),ry+Math.round(12*z),Math.max(1,Math.round(3*z)),pitch-Math.round(24*z)); }   // v28.xx (cw-cx-mapstart-plates): a status mark, with no invented selection or new control.
'@

SubRx @'
    ctx.font=nameFont; ctx.fillStyle=UIC.tx_1; ctx.fillText('contracts',c.x+q,c.y+th/2);
'@ @'
    ctx.font=mapFirstOn()?FSz('700 24.6px '+HUDF,z):nameFont; ctx.fillStyle=UIC.tx_1; ctx.fillText('contracts',c.x+q,c.y+th/2);   // v28.xx (cw-cx-mapstart-plates): the panel heading uses the 32px title role.
'@

SubRx @'
    if(nm){ ctx.font=FSz('500 15.4px '+HUDF,z); ctx.fillStyle=UIC.tx_2; ctx.fillText('SECTOR MAP',hx,_tby); hx+=hudRawW('SECTOR MAP')+Math.round(24*u); }  ctx.textBaseline='middle';
'@ @'
    if(nm){ ctx.font=mapFirstOn()?('600 '+(16*z)+'px '+HUDF):FSz('500 15.4px '+HUDF,z); ctx.fillStyle=UIC.tx_2; ctx.fillText('SECTOR MAP',hx,_tby); hx+=hudRawW('SECTOR MAP')+Math.round(24*u); }  ctx.textBaseline='middle';
'@

SubRx @'
    ctx.font=FSz('600 15.4px '+HUDF,z); ctx.textAlign='right'; ctx.fillStyle=(wx().id==='clear')?UIC.tx_2:UIC.tx_1; ctx.fillText(wxs,xb.x-Math.round(24*u),hy); ctx.textAlign='left';
'@ @'
    ctx.font=mapFirstOn()?('600 '+(16*z)+'px '+HUDF):FSz('600 15.4px '+HUDF,z); ctx.textAlign='right'; ctx.fillStyle=(mapFirstOn()||wx().id==='clear')?UIC.tx_2:UIC.tx_1; if(mapFirstOn())ctx.textBaseline='alphabetic'; ctx.fillText(wxs,xb.x-Math.round(24*u),mapFirstOn()?_tby:hy); ctx.textAlign='left'; ctx.textBaseline='middle';
'@

SubRx @'
var VER='33.54';
'@ @'
var VER='33.55';
'@

$pat = "(?m)^  now:'v33\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.55: Raid-start map labels have dark backing. Contract names and holding states are clearer. Check 33.55 fails on v33.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# RAID HUD PANELS SHARE ONE FILL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
plate:'rgba(6,9,13,.78)'
'@ @'
plate:'rgba(17,19,21,.88)'/* v28.xx (cw-hudpanels), the critic on screens 21, 19, 37, 61: 'panel styles disagree'. One HUD panel fill, the graphite of hudPanel at 88 percent (was blue-black at 78) */
'@

SubRx @'
hudPlate(x,y,w,h,null,'rgba(11,12,13,.9)'); hudPlate(x,y,w,h,o.col,HUDC.plate);
'@ @'
hudPlate(x,y,w,h,null,HUDC.plate); hudPlate(x,y,w,h,o.col,HUDC.plate);
'@

SubRx @'
hudPlate(xR-sz.w,yB-sz.h,sz.w,sz.h,null,'rgba(11,12,13,.9)')
'@ @'
hudPlate(xR-sz.w,yB-sz.h,sz.w,sz.h,null,HUDC.plate)
'@

SubRx @'
hudPlate(bx,by,tw,ph,null,'rgba(11,12,13,.9)')
'@ @'
hudPlate(bx,by,tw,ph,null,HUDC.plate)
'@

SubRx @'
h+_uh,0.78,1)
'@ @'
h+_uh,0.88,1)
'@

SubRx @'
hudPanel(18,by-_up-LH(18),_pw+14,LH(16),0.78,1)
'@ @'
hudPanel(18,by-_up-LH(18),_pw+14,LH(16),0.88,1)
'@

SubRx @'
hudPanel(_wpx,by-_gtop,_wpw,_gh,0.62)
'@ @'
hudPanel(_wpx,by-_gtop,_wpw,_gh,0.88)
'@

SubRx @'
var VER='34.23';
'@ @'
var VER='34.24';
'@

$pat = "(?m)^  now:'v34\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.24: The boxes on the raid HUD are all the same dark graphite, a little more solid than before. Check 34.24 fails on v34.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

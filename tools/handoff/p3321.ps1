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

# EXPERIMENTAL CHOICES HOLD FOR THE RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function xfSnap(){ var i, k; XF={}; for(i=0;i<XF_WORLD.length;i++){ k=XF_WORLD[i]; XF[k]=(CFG&&CFG[k]===0)?0:1; } return XF; }
'@ @'
// v28.xx (cw-cx-expsnap): job 61 says switches are read once at raid start and the host rules in both windows. Include the four formerly local keys.
function xfSnap(){ var i, k; XF={}; for(i=0;i<XF_KEYS.length;i++){ k=XF_KEYS[i]; XF[k]=(CFG&&CFG[k]===0)?0:1; } return XF; }
'@

SubRx @'
function xfL(k){ return !(CFG&&CFG[k]===0); }            // a LOCAL switch, this window, now
'@ @'
// v28.xx (cw-cx-expsnap): a guest restores its own CFG after netUpStart, so raid-time local calls must read the host snapshot too. Outside a raid the shop and party-seed controls act on the next run.
function xfL(k){ return (typeof G!=='undefined'&&G&&!G.sim&&!G.over)?xf(k):!(CFG&&CFG[k]===0); }
'@

SubRx @'
  if(!xfL('xfHaul')) return 0;   // v32.xx (cw-expmenu6): switched off, the haul on the extracted card shows at once
'@ @'
  if(!xf('xfHaul')) return 0;   // v28.xx (cw-cx-expsnap): the result card keeps this raid choice after G.over, including the host choice for a linked window
'@

SubRx @'
// built, never from CFG during a raid: a change made mid raid starts with the next raid. A LOCAL switch ('l') is read live from CFG. A row is listed only when
'@ @'
// v28.xx (cw-cx-expsnap): all keys are snapshotted; changes made mid raid start with the next raid. The shop and party seed read CFG outside a raid. A row is listed only when
'@

SubRx @'
  if(!xfL('xfNeed')){ G.need={}; G.needN=0; return 0; }   // v32.xx (cw-expmenu6): switched off, no box glows for a contract (read live, this window)
'@ @'
  if(!xfL('xfNeed')){ G.need={}; G.needN=0; return 0; }   // v28.xx (cw-cx-expsnap): needed-item glow uses this raid snapshot, including the host choice
'@

SubRx @'
var VER='33.20';
'@ @'
var VER='33.21';
'@

$pat = "(?m)^  now:'v33\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.21: Experimental choices hold for the whole raid. Both windows use the host choices, including needed-item glow and the result haul. Check 33.21 fails on v33.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

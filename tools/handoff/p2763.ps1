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

# HELD AIM LET GO ON A FOCUS CHANGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  keys={}; try{ HHOLD.arm=0; }catch(_hh){} mouse.down=false; if(G) G.sprinting=false; if(G&&CFG.crouchHold===1) G.crouchTog=false; /* v26.xx (settings2): a held crouch is let go with the keys */ if(G) G.wheel=null; /* v26.xx (wheel2) */
'@ @'
  keys={}; try{ HHOLD.arm=0; }catch(_hh){} mouse.down=false; if(G) G.sprinting=false; if(G&&CFG.crouchHold===1) G.crouchTog=false; /* v26.xx (settings2): a held crouch is let go with the keys */ if(G) G.wheel=null; /* v26.xx (wheel2) */
  if(G&&G.player&&CFG.aimTgl!==1) G.player.ads=false;   // v27.63 (cloud-menus-held-aim-blur), CLOUD HUNT 2026-10-15: with AIM on HOLD a right button held when the window lost focus never sends its mouseup here, so the aim (slow walk) stayed on until the next right click; a toggled aim stays
'@

SubRx @'
var VER='27.62';
'@ @'
var VER='27.63';
'@

$pat = "(?m)^  now:'v27\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.63: A held aim is let go when the window loses focus, like the other held keys. Check 27.63 fails on v27.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

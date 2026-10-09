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

# THE RAID NO LONGER FREEZES WHEN THE HOST LEAVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(_i=G.ents.length-1;_i>=0;_i--){ _e=G.ents[_i]; if(_e&&_e.net){ if(_e.name===BOSS_NAME) _boss=_e; G.ents.splice(_i,1); } }
'@ @'
  for(_i=G.ents.length-1;_i>=0;_i--){ _e=G.ents[_i]; if(_e&&_e.net){ if(_e.name===BOSS_NAME) _boss=_e; G.ents.splice(_i,1); } }
  // v21.69, from the whole-game bug hunt of 2026-10-08 (K1): A PILLAGER LAST SEEN AT A BOX LOOKS FOR A REAL ONE. To draw the crouch,
  // this window gave a pillager the host showed crouched at a box himself as the box (and a man reviving a friend himself as the
  // friend). At the takeover he kept that stand-in, searched himself for up to two seconds, and then the game threw an error on
  // every frame, so the raid froze for the remaining player. The stand-ins go now, and he picks a real box on a fresh search.
  for(_i=0;_i<G.ents.length;_i++){ _e=G.ents[_i]; if(!_e) continue; if(_e.goal===_e){ _e.goal=null; _e.lootT=0; } if(_e.reviving===_e) _e.reviving=null; }
'@

SubRx @'
var VER='21.68';
'@ @'
var VER='21.69';
'@

$pat = "(?m)^  now:'v21\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.69: In co-op, the raid no longer freezes a moment after the host leaves. Check 21.69 fails on v21.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# GUNFIRE ENDS SPRINT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    G.player.recoil=1; G.player.combatT=0; G.tel.shots+=shots;
'@ @'
    // v28.xx (cw-cx-shotendssprint): his 10-28 decision: "ends your sprint period". A held key must be released; a toggle needs another press. Melee returned above.
    G.player.shotSprintRelease=!!(keys['ShiftLeft']||keys['ShiftRight']); G.sprintOn=false; G.sprinting=false;
    G.player.recoil=1; G.player.combatT=0; G.tel.shots+=shots;
'@

SubRx @'
  var _shHeld=!!(keys['ShiftLeft']||keys['ShiftRight']);
'@ @'
  var _shHeld=!!(keys['ShiftLeft']||keys['ShiftRight']);
  // v28.xx (cw-cx-shotendssprint): releasing the physical sprint input permits a fresh sprint after a gunshot; time alone never does.
  if(!_shHeld) p.shotSprintRelease=false;
'@

SubRx @'
  } else { G.sprintOn=false; G.shWas=_shHeld; }
'@ @'
  } else { G.sprintOn=false; G.shWas=_shHeld; }
  // v28.xx (cw-cx-shotendssprint): apply the shot latch before crouch, scent, movement and stamina read the sprint request.
  if(p.shotSprintRelease){ G.sprintOn=false; _shHeld=false; }
'@

SubRx @'
var VER='35.85';
'@ @'
var VER='35.86';
'@

$pat = "(?m)^  now:'v35\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.86: A fired gunshot ends sprint until a fresh sprint press, in both windows and on keys or pad. Melee and a trigger that fires no round keep sprint. Check 35.86 fails on v35.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

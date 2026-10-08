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

# WHEN THE HOST LEAVES, THE MAP KEEPS ITS ENEMIES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _i, _e, _boss=null, _b;
'@ @'
  var _i, _e, _boss=null, _b, _k;
'@

SubRx @'
  for(_i=G.ents.length-1;_i>=0;_i--){ _e=G.ents[_i]; if(_e&&_e.net){ if(_e.name===BOSS_NAME) _boss=_e; G.ents.splice(_i,1); } }
'@ @'
  // v20.32, from the whole-game bug hunt of 2026-10-08 (H25): AND THE BODIES FAR FROM THE PLAYERS COME BACK. The host sends rows
  // only for bodies near a player, and this window takes a body with no row for 3 seconds off the map (it stays known), so at the
  // takeover most of the map was empty, and THE OVERSEER, out of range in its lair, was marked done and never came. Every body
  // built here that is still known goes back on the map where it was last placed, and an Overseer the host made is remade at its
  // health wherever it was.
  if(NET.entMap) for(_k in NET.entMap){
    if(!Object.prototype.hasOwnProperty.call(NET.entMap,_k)) continue;
    _e=NET.entMap[_k]; if(!_e||_e.nIn) continue;
    if(_e.net){ if(_e.name===BOSS_NAME&&!_boss) _boss=_e; continue; }
    if(!(_e.hp<=0)){ _e.nIn=1; G.ents.push(_e); }
  }
  for(_i=G.ents.length-1;_i>=0;_i--){ _e=G.ents[_i]; if(_e&&_e.net){ if(_e.name===BOSS_NAME) _boss=_e; G.ents.splice(_i,1); } }
'@

SubRx @'
var VER='20.31';
'@ @'
var VER='20.32';
'@

$pat = "(?m)^  now:'v20\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.32: In co-op, when the host leaves, the rest of the map keeps its enemies and THE OVERSEER. Check 20.32 fails on v20.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

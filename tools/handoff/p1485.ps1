$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  for(i=0;i<(P.kit||[]).length;i++) have[P.kit[i]]=1;
  for(k in P.hotAssign) if(!have[P.hotAssign[k]]) delete P.hotAssign[k];
'@ @'
  for(i=0;i<(P.kit||[]).length;i++) have[P.kit[i]]=1;
  // v14.85, belt audit finding 2: A KEY ON A GUN IN HIS HANDS IS A LIVE KEY. rackPut binds a key to gun 1 or gun 2 and leaves
  // the gun on the rack, so it is in neither the stash nor the kit, and every extraction and every MY LOADOUT after the
  // freebie kit deleted the key he had set. The two equipped guns count as held.
  if(P.equipped&&P.equipped!=='fists') have['gun_'+P.equipped]=1;
  if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists') have['gun_'+P.equippedSec]=1;
  for(k in P.hotAssign) if(!have[P.hotAssign[k]]) delete P.hotAssign[k];
'@
SubRx @'
var VER='14.84';
'@ @'
var VER='14.85';
'@

$pat = "(?m)^  now:'v14\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.85: A BELT KEY ON A GUN IN HIS HANDS SURVIVES AN EXTRACTION. A key bound to gun 1 or gun 2 from the rack points at a gun that is in neither the stash nor the kit, so the dead key sweep after every extraction and after MY LOADOUT deleted it. The two equipped guns now count as held. Check 14.85 sweeps with a key on the equipped SMG and a key on an item held nowhere; it fails on v14.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

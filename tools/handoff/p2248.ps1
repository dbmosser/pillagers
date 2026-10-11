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

# A GUN CARRIED OUT KEEPS ITS SLOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(_d3[0]&&P.weapons.indexOf(_d3[0])>=0){ if(P.equippedSec===_d3[0]) P.equippedSec='none'; P.equipped=_d3[0]; }
    if(_d3[1]&&_d3[1]!==P.equipped&&P.weapons.indexOf(_d3[1])>=0) P.equippedSec=_d3[1];
'@ @'
    var _d3o=P.equipped;
    if(_d3[0]&&P.weapons.indexOf(_d3[0])>=0){ if(P.equippedSec===_d3[0]) P.equippedSec='none'; P.equipped=_d3[0]; }
    if(_d3[1]&&_d3[1]!==P.equipped&&P.weapons.indexOf(_d3[1])>=0) P.equippedSec=_d3[1];
    // v22.48, from the review of build 4: D3 NEVER UNSLOTS A GUN HE CARRIED OUT. With the SMG on key 1 and the Longshot moved to key 3
    // (or a Medkit on key 2), key 2 showed no gun: the tier sort made the Longshot gun 1 and the SMG gun 2, then D3 put the SMG in gun 1,
    // emptied gun 2 and nothing refilled it. He came home with the SMG and Bare Hands, the Longshot in the armoury in no slot, and the
    // extraction then deleted his key 3 for it. The gun D3 moved out of gun 1 now takes gun 2 when gun 2 is empty, as long as it is a
    // gun he carried out (never the freebie kit pistol, which the list already leaves out), the v12.38 rule.
    if(_d3o&&_d3o!==P.equipped&&_d3o!=='fists'&&((P.equippedSec||'none')==='none'||P.equippedSec==='fists')&&P.weapons.indexOf(_d3o)>=0){
      for(var _d3j=0;_d3j<_keq.length;_d3j++) if(_keq[_d3j].id===_d3o){ P.equippedSec=_d3o; break; }
    }
'@

SubRx @'
var VER='22.47';
'@ @'
var VER='22.48';
'@

$pat = "(?m)^  now:'v22\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.48: After an extraction a gun he carried out is never left in no slot, even when key 2 showed no gun. Check 22.48 fails on v22.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

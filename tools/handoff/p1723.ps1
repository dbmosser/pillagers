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

# AN ARMOURY GUN THE HOST DROPPED IS NO LONGER IN BOTH SAVES WHEN A TEAMMATE PICKS IT UP AFTER THE HOST ABANDONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netGunsGone(ct,items){
  var i, it, j, n=0;
'@ @'
function netGunsGone(ct,items){
  var i, it, j, n=0, back=0;
'@

SubRx @'
    if(P&&Array.isArray(P.raidSpliced)){ j=P.raidSpliced.indexOf(it.gk); if(j>=0) P.raidSpliced.splice(j,1); }
  }
  if(n) saveProfile();
'@ @'
    if(P&&Array.isArray(P.raidSpliced)){ j=P.raidSpliced.indexOf(it.gk); if(j>=0) P.raidSpliced.splice(j,1); }
    // v17.23, co-op hunt 2026-09-28: AND OUT OF HIS ARMOURY WHEN HE HAS ALREADY ABANDONED. His party still up top keeps the raid
    // running after his abandon (netSpecStart), and the abandon (and the instant quit) has already put every id on the list back in
    // his armoury and saved it, so taking the id off the list alone changed nothing: a teammate searched the gun up after the
    // abandon, banked it on his save, and the one gun was in both saves. A death or an extract never puts the list back, so only
    // an abandon takes it out of the armoury here.
    if(G.over==='abandon'&&P&&Array.isArray(P.weapons)){ j=P.weapons.indexOf(it.gk); if(j>=0){ P.weapons.splice(j,1); back++; } }
  }
  // v17.23: and his two gun slots never name the gun he no longer owns (he may have taken it up again in the Undercroft by now),
  // the repair the death branch of endRaid makes.
  if(back){
    if(P.equipped&&P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
    if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
    if((P.equippedSec||'none')===P.equipped) P.equippedSec='none';
  }
  if(n) saveProfile();
'@

SubRx @'
var VER='17.22';
'@ @'
var VER='17.23';
'@

$pat = "(?m)^  now:'v17\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.23: An armoury gun the host dropped and a teammate searched up after the host abandoned stayed in the host armoury, because the abandon had already put every spliced gun back and saved, and netGunsGone only took the id off G.spliced and P.raidSpliced. netGunsGone now also takes one copy out of P.weapons when the kept raid ended as an abandon (the abandon branch and the instant quit are the only ends that put the list back), repairs P.equipped and P.equippedSec the way the death branch does, and saves. Check 17.23 fails on v17.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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
  var sn=document.getElementById('stashn'); if(sn) sn.textContent=P.stash.length;
'@ @'
  // v14.75, stash and trader audit finding 3: THE STASH HEADER COUNTS WHAT THE ALL TAB COUNTS. Armoury guns are drawn in the
  // stash grid and counted by the ALL and GUNS tabs, but not by this header, which also counted save keys with no item. A
  // fresh profile read STASH 0 held above ALL 1 and a pistol, and buying the SMG did not move it.
  var sn=document.getElementById('stashn'); if(sn) sn.textContent=P.stash.filter(function(x){ return !!ITEMS[x]; }).length+(P.weapons||[]).length;
'@
SubRx @'
var VER='14.74';
'@ @'
var VER='14.75';
'@

$pat = "(?m)^  now:'v14\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.75: THE STASH HEADER COUNTS WHAT THE ALL TAB COUNTS. Armoury guns are in the stash grid and in the ALL tab count but were left out of the STASH held number, so a fresh profile read 0 held above ALL 1. The header now counts the guns too. Check 14.75 holds two Bandages and two guns; it fails on v14.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

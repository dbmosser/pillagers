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

# SOUND BACK IN BOTH SPEAKERS AFTER A PARTY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netSndRelease(){ NET.sndOther=-1; if(NET.sndG){ try{ NET.sndG.gain.value=1; }catch(e){} } return true; }
'@ @'
// v20.45, from the whole-game bug hunt of 2026-10-08 (H50): ENDING A SAME MACHINE PARTY PUTS THE SOUND BACK IN BOTH SPEAKERS. With
// SPLIT SPEAKERS on (the default) the party panned this window hard left (player 1) or hard right (player 2), and ending the party
// only put the master gain back to 1. The panner kept its side, so every sound after it, guns, steps, the ambience and the
// Undercroft music, came out of one speaker until a reload, and the rows that set it only show in a party. It goes back to the middle.
function netSndRelease(){ NET.sndOther=-1; if(NET.sndG){ try{ NET.sndG.gain.value=1; }catch(e){} } if(NET.sndP){ try{ NET.sndP.pan.value=0; }catch(e2){} } return true; }
'@

SubRx @'
var VER='20.44';
'@ @'
var VER='20.45';
'@

$pat = "(?m)^  now:'v20\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.45: After you end a two player party on one machine, sound plays in both speakers again. Check 20.45 fails on v20.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

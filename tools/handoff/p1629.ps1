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

# PLAYER 2 HEARS THE GAME: split speakers by default. His note of 2026-09-27.

SubRx @'
function netSndSplitOn(){ var v=null; if(!NET.same) return false; try{ v=localStorage.getItem(NET_SPLIT_KEY); }catch(e){ v=null; } return v==='1'; }
'@ @'
function netSndSplitOn(){ var v=null; if(!NET.same) return false; try{ v=localStorage.getItem(NET_SPLIT_KEY); }catch(e){ v=null; } return (v===null)?true:(v==='1'); }   // v16.29, his note: player 2 heard nothing; split is the default until switched off
'@

SubRx @'
var VER='16.28';
'@ @'
var VER='16.29';
'@

$pat = "(?m)^  now:'v16\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.29: PLAYER 2 HEARS THE GAME. His note: player 2 heard nothing at all, since the second window started with its sound off. Two player co-op on one PC now starts with SPLIT SPEAKERS on: both windows play, player 1 in the left speaker and player 2 in the right. It can still be switched off in the PARTY window. No number moved. Check 16.29 fails on v16.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# every word on screen is lower case (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function ncFix(s){
  if(typeof s!=='string'||s.length<2||!/[A-Z][A-Z]/.test(s)) return s;

'@ @'
// v30.xx (cw-lowercase), HIS ORDER (2026-10-18): "change all text shown to player to lowercase only -- i don't like how you have random
// words capitalized". This is the one door every canvas line, every measure, every text node and every tooltip goes through (see
// cw-nocaps-net above), so from here every word on screen is lower case: titles, buttons, callouts, acronyms and key names too (sp, hp,
// esc). His own edited lines keep their words; only the case changes. A box the player types in still shows what is typed.
// NCLOWER=0 brings back the older sentence-case fix below.
var NCLOWER=1;
function ncFix(s){
  if(NCLOWER) return (typeof s==='string')?s.toLowerCase():s;
  if(typeof s!=='string'||s.length<2||!/[A-Z][A-Z]/.test(s)) return s;

'@

SubRx @'
*{ text-transform:none !important; }

'@ @'
*{ text-transform:none !important; }
/* v30.xx (cw-lowercase), HIS ORDER (2026-10-18): every word on screen is lower case. The words a stylesheet writes itself (the
   Esc  Resume and pad hint strips, Taken) never pass the text door, so they are lowered here. */
*::before, *::after{ text-transform:lowercase !important; }

'@

SubRx @'
var VER='30.71';
'@ @'
var VER='30.72';
'@

$pat = "(?m)^  now:'v30\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.72: Every word on screen is now lower case, everywhere. Check 30.72 fails on v30.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

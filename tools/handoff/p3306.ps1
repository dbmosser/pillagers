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

# EXPERIMENTAL: THE LAST SWITCH (PARTY SEED) (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // XF_ROWS_END

'@ @'
  ['xfSeed','party seed','new party locks one seed','l'],
  // XF_ROWS_END

'@

SubRx @'
function arcadePartySeed(){ var o=arcadePartyRec(), s=(+o.s)>>>0;
'@ @'
function arcadePartySeed(){ if(!xfL('xfSeed')) return 0; var o=arcadePartyRec(), s=(+o.s)>>>0;
'@

SubRx @'
ARCOP.note='Clears tonight\u2019s best  \u00b7  New seed';
'@ @'
ARCOP.note='Clears tonight\u2019s best'+(xfL('xfSeed')?'  \u00b7  New seed':'');
'@

SubRx @'
ARCOP.note=arcadeNewParty()?'Board cleared  \u00b7  Seed '+arcadePartyCode():'Could not clear the board';
'@ @'
ARCOP.note=arcadeNewParty()?'Board cleared'+(arcadePartyCode()?'  \u00b7  Seed '+arcadePartyCode():''):'Could not clear the board';
'@

SubRx @'
var VER='33.05';
'@ @'
var VER='33.06';
'@

$pat = "(?m)^  now:'v33\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.06: The experimental page switches the party seed. Check 33.06 fails on v33.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

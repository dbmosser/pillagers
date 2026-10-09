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

# AN OWNED CONTRACT GUN PAYS WHAT IT IS WORTH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _pgv=(ITEMS['gun_'+g.k]&&ITEMS['gun_'+g.k].val)||0;
'@ @'
    // v20.70, from the whole-game bug hunt of 2026-10-08 (H33): THE VALUE THE GAME SHOWS FOR THAT GUN. This paid the raw table value,
    // while the stash, Tag as junk and Sell one all say and pay the value scaled by How much is out there (ival, v15.93), so on Rich
    // the receipt paid less than the gun was worth everywhere else, and on Lean more. The receipt and the payment use ival now.
    var _pgv=ival('gun_'+g.k);
'@

SubRx @'
var VER='20.69';
'@ @'
var VER='20.70';
'@

$pat = "(?m)^  now:'v20\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.70: A contract gun you already own now pays the same value the stash shows for it. Check 20.70 fails on v20.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

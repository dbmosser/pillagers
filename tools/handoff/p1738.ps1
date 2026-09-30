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

# CTRL AND A CLICK MOVES ONE ITEM FROM THE STASH TO THE BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(ev.altKey){                            // ALT split, per the key bar
'@ @'
      if(ev.ctrlKey||ev.metaKey){               // v17.38, his pick 26 (2026-09-30): CTRL and a click moves one into the backpack
        ev.stopPropagation(); ev.preventDefault();
        _packSome(1); return;
      }      if(ev.altKey){                            // ALT split, per the key bar
'@

SubRx @'
        <div><kbd>SHIFT</kbd> quick move</div>
'@ @'
        <div><kbd>SHIFT</kbd> quick move</div>
        <div><kbd>CTRL</kbd> move one</div>
'@

SubRx @'
var VER='17.37';
'@ @'
var VER='17.38';
'@

$pat = "(?m)^  now:'v17\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.38: CTRL AND A CLICK MOVES ONE ITEM FROM THE STASH TO THE BACKPACK, his pick from the feature list. On the Stash screen CTRL and a click packs one of that item, the key bar names it beside SHIFT, SHIFT still packs the whole stack, and a click on a backpack item still puts one back. Check 17.38 fails on v17.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

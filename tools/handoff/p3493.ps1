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

# THE DIFFICULTY PANEL SAYS WHAT EACH CHOICE MEANS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return '<div class="row"><div style="flex:1"><b>difficulty</b><div class="hint">new player: softer hits, longer raids, more loot, fewer extras</div></div>'+
'@ @'
  // v28.xx (cw-diffhint): the side panel keeps a hint only up to its first colon, so "new player: ..." read "new player" on the main game too; the hint now says what the choice on the button means
  return '<div class="row"><div style="flex:1"><b>difficulty</b><div class="hint">'+(d==='new player'?'softer hits, longer raids, more loot, fewer extras':(d==='main game'?'standard hits, raid length and loot, extras on':'rows changed by hand'))+'</div></div>'+
'@

SubRx @'
var VER='34.92';
'@ @'
var VER='34.93';
'@

$pat = "(?m)^  now:'v34\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.93: The side panel for the difficulty row matches the button: new player, main game or custom. Check 34.93 fails on v34.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

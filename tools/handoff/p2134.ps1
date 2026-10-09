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

# YOUR STATS NAMES WHO KILLED YOU PROPERLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  h+=card('Usually killed by', tk?tk.k:'--', tk?(tk.n+' time'+(tk.n===1?'':'s')):'nothing has killed you yet');
'@ @'
  // v21.34, from the 4K visual pass of 2026-10-09 (W-C1): THE USUAL KILLER IS NAMED AS THE PLAYER KNOWS IT, IN CAPITALS. The card
  // printed the kind as the run log stores it, so it read warden in small letters beside COLD STORAGE and Level 4 on the same row,
  // and deaths to pillagers would read raider (a crier snitch, the Pillbox choir). It now prints the name the contracts use for the
  // kind (UNITNAME), in capitals as the KILLED BY line of the death card does. The count under it is unchanged.
  var _tkN=tk?String(Object.prototype.hasOwnProperty.call(UNITNAME,tk.k)?UNITNAME[tk.k]:(tk.k==='choir'?'pillbox':tk.k)).toUpperCase():'--';
  h+=card('Usually killed by', _tkN, tk?(tk.n+' time'+(tk.n===1?'':'s')):'nothing has killed you yet');
'@

SubRx @'
var VER='21.33';
'@ @'
var VER='21.34';
'@

$pat = "(?m)^  now:'v21\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.34: YOUR STATS now names who usually kills you in capitals and by its real name, such as PILLAGER or WARDEN. Check 21.34 fails on v21.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

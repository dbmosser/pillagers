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

# A DOOR OPENED FOR THE PARTY OPENS FOR THE ENEMIES TOO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!G||G.over||!G.map||((+m.sd)>>>0)!==(G.seed>>>0)) return 'other';
'@ @'
  // v22.03, from the whole-game bug hunt of 2026-10-08 (K13): A DOOR OPENED WHILE THE HOST WATCHES OPENS IN HIS KEPT RAID TOO. The
  // raid a host keeps running for his party after his own run is over (NET.specG) always has G.over set, so a door player 2 opened
  // with a key stayed shut there: every machine and pillager, all run by the host, still saw and walked against the door, and no
  // third player ever got it. That kept raid takes the word now, as a dropped pile already does; any other raid that is over does not.
  if(!G||(G.over&&G!==NET.specG)||!G.map||((+m.sd)>>>0)!==(G.seed>>>0)) return 'other';
'@

SubRx @'
var VER='22.02';
'@ @'
var VER='22.03';
'@

$pat = "(?m)^  now:'v22\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.03: In co-op, a door opened with a key while the host watches opens for everyone, enemies included. Check 22.03 fails on v22.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# DEMO KILLS PAY AS CAREER KILLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ARCADE_HEALS_MAX=5;

'@ @'
// 2026-10-12 (unify2), HIS ANSWER: "GAMEPLAY ELEMENTS ... SHOULD BE EXACTLY THE SAME IN DEMO AND CAREER", with 13 b (loot as now) and
// 16 a (shared ammo). A DEMO kill refunded half a magazine and every third kill handed out a Bandage, which a CAREER kill never does,
// so ammo and heals ran on different rules in the two modes. ARCADE_KILLPERKS 0 turns both off: a DEMO kill pays its score and
// nothing else, as a CAREER kill pays nothing but the kill. The perk code stays behind the dial.
var ARCADE_KILLPERKS=0;
var ARCADE_HEALS_MAX=5;

'@

SubRx @'
  if(!p||!G.arcade||G.sim||G.over) return;
  m=(p.wep&&p.wep.mag)|0;
'@ @'
  if(!p||!G.arcade||G.sim||G.over||!ARCADE_KILLPERKS) return;   // 2026-10-12 (unify2): off, DEMO kills pay as CAREER kills do
  m=(p.wep&&p.wep.mag)|0;
'@

SubRx @'
var VER='24.85';
'@ @'
var VER='24.86';
'@

$pat = "(?m)^  now:'v24\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.86: A kill in DEMO no longer gives ammo back or a free Bandage, the same as in CAREER. Check 24.86 fails on v24.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

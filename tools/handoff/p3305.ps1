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

# EXPERIMENTAL: THREE MORE SWITCHES (NEEDED-ITEM GLOW, HAUL REVEAL, SHOP RE-ROLL) (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // XF_ROWS_END

'@ @'
  ['xfNeed','needed-item glow','a box with a contract item glows','l'],
  ['xfHaul','haul reveal','the haul comes up item by item','l'],
  ['xfShop','shop re-roll','two of four extras in stock','l'],
  // XF_ROWS_END

'@

SubRx @'
function needRefresh(){
  var n=0, k;
  if(!G||G.sim) return 0;

'@ @'
function needRefresh(){
  var n=0, k;
  if(!G||G.sim) return 0;
  if(!xfL('xfNeed')){ G.need={}; G.needN=0; return 0; }   // v32.xx (cw-expmenu6): switched off, no box glows for a contract (read live, this window)

'@

SubRx @'
  HAUL_REV=null;
  if(!w) return 0;

'@ @'
  HAUL_REV=null;
  if(!xfL('xfHaul')) return 0;   // v32.xx (cw-expmenu6): switched off, the haul on the extracted card shows at once
  if(!w) return 0;

'@

SubRx @'
function shopStocked(o){ return !o||
'@ @'
function shopStocked(o){ return !xfL('xfShop')||!o||
'@

SubRx @'
var VER='33.04';
'@ @'
var VER='33.05';
'@

$pat = "(?m)^  now:'v33\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.05: The experimental page switches the needed-item glow, the haul reveal and the shop re-roll. Check 33.05 fails on v33.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

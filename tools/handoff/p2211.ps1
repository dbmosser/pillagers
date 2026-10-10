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

# YOUR IMPORTED FRIEND STAYS OUT OF A PARTY RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function applyGhost(){
  if(!P.ghost||!G||G.sim) return;
'@ @'
function applyGhost(){
  // v22.11, from the whole-game bug hunt of 2026-10-08 (K23): NEVER ON A PARTY GUEST BUILD. In a party raid the host runs every
  // body, and he never dressed one as this window's imported friend, so player 2 saw the friend's name and gun on a man who fought
  // as the pillager the host rolled, and killing him turned the friend hostile with a grudge in every later raid while the man
  // actually killed had no record of it. On a guest build (NET.upHold, which also keeps his own hire at home) the bodies keep the
  // names and records the host rolled. Solo and the host build are unchanged.
  if(!P.ghost||!G||G.sim||(typeof NET==='object'&&NET&&NET.upHold)) return;
'@

SubRx @'
var VER='22.10';
'@ @'
var VER='22.11';
'@

$pat = "(?m)^  now:'v22\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.11: In co-op, player 2 no longer sees his imported friend on a pillager the host runs, and killing that pillager no longer turns the friend hostile. Check 22.11 fails on v22.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

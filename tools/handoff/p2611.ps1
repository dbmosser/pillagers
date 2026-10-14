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

# A HEALING PILLAGER STILL GOES DOWN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if((e.healQ||0)>0){
'@ @'
  // v26.11 (nightfix2), found by the overnight regression run of 2026-10-13 (check 25.44, his second fall): A PILLAGER AT NO HEALTH DOES NOT HEAL HIMSELF OUT OF HIS FALL. This
  // heal runs before updateEnts counts the fall (hp <= 0 goes down). A pillager with a heal running and a medkit in his bag, brought to nothing, got a
  // sliver of health back first (the heal adds up to 0.15 a frame), so hp was 0.05 and the fall never counted: he stood up at 0.05 health, and his second
  // fall (the one that kills him) never came. On no health he is going down this frame, so the heal waits; it picks up again if he gets up.
  if(e.hp<=0){ /* going down this frame: no heal */ }
  else if((e.healQ||0)>0){
'@

SubRx @'
var VER='26.10';
'@ @'
var VER='26.11';
'@

$pat = "(?m)^  now:'v26\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.11: A pillager who is healing now goes down when his health reaches nothing, instead of standing back up. Check 26.11 fails on v26.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIRE AND PEDDLER AUDIT OF 2026-09-14, finding 2: YOUR OWN FRAG KILLED YOUR HIRE. Your rounds
# (v6.72) and your fists (v11.38) pass through him, and the hire screen says your shots cannot
# hurt him, but the frag loop had no such rule. A charge does up to 140 and a hire has 78 or
# less and cannot be downed, so he died outright with byPlayer set: a kill on that identity's
# record so he never works for you again, a pillager kill contract ticked, the death benefit
# billed at the extraction, and a charge that only wounded him set him chasing you.
SubRx @'
    var e=G.ents[i],de=dist(e,f);
    if(de<R+e.r&&losClear(f.x,f.y,e.x,e.y,G.map.segs)){
'@ @'
    var e=G.ents[i],de=dist(e,f);
    if(_fMine&&e.merc&&!e.downed) continue;   // v13.68, hire audit: your charge spares your hire, as your rounds (v6.72) and fists (v11.38) do
    if(de<R+e.r&&losClear(f.x,f.y,e.x,e.y,G.map.segs)){
'@
SubRx @'
var VER='13.68';
'@ @'
var VER='13.69';
'@

$pat = "(?m)^  now:'v13\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.69: YOUR OWN CHARGE DOES NOT KILL YOUR HIRE. Hire and peddler audit of 2026-09-14, finding 2: your rounds and fists pass through your hire but the frag loop had no such rule, so a charge killed him outright with byPlayer set, which put a kill on his identity so he never works for you again, ticked a pillager kill contract, billed the death benefit, and sent a wounded hire chasing you. The frag loop now skips your standing hire when the charge is yours; an enemy charge still hurts him. Check 13.69 bursts your charge beside the hire and requires him untouched with no kill recorded, with an enemy charge wounding him as the control; it fails on v13.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

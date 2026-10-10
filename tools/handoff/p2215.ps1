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

# KID FIRING HOLDS FIRE AT THE STALL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(p&&!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&!p.downed&&!(p.reloading>0)&&!(p.jam>0)&&!p.cooking&&p.wep&&p.wep.mag>0&&(p.ammo>0||p.reserve>0)){
'@ @'
  // v22.15, from the whole-game bug hunt of 2026-10-08 (K26): KID FIRING NEVER SHOOTS THROUGH THE OPEN PEDDLER STALL. A click, RT
  // and A held into the stall are all kept off the gun while it is open (v14.20, v15.35), but this test had no stall in it, so
  // player 2 browsing the stall with a machine or a hostile pillager in range and in sight fired round after round through the
  // panel: his magazine spent, the noise drawing more machines, his facing turned, and a round could hit the Peddler beside him
  // and shut the stall. With the stall open the trigger is let go and the cursor is left alone.
  if(p&&!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&!G.trade&&!p.downed&&!(p.reloading>0)&&!(p.jam>0)&&!p.cooking&&p.wep&&p.wep.mag>0&&(p.ammo>0||p.reserve>0)){
'@

SubRx @'
    if(p&&!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&!p.downed){ try{ lk=afLook(p); }
'@ @'
    if(p&&!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&!G.trade&&!p.downed){ try{ lk=afLook(p); }
'@

SubRx @'
var VER='22.14';
'@ @'
var VER='22.15';
'@

$pat = "(?m)^  now:'v22\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.15: Kid firing no longer shoots while player 2 has the Peddler stall open. Check 22.15 fails on v22.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

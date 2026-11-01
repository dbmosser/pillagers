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

# HURT MACHINES SHOW SMOKE AND SPARKS, NOT A HEALTH BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(ne.hp<ne.maxhp){
      var fw=clamp(ne.hp/ne.maxhp,0,1);

'@ @'
    // v37.13 (cw-nomachpip), his pick 'smoke and sparks only' (g-83, 10-25): a hurt machine shows its damage as smoke and sparks (gfxDamageFx), not as a bar.
    // Pillager bots, the hire, strays and the peddler keep the pip; the Overseer keeps its top boss bar (drawBossBar).
    if(ne.hp<ne.maxhp&&!GFXDMG_KINDS[ne.kind]){
      var fw=clamp(ne.hp/ne.maxhp,0,1);

'@

SubRx @'
var VER='37.12';
'@ @'
var VER='37.13';
'@

$pat = "(?m)^  now:'v37\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.13: A hurt machine shows smoke and sparks and no health bar under its name. Check 37.13 fails on v37.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

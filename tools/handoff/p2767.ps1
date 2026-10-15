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

# REDUCED FLASHING TONES DOWN THE SITE GOING UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    wc.fillStyle='rgba(255,236,196,'+clamp(_nf,0,0.94).toFixed(3)+')';
'@ @'
    wc.fillStyle='rgba(255,236,196,'+clamp(_nf*flashK(),0,0.94).toFixed(3)+')';   // v27.67 (cloud-menus-nuke-reduced-flash), CLOUD HUNT 2026-10-15: REDUCED FLASHING left this full-screen white-out at full strength; it now takes flashK like the lightning
'@

SubRx @'
      G.flashes.push({x:bx,y:by,r:rnd(180,340),t:0,life:0.5,c:'#ffd6a0'});
'@ @'
      G.flashes.push({x:bx,y:by,r:rnd(180,340)*(CFG.flashRed===1?0.6:1),t:0,life:0.5*(CFG.flashRed===1?0.7:1),c:'#ffd6a0'});   // v27.67 (cloud-menus-nuke-reduced-flash), CLOUD HUNT 2026-10-15: these blooms skip flash(), so REDUCED FLASHING never shrank them; same factors as flash(), same rnd draw
'@

SubRx @'
var VER='27.66';
'@ @'
var VER='27.67';
'@

$pat = "(?m)^  now:'v27\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.67: REDUCED FLASHING now also tones down the white-out when the site goes up. Check 27.67 fails on v27.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

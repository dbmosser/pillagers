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

# PLAYER 2'S CROWBAR AND BLASTS ACT LIKE THE HOST'S (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(CFG.raiderRoll!==0&&e.kind==='raider'&&!e.downed&&!e.finished&&!e.roll&&!(e.rollCd>0)&&e.hp>0&&typeof m.a==='number'&&isFinite(m.a)&&
'@ @'
  /* v28.xx (cw-blowround), CLOUD HUNT 2026-10-15: only a gun round (sk) rolls him out of the line; player 2 crowbar, frag, finisher and air strike do not, as the host own blows do not */
  if(m.sk&&CFG.raiderRoll!==0&&e.kind==='raider'&&!e.downed&&!e.finished&&!e.roll&&!(e.rollCd>0)&&e.hp>0&&typeof m.a==='number'&&isFinite(m.a)&&
'@

SubRx @'
var VER='29.06';
'@ @'
var VER='29.07';
'@

$pat = "(?m)^  now:'v29\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.07: Player 2s crowbar, frag charges and air strikes hit a pillager the same way the hosts do. Check 29.07 fails on v29.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# THE EMPTY RETICLE NAMES THE RELOAD KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      ctx.fillText(rState==='jam'?'JAMMED':(rState==='dry'?'NO AMMO':'EMPTY - R'),rx0,ry0+gap+len+LH(14));
'@ @'
      // v22.17, from the whole-game bug hunt of 2026-10-08 (K28), in the shooter voice of the raid text plan (R22): THE EMPTY
      // RETICLE NAMES THE RELOAD BUTTON IN HAND. It always said EMPTY - R, a key a controller does not have (X reloads there) and
      // the wrong key after CHANGE KEYS moved reload. It reads [key] RELOAD through keyLabel like every other prompt now: [X] RELOAD
      // on a pad, [SQUARE] RELOAD on a PlayStation pad, [R] RELOAD on a keyboard with R unmoved. NO AMMO and JAMMED keep their words.
      ctx.fillText(rState==='jam'?'JAMMED':(rState==='dry'?'NO AMMO':'['+keyLabel('KeyR','R')+'] RELOAD'),rx0,ry0+gap+len+LH(14));
'@

SubRx @'
var VER='22.16';
'@ @'
var VER='22.17';
'@

$pat = "(?m)^  now:'v22\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.17: The empty crosshair now says [X] RELOAD on a controller and [R] RELOAD on a keyboard, the reload button you have. Check 22.17 fails on v22.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

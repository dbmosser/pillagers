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

# MISSED EXTRACTION NOTICE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        say('EXTRACTION MISSED','ext',{c:'warn',key:'xcall',sub:((z.closeAt!==undefined&&G.timeLeft<=z.closeAt)?'':((raidClockOn()&&G.timeLeft<CFG.extractWait)?'No time to call again':('Hold ['+keyLabel('KeyX','X')+'] to call again')))}); }   // v22.38 (R13)   // v22.xx (tr3fixc): the shooter voice
'@ @'
        say('EXTRACTION MISSED','ext',{c:'warn',key:'xcall',sub:((z.closeAt!==undefined&&G.timeLeft<=z.closeAt)?'':((raidClockOn()&&G.timeLeft<CFG.extractWait)?'No time to call again':''))}); }   // v22.38 (R13)   // v22.xx (tr3fixc): the shooter voice   // v28.xx (cw-cx-missedextract), HIS NOTE (10-29): remove the call-again instruction; the player may be outside the circle.
'@

SubRx @'
var VER='36.38';
'@ @'
var VER='36.39';
'@

$pat = "(?m)^  now:'v36\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.39: missed extraction no longer says hold x to call again Check 36.39 fails on v36.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

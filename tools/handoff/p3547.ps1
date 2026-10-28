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

# NEW SAVES COUNT EACH KILL ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  mig739:1,mig945:1,beltV:5,   // v21.93: beltV, the four-gun belt plan, born set (beltSlidePlan)
'@ @'
  mig739:1,mig945:1,beltV:5,   // v21.93: beltV, the four-gun belt plan, born set (beltSlidePlan)
  achScan:1,   // v35.47 (cloud-ach-born-scan), CLOUD AUDIT 2026-10-28: BORN SET. Live runs already count kills (achRun live), so the one-time log scan in achStatsDraw added every run again the first time a new save opened its stats: 14 pillager kills read 28 and unlocked the 25 kill medal
'@

SubRx @'
var VER='35.46';
'@ @'
var VER='35.47';
'@

$pat = "(?m)^  now:'v35\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.47: new saves count each kill once for medals Check 35.47 fails on v35.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

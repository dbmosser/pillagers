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

# THE HEARTBEAT STARTS AT 30 PERCENT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(HEART<=0&&(pp.hp<45||pp.downed||chaseNear>0.25)){
        var hurtF=pp.downed?1:clamp(1-(pp.hp/45),0,1);
'@ @'
      // v27.xx (heart30), HIS ANSWER 40 (2026-10-13): "the low-health heartbeat starts at 30%". It began at 45 health; it now begins at 30 (of 100),
      // and the knock still grows from nothing at that line to its worst at 0, so the rate and the weight are the same curve over a shorter range.
      // Being downed, and a machine or a pillager hunting you close, still set it off at any health, as before.
      if(HEART<=0&&(pp.hp<30||pp.downed||chaseNear>0.25)){
        var hurtF=pp.downed?1:clamp(1-(pp.hp/30),0,1);
'@

SubRx @'
var VER='27.15';
'@ @'
var VER='27.16';
'@

$pat = "(?m)^  now:'v27\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.16: The low-health heartbeat now starts at 30 health instead of 45. Check 27.16 fails on v27.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

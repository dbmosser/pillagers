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

# HIT TICKS SHOW OVER THE HUD PANELS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var hIn=((hm.kill?7:5)+(1-hk)*(hm.kill?7:4))*_rz,hOut=hIn+(hm.kill?7:5)*_rz;
'@ @'
      var _hmz=hudRes();   // v21.25, from the review of 2026-10-09 (R7): its own screen factor; _rz is set only when the cross is drawn, so over a HUD panel the ticks were NaN and never drew
      var hIn=((hm.kill?7:5)+(1-hk)*(hm.kill?7:4))*_hmz,hOut=hIn+(hm.kill?7:5)*_hmz;
'@

SubRx @'
      ctx.lineWidth=(hm.kill?2.4:1.8)*_rz;
'@ @'
      ctx.lineWidth=(hm.kill?2.4:1.8)*_hmz;
'@

SubRx @'
var VER='21.24';
'@ @'
var VER='21.25';
'@

$pat = "(?m)^  now:'v21\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.25: Hit ticks show even when your crosshair is over a HUD panel. Check 21.25 fails on v21.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# THE COMBO MULTIPLIER CLEARS THE TEAM RING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
hudText('x'+mx,Math.round(rx+r+7*z),Math.round(ry+4*z));
'@ @'
hudText('x'+mx,Math.round(rx+r+((typeof ARCADE==='object'&&ARCADE&&G.arcade&&!ARCADE.solo&&ARCADE.team&&Date.now()-ARCADE.team.at<TEAM.win*1000)?18:7)*z),Math.round(ry+4*z));   // v26.xx (party7): clear of the TEAM ring
'@

SubRx @'
var VER='26.97';
'@ @'
var VER='26.98';
'@

$pat = "(?m)^  now:'v26\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.98: The combo multiplier moves clear of the TEAM ring while it shows. Check 26.98 fails on v26.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

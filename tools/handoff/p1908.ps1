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

# THE SCOPE ZOOM FOLLOWS A DELIBERATE AIM ONLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if((PAD.adsT>0||PAD.adsTog||(trig(6)>0.35&&!G.over&&!G.paused))&&
'@ @'
  PAD.adsAim=!!(PAD.adsTog||(trig(6)>0.35&&!G.over&&!G.paused));   // v19.08, from the review (2026-10-07): a deliberate aim (LT or the RS toggle), apart from the steadying after each RT pull
  if((PAD.adsT>0||PAD.adsTog||(trig(6)>0.35&&!G.over&&!G.paused))&&
'@

SubRx @'
tgt=(m>1&&!G.sim&&!G.over)?Math.max(1,1+(m-1)*k):1
'@ @'
tgt=(m>1&&!G.sim&&!G.over&&!(typeof PAD!=='undefined'&&PAD&&PAD.adsing&&!PAD.adsAim))?Math.max(1,1+(m-1)*k):1
'@

SubRx @'
var VER='19.07';
'@ @'
var VER='19.08';
'@

$pat = "(?m)^  now:'v19\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.08: On a controller the view no longer zooms in and out with every shot of a scoped gun; holding LT still zooms. Check 19.08 fails on v19.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# THE FEED ZONE IS A QUARTER WIDE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var rs=Math.max(1,hudRes()), fp=msgPx(hudFS(TYPE.label)), rh=Math.round(fp*1.5), gap=Math.max(2,Math.round(LH(2)*rs)), B=HUDBOX.body, h=FEED.show*rh+(FEED.show-1)*gap, bot;
'@ @'
  // v27.35 (feedw), seen in the busy frame picture: the feed zone was 30 percent of the screen wide (576 px at 1080p) and its lines are
  // under 410, so the controls list beside it was squeezed to a sliver. The zone is 24 percent of the width, and each line is a little
  // tighter (1.38 x the type, was 1.5), so the ten lines are about 280 px tall at 1080p.
  var rs=Math.max(1,hudRes()), fp=msgPx(hudFS(TYPE.label)), rh=Math.round(fp*1.38), gap=Math.max(2,Math.round(LH(2)*rs)), B=HUDBOX.body, h=FEED.show*rh+(FEED.show-1)*gap, bot;
'@

SubRx @'
  return {x:Math.round(LH(9)*rs),y:bot-h,w:Math.min(Math.round(LH(460)*rs),Math.round(W*0.3)),h:h,rh:rh,gap:gap,fp:fp};
'@ @'
  return {x:Math.round(LH(9)*rs),y:bot-h,w:Math.round(W*0.24),h:h,rh:rh,gap:gap,fp:fp};
'@

SubRx @'
var VER='27.34';
'@ @'
var VER='27.35';
'@

$pat = "(?m)^  now:'v27\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.35: The feed zone is now a quarter of the screen wide, so the controls list beside it stays readable. Check 27.35 fails on v27.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

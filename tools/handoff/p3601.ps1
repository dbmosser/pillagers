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

# medal row follows feed width (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feedRect(){
  // v27.35 (feedw), seen in the busy frame picture: the feed zone was 30 percent of the screen wide (576 px at 1080p) and its lines are
  // under 410, so the controls list beside it was squeezed to a sliver. The zone is 24 percent of the width, and each line is a little
  // tighter (1.38 x the type, was 1.5), so the ten lines are about 280 px tall at 1080p.
  var rs=Math.max(1,hudRes()), fp=msgPx(feedFont()), rh=Math.round(fp*1.38),   /* v35.xx (cw-hudsize): 20 px */ gap=Math.max(2,Math.round(LH(2)*rs)), B=HUDBOX.body, h=FEED.show*rh+(FEED.show-1)*gap, bot;
  bot=((B&&B.h>0&&B.y>H*0.5)?B.y:Math.round(H-LH(142)*rs*1.4))-Math.round(LH(8)*rs);
  MEDALBOX.h=Math.round(LH(40)*rs); MEDALBOX.y=bot-MEDALBOX.h; MEDALBOX.x=Math.round(LH(9)*rs); MEDALBOX.w=Math.round(W*0.24); MEDALBOX.on=1;   // v27.40 (medal0): the medal spot, on the vitals
  bot=MEDALBOX.y-Math.round(LH(6)*rs);   // and the feed stands on it
  return {x:Math.round(LH(9)*rs),y:bot-h,w:Math.round(W*0.28),h:h,rh:rh,gap:gap,fp:fp};   // v35.xx (cw-hudsize): 28 percent, so a 20 px line fits whole
}
'@ @'
function feedRect(){
  // v28.xx (cw-cx-medalwidth), HIS ANSWER: "a row for the style medals is reserved between the feed and the vitals, the width of the feed". Share the feed width so the reserved row cannot drift.
  // v27.35 (feedw), seen in the busy frame picture: the feed zone was 30 percent of the screen wide (576 px at 1080p) and its lines are
  // under 410, so the controls list beside it was squeezed to a sliver. The zone is 24 percent of the width, and each line is a little
  // tighter (1.38 x the type, was 1.5), so the ten lines are about 280 px tall at 1080p.
  var rs=Math.max(1,hudRes()), fp=msgPx(feedFont()), rh=Math.round(fp*1.38),   /* v35.xx (cw-hudsize): 20 px */ gap=Math.max(2,Math.round(LH(2)*rs)), B=HUDBOX.body, h=FEED.show*rh+(FEED.show-1)*gap, fw=Math.round(W*0.28), bot;
  bot=((B&&B.h>0&&B.y>H*0.5)?B.y:Math.round(H-LH(142)*rs*1.4))-Math.round(LH(8)*rs);
  MEDALBOX.h=Math.round(LH(40)*rs); MEDALBOX.y=bot-MEDALBOX.h; MEDALBOX.x=Math.round(LH(9)*rs); MEDALBOX.w=fw; MEDALBOX.on=1;   // v27.40 (medal0): the medal spot, on the vitals
  bot=MEDALBOX.y-Math.round(LH(6)*rs);   // and the feed stands on it
  return {x:Math.round(LH(9)*rs),y:bot-h,w:fw,h:h,rh:rh,gap:gap,fp:fp};   // v35.xx (cw-hudsize): 28 percent, so a 20 px line fits whole
}
'@

SubRx @'
var VER='36.00';
'@ @'
var VER='36.01';
'@

$pat = "(?m)^  now:'v36\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.01: The medal row matches the feed width. Check 36.01 fails on v36.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

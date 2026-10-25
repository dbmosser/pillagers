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

# CAREER CONTROLS LIST FOLDED, MID-BOTTOM LEFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  g.career=1; g.raidLen=g.timeLeft=CAREER_RAID_SEC;

'@ @'
  g.career=1; g.raidLen=g.timeLeft=CAREER_RAID_SEC;
  g.legendOn=0;   // v34.xx (cw-careerlegend), his answer rs-1 (2026-10-24): "keys should be in mid bottom LEFT hand side", minimized, hit key to reveal. A career raid starts with the controls list folded (the demo keeps its own start).

'@

SubRx @'
var FEEDBOX={on:0,x:0,y:0,w:0,h:0,rows:[]};
'@ @'
var FEEDBOX={on:0,x:0,y:0,w:0,h:0,rows:[]};
var LEGHINT=null;   // v34.xx (cw-careerlegend): where the folded f1 controls line stood this frame (career raids), for the checks
'@

SubRx @'
var _hy=(FEEDBOX.on?FEEDBOX.y-LH(6):(HUDBOX.body?HUDBOX.body.y-LH(6):H-14));
'@ @'
var _hy=(FEEDBOX.on?FEEDBOX.y-LH(6):(HUDBOX.body?HUDBOX.body.y-LH(6):H-14)), _hx=8;
    // v34.xx (cw-careerlegend), his answer rs-1 (2026-10-24): "keys should be in mid bottom LEFT hand side", minimized. In a career raid the folded line stands where the opened list stands (left of the middle, its bottom just over the vitals, beside the feed), so F1 opens the list upward from it and the two never overlap the feed or the vitals.
    LEGHINT=null;
    if(G.career&&!G.arcade&&FEEDBOX.on&&HUDBOX.body){ _hx=FEEDBOX.x+FEEDBOX.w+Math.round(LH(10)*Math.max(1,hudRes())); _hy=HUDBOX.body.y-LH(8)-LH(8); }
'@

SubRx @'
hudPlate(8,Math.round(_hy-LH(14)),_f1w,LH(22),null,HUDC.plate); ctx.fillStyle=UIC.tx_2; ctx.fillText(_f1t,16,_hy);
'@ @'
hudPlate(_hx,Math.round(_hy-LH(14)),_f1w,LH(22),null,HUDC.plate); ctx.fillStyle=UIC.tx_2; ctx.fillText(_f1t,_hx+8,_hy); LEGHINT={x:_hx,y:Math.round(_hy-LH(14)),w:_f1w,h:LH(22)};
'@

SubRx @'
var VER='34.53';
'@ @'
var VER='34.54';
'@

$pat = "(?m)^  now:'v34\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.54: Career raids start with the controls list folded; the folded f1 line stands at the lower left beside the feed, and F1 opens the list upward from it. Check 34.54 fails on v34.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

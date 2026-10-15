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

# THE CONTROLS LIST STANDS BESIDE THE FEED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HUDZ={body:1.40, gear:1.36, raiders:1.15, legend:1.5, cond:1.05};
'@ @'
var HUDZ={body:1.40, gear:1.36, raiders:1.15, legend:1.5, cond:1.05};
var LEGZ0=HUDZ.legend, LEGMW=0;   // v27.26 (feedleg): the compact controls list zoom as set, and its width at zoom 1 as last drawn
'@

SubRx @'
    var _legTarget=(HUDBOX.body?HUDBOX.body.y:H)-LH(8);
    if(FEEDBOX.on&&FEEDBOX.y-LH(8)<_legTarget) _legTarget=FEEDBOX.y-LH(8);   // v27.24 (feed1): the controls list stands above the feed
'@ @'
    var _legTarget=(HUDBOX.body?HUDBOX.body.y:H)-LH(8), _legFX=0, _lgR=Math.max(1,hudRes()), _lgU=hudUserZ('legend');
    // v27.26 (feedleg), seen in the busy frame picture: the controls list stood above the feed and ran up over the CURRENT PILLAGERS board.
    // The compact list now stands on the vitals as before but to the right of the feed, and shrinks if it must so that it ends before
    // 47 percent of the screen width (the player stands in the middle of it). The feed keeps its own zone at the left.
    if(FEEDBOX.on&&G.legendOn===1){
      var _lgX=FEEDBOX.x+FEEDBOX.w+Math.round(LH(10)*_lgR), _lgZ=LEGZ0;
      if(LEGMW>0) _lgZ=Math.max(0.9,Math.min(LEGZ0,((W*0.47-_lgX)/LEGMW)/(_lgR*_lgU)));
      HUDZ.legend=_lgZ; _legFX=Math.round(_lgX-6*_lgZ*_lgR*_lgU);
    } else HUDZ.legend=LEGZ0;
'@

SubRx @'
      ctx.translate(_legDX,_legShift+_legDY);   // bottom on the target, plus his drag
'@ @'
      ctx.translate(_legDX+_legFX,_legShift+_legDY);   // bottom on the target, plus his drag (and the room the feed takes)
'@

SubRx @'
      _legBase={x:_lz.x,y:_lz.y+_legShift,w:_lz.w,h:_lz.h};
      _lz.x+=_legDX;
      _lz.y+=_legShift+_legDY;
      if(_lz.tg) _lz.tg={x:_lz.tg.x+_legDX,
'@ @'
      if(G.legendOn===1) LEGMW=_lz.w/(HUDZ.legend*_lgR*_lgU);   // v27.26 (feedleg): its width at zoom 1, for the cap next frame
      _legBase={x:_lz.x+_legFX,y:_lz.y+_legShift,w:_lz.w,h:_lz.h};
      _lz.x+=_legDX+_legFX;
      _lz.y+=_legShift+_legDY;
      if(_lz.tg) _lz.tg={x:_lz.tg.x+_legDX+_legFX,
'@

SubRx @'
    var _hy=(HUDBOX.body?HUDBOX.body.y-LH(6):H-14);
'@ @'
    var _hy=(FEEDBOX.on?FEEDBOX.y-LH(6):(HUDBOX.body?HUDBOX.body.y-LH(6):H-14));   // v27.26 (feedleg): the hint stands over the feed, not on its last line
'@

SubRx @'
var VER='27.25';
'@ @'
var VER='27.26';
'@

$pat = "(?m)^  now:'v27\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.26: The compact controls list now stands to the right of the feed, clear of the pillagers board. Check 27.26 fails on v27.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

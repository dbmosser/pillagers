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

# THE WHAT IS NEW CARD GROWS WITH THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var wnRole='head',wnRows=[],wnW=0,wnH=0,wnLH=0,wnGaps=0;
'@ @'
    // v19.21, seen on the 4K screenshot (2026-10-08): the card was drawn at its 1080p size on a 4K screen, a quarter of the area, its
    // words half the height of the station names around it (his v8.79 note was that this text is too small). It is now drawn in a
    // space scaled with the screen like the rest of the floor text, so it reads the same from the couch at 1080p, 1440p and 4K.
    var _wnr=Math.max(1,(typeof hudRes==='function')?hudRes():1), _wnWW=W/_wnr, _wnHH=H/_wnr;
    ctx.save(); ctx.scale(_wnr,_wnr);    var wnRole='head',wnRows=[],wnW=0,wnH=0,wnLH=0,wnGaps=0;
'@

SubRx @'
      wnW=Math.min(W-LH(60),LH(1000));
'@ @'
      wnW=Math.min(_wnWW-LH(60),LH(1000));
'@

SubRx @'
      if(wnH<=H-LH(60)) break;
'@ @'
      if(wnH<=_wnHH-LH(60)) break;
'@

SubRx @'
    if(wnH>H-LH(60)){
'@ @'
    if(wnH>_wnHH-LH(60)){
'@

SubRx @'
      var _wnFit=H-LH(60), _wnAcc=LH(90), _wnKeep=0, _wk;
'@ @'
      var _wnFit=_wnHH-LH(60), _wnAcc=LH(90), _wnKeep=0, _wk;
'@

SubRx @'
    var wnX=W/2-wnW/2, wnY=H/2-wnH/2-LH(10);
'@ @'
    var wnX=_wnWW/2-wnW/2, wnY=_wnHH/2-wnH/2-LH(10);
'@

SubRx @'
    ctx.fillText('NEW IN v'+WHATSNEW_VER,W/2,wnY+LH(32));
'@ @'
    ctx.fillText('NEW IN v'+WHATSNEW_VER,_wnWW/2,wnY+LH(32));
'@

SubRx @'
    ctx.fillText('press ENTER or walk to dismiss',W/2,wnY+wnH-LH(12));
    ctx.textAlign='left';
    if(p.moving){ WNSEEN=1; }
'@ @'
    ctx.fillText('press ENTER or walk to dismiss',_wnWW/2,wnY+wnH-LH(12));
    ctx.textAlign='left';
    ctx.restore();
    if(p.moving){ WNSEEN=1; }
'@

SubRx @'
var VER='19.20';
'@ @'
var VER='19.21';
'@

$pat = "(?m)^  now:'v19\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.21: At 4K the what is new card is as easy to read as at 1080p. Check 19.21 fails on v19.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

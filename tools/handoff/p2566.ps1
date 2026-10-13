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

# NO TEXT COLLIDES AT TOP CENTRE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var fb=FSz(TYPE.title,z), fs=FSz(TYPE.micro,z), mh=/([\d.]+)px/.exec(fb), h=mh?+mh[1]:20, w, gx;
'@ @'
  var fb=FSz(TYPE.title,z), fs=FSz(TYPE.micro,z), mh=/([\d.]+)px/.exec(fb), h=mh?+mh[1]:20, w, gx, yL=y, _bot;
  // v25.xx (topmid), HIS NOTE 2026-10-13: "text at top mid iscolliding". The SCORE label sat flush on the number under it (1 pixel of
  // ink over it at 1080p), so the number, the clock under it and everything below go down 4 pixels (times the screen scale) and the
  // label stays at the top edge. The function returns the bottom of its ink, for the compass stack to start under.
  y=y+Math.round(4*z); _bot=Math.round(y+h*0.22);
'@

SubRx @'
ctx.font=fs; ctx.fillStyle='#ffc04a'; hudText(solo?'SCORE':'TEAM SCORE',cx,Math.round(y-h*0.80));
'@ @'
ctx.font=fs; ctx.fillStyle='#ffc04a'; hudText(solo?'SCORE':'TEAM SCORE',cx,Math.round(yL-h*0.80));
'@

SubRx @'
ctx.font=_cfin?FSz(TYPE.head,z):fs; ctx.fillStyle=_cfin?'#ff5a4a':'#cdd6dd'; hudText(_cm+':'+(_cs<10?'0':'')+_cs,cx,_cy); if(_apo) ctx.restore();
'@ @'
ctx.font=_cfin?FSz(TYPE.head,z):fs; ctx.fillStyle=_cfin?'#ff5a4a':'#cdd6dd'; hudText(_cm+':'+(_cs<10?'0':'')+_cs,cx,_cy); if(_apo) ctx.restore();
    _bot=Math.max(_bot,Math.round(_cy+(+((/([\d.]+)px/.exec(ctx.font)||[0,14])[1]))*0.25));   // v25.xx (topmid): the bottom of the clock row
'@

SubRx @'
  if(_sx>1){ ctx.font=fb; ctx.textAlign='right'; ctx.fillStyle='#ffc04a'; hudText('x'+_sx,Math.round(cx-w/2-10*z),y); }
  ctx.restore();
}
'@ @'
  if(_sx>1){ ctx.font=fb; ctx.textAlign='right'; ctx.fillStyle='#ffc04a'; hudText('x'+_sx,Math.round(cx-w/2-10*z),y); }
  ctx.restore();
  return _bot;   // v25.xx (topmid): where the block ends, for the compass under it
}
'@

SubRx @'
if(G.arcade||G.career) arcadeScoreHud(_yClk,_tz); else {
'@ @'
if(G.arcade||G.career){ var _arcB=arcadeScoreHud(_yClk,_tz)||0; if(_arcB>0&&_yCmp<_arcB+Math.round(3*_tz+_hCmp*0.80)){ _yCmp=_arcB+Math.round(3*_tz+_hCmp*0.80); _yArw=Math.round(_yCmp+_hCmp*0.90); _yMk=Math.round(_yArw+_hMk*1.30); } } else {   /* v25.xx (topmid): the compass starts under the score block, not through its clock row */
'@

SubRx @'
var VER='25.65';
'@ @'
var VER='25.66';
'@

$pat = "(?m)^  now:'v25\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.66: The score, clock and EXTRACT lines at top centre no longer run into each other. Check 25.66 fails on v25.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# TWO MESSAGE ROWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    G.msg=m; G.msgT=3.2; G.msgK=k; G.msgSub=(o&&o.sub)||''; return;
'@ @'
    // v21.86, the raid text rewrite (R04): TWO ROWS INSTEAD OF ONE OVERWRITE. A second line said while one still showed wrote
    // over it, so two things that happened in the same second left only the last on screen. The line showing now moves down to
    // the second row (G.feed[1], with the time it had left) and the new one takes the top; a third pushes the oldest off. The
    // same line said again (a per-frame caller) only refreshes the top row. G.msg and G.msgT stay the top row, as before.
    var f=(G.feed=G.feed||[]);
    if(G.msgT>0&&G.msg&&G.msg!==m) f[1]={m:G.msg,k:G.msgK||'info',sub:G.msgSub||'',T:G.msgT};
    G.msg=m; G.msgT=3.2; G.msgK=k; G.msgSub=(o&&o.sub)||'';
    f[0]={m:m,k:k,sub:G.msgSub,T:3.2}; return;
'@

SubRx @'
      if(G.msgT>0) G.msgT-=dt;
'@ @'
      if(G.msgT>0) G.msgT-=dt;
      if(G.feed&&G.feed[1]&&G.feed[1].T>0) G.feed[1].T-=dt;   // v21.86 (R04): the second message row runs out on the same clock
'@

SubRx @'
var HUDBOSSB=0, HUDGIFTB=0;
'@ @'
var HUDBOSSB=0, HUDGIFTB=0, HUDMSGB=0;   // v21.86 (R04): HUDMSGB is the bottom of the message rows, set by msgLayout
'@

SubRx @'
var CONDWRAP={}, CONDWRAPN=0;   // v19.82: the CONDITIONS box's wrapped lines, by font, width and text (see wrap() below)
'@ @'
var CONDWRAP={}, CONDWRAPN=0;   // v19.82: the CONDITIONS box's wrapped lines, by font, width and text (see wrap() below)
// v21.86, the raid text rewrite (R04): THE MESSAGE ROWS ARE LAID OUT BEFORE ANYTHING UNDER THEM IS DRAWN. feedRows() is what the
// message band shows this frame, newest first: the top row (G.msg while G.msgT runs) and the row it pushed down, while that one
// still has time and the top row shows. msgLayout() runs at the top of drawHUD, before the boss bar, and sets HUDMSGB, the bottom
// of the band in screen pixels. With one row (or none) it is exactly the old fixed bottom, (LH(96)+LH(17)) under the message
// scale, so nothing moves; a second row adds one row step, and the boss bar, the offer line and the controller word start under it.
function feedRows(){
  var r=[], f;
  if(!G||!(G.msgT>0)||!G.msg) return r;
  r.push({m:G.msg,k:G.msgK||'info',sub:G.msgSub||'',T:G.msgT});
  f=G.feed&&G.feed[1];
  if(f&&f.T>0&&f.m&&f.m!==G.msg) r.push(f);
  return r;
}
function msgRowH(){ var mf=(/([\d.]+)px/).exec(FS(TYPE.label)), px=mf?parseFloat(mf[1]):LH(12); return Math.round(px*1.42); }
function msgLayout(){
  var z=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'), rows=feedRows(), ex=0;
  if(G) G.feed=rows;
  if(rows.length>1) ex=(rows.length-1)*(msgRowH()+LH(3));
  HUDMSGB=Math.round((LH(96)+LH(17)+ex)*z);
  return rows;
}
'@

SubRx @'
  y=Math.round((LH(96)+LH(17))*(HUDZ.msg||1)*hudRes()*hudUserZ('msg'))+LH(4)+LH(16);   // v20.55 (H38): the plate starts under the message plate, at every screen size and message size
'@ @'
  y=Math.round((LH(96)+LH(17))*(HUDZ.msg||1)*hudRes()*hudUserZ('msg'))+LH(4)+LH(16);   // v20.55 (H38): the plate starts under the message plate, at every screen size and message size
  if(HUDMSGB>0) y=HUDMSGB+LH(4)+LH(16);   // v21.86 (R04): under the message rows msgLayout laid out this frame (the same place with one row)
'@

SubRx @'
  try{ drawBossBar(); }catch(_bb){}   // v17.45: his pick 21
'@ @'
  try{ msgLayout(); }catch(_ml){ HUDMSGB=0; }   // v21.86 (R04): the message rows first, so everything under them knows where they end
  try{ drawBossBar(); }catch(_bb){}   // v17.45: his pick 21
'@

SubRx @'
  if(HUDBOSSB>0) y=Math.max(y,HUDBOSSB+LH(4)+LH(15));   // v20.55 (H38): its plate starts under the boss bar when the bar is up
'@ @'
  if(HUDBOSSB>0) y=Math.max(y,HUDBOSSB+LH(4)+LH(15));   // v20.55 (H38): its plate starts under the boss bar when the bar is up
  if(HUDMSGB>0) y=Math.max(y,HUDMSGB+LH(4)+LH(15));   // v21.86 (R04): and under a second message row (with one row this is LH(132) exactly)
'@

SubRx @'
_py=Math.max(LH(120),Math.ceil((Math.max(HUDBOSSB,HUDGIFTB)+LH(4))/_pz));
'@ @'
_py=Math.max(LH(120),Math.ceil((Math.max(HUDBOSSB,HUDGIFTB,HUDMSGB)+LH(4))/_pz));   // v21.86 (R04): and the message rows
'@

SubRx @'
  if(G.msgT>0){
    // v10.43, his answers 25 and 30
'@ @'
  var _frows=feedRows();   // v21.86 (R04): the rows msgLayout laid out
  if(_frows.length){
    // v10.43, his answers 25 and 30
'@

SubRx @'
    ctx.textAlign='center';
    var _ma=clamp(G.msgT,0,1), _mw=ctx.measureText(G.msg).width, _mf=(/([\d.]+)px/).exec(ctx.font), _mpx=_mf?parseFloat(_mf[1]):LH(12), _mh=Math.round(_mpx*1.42);
    ctx.globalAlpha=_ma;
    hudPlate(W/2-_mw/2-LH(8),LH(96),_mw+LH(16),_mh);
    ctx.fillStyle=HUDC.text;
    hudText(G.msg,W/2,LH(96)+Math.round(_mh*13/17),2);
'@ @'
    // v21.86 (R04): one plate per row, the newest on top at LH(96) and the one it pushed down a row step under it at 75% alpha.
    ctx.textAlign='center';
    var _mh=msgRowH(), _mst=_mh+LH(3);
    for(var _mri=0;_mri<_frows.length;_mri++){
      var _mrw=_frows[_mri], _ma=clamp(_mrw.T,0,1)*(_mri?0.75:1), _mw=ctx.measureText(_mrw.m).width, _mty=LH(96)+_mri*_mst;
      ctx.globalAlpha=_ma;
      hudPlate(W/2-_mw/2-LH(8),_mty,_mw+LH(16),_mh);
      ctx.fillStyle=HUDC.text;
      hudText(_mrw.m,W/2,_mty+Math.round(_mh*13/17),2);
    }
    ctx.globalAlpha=1;
'@

SubRx @'
var VER='21.85';
'@ @'
var VER='21.86';
'@

$pat = "(?m)^  now:'v21\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.86: Two raid lines in the same second both show, the newest on top, instead of the second erasing the first. Check 21.86 fails on v21.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# THE MESSAGE LINE TAKES THE NEW LOOK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudFS(spec){ var f=FS(spec), r=Math.max(1,(typeof hudRes==='function')?hudRes():1); return (r===1)?f:f.replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*r).toFixed(1)+'px'; }); }
'@ @'
function hudFS(spec){ var f=FS(spec), r=Math.max(1,(typeof hudRes==='function')?hudRes():1); return (r===1)?f:f.replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*r).toFixed(1)+'px'; }); }
// v21.82, THE RAID TEXT REWRITE (R03): ONE LOOK. His order of 2026-10-09 is that the raid text reads like a shooter HUD, and a
// shooter HUD has one look: a few colours that each mean one thing, text that reads on any ground, and plates that fit their
// words. HUDC is that palette (text, dim, danger the only red, warn, extract for extraction only, gain, ally for every teammate
// mark, special for elites and caches), with the two plates and the ink outline. hudPlate draws a rounded plate (LH(4) corners)
// with an optional accent bar down its left edge in a kind colour. hudText outlines a line in ink (round joins, 2 x hudRes px
// unless the caller is already under a screen scale and passes its own width) and fills it on top. strokeText does not come
// through the TX door, so it is handed TX(s) here; the fill goes through the door as every line does. No shadowBlur: frame cost.
var HUDC={text:'#e8f0f6', dim:'#8a96a1', danger:'#ff5a4a', warn:'#ffc04a', extract:'#4de3d0', gain:'#7fc4a0', ally:'#bfe0ff',
  special:'#d08ce8', plate:'rgba(6,9,13,.78)', dangerPlate:'rgba(40,8,6,.84)', ink:INK};
function hudPlate(x,y,w,h,accent,fill){
  if(!(w>0&&h>0)) return;
  var r=Math.max(0,Math.min(LH(4),h/2,w/2));
  ctx.fillStyle=fill||HUDC.plate;
  ctx.beginPath();
  if(ctx.roundRect) ctx.roundRect(x,y,w,h,r);
  else { ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r); ctx.arcTo(x+w,y+h,x,y+h,r); ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath(); }
  ctx.fill();
  if(accent){ ctx.fillStyle=accent; ctx.fillRect(x,y+r*0.5,Math.max(2,LH(3)),h-r); }
}
function hudText(s,x,y,lw){
  var t=(typeof s==='string')?s:String(s);
  if(!t) return;
  var oj=ctx.lineJoin, ow=ctx.lineWidth, os=ctx.strokeStyle;
  ctx.lineJoin='round'; ctx.lineWidth=(lw>0)?lw:2*Math.max(1,(typeof hudRes==='function')?hudRes():1); ctx.strokeStyle=HUDC.ink;
  ctx.strokeText(TX(t),x,y);
  ctx.lineJoin=oj; ctx.lineWidth=ow; ctx.strokeStyle=os;
  ctx.fillText(t,x,y);
}
'@

SubRx @'
    ctx.font=FS(TYPE.label);
    ctx.fillStyle='rgba(205,214,221,'+clamp(G.msgT,0,1)+')';
'@ @'
    ctx.font=FS(TYPE.label);
'@

SubRx @'
    ctx.textAlign='center';
    var _mw=ctx.measureText(G.msg).width;
    ctx.fillStyle='rgba(6,9,13,'+(0.62*clamp(G.msgT,0,1))+')';
    ctx.fillRect(W/2-_mw/2-LH(8),LH(96),_mw+LH(16),LH(17));
    ctx.fillStyle='rgba(232,240,246,'+clamp(G.msgT,0,1)+')';
    ctx.fillText(G.msg,W/2,LH(109));
'@ @'
    // v21.82, the raid text rewrite (R03): the message line is the first to take the one look. Its plate is a rounded hudPlate
    // whose height comes from the font it carries (1.42 x the px, which is LH(17) at every default size, so the boss bar and the
    // offer line under it keep their places), the words are outlined in ink so they read over snow and over fire alike, and the
    // fade is one alpha for plate and words. The fillStyle that was set here and overwritten before anything was drawn is gone.
    ctx.textAlign='center';
    var _ma=clamp(G.msgT,0,1), _mw=ctx.measureText(G.msg).width, _mf=(/([\d.]+)px/).exec(ctx.font), _mpx=_mf?parseFloat(_mf[1]):LH(12), _mh=Math.round(_mpx*1.42);
    ctx.globalAlpha=_ma;
    hudPlate(W/2-_mw/2-LH(8),LH(96),_mw+LH(16),_mh);
    ctx.fillStyle=HUDC.text;
    hudText(G.msg,W/2,LH(96)+Math.round(_mh*13/17),2);
'@

SubRx @'
var VER='21.81';
'@ @'
var VER='21.82';
'@

$pat = "(?m)^  now:'v21\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.82: The raid message line is outlined in ink on a rounded plate, the first part of the new HUD look. Check 21.82 fails on v21.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

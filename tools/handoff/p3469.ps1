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

# ONE CORNER PANEL LOOK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
dangerPlate:'rgba(40,8,6,.84)', ink:INK};
'@ @'
dangerPlate:'rgba(40,8,6,.84)', ink:INK};
// v34.69 (cw-hudpanel1), the critic on screens 47, 48 and 51 (every corner has a differently shaped box): ONE corner panel look, the fill of HUDC.plate, a 1px line and a 4px radius. hudPlate and hudPanel both read it (hudPanel had a cut corner, hudPlate had no line).
var HUDPS={fill:HUDC.plate, line:'rgba(112,122,130,.95)', rad:4};
'@

SubRx @'
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
function hudText
'@ @'
function hudPlate(x,y,w,h,accent,fill){
  if(!(w>0&&h>0)) return;
  var r=Math.max(0,Math.min(LH(HUDPS.rad),h/2,w/2));
  ctx.fillStyle=fill||HUDPS.fill;
  ctx.beginPath();
  if(ctx.roundRect) ctx.roundRect(x,y,w,h,r);
  else { ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r); ctx.arcTo(x+w,y+h,x,y+h,r); ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath(); }
  ctx.fill();
  ctx.beginPath();   // v34.69 (cw-hudpanel1): the shared 1px line
  if(ctx.roundRect) ctx.roundRect(x+.5,y+.5,w-1,h-1,Math.max(0,r-.5));
  else ctx.rect(x+.5,y+.5,w-1,h-1);
  ctx.strokeStyle=HUDPS.line; ctx.lineWidth=1; ctx.stroke();
  if(accent){ ctx.fillStyle=accent; ctx.fillRect(x,y+r*0.5,Math.max(2,LH(3)),h-r); }
}
function hudText
'@

SubRx @'
  c=Math.max(0,Math.min(10,w/3,h/3)); a=(a===undefined)?0.88:a;
  function path(px,py,pw,ph,pc){ ctx.beginPath(); ctx.moveTo(px+pc,py); ctx.lineTo(px+pw,py); ctx.lineTo(px+pw,py+ph); ctx.lineTo(px,py+ph); ctx.lineTo(px,py+pc); ctx.closePath(); }
'@ @'
  c=Math.max(0,Math.min(LH(HUDPS.rad),w/3,h/3)); a=(a===undefined)?0.88:a;   // v34.69 (cw-hudpanel1): the shared 4px radius, not a cut corner
  function path(px,py,pw,ph,pc){ ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(px,py,pw,ph,pc); else ctx.rect(px,py,pw,ph); }
'@

SubRx @'
ctx.strokeStyle='rgba(112,122,130,.95)'; ctx.lineWidth=1; ctx.stroke();   // v28.xx (cw-panelflat)
'@ @'
ctx.strokeStyle=HUDPS.line; ctx.lineWidth=1; ctx.stroke();   // v28.xx (cw-panelflat)
'@

SubRx @'
var VER='34.68';
'@ @'
var VER='34.69';
'@

$pat = "(?m)^  now:'v34\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.69: The raid hud panels (score, ammo, log rows, controls) all share one fill, one border and 4px round corners. Check 34.69 fails on v34.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

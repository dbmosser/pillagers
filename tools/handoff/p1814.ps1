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

# THE ITEM ICONS GET A LIFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var _iconURL={};
'@ @'
// v18.14, HIS ORDER (2026-10-03, the item graphics): THE LIFT. Every non-gun icon the menus show was a flat shape. After the
// painter has drawn it, the painted shape gets a light from the top left and a shade toward the bottom right (clipped to the
// shape, so nothing spills), and a soft dark shadow under it, so a bandage or a plate sits in its cell like an object instead
// of a sticker. Guns shade themselves (v18.10) and are left alone.
function iconLift(c,w,h){
  var g, t, tc;
  if(!c||!(w>0&&h>0)) return false;
  try{
    c.save(); c.globalCompositeOperation='source-atop';
    // two half gradients meeting at the middle: a stop that is transparent white next to one that is transparent black, or the
    // shaded half interpolates toward light grey and never darkens anything
    g=c.createLinearGradient(0,0,w,h); g.addColorStop(0,'rgba(255,255,255,.22)'); g.addColorStop(0.5,'rgba(255,255,255,0)'); g.addColorStop(0.5,'rgba(0,0,0,0)'); g.addColorStop(1,'rgba(0,0,0,.30)');
    c.fillStyle=g; c.fillRect(0,0,w,h); c.restore();
    t=document.createElement('canvas'); t.width=w; t.height=h; tc=t.getContext('2d');
    tc.drawImage(c.canvas,0,0); tc.globalCompositeOperation='source-in'; tc.fillStyle='rgba(0,0,0,.55)'; tc.fillRect(0,0,w,h);
    c.save(); c.globalCompositeOperation='destination-over'; try{ c.filter='blur('+Math.max(0.6,w*0.015).toFixed(2)+'px)'; }catch(_f){}
    c.drawImage(t,w*0.025,h*0.04); c.restore();
    return true;
  }catch(e){ try{ c.restore(); }catch(_r){} return false; }
}
var _iconURL={};
'@

SubRx @'
  drawItemIcon(c2,key,S*R/2,S*R/2,S*R*0.82);
  return _iconURL[ck]=cnv.toDataURL();
'@ @'
  drawItemIcon(c2,key,S*R/2,S*R/2,S*R*0.82);
  if(!(WEAPONS[key]||(ITEMS[key]&&ITEMS[key].use==='gun'))) iconLift(c2,S*R,S*R);   // v18.14: the lift, for everything but a gun
  return _iconURL[ck]=cnv.toDataURL();
'@

SubRx @'
var VER='18.13';
'@ @'
var VER='18.14';
'@

$pat = "(?m)^  now:'v18\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.14: Item pictures in the menus have light, shade and a shadow now, not flat shapes. Check 18.14 fails on v18.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# THE BELT AND THE BACKPACK DRAW THE NEW ICONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function iconLift(c,w,h){
'@ @'
// v18.33, THE ART PASS IN THE RAID (2026-10-04): THE BELT AND THE BACKPACK DRAW THE MENU ICONS. The raid belt and backpack
// painted every icon live on the HUD canvas each frame, flat and without the lift the menus got (v18.14). They now draw a
// sprite painted once per item and size, at the screen scale, with the same lift: sharper, shaded like the stash, and one draw
// call per icon instead of thirty fills. A size or screen scale change paints a new sprite; the store is capped.
var ICONSPR={m:{},n:0};
function iconSprite(key,S){
  var R, side, k, e, cv2, c2, it;
  if(!(S>0)) return null;
  R=Math.max(1,Math.min(3,Math.round((typeof DPR==='number'&&DPR>0)?DPR*1.5:1.5)));
  k=key+'|'+Math.round(S)+'|'+R; e=ICONSPR.m[k];
  if(e) return e;
  side=Math.ceil(S*1.3*R);
  cv2=document.createElement('canvas'); cv2.width=side; cv2.height=side; c2=cv2.getContext('2d'); if(!c2) return null;
  drawItemIcon(c2,key,side/2,side/2,S*R);
  it=ITEMS[key];
  if(!(WEAPONS[key]||(it&&it.use==='gun'))&&typeof iconLift==='function') iconLift(c2,side,side);
  if(ICONSPR.n>400){ ICONSPR.m={}; ICONSPR.n=0; }
  e={c:cv2,s:side/R}; ICONSPR.m[k]=e; ICONSPR.n++;
  return e;
}
function drawIconSprite(c,key,cx,cy,S){
  var e=null;
  try{ e=iconSprite(key,S); }catch(_is){ e=null; }
  if(!e){ drawItemIcon(c,key,cx,cy,S); return false; }
  c.drawImage(e.c,cx-e.s/2,cy-e.s/2,e.s,e.s);
  return true;
}
function iconLift(c,w,h){
'@

SubRx @'
      if(S.icon){ drawItemIcon(ctx,S.icon,cx2,cy2,bw*0.64); }
'@ @'
      if(S.icon){ drawIconSprite(ctx,S.icon,cx2,cy2,bw*0.64); }   // v18.33: the sprite icon
'@

SubRx @'
      drawItemIcon(ctx,st.key,tx+TILE/2,ty+TILE/2-LH(2),TILE*0.62);
'@ @'
      drawIconSprite(ctx,st.key,tx+TILE/2,ty+TILE/2-LH(2),TILE*0.62);   // v18.33: the sprite icon
'@

SubRx @'
  drawItemIcon(ctx,p.wep.id,x+11+LH(16),cy-LH(2),LH(30));
'@ @'
  drawIconSprite(ctx,p.wep.id,x+11+LH(16),cy-LH(2),LH(30));   // v18.33: the sprite icon
'@

SubRx @'
var VER='18.32';
'@ @'
var VER='18.33';
'@

$pat = "(?m)^  now:'v18\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.33: The tactical belt and the raid backpack show the same shaded, sharp icons as the stash. Check 18.33 fails on v18.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

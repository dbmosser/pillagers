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

# THE RAID PANELS ARE THE MENU PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudPanel(x,y,w,h,a){
  var r, g;
  if(!(w>0&&h>0)) return;
  r=Math.min(6,w/2,h/2); a=(a===undefined)?0.76:a;
  function path(px,py,pw,ph,pr){ pr=Math.max(0,Math.min(pr,pw/2,ph/2)); ctx.beginPath(); ctx.moveTo(px+pr,py); ctx.lineTo(px+pw-pr,py); ctx.quadraticCurveTo(px+pw,py,px+pw,py+pr); ctx.lineTo(px+pw,py+ph-pr); ctx.quadraticCurveTo(px+pw,py+ph,px+pw-pr,py+ph); ctx.lineTo(px+pr,py+ph); ctx.quadraticCurveTo(px,py+ph,px,py+ph-pr); ctx.lineTo(px,py+pr); ctx.quadraticCurveTo(px,py,px+pr,py); ctx.closePath(); }
  ctx.save();
  path(x,y,w,h,r);
  try{ g=ctx.createLinearGradient(0,y,0,y+h); g.addColorStop(0,'rgba(14,19,40,'+a+')'); g.addColorStop(1,'rgba(6,9,13,'+a+')'); ctx.fillStyle=g; }catch(_g){ ctx.fillStyle='rgba(6,9,13,'+a+')'; }
  ctx.fill();
  path(x+.5,y+.5,w-1,h-1,r);
  ctx.strokeStyle='rgba(127,146,216,.42)'; ctx.lineWidth=1; ctx.stroke();
  ctx.beginPath(); ctx.moveTo(x+r,y+1.5); ctx.lineTo(x+w-r,y+1.5); ctx.strokeStyle='rgba(255,255,255,.06)'; ctx.lineWidth=1; ctx.stroke();
  ctx.restore();
}

'@ @'
// vNN.xx, UI REDESIGN ui5q1k (his #50, and his #35: redo the HUD as part of the graphics work, keep all the critical info), from the
// AAA judge of the raid HUD shots: THE HUD PANEL IS THE MENU PLATE. The raid panels (conditions and contracts, the pillager board, the
// legends, the backpack) were navy glass with a periwinkle line and round corners, the look the menus left behind at ui5 and ui6, and
// at 76 percent a world label (THE ... DOCK CACHE) read through the contracts panel. They are the plate of the menus now: graphite,
// the top left corner cut at 10px, a hairline edge and a short amber tick on the top edge; the default fill is 88 percent, so the
// world does not read through. A caller that asks for its own fill keeps it. Every position, size and hit box is what it was.
function hudPanel(x,y,w,h,a){
  var c, g;
  if(!(w>0&&h>0)) return;
  c=Math.max(0,Math.min(10,w/3,h/3)); a=(a===undefined)?0.88:a;
  function path(px,py,pw,ph,pc){ ctx.beginPath(); ctx.moveTo(px+pc,py); ctx.lineTo(px+pw,py); ctx.lineTo(px+pw,py+ph); ctx.lineTo(px,py+ph); ctx.lineTo(px,py+pc); ctx.closePath(); }
  ctx.save();
  path(x,y,w,h,c);
  try{ g=ctx.createLinearGradient(0,y,0,y+h); g.addColorStop(0,'rgba(24,27,30,'+a+')'); g.addColorStop(1,'rgba(14,16,18,'+a+')'); ctx.fillStyle=g; }catch(_g){ ctx.fillStyle='rgba(17,19,21,'+a+')'; }
  ctx.fill();
  path(x+.5,y+.5,w-1,h-1,Math.max(0,c-.5));
  ctx.strokeStyle='rgba(74,82,87,.9)'; ctx.lineWidth=1; ctx.stroke();
  if(w>c+20){ ctx.fillStyle='#f5b73b'; ctx.fillRect(x+c+4,y,Math.min(36,w*0.25),2); }   // the amber tick of the menu plate (ui6)
  ctx.restore();
}
'@

SubRx @'
var VER='24.66';
'@ @'
var VER='24.67';
'@

$pat = "(?m)^  now:'v24\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.67: The raid HUD panels are the graphite plate of the menus, solid enough that the map does not show through. Check 24.67 fails on v24.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

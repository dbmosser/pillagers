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

# AIR STRIKE CLEARS THE HELD ITEM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawHand(){
  var p=G&&G.player, h=p&&p.hand, it, bw, bh, x, y, c0, fl, st, vb;
  if(!h||!ITEMS[h.k]||G.wheel) return;
  it=ITEMS[h.k]; c0=(G.hotCells&&G.hotCells[0])?G.hotCells[0].y:H-LH(130);
  bw=LH(250); bh=LH(46); x=Math.round(W/2-bw/2); y=Math.round(c0-bh-LH(26));
  ctx.save();
  hudPlate(x,y,bw,bh,UIC.acc,HUDC.plate);
  drawIconSprite(ctx,h.k,x+LH(30),y+bh/2,LH(34));
  ctx.textAlign='left'; ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_1; hudText(String(it.name).toUpperCase(),x+LH(54),y+LH(19));
  fl=(h.len>0)?1-h.t/h.len:1;
  if(h.t>0){
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.tx_2; hudText('READYING',x+LH(54),y+LH(36));
    ctx.fillStyle='rgba(255,255,255,.12)'; ctx.fillRect(x+LH(12),y+bh-LH(5),bw-LH(24),LH(3));
    ctx.fillStyle=UIC.acc; ctx.fillRect(x+LH(12),y+bh-LH(5),(bw-LH(24))*fl,LH(3));
  } else {
    st=(it.use==='throw')?(h.k==='trip'?'PLACE':'THROW'):(it.use==='armor'?'SLOT':(it.use==='stim'?'INJECT':'APPLY'));
    ctx.font=FS(TYPE.micro); vb=padOn()?pbn(7):'LMB';
    hudKey(vb,x+LH(52),y+LH(38),LH(8),LH(34));
    ctx.textAlign='left'; ctx.fillStyle=UIC.acc; hudText(st,x+LH(52)+LH(42),y+LH(36));
  }
  ctx.restore();
}
'@ @'
// v28.xx (cw-cx-airhandclear): the held-item panel is also an obstacle for the air-strike plate; share its actual bounds with drawing.
function handPlateBox(){
  var p=G&&G.player, h=p&&p.hand, c0, bw, bh;
  if(!h||!ITEMS[h.k]||G.wheel) return null;
  c0=(G.hotCells&&G.hotCells[0])?G.hotCells[0].y:H-LH(130);
  bw=LH(250); bh=LH(46);
  return {x:Math.round(W/2-bw/2),y:Math.round(c0-bh-LH(26)),w:bw,h:bh};
}
function drawHand(){
  var p=G&&G.player, h=p&&p.hand, it, bw, bh, x, y, c0, fl, st, vb;
  if(!h||!ITEMS[h.k]||G.wheel) return;
  it=ITEMS[h.k]; var hb=handPlateBox(); if(!hb) return;
  bw=hb.w; bh=hb.h; x=hb.x; y=hb.y;
  ctx.save();
  hudPlate(x,y,bw,bh,UIC.acc,HUDC.plate);
  drawIconSprite(ctx,h.k,x+LH(30),y+bh/2,LH(34));
  ctx.textAlign='left'; ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_1; hudText(String(it.name).toUpperCase(),x+LH(54),y+LH(19));
  fl=(h.len>0)?1-h.t/h.len:1;
  if(h.t>0){
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.tx_2; hudText('READYING',x+LH(54),y+LH(36));
    ctx.fillStyle='rgba(255,255,255,.12)'; ctx.fillRect(x+LH(12),y+bh-LH(5),bw-LH(24),LH(3));
    ctx.fillStyle=UIC.acc; ctx.fillRect(x+LH(12),y+bh-LH(5),(bw-LH(24))*fl,LH(3));
  } else {
    st=(it.use==='throw')?(h.k==='trip'?'PLACE':'THROW'):(it.use==='armor'?'SLOT':(it.use==='stim'?'INJECT':'APPLY'));
    ctx.font=FS(TYPE.micro); vb=padOn()?pbn(7):'LMB';
    hudKey(vb,x+LH(52),y+LH(38),LH(8),LH(34));
    ctx.textAlign='left'; ctx.fillStyle=UIC.acc; hudText(st,x+LH(52)+LH(42),y+LH(36));
  }
  ctx.restore();
}
'@

SubRx @'
function airPlateAt(bw,bh,z){
  var hc=G.hotCells, L=(hc&&hc.length)?hc[hc.length-1]:null, g8=Math.round(8*z), x, y, top=1e9, i, o, tries, hit, E, R;
  if(!L) return {x:Math.round(W-bw-16*z),y:Math.round(H*0.6)};
  for(i=0;i<hc.length;i++) top=Math.min(top,hc[i].y);
  x=Math.round(L.x+L.w-bw);
  y=Math.round(top-64*z-g8-bh);
  E=[HUDBOX.gear,(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.pick:null,(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.gun:null,(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.feed:null];
  for(tries=0;tries<4;tries++){
    hit=null;
    for(i=0;i<E.length;i++){ o=E[i]; if(o&&o.w>0&&o.h>0&&x<o.x+o.w+g8&&x+bw>o.x-g8&&y<o.y+o.h+g8&&y+bh>o.y-g8){ hit=o; break; } }
    if(!hit) break;
    y=Math.round(hit.y-g8-bh);
  }
  return {x:clamp(x,g8,Math.max(g8,W-bw-g8)),y:Math.max(g8,y)};
}
'@ @'
function airPlateAt(bw,bh,z){
  var hc=G.hotCells, L=(hc&&hc.length)?hc[hc.length-1]:null, g8=Math.round(8*z), x, y, top=1e9, i, o, tries, hit, E, R;
  if(!L) return {x:Math.round(W-bw-16*z),y:Math.round(H*0.6)};
  for(i=0;i<hc.length;i++) top=Math.min(top,hc[i].y);
  x=Math.round(L.x+L.w-bw);
  y=Math.round(top-64*z-g8-bh);
  E=[HUDBOX.gear,handPlateBox(),(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.pick:null,(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.gun:null,(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.feed:null];
  // v28.xx (cw-cx-airhandclear): a narrow belt may need a vertical clearance above the held-item panel.
  for(tries=0;tries<E.length+1;tries++){
    hit=null;
    for(i=0;i<E.length;i++){ o=E[i]; if(o&&o.w>0&&o.h>0&&x<o.x+o.w+g8&&x+bw>o.x-g8&&y<o.y+o.h+g8&&y+bh>o.y-g8){ hit=o; break; } }
    if(!hit) break;
    y=Math.floor(hit.y-g8-bh);
  }
  return {x:clamp(x,g8,Math.max(g8,W-bw-g8)),y:Math.max(g8,y)};
}
'@

SubRx @'
var VER='32.85';
'@ @'
var VER='32.86';
'@

$pat = "(?m)^  now:'v32\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.86: The air-strike plate lifts above an item in hand when the belt is too narrow to clear it sideways. Its right edge stays aligned with the belt. Check 32.86 fails on v32.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

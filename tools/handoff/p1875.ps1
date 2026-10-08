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

# BANDAGES, MEDKITS AND PLATES SHOW A USE BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawBossBar(){
'@ @'
// v18.75, HIS NOTE (2026-10-07): "need to be a bar for using the bandage/med pack, like how the bar to use armor works". Both
// wind-ups (v3.54: 1.5 s for medical, 2 s for a plate) had only a small strip above the player, 48 world units wide, easy to
// miss on a TV and gone into the crowd of a fight. Each wind-up now also gets a HUD bar, centred above the belt, with what is
// going on and the seconds left: APPLYING BANDAGE, APPLYING MEDKIT, SLOTTING ARMOUR PLATE, or ... ON NAME for a teammate. Two
// at once (a plate while a bandage goes on, v11.82) stack, the plate above. Drawn on the HUD after its clear. Returns how many.
function drawUseBar(){
  var p=G&&G.player, L=[], i, PR, it, nm, f, w, h, x, y, by, cap, s, n=0, bw0, hr;
  if(!p||G.over||G.sim) return 0;
  if(p.prep) L.push(p.prep);
  if(p.prepA) L.push(p.prepA);
  if(!L.length) return 0;
  hr=(typeof hudRes==='function')?hudRes():1;
  bw0=(G.hotCells&&G.hotCells.length)?G.hotCells[0].w:LH(60);
  by=(G.hotCells&&G.hotCells.length)?G.hotCells[0].y:(H-LH(80));
  cap=Math.round(Math.max(LH(11),bw0*0.12));   // the belt caption over the slots (v18.71)
  w=Math.round(Math.min(LH(300)*hr,W*0.34)); h=Math.max(6,Math.round(LH(9)*hr));
  x=Math.round(W/2-w/2);
  y=Math.round(by-LH(6)-cap-LH(12)-h);
  ctx.save();
  ctx.font=FS(TYPE.label); ctx.textAlign='center';
  for(i=0;i<L.length;i++){
    PR=L[i]; it=ITEMS[PR.key]; nm=(it&&it.name)?it.name.toUpperCase():(PR.kind==='armor'?'ARMOUR PLATE':'MEDICAL');
    f=clamp((PR.t||0)/(PR.max||1),0,1);
    s=(PR.kind==='armor'?'SLOTTING ':'APPLYING ')+nm;
    if(typeof PR.aid==='number'){ try{ s+=' ON '+String(netSeatName(PR.aid)||'YOUR TEAMMATE').toUpperCase(); }catch(_an){ s+=' ON YOUR TEAMMATE'; } }
    s+='   '+Math.max(0,(PR.max||0)-(PR.t||0)).toFixed(1)+'s';
    if(typeof hudPanel==='function') hudPanel(x-LH(10),y-LH(20),w+LH(20),h+LH(28),0.78);
    else { ctx.fillStyle='rgba(6,9,13,.78)'; ctx.fillRect(x-LH(10),y-LH(20),w+LH(20),h+LH(28)); }
    ctx.fillStyle='#e8f0f6'; ctx.fillText(s,W/2,y-LH(6));
    ctx.fillStyle='rgba(255,255,255,.12)'; ctx.fillRect(x,y,w,h);
    ctx.fillStyle=(PR.kind==='armor')?'#5aa9e6':'#6fe0a0'; ctx.fillRect(x,y,Math.round(w*f),h);
    n++;
    y-=h+LH(34);
  }
  ctx.restore();
  return n;
}
function drawBossBar(){
'@

SubRx @'
  try{ drawGiftLine(); }catch(_gl){}   // v17.52: an open trade offer stays on screen
'@ @'
  try{ drawGiftLine(); }catch(_gl){}   // v17.52: an open trade offer stays on screen
  try{ drawUseBar(); }catch(_ub){}   // v18.75, his note: the bandage, medkit and plate wind-ups on the HUD
'@

SubRx @'
    var _py=p.y-62-((_pbi&&p.prep)?10:0);
    wc.fillStyle='rgba(6,9,13,.85)';
    wc.fillRect(p.x-24,_py,48,8);
    wc.strokeStyle='rgba(255,255,255,.22)'; wc.lineWidth=1;
    wc.strokeRect(p.x-23.5,_py+0.5,47,7);
    wc.fillStyle=_pb.kind==='armor'?'#5aa9e6':'#6fe0a0';
    wc.fillRect(p.x-23,_py+1,46*_pf,6);
'@ @'
    var _py=p.y-68-((_pbi&&p.prep)?13:0);   // v18.75: a size bigger (was 48 by 8), with the HUD bar (drawUseBar) as well
    wc.fillStyle='rgba(6,9,13,.85)';
    wc.fillRect(p.x-32,_py,64,11);
    wc.strokeStyle='rgba(255,255,255,.22)'; wc.lineWidth=1;
    wc.strokeRect(p.x-31.5,_py+0.5,63,10);
    wc.fillStyle=_pb.kind==='armor'?'#5aa9e6':'#6fe0a0';
    wc.fillRect(p.x-31,_py+1,62*_pf,9);
'@

SubRx @'
var VER='18.74';
'@ @'
var VER='18.75';
'@

$pat = "(?m)^  now:'v18\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.75: Using a bandage, medkit or armour plate shows a clear progress bar above your belt with the seconds left. Check 18.75 fails on v18.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

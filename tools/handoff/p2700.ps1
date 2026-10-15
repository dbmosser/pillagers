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

# THE NEEDED-ITEM GLOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function careerTick(dt){
'@ @'
// v26.xx (career3), HIS YES (2026-10-14) to suggestion 31, THE NEEDED-ITEM GLOW, with his answer to "glow where and how? ground items are boxes": glow the CONTAINER
// that holds an item you need, and the item itself in the pickup stack and in the backpack. WHAT IS NEEDED is what the game's own board asks you to carry out: an item
// of an unfinished extraction contract (the exItem cards: a Circuit Board, an Optic, a Servo, a Data Core), still short of its count by what this raid has earned
// (the lift's own kit does not count, as at the extraction). It is worked out once a second (needRefresh, from careerTick) into G.need, item to the number still
// short. A box glows while it is shut and still holds one of those (it stops the moment the item is pulled out or the card is done): a gold ring and a soft light
// on the box, under the fog like the box itself, with a small diamond over it. The item gets the same gold edge on its cell in the backpack and on its row in the
// pickup stack. There are no contracts in the DEMO and the glow does not exist there. Display only: nothing that is dropped, found or paid moves.
function needItems(){
  var o={}, i, j, c, have, up, rem, bag, kit;
  if(!P||!Array.isArray(P.contracts)||typeof G==='undefined'||!G||G.sim||G.arcade) return o;
  bag=G.bag||[]; kit=G.carriedKit||[];
  for(i=0;i<P.contracts.length;i++){
    c=P.contracts[i];
    if(!c||c.type!=='exItem'||!c.item||!ITEMS[c.item]||(c.prog|0)>=(c.n|0)) continue;
    have=0; for(j=0;j<bag.length;j++) if(bag[j]===c.item) have++;
    up=0; for(j=0;j<kit.length;j++) if(kit[j]===c.item) up++;
    rem=(c.n|0)-Math.max(0,have-up);
    if(rem>0) o[c.item]=(o[c.item]||0)+rem;
  }
  return o;
}
function needRefresh(){
  var n=0, k;
  if(!G||G.sim) return 0;
  G.need=needItems();
  for(k in G.need) n++;
  G.needN=n;
  return n;
}
function needHolds(ct){
  var lo, i;
  if(!G||!G.need||!G.needN||!ct||ct.opened||ct.net) return false;
  lo=ct.loot; if(!lo||!lo.length) return false;
  for(i=0;i<lo.length;i++) if(G.need[lo[i]]>0) return true;
  return false;
}
function needGlow(wc,ct,lift,d2){
  var cx=ct.x, cy=ct.y-lift-d2-3, pu=.55+.45*Math.sin((+G.t||0)*4.2+ct.x*.03);
  wc.save();
  wc.globalCompositeOperation='lighter';
  wc.globalAlpha=.24*pu; wc.fillStyle='#ffd452'; wc.beginPath(); wc.arc(cx,cy,27,0,6.2832); wc.fill();
  wc.globalAlpha=Math.min(1,.8*pu+.2); wc.strokeStyle='#ffd452'; wc.lineWidth=2.4; wc.beginPath(); wc.arc(cx,cy,17,0,6.2832); wc.stroke();
  wc.globalAlpha=.95; wc.fillStyle='#fff0b0';
  wc.beginPath(); wc.moveTo(cx,cy-32); wc.lineTo(cx+5,cy-26); wc.lineTo(cx,cy-20); wc.lineTo(cx-5,cy-26); wc.closePath(); wc.fill();
  wc.restore();
}
function careerTick(dt){
'@

SubRx @'
  G.cxT=1;
  codexScan();
'@ @'
  G.cxT=1;
  codexScan();
  needRefresh();
'@

SubRx @'
if(!G.sim&&ammoTell(ct)){
'@ @'
if(!G.sim&&needHolds(ct)) needGlow(wc,ct,lift,d2);   // v26.xx (career3): a box that holds an item a contract needs
    if(!G.sim&&ammoTell(ct)){
'@

SubRx @'
ctx.strokeRect(tx+.5,ty+.5,TILE-1,TILE-1);
'@ @'
ctx.strokeRect(tx+.5,ty+.5,TILE-1,TILE-1);
      if(G.need&&G.need[st.key]>0){ ctx.save(); ctx.strokeStyle='#ffd452'; ctx.lineWidth=Math.max(2,LH(2)*BZ); ctx.globalAlpha=.75+.25*Math.sin((+G.t||0)*4); ctx.strokeRect(tx+2,ty+2,TILE-4,TILE-4); ctx.restore(); }   // v26.xx (career3): an item a contract needs
'@

SubRx @'
hudPlate(xR-w,y-rh,w,rh,col,HUDC.plate);
'@ @'
hudPlate(xR-w,y-rh,w,rh,col,HUDC.plate);
      if(r.item&&G.need&&G.need[r.item]>0){ ctx.strokeStyle='#ffd452'; ctx.lineWidth=Math.max(2,rs*1.5); ctx.strokeRect(xR-w+1,y-rh+1,w-2,rh-2); }   // v26.xx (career3): an item a contract needs
'@

SubRx @'
var VER='26.99';
'@ @'
var VER='27.00';
'@

$pat = "(?m)^  now:'v26\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.00: A box that holds an item your contract needs glows gold, and so does the item. Check 27.00 fails on v26.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

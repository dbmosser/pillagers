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

# TRADING IS DROPPING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function dropItem(idx){
'@ @'
// v18.27, HIS ORDER (2026-10-03, "trading sounds way too complicated"): TRADING IS DROPPING. Drop an item (Z on keys, Y on a
// controller with the backpack open) and it is a pile at your feet; your teammate searches it like any box. The offer words of
// v17.44 stay in the code but nothing teaches them any more. One drop function for the key and the button.
function bagDropSel(){
  var S=bagStacks(), n=S.length, st=S[clamp(G.bagSel|0,0,Math.max(0,n-1))], dk;
  if(!st||!st.idxs||!st.idxs.length) return false;
  dk=dropItem(st.idxs[st.idxs.length-1]);
  if(dk){ say('Dropped '+ITEMS[dk].name+((typeof NET==='object'&&NET&&NET.on)?'. Your teammate can search it.':'')); blip('clank'); }
  n=bagStacks().length; if(G.bagSel>=n) G.bagSel=Math.max(0,n-1);
  return !!dk;
}
// THE HOST: one of the party dropped an item; the pile is made here, at the spot he named, and numbered and told to everyone by
// the box tick as any new box is.
function netPileTake(peer,m){
  var k, c, g, x, y;
  if(!peer||peer.state!=='in'||NET.role!=='host') return 'ignored';
  if(typeof G==='undefined'||!G||G.over||typeof netContHost!=='function'||!netContHost()) return 'down';
  k=netClean(m.k,32); if(!k||!Object.prototype.hasOwnProperty.call(ITEMS,k)||!ITEMS[k]) return 'bad';
  g=NET.up[peer.seat];
  x=(typeof m.x==='number'&&isFinite(m.x))?m.x:(g?g.tx:G.player.x); y=(typeof m.y==='number'&&isFinite(m.y))?m.y:(g?g.ty:G.player.y);
  c=setLoot(mkContainer(x+rnd(-14,14),y+rnd(6,18),'crate'),[k]);
  c.time=0.6; c.dropped=1; c.dropBy=peer.seat; if(m.ib) c.issuedB=1;
  if(G.vseg&&!losClear(x,y,c.x,c.y,G.vseg)){ c.x=x; c.y=y; }
  G.containers.push(c);
  return 'pile';
}
function dropItem(idx){
'@

SubRx @'
  var p=G.player,key=G.bag[idx];
  G.bag.splice(idx,1);
'@ @'
  var p=G.player,key=G.bag[idx];
  G.bag.splice(idx,1);
  // v18.27, HIS ORDER (2026-10-03): TRADING IS DROPPING. On a linked window up top the pile is made by the host, which runs every
  // box, so the whole party sees it and can search it; the host's new-box word brings it back to this window. A loaner Bandage
  // is spent from this window's count here and marked on the pile, as the solo drop below does.
  if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&typeof netContPeer==='function'&&netContPeer()){
    var _ib=0; if(key==='bandage'&&(G.issuedBandages||0)>0){ G.issuedBandages--; _ib=1; if(G.bandSeen!==undefined) G.bandSeen--; }
    var _q=netPeerOfSeat(0); if(_q) netSend(_q,{t:'pile',k:key,x:Math.round(p.x),y:Math.round(p.y),ib:_ib});
    return key;
  }
'@

SubRx @'
    if(code==='KeyZ'&&!repeat){
      // Drop ONE from the selected stack, the last one picked up.
      var _stk=bagStacks()[clamp(G.bagSel,0,_stN-1)];
      if(_stk){
        var dk=dropItem(_stk.idxs[_stk.idxs.length-1]);
        if(dk){ say('Dropped '+ITEMS[dk].name); blip('clank'); }
      }
      var _n2=bagStacks().length;
      if(G.bagSel>=_n2) G.bagSel=Math.max(0,_n2-1);
    }
'@ @'
    if(code==='KeyZ'&&!repeat) bagDropSel();   // v18.27: his order, trading is dropping; the block moved into bagDropSel, which the controller shares
'@

SubRx @'
  if(m.t==='gift') return netGiftTake(peer,m);   // v17.44: his pick 4, an offer, a yes, a hand-over or a no
'@ @'
  if(m.t==='gift') return netGiftTake(peer,m);   // v17.44: his pick 4, an offer, a yes, a hand-over or a no
  if(m.t==='pile') return netPileTake(peer,m);   // v18.27: one of the party dropped an item; the host makes the pile
'@

SubRx @'
      if(pressed(3)&&bagNav&&!PAD.prev[3]&&NET.on){ try{ netGiftKey(); }catch(_gk){} }   // v17.44: his pick 4, Y in the backpack offers the selected item
'@ @'
      if(pressed(3)&&bagNav&&!PAD.prev[3]){ try{ bagDropSel(); }catch(_gk){} }   // v18.27: his order, trading is dropping: Y in the backpack drops the selected item (it offered, v17.44)
'@

SubRx @'
  ['TEAM',[['T','offer or take a traded item'],['N','ping, twice for danger']]],   // v18.17: his note, trading was on no legend
'@ @'
  ['TEAM',[['Z','drop an item for a teammate'],['N','ping, twice for danger']]],   // v18.27: his order, trading is dropping
'@

SubRx @'
  ['TEAM',[['Y','offer or take a traded item'],['LB + RB','ping, twice for danger']]]   // v18.17: his note, trading was on no legend
'@ @'
  ['TEAM',[['Y','backpack open: drop an item for a teammate'],['LB + RB','ping, twice for danger']]]   // v18.27: his order, trading is dropping
'@

SubRx @'
    if(typeof NET==='object'&&NET&&NET.on) MN.push([(PAD&&PAD.on)?'Y':'T','trade / patch up'],[(PAD&&PAD.on)?'LB + RB':'N','ping']);   // v18.17: his note, in a party the trade key is on the short list too; v18.22: and it is the patch-up key with nothing selected
'@ @'
    if(typeof NET==='object'&&NET&&NET.on) MN.push([(PAD&&PAD.on)?'Y':'Z','drop to trade'],[(PAD&&PAD.on)?'LB + RB':'N','ping']);   // v18.27: his order, trading is dropping
'@

SubRx @'
s('KeyT')+' offer or take a traded item &nbsp; '
'@ @'
s('KeyZ')+' drop an item for a teammate &nbsp; '
'@

SubRx @'
_bo=((PAD&&PAD.on)?padB('Y'):'T')+' offer to teammate   '; _bh=_bo+_bh; if(ctx.measureText(_bh).width>PW-LH(130)) _bh=((PAD&&PAD.on)?padB('Y'):'T')+' offer   '+_bh.slice(_bo.length); }
'@ @'
_bo=((PAD&&PAD.on)?padB('Y'):'Z')+' drop for teammate   '; _bh=_bo+_bh; if(ctx.measureText(_bh).width>PW-LH(130)) _bh=((PAD&&PAD.on)?padB('Y'):'Z')+' drop   '+_bh.slice(_bo.length); }
'@

SubRx @'
TRADING. Up top: open the backpack, pick the item and press T (Y on a controller); your teammate takes it with T or Y with their backpack closed. In the Undercroft:
'@ @'
TRADING. Up top: open the backpack, pick the item and press Z (Y on a controller) to drop it at your feet; your teammate searches the pile like any box. In the Undercroft:
'@

SubRx @'
var VER='18.26';
'@ @'
var VER='18.27';
'@

$pat = "(?m)^  now:'v18\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.27: To give a teammate something up top, drop it (Z, or Y with the backpack open on a controller) and they search the pile like any box. Check 18.27 fails on v18.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# TRADING IS DROPPING, ON THE FLOOR TOO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netHubSeat(){
'@ @'
// v18.28, HIS ORDER (2026-10-03, "drop it on the floor and the other player picks it up"): TRADING IS DROPPING ON THE FLOOR TOO.
// From the stash menu, Drop on the floor puts the item in a small crate at your feet in the Undercroft; it shows on both
// windows; your teammate walks to it and presses E (A on a controller) to take it into their stash. The crate stays until
// someone takes it. The hub offer words of v18.05 stay in the code but nothing teaches them any more.
function hubDropMake(key){
  var p=HB&&HB.player, ix=P.stash.lastIndexOf(key), d, it=ITEMS[key], s;
  if(!p||ix<0||!it) return false;
  P.stash.splice(ix,1); try{ clearKeysFor(key); }catch(_ck){} saveProfile(); try{ refreshInv(); }catch(_ri){}
  HB.drops=HB.drops||[];
  d={id:String(Date.now()%1e9)+'-'+Math.floor(Math.random()*1e4),k:key,x:Math.round(p.x+Math.cos(p.face||0)*26),y:Math.round(p.y+Math.sin(p.face||0)*26)+6,by:NET.seat};
  d.x=clamp(d.x,30,HUBW-30); d.y=clamp(d.y,30,HUBH-30);
  HB.drops.push(d);
  if(NET.on) netBroadcast({t:'hdrop',op:'put',id:d.id,k:d.k,x:d.x,y:d.y});
  s=(typeof netHubSeat==='function')?netHubSeat():-1;
  say2('Dropped '+it.name+' on the floor.'+((s>=0)?(' '+(netSeatName(s)||'Your teammate')+' can pick it up.'):''));
  try{ blip('clank'); }catch(_b){}
  return true;
}
function hubDropTake(d){
  var it=d&&ITEMS[d.k], i;
  if(!d||!it) return false;
  i=(HB.drops||[]).indexOf(d); if(i>=0) HB.drops.splice(i,1);
  P.stash.push(d.k); saveProfile(); try{ refreshInv(); }catch(_ri){}
  if(NET.on) netBroadcast({t:'hdrop',op:'took',id:d.id});
  say2('Took '+it.name+' from the floor.'); try{ blip('pick'); }catch(_b){}
  return true;
}
function netHubRelay(peer,m){ var i; for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],m); }
function netHubDropTake(peer,m){
  var i, k;
  if(!peer||peer.state!=='in'||!m) return 'ignored';
  if(!HB) return 'nofloor';
  HB.drops=HB.drops||[];
  if(m.op==='put'){
    k=netClean(m.k,32); if(!k||!Object.prototype.hasOwnProperty.call(ITEMS,k)||!ITEMS[k]) return 'bad';
    for(i=0;i<HB.drops.length;i++) if(HB.drops[i].id===m.id) return 'dup';
    HB.drops.push({id:String(m.id).slice(0,40),k:k,x:clamp(+m.x||0,30,HUBW-30),y:clamp(+m.y||0,30,HUBH-30),by:peer.seat});
    if(NET.role==='host') netHubRelay(peer,m);
    return 'put';
  }
  if(m.op==='took'){
    for(i=0;i<HB.drops.length;i++) if(HB.drops[i].id===m.id){ HB.drops.splice(i,1); break; }
    if(NET.role==='host') netHubRelay(peer,m);
    return 'took';
  }
  return 'bad';
}
function hubDropsToDR(DR){ var i; if(!HB||!HB.drops) return 0; for(i=0;i<HB.drops.length;i++) DR.push({k:HB.drops[i].y,dp:HB.drops[i]}); return HB.drops.length; }
function hubDrawDrop(d){
  shadowE(d.x,d.y+2,14,5,.35);
  wc.fillStyle=INK; rrF(d.x-13,d.y-16,26,20,3);
  wc.fillStyle='#6a5236'; rrF(d.x-12,d.y-15,24,18,2.5);
  wc.fillStyle='#8a6a3a'; wc.fillRect(d.x-12,d.y-15,24,4);
  try{ drawItemIcon(wc,d.k,d.x,d.y-25,18); }catch(_di){}
}
function hubDrawDropPrompt(){
  var d=HB&&HB.nearDrop, it;
  if(!d) return false;
  it=ITEMS[d.k];
  ctx.save(); ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#ffc04a';
  ctx.fillText('['+keyLabel('KeyE','E')+'] TAKE '+(it?it.name.toUpperCase():d.k),W/2,H-LH(40));
  ctx.restore();
  return true;
}
function netHubSeat(){
'@

SubRx @'
  HB.near=best;
'@ @'
  HB.near=best;
  // v18.28, his order: a dropped item on the floor is taken with E (A) when no station is in reach
  HB.nearDrop=null;
  if(!best&&HB.drops&&HB.drops.length){ var _dbd=44, _ddd; for(i=0;i<HB.drops.length;i++){ _ddd=dist(p,HB.drops[i]); if(_ddd<_dbd){ _dbd=_ddd; HB.nearDrop=HB.drops[i]; } } }
  if(HB.nearDrop&&!HB.eLock&&keys['KeyE']){ HB.eLock=true; ac(); hubDropTake(HB.nearDrop); HB.nearDrop=null; }
'@

SubRx @'
  if(NET.on) netDrawPeers(DR);
'@ @'
  if(NET.on) netDrawPeers(DR);
  hubDropsToDR(DR);   // v18.28: the dropped crates, sorted with everything else
'@

SubRx @'
    } else if(it.np){
      // v15.75 (multiplayer, build 2): one of the party.
'@ @'
    } else if(it.dp){
      hubDrawDrop(it.dp);   // v18.28: a crate someone dropped for a teammate
    } else if(it.np){
      // v15.75 (multiplayer, build 2): one of the party.
'@

SubRx @'
  try{ drawHubGiftLine(); }catch(_hg){}   // v18.05: an open trade offer, on the floor
'@ @'
  try{ drawHubGiftLine(); }catch(_hg){}   // v18.05: an open trade offer, on the floor
  try{ hubDrawDropPrompt(); }catch(_hdp){}   // v18.28: E TAKE beside a dropped crate
'@

SubRx @'
  if(m.t==='gift') return netGiftTake(peer,m);   // v17.44: his pick 4, an offer, a yes, a hand-over or a no
'@ @'
  if(m.t==='gift') return netGiftTake(peer,m);   // v17.44: his pick 4, an offer, a yes, a hand-over or a no
  if(m.t==='hdrop') return netHubDropTake(peer,m);   // v18.28: a crate dropped or taken on the Undercroft floor
'@

SubRx @'
  if(ctx!=='kit'&&typeof netHubSeat==='function'&&netHubSeat()>=0){   // v18.05: his order, trading in the Undercroft
    rows.push({sep:1});
    rows.push({label:'Offer to '+(netSeatName(netHubSeat())||'your teammate'),hint:'they take it with T, or Y on the floor',act:function(){ netHubOffer(key); }});
  }
'@ @'
  if(ctx!=='kit'&&typeof netHubSeat==='function'&&netHubSeat()>=0){   // v18.05: his order, trading in the Undercroft; v18.28: by dropping
    rows.push({sep:1});
    rows.push({label:'Drop on the floor',hint:'for '+(netSeatName(netHubSeat())||'your teammate')+': they walk to it and press E',act:function(){ hubDropMake(key); }});
  }
'@

SubRx @'
        <div id="kb_trade" style="display:none"><kbd>RIGHT CLICK</kbd> or <kbd>Y</kbd> offer to your teammate</div>
'@ @'
        <div id="kb_trade" style="display:none"><kbd>RIGHT CLICK</kbd> or <kbd>Y</kbd> drop on the floor for your teammate</div>
'@

SubRx @'
    if(typeof NET==='object'&&NET&&NET.on) _lg.push('T','take an offer from your teammate (offer from the stash)');   // v18.25: trading on the floor card
'@ @'
    if(typeof NET==='object'&&NET&&NET.on) _lg.push('E','take an item your teammate dropped (drop one from the stash menu)');   // v18.28: trading on the floor card
'@

SubRx @'
((typeof NET==='object'&&NET&&NET.on)?'  \u00b7  Y TAKE AN OFFER':'')
'@ @'
((HB&&HB.drops&&HB.drops.length)?'  \u00b7  '+keyLabel('KeyE','E')+' TAKE THE DROPPED ITEM':'')
'@

SubRx @'
((typeof NET==='object'&&NET&&NET.on)?'  \u00b7  T TAKE AN OFFER':'')
'@ @'
((HB&&HB.drops&&HB.drops.length)?'  \u00b7  E TAKE THE DROPPED ITEM':'')
'@

SubRx @'
((typeof netHubSeat==='function'&&netHubSeat()>=0)?('Right-click an item (Y on a controller) and pick Offer to hand it to '+(netSeatName(netHubSeat())||'your teammate')+'; they take it with T or Y. '):'')
'@ @'
((typeof netHubSeat==='function'&&netHubSeat()>=0)?('Right-click an item (Y on a controller) and pick Drop on the floor to hand it to '+(netSeatName(netHubSeat())||'your teammate')+'; they walk to it and press E. '):'')
'@

SubRx @'
In the Undercroft: right-click a stash item and choose Offer; they take it with T, or Y on the floor.
'@ @'
In the Undercroft: right-click a stash item (Y on a controller) and choose Drop on the floor; your teammate walks to the crate and presses E (A on a controller).
'@

SubRx @'
var VER='18.27';
'@ @'
var VER='18.28';
'@

$pat = "(?m)^  now:'v18\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.28: In the Undercroft, right-click a stash item (Y on a controller) and choose Drop on the floor; your teammate walks to the crate and presses E to take it. Check 18.28 fails on v18.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

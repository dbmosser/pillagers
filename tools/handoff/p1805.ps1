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

# TRADING WITH THE OTHER PLAYER WORKS IN THE UNDERCROFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netGiftTake(peer,m){
'@ @'
// v18.05, HIS ORDER (2026-10-03): TRADING WITH THE OTHER PLAYER WORKS IN THE UNDERCROFT. The raid trade of v17.44 needed two
// bodies up top. Down here the stash item menu offers an item to the linked player; the offer, the yes and the hand-over are
// the same gift words with a hub mark, the item leaves the giver's stash only on the yes and lands in the taker's stash on the
// hand-over, so nothing is lost or copied on the way. The taker presses T (or Y on the floor); a line on the floor and a toast
// say what is waiting, for HUB_GIFT_T seconds.
var HUB_GIFT_T=30;
function netHubSeat(){
  var i;
  if(!(typeof NET==='object'&&NET&&NET.on)) return -1;
  if(NET.role==='host'){ for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') return NET.peers[i].seat; return -1; }
  return netPeerOfSeat(0)?0:-1;
}
function hubGiftName(s){ return netSeatName(s)||'your teammate'; }
function netHubOffer(key){
  var s=netHubSeat(), it=ITEMS[key], H=NET.hg||(NET.hg={});
  if(!it) return false;
  if(s<0){ say2('Nobody is linked up to give it to.'); return false; }
  if(P.stash.indexOf(key)<0) return false;
  H.out={id:String(Date.now()%1e9)+'-'+Math.floor(Math.random()*1e4),k:key,to:s,t:Date.now()};
  netGiftSend(s,{op:'offer',id:H.out.id,k:key,hub:1});
  say2('Offered '+it.name+' to '+hubGiftName(s)+'. They take it with T or '+padB('Y')+'.');
  return true;
}
function netHubGiftKey(){
  var H=NET.hg, gi=H&&H.in;
  if(!gi||gi.yes||Date.now()-gi.t>HUB_GIFT_T*1000) return false;
  gi.yes=1; netGiftSend(gi.from,{op:'yes',id:gi.id,hub:1}); say2('Taking it.');
  return true;
}
function netHubGiftTake(peer,m,fr){
  var H=NET.hg||(NET.hg={}), key=netClean(m.k,32), it=ITEMS[key], nm=hubGiftName(fr), go, gi, ix;
  if(m.op==='offer'){
    if(!it) return 'bad';
    H.in={id:String(m.id).slice(0,40),k:key,from:fr,t:Date.now()};
    say2(nm+' offers you '+it.name+'. Press T or '+padB('Y')+' to take it.'); try{ blip('pick'); }catch(_b){}
    return 'offer';
  }
  if(m.op==='yes'){
    go=H.out;
    if(!go||go.id!==m.id||go.to!==fr||Date.now()-go.t>HUB_GIFT_T*1000+5000){ netGiftSend(fr,{op:'no',id:m.id,hub:1}); return 'stale'; }
    ix=P.stash.lastIndexOf(go.k); H.out=null;
    if(ix<0){ netGiftSend(fr,{op:'no',id:m.id,hub:1}); return 'gone'; }
    P.stash.splice(ix,1); try{ clearKeysFor(go.k); }catch(_ck){} saveProfile(); try{ refreshInv(); }catch(_ri){}
    netGiftSend(fr,{op:'give',id:m.id,k:go.k,hub:1});
    say2('Gave '+(ITEMS[go.k]?ITEMS[go.k].name:go.k)+' to '+nm+'.');
    return 'gave';
  }
  if(m.op==='give'){
    gi=H.in; if(!it||!gi||gi.id!==m.id) return 'stale';
    H.in=null; P.stash.push(key); saveProfile(); try{ refreshInv(); }catch(_ri2){}
    say2('Took '+it.name+' from '+nm+'.'); try{ blip('pick'); }catch(_b2){}
    return 'took';
  }
  if(m.op==='no'){ if(H.in&&H.in.id===m.id) H.in=null; if(H.out&&H.out.id===m.id) H.out=null; say2(nm+' could not hand it over.'); return 'no'; }
  return 'bad';
}
function drawHubGiftLine(){
  var H=NET.hg, gi=H&&H.in, go=H&&H.out, now=Date.now(), s=null, t, it, w, y;
  if(gi&&now-gi.t>HUB_GIFT_T*1000+5000){ H.in=null; gi=null; }
  if(go&&now-go.t>HUB_GIFT_T*1000+5000){ H.out=null; go=null; }
  if(gi&&!gi.yes&&(t=HUB_GIFT_T-(now-gi.t)/1000)>0){ it=ITEMS[gi.k]; s=hubGiftName(gi.from)+' offers you '+(it?it.name:gi.k)+'.  T or '+padB('Y')+' to take it.  '+Math.ceil(t)+'s'; }
  else if(go&&(t=HUB_GIFT_T-(now-go.t)/1000)>0){ it=ITEMS[go.k]; s='Offered '+(it?it.name:go.k)+' to '+hubGiftName(go.to)+'. Waiting for them to take it.  '+Math.ceil(t)+'s'; }
  if(!s) return null;
  y=LH(76);
  ctx.save(); ctx.font=FS(TYPE.label); ctx.textAlign='center';
  w=ctx.measureText(s).width;
  ctx.fillStyle='rgba(6,9,13,.78)'; ctx.fillRect(W/2-w/2-12,y-LH(15),w+24,LH(22));
  ctx.fillStyle='#ffc04a'; ctx.fillText(s,W/2,y);
  ctx.restore();
  return s;
}
function netGiftTake(peer,m){
'@

SubRx @'
  if(typeof G==='undefined'||!G||G.over||!G.player) return 'no raid';
'@ @'
  if(m.hub) return netHubGiftTake(peer,m,fr);   // v18.05: a trade in the Undercroft
  if(typeof G==='undefined'||!G||G.over||!G.player) return 'no raid';
'@

SubRx @'
    out={t:'gift',op:m.op,id:m.id,k:m.k,ib:m.ib,to:m.to,from:fr};
'@ @'
    out={t:'gift',op:m.op,id:m.id,k:m.k,ib:m.ib,to:m.to,from:fr,hub:m.hub?1:0};   // v18.05: the hub mark rides along
'@

SubRx @'
  if(ctx!=='kit'){
    rows.push({sep:1});
    var isJ=(P.junk||{})[key]?true:false;
'@ @'
  if(ctx!=='kit'&&typeof netHubSeat==='function'&&netHubSeat()>=0){   // v18.05: his order, trading in the Undercroft
    rows.push({sep:1});
    rows.push({label:'Offer to '+(netSeatName(netHubSeat())||'your teammate'),hint:'they take it with T, or Y on the floor',act:function(){ netHubOffer(key); }});
  }
  if(ctx!=='kit'){
    rows.push({sep:1});
    var isJ=(P.junk||{})[key]?true:false;
'@

SubRx @'
  if(state==='hub'){
    keys[e.code]=true;
'@ @'
  if(state==='hub'){
    if(e.code==='KeyT'&&!e.repeat&&typeof netHubGiftKey==='function'&&netHubGiftKey()){ e.preventDefault(); return; }   // v18.05: T takes an offer in the Undercroft
    keys[e.code]=true;
'@

SubRx @'
    padHold('KeyF',pressed(3));
'@ @'
    if(pressed(3)&&!PAD.prev[3]&&typeof netHubGiftKey==='function'&&NET.hg&&NET.hg.in&&!NET.hg.in.yes){ netHubGiftKey(); }   // v18.05: Y takes an offer on the floor
    padHold('KeyF',pressed(3));
'@

SubRx @'
  ctx.fillText('THE UNDERCROFT',16,28);
'@ @'
  ctx.fillText('THE UNDERCROFT',16,28);
  try{ drawHubGiftLine(); }catch(_hg){}   // v18.05: an open trade offer, on the floor
'@

SubRx @'
var VER='18.04';
'@ @'
var VER='18.05';
'@

$pat = "(?m)^  now:'v18\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.05: You can trade in the Undercroft: right-click a stash item and OFFER it to the other player, who takes it with T (or Y on the floor). Check 18.05 fails on v18.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

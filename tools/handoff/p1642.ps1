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

# KILL FEED (co-op list item 4).

SubRx @'
  if(how==='dead'&&e.bySeat>0&&!e.byPlayer){ q=netPeerOfSeat(e.bySeat); if(q) netSend(q,{t:'kill',seat:e.bySeat,id:e.nid,k:e.kind,el:e.elite?1:0}); }
'@ @'
  if(how==='dead'&&e.bySeat>0&&!e.byPlayer){ q=netPeerOfSeat(e.bySeat); if(q) netSend(q,{t:'kill',seat:e.bySeat,id:e.nid,k:e.kind,el:e.elite?1:0}); }
  if(how==='dead'&&(e.byPlayer||e.bySeat>0)) netFeedKill(e.byPlayer?0:e.bySeat,e);   // v16.42: the kill feed
'@

SubRx @'
  if(m.t==='sum') return netSumTake(peer,m);   // v16.40: a teammate's raid result, for the party summary
'@ @'
  if(m.t==='sum') return netSumTake(peer,m);   // v16.40: a teammate's raid result, for the party summary
  if(m.t==='kf') return netFeedTake(peer,m);   // v16.42: a line for the kill feed, from the host
'@

SubRx @'
function netAllPaused(){
'@ @'
// v16.42, THE CO-OP LIST (item 4): A KILL FEED. THE HOST, when a player kills a body: NAME killed WHAT, shown on the host and sent
// to the party. Each window keeps the last four lines for six seconds, drawn at the right edge. Drawing and words only.
var NET_FEED_T=6;
function netFeedKill(s,e){
  var who=(e.kind==='raider'&&e.name)?netClean(e.name,24):String(e.kind||'').toUpperCase();
  if(e.elite) who='ELITE '+who;
  netBroadcast({t:'kf',s:s,w:who});
  netFeedPush(s,who);
  return who;
}
function netFeedTake(peer,m){
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(typeof m.s!=='number'||m.s!==(m.s|0)) return 'bad';
  netFeedPush(m.s,netClean(m.w,32));
  return 'kf';
}
function netFeedPush(s,who){
  var nm=(s===NET.seat)?'YOU':(netSeatName(s)||'PILLAGER');
  if(!NET.feed) NET.feed=[];
  NET.feed.push({txt:nm+' killed '+who,me:(s===NET.seat),at:Date.now()});
  if(NET.feed.length>4) NET.feed.shift();
  return NET.feed.length;
}
function netFeedDraw(){
  var i, f, now=Date.now(), y=Math.round(H*0.40), x=W-LH(16), n=0, a, tw;
  if(!NET.feed||!NET.feed.length) return 0;
  ctx.font=FS(TYPE.label); ctx.textAlign='right';
  for(i=NET.feed.length-1;i>=0;i--){
    f=NET.feed[i]; a=(now-f.at)/1000;
    if(a>NET_FEED_T){ NET.feed.splice(i,1); continue; }
    ctx.globalAlpha=clamp((NET_FEED_T-a)/1.2,0,1);
    tw=ctx.measureText(f.txt).width;
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(x-tw-LH(6),y-LH(13),tw+LH(12),LH(18));
    ctx.fillStyle=f.me?'#ffc04a':'#bfe0ff'; ctx.fillText(f.txt,x,y);
    y+=LH(22); n++;
  }
  ctx.globalAlpha=1; ctx.textAlign='left';
  return n;
}
function netAllPaused(){
'@

SubRx @'
  try{ if(NET.on) netTeamHud(by); }catch(_nth){}   // v16.26: your teammates, their health and armour, above your own
'@ @'
  try{ if(NET.on) netTeamHud(by); }catch(_nth){}   // v16.26: your teammates, their health and armour, above your own
  try{ if(NET.on) netFeedDraw(); }catch(_nfd){}   // v16.42: the kill feed
'@

SubRx @'
var VER='16.41';
'@ @'
var VER='16.42';
'@

$pat = "(?m)^  now:'v16\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.42: KILL FEED. Co-op list item 4. When a player kills a body the host shows NAME killed WHAT (a pillager by name, a machine by kind, ELITE marked) and sends it to the party; each window shows the last four for six seconds at the right edge, its own kills in amber as YOU. Check 16.42 fails on v16.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

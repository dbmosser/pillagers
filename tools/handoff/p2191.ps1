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

# THE WAITING QUEUE: RANKED, CAPPED, NO REPEATS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function msgEnq(m,kind,o){
  var q=(G.msgQ=G.msgQ||[]), qm=(G.msgQM=G.msgQM||[]);
  qm.length=q.length;   // anything that emptied G.msgQ alone leaves no stale kinds behind
  q.push(m); qm.push({k:msgKind(kind),o:o||null});
}
function sayWhenFree(m,kind,o){
  if(G&&!G.sim&&G.msgT>0){ msgEnq(m,kind,o); return; }   // v21.88 (R06): the one queue writer
  say(m,kind,o);
}
'@ @'
// v21.91, the raid text rewrite (R07): THE WAITING QUEUE IS RANKED, CAPPED, NEVER REPEATS AND NEVER GOES STALE. It was a plain
// first in, first out list with no limit, so a burst of lines played out one after another for half a minute, the same line
// could wait three times over, a line about something long gone still showed ten seconds late, and a warning waited behind
// remarks. Now: a line that outranks every row showing is said at once instead of waiting. A line whose text (or whose key,
// o.key, for a line whose numbers change while it is said every frame) is already showing refreshes that row in place, and one
// already waiting refreshes its place in the queue; neither adds a copy. The queue holds at most 4 (past that, the lowest
// ranked, oldest line goes). A waiting line goes stale after 10 s for an objective, 3 s for chatter and system lines, 4 s for
// the rest. It comes out highest rank first, first in, first out within a rank, and while two or more wait the line it shows
// lives 1.8 s instead of 3.2 s so the queue catches up. Each waiting entry in G.msgQM is {k,o,t}, t the time it joined.
function msgQTTL(k){ return k==='obj'?10:(k==='chat'||k==='sys')?3:4; }
function msgQAlign(){ var q=(G.msgQ=G.msgQ||[]), qm=(G.msgQM=G.msgQM||[]); if(qm.length!==q.length) qm.length=q.length; return q; }   // anything that emptied G.msgQ alone leaves no stale kinds behind
function msgQPrune(now){
  var q=msgQAlign(), qm=G.msgQM, i, e;
  for(i=q.length-1;i>=0;i--){ e=qm[i]; if(e&&typeof e.t==='number'&&now-e.t>msgQTTL(e.k)){ q.splice(i,1); qm.splice(i,1); } }
}
function msgQFind(m,key){
  var q=msgQAlign(), qm=G.msgQM, i;
  for(i=0;i<q.length;i++) if(q[i]===m||(key&&qm[i]&&qm[i].o&&qm[i].o.key===key)) return i;
  return -1;
}
function msgQDrop(m,key){ var i; while((i=msgQFind(m,key))>=0){ G.msgQ.splice(i,1); G.msgQM.splice(i,1); } }
function msgEnq(m,kind,o){
  var q, qm, now=G.t||0, k=msgKind(kind), i, lo, lr, r;
  msgQPrune(now); q=G.msgQ; qm=G.msgQM;
  i=msgQFind(m,(o&&o.key)||'');
  if(i>=0){ q[i]=m; qm[i]={k:k,o:o||null,t:now}; return; }   // already waiting: refreshed where it stands, no copy
  q.push(m); qm.push({k:k,o:o||null,t:now});
  while(q.length>4){ lo=0; lr=1e9; for(i=0;i<q.length;i++){ r=MSGK[msgKind(qm[i]&&qm[i].k)].r; if(r<lr){ lr=r; lo=i; } } q.splice(lo,1); qm.splice(lo,1); }
}
function msgQNext(){   // the next waiting line to show, taken out of the queue: {m,k,o,n}, n how many were waiting
  var q, qm, i, b=-1, br=-1e9, r, e, n;
  msgQPrune(G.t||0); q=G.msgQ; qm=G.msgQM;
  if(!q.length) return null;
  n=q.length;
  for(i=0;i<q.length;i++){ r=MSGK[msgKind(qm[i]&&qm[i].k)].r; if(r>br){ br=r; b=i; } }
  e=qm[b]; r={m:q[b],k:e&&e.k,o:e&&e.o,n:n};
  q.splice(b,1); qm.splice(b,1);
  return r;
}
function msgRowsUp(){   // the rows showing now, head first: {m,k,key}
  var r=[], f=G.feed&&G.feed[1];
  if(!(G.msgT>0)||!G.msg) return r;
  r.push({m:G.msg,k:G.msgK||'info',key:G.msgKey||''});
  if(f&&f.T>0&&f.m&&f.m!==G.msg) r.push(f);
  return r;
}
function sayWhenFree(m,kind,o){
  if(G&&!G.sim&&G.msgT>0){
    var up=msgRowsUp(), key=(o&&o.key)||'', rk=MSGK[msgKind(kind)].r, i, over=up.length>0, shown=false;
    for(i=0;i<up.length;i++){
      if(up[i].m===m||(key&&up[i].key===key)) shown=true;
      if(MSGK[msgKind(up[i].k)].r>=rk) over=false;
    }
    if(!shown&&!over){ msgEnq(m,kind,o); return; }   // v21.91 (R07): showing already refreshes in place, and a line that outranks every row is said now
  }
  say(m,kind,o);
}
'@

SubRx @'
    var f=(G.feed=G.feed||[]), now=G.t||0, hv=!!(G.msgT>0&&G.msg), same=hv&&G.msg===m,
        r1=(hv&&f[1]&&f[1].T>0&&f[1].m&&f[1].m!==G.msg)?f[1]:null, hd, v;
    if(hv&&!same){
      hd={m:G.msg,k:G.msgK||'info',sub:G.msgSub||'',T:G.msgT,at:G.msgAt};
      if(r1){
        v=msgVictim([hd,r1],MSGK[k].r,now,!!G.msgDrain);
        if(!v){ msgEnq(m,k,o); return; }
        if(msgProt(v,now)&&v.m!==m) msgEnq(v.m,v.k,v.sub?{sub:v.sub}:null);
        if(v===r1) f[1]=hd;
      } else f[1]=hd;
    }
    if(!same) G.msgAt=now;   // the same line said again keeps its first time, so a per-frame caller never renews its protection
    G.msg=m; G.msgT=3.2; G.msgK=k; G.msgSub=(o&&o.sub)||'';
    f[0]={m:m,k:k,sub:G.msgSub,T:3.2,at:G.msgAt}; return;
'@ @'
    // v21.91 (R07): a line already on a row, by its text or by its key (o.key), refreshes that row where it is; the second row
    // keeps its place and its first time. A line said is taken out of the queue if it was also waiting there.
    var f=(G.feed=G.feed||[]), now=G.t||0, key=(o&&o.key)||'', hv=!!(G.msgT>0&&G.msg), same=hv&&(G.msg===m||(!!key&&G.msgKey===key)),
        r1=(hv&&f[1]&&f[1].T>0&&f[1].m&&f[1].m!==G.msg)?f[1]:null, hd, v;
    if(!same&&r1&&(r1.m===m||(key&&r1.key===key))){ r1.m=m; r1.k=k; r1.sub=(o&&o.sub)||''; r1.T=3.2; if(G.msgQ&&G.msgQ.length) msgQDrop(m,key); return; }
    if(G.msgQ&&G.msgQ.length) msgQDrop(m,key);
    if(hv&&!same){
      hd={m:G.msg,k:G.msgK||'info',sub:G.msgSub||'',T:G.msgT,at:G.msgAt,key:G.msgKey||''};
      if(r1){
        v=msgVictim([hd,r1],MSGK[k].r,now,!!G.msgDrain);
        if(!v){ msgEnq(m,k,o); return; }
        if(msgProt(v,now)&&v.m!==m) msgEnq(v.m,v.k,(v.sub||v.key)?{sub:v.sub,key:v.key}:null);
        if(v===r1) f[1]=hd;
      } else f[1]=hd;
    }
    if(!same) G.msgAt=now;   // the same line said again keeps its first time, so a per-frame caller never renews its protection
    G.msg=m; G.msgT=3.2; G.msgK=k; G.msgSub=(o&&o.sub)||''; G.msgKey=key;
    f[0]={m:m,k:k,sub:G.msgSub,T:3.2,at:G.msgAt,key:key}; return;
'@

SubRx @'
      if(G.msgQ&&G.msgQ.length&&msgFree()){ var _qm=(G.msgQM&&G.msgQM.length===G.msgQ.length)?G.msgQM.shift():(G.msgQM=[],null); G.msgDrain=1; try{ say(G.msgQ.shift(),_qm&&_qm.k,_qm&&_qm.o); } finally { G.msgDrain=0; } }   // v21.80: a waiting line keeps its kind
'@ @'
      // v21.91 (R07): the highest ranked waiting line first, stale ones dropped (msgQNext), and 1.8 s while two or more wait.
      if(G.msgQ&&G.msgQ.length&&msgFree()){ var _qn=msgQNext(); if(_qn){ G.msgDrain=1; try{ say(_qn.m,_qn.k,_qn.o); } finally { G.msgDrain=0; } if(_qn.n>=2&&G.msg===_qn.m&&G.msgT>1.8) G.msgT=1.8; } }   // v21.80: a waiting line keeps its kind
'@

SubRx @'
                    :('Backpack full ('+cap+'). Z drops the selected item.'));
'@ @'
                    :('Backpack full ('+cap+'). Z drops the selected item.'),'info',{key:'bagfull'});   // v21.91 (R07): said every frame E is held, so it refreshes its row
'@

SubRx @'
near.netSaidT=G.t; nm=netSeatName(near.netBy); if(!G.sim) say((nm||'One of your party')+' is searching this one.');
'@ @'
near.netSaidT=G.t; nm=netSeatName(near.netBy); if(!G.sim) say((nm||'One of your party')+' is searching this one.','info',{key:'netsrch'});
'@

SubRx @'
ct.netSaidT=G.t; nm=netSeatName(ct.netBy); if(!G.sim) say((nm||'One of your party')+' is searching this one.');
'@ @'
ct.netSaidT=G.t; nm=netSeatName(ct.netBy); if(!G.sim) say((nm||'One of your party')+' is searching this one.','info',{key:'netsrch'});
'@

SubRx @'
var VER='21.90';
'@ @'
var VER='21.91';
'@

$pat = "(?m)^  now:'v21\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.91: Waiting raid lines come out most important first, never twice, and never long after the moment has passed. Check 21.91 fails on v21.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

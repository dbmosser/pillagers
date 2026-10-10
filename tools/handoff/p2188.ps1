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

# A LOWER LINE CANNOT PUSH A HIGHER ONE OFF (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sayWhenFree(m,kind,o){
'@ @'
// v21.88, the raid text rewrite (R06): A LOWER LINE CANNOT PUSH A HIGHER ONE OFF. With two rows, the third line said in a second
// pushed the oldest row off whatever it was, so a remark could wipe a warning the player had not had time to read. A row is now
// protected for 1.2 s after it shows (an objective or a critical line for 2.0 s). A new line that ranks below both rows while
// they are protected waits in the queue instead. A line of equal or higher rank takes the place of the lowest ranked, oldest
// row, and a row taken while still protected (not yet read) goes back into the queue. A waiting line comes out of the queue as
// soon as a row is free or one is past its protection, and only ever into such a row, so lines never chase each other off.
// msgProt: is this row still protected at time now. A row with no time (set by hand) is not. msgVictim: the row a line of rank
// rk takes, or null when it must wait. msgFree: may a waiting line come out now. msgEnq: add a line to the waiting queue.
function msgProt(r,now){ var pt=(r&&(r.k==='obj'||r.k==='crit'))?2.0:1.2; return !!r&&(now-r.at)<pt; }
function msgVictim(rows,rk,now,drain){
  var best=null, i, r, rr;
  for(i=0;i<rows.length;i++){
    r=rows[i]; rr=MSGK[msgKind(r.k)].r;
    if(msgProt(r,now)&&(drain||rr>rk)) continue;
    if(!best||rr<best.rr||(rr===best.rr&&(+r.at||-1e9)<(+best.r.at||-1e9))) best={r:r,rr:rr};
  }
  return best?best.r:null;
}
function msgFree(){
  if(!G||!(G.msgT>0)||!G.msg) return true;
  var f=G.feed&&G.feed[1], now=G.t||0;
  if(!(f&&f.T>0&&f.m&&f.m!==G.msg)) return true;
  return !msgProt({k:G.msgK,at:G.msgAt},now)||!msgProt(f,now);
}
function msgEnq(m,kind,o){
  var q=(G.msgQ=G.msgQ||[]), qm=(G.msgQM=G.msgQM||[]);
  qm.length=q.length;   // anything that emptied G.msgQ alone leaves no stale kinds behind
  q.push(m); qm.push({k:msgKind(kind),o:o||null});
}
function sayWhenFree(m,kind,o){
'@

SubRx @'
    var f=(G.feed=G.feed||[]);
    if(G.msgT>0&&G.msg&&G.msg!==m) f[1]={m:G.msg,k:G.msgK||'info',sub:G.msgSub||'',T:G.msgT};
    G.msg=m; G.msgT=3.2; G.msgK=k; G.msgSub=(o&&o.sub)||'';
    f[0]={m:m,k:k,sub:G.msgSub,T:3.2}; return;
'@ @'
    // v21.88 (R06): with both rows up, msgVictim decides which row gives way, or that this line waits (see msgProt above).
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
'@

SubRx @'
  if(G&&!G.sim&&G.msgT>0){
    var q=(G.msgQ=G.msgQ||[]), qm=(G.msgQM=G.msgQM||[]);
    qm.length=q.length;   // anything that emptied G.msgQ alone leaves no stale kinds behind
    q.push(m); qm.push({k:msgKind(kind),o:o||null}); return;
  }
'@ @'
  if(G&&!G.sim&&G.msgT>0){ msgEnq(m,kind,o); return; }   // v21.88 (R06): the one queue writer
'@

SubRx @'
      if(G.msgQ&&G.msgQ.length&&!(G.msgT>0)){ var _qm=(G.msgQM&&G.msgQM.length===G.msgQ.length)?G.msgQM.shift():(G.msgQM=[],null); say(G.msgQ.shift(),_qm&&_qm.k,_qm&&_qm.o); }   // v21.80: a waiting line keeps its kind
'@ @'
      // v21.88 (R06): a waiting line comes out as soon as a row is free or past its protection (msgFree), and only into such a row.
      if(G.msgQ&&G.msgQ.length&&msgFree()){ var _qm=(G.msgQM&&G.msgQM.length===G.msgQ.length)?G.msgQM.shift():(G.msgQM=[],null); G.msgDrain=1; try{ say(G.msgQ.shift(),_qm&&_qm.k,_qm&&_qm.o); } finally { G.msgDrain=0; } }   // v21.80: a waiting line keeps its kind
'@

SubRx @'
var VER='21.87';
'@ @'
var VER='21.88';
'@

$pat = "(?m)^  now:'v21\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.88: A warning on the message rows stays up until it has been read, and a line that had to give way comes back instead of being lost. Check 21.88 fails on v21.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

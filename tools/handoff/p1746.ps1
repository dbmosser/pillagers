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

# DROP-IN: A TEAMMATE CAN JOIN A RAID ALREADY UNDER WAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netUpTake(peer,m){
'@ @'
// v17.46, HIS PICK 3 (2026-09-30): DROP-IN. A teammate in the Undercroft while the host is up top gets a JOIN THE RAID IN
// PROGRESS button (netLateBtn, from netRefresh). It asks the host {t:'raidq'}; the host answers that window alone with the
// raid word it announced (NET.upWord) plus late:{t, left, x, y} and gone, the numbers of the bodies already down. The window
// builds the same surface as any teammate does (netUpStart), then netLateApply takes the dead bodies out, sets the raid clock
// and the time left to the host's and stands the player beside the host. Boxes already open reach it as they reach any window
// that comes up (netContHello). Drop-out is as before: abandon, extract or close the window.
function netLateReply(peer){
  var gone=[], id, n;
  if(!peer||peer.state!=='in'||NET.role!=='host') return 'ignored';
  if(!NET.upWord||typeof G==='undefined'||!G||G.over||G.sim||!G.player){ netSend(peer,{t:'raidno'}); return 'no raid'; }
  n=(G.nidN|0);
  for(id=1;id<n&&gone.length<600;id++) if(!NET.entMap||!NET.entMap[id]) gone.push(id);
  var m={}, k; for(k in NET.upWord) if(Object.prototype.hasOwnProperty.call(NET.upWord,k)) m[k]=NET.upWord[k];
  m.late={t:+(+G.t||0).toFixed(2),left:(typeof G.timeLeft==='number')?+G.timeLeft.toFixed(2):null,x:Math.round(G.player.x),y:Math.round(G.player.y)};
  m.gone=gone;
  return netSend(peer,m)?'sent':'lost';
}
function netLateApply(m){
  var i, j, id, e, L=m&&m.late, p;
  if(!L||typeof G==='undefined'||!G||G.over||!G.player) return 'no raid';
  if(m.gone&&m.gone.length) for(i=0;i<m.gone.length&&i<600;i++){
    id=m.gone[i]|0; e=(NET.entMap&&NET.entMap[id])||null;
    if(!e) for(j=0;j<G.ents.length;j++) if(G.ents[j]&&G.ents[j].nid===id){ e=G.ents[j]; break; }
    if(e){ j=G.ents.indexOf(e); if(j>=0) G.ents.splice(j,1); if(NET.entMap) delete NET.entMap[id]; if(!NET.entGone) NET.entGone={}; NET.entGone[id]=NET.entLast+1; }
  }
  if(typeof L.t==='number'&&isFinite(L.t)&&L.t>0) G.t=L.t;
  if(typeof L.left==='number'&&isFinite(L.left)) G.timeLeft=L.left;
  p=G.player;
  if(typeof L.x==='number'&&typeof L.y==='number'&&isFinite(L.x)&&isFinite(L.y)){ p.x=L.x+36; p.y=L.y+8; if(typeof resolvePlayer==='function'){ try{ resolvePlayer(p); }catch(_rp){} } }
  say('You joined the raid in progress.');
  return 'late';
}
function netLateAsk(){
  var q;
  if(!NET.on||NET.role!=='join') return false;
  q=netPeerOfSeat(0); if(!q) return false;
  NET.status='Asking to join the raid in progress.'; netRefresh();
  return netSend(q,{t:'raidq'});
}
function netLateBtn(){
  var hub=document.getElementById('hub'), b=document.getElementById('joinlate'), want;
  want=!!(hub&&NET.on&&NET.role==='join'&&NET.hostSeed&&state==='hub'&&!(typeof G!=='undefined'&&G&&!G.over));
  if(!want){ if(b&&b.parentNode) b.parentNode.removeChild(b); return false; }
  if(!b){
    b=document.createElement('button'); b.id='joinlate'; b.className='deploy';
    b.textContent='JOIN THE RAID IN PROGRESS';
    b.style.cssText='position:absolute;left:50%;top:14px;transform:translateX(-50%);z-index:30;padding:6px 18px';
    b.onclick=function(){ netLateAsk(); };
    hub.appendChild(b);
  }
  return true;
}function netUpTake(peer,m){
'@

SubRx @'
function netRefresh(){ var m=document.getElementById('partymodal'); if(m&&m.classList.contains('on')) renderParty(); }
'@ @'
function netRefresh(){ try{ netLateBtn(); }catch(_nlb){} var m=document.getElementById('partymodal'); if(m&&m.classList.contains('on')) renderParty(); }
'@

SubRx @'
  netContInit(g);   // v15.91: every container numbered in list order, the numbers a linked window gives the same containers
  netBroadcast(m);
  return m;
'@ @'
  netContInit(g);   // v15.91: every container numbered in list order, the numbers a linked window gives the same containers
  NET.upWord=m;   // v17.46: his pick 3, kept for a teammate who joins late
  netBroadcast(m);
  return m;
'@

SubRx @'
  NET.upOut={};   // v16.86: the raid is let go, and with it every seat marked out on it
'@ @'
  NET.upOut={};   // v16.86: the raid is let go, and with it every seat marked out on it
  NET.upWord=null;   // v17.46: his pick 3, no late join into a raid that is over
'@

SubRx @'
  if(why){ NET.err='Your party went up without you: this window was '+why+'.'; netBroadcast({t:'up',st:'no',why:why}); netRefresh(); return 'busy'; }
'@ @'
  if(typeof m.seed==='number') NET.hostSeed=m.seed>>>0;   // v17.46: his pick 3, the host is up on this seed
  if(why){ NET.err='Your party went up without you: this window was '+why+'.'; netBroadcast({t:'up',st:'no',why:why}); netRefresh(); return 'busy'; }
'@

SubRx @'
  return netUpStart(m);
'@ @'
  var _lr=netUpStart(m);
  if(m.late&&typeof G!=='undefined'&&G&&!G.over){ try{ netLateApply(m); }catch(_la){} }   // v17.46: his pick 3, a late join
  return _lr;
'@

SubRx @'
  if(NET.role==='join'&&st==='out'&&s===0) netHostGone('out');   // v15.91: the host raid ended with nobody left to run it: abandon for the whole party
'@ @'
  if(NET.role==='join'&&st==='out'&&s===0) netHostGone('out');   // v15.91: the host raid ended with nobody left to run it: abandon for the whole party
  if(NET.role==='join'&&s===0&&(st==='out'||st==='spec')){ NET.hostSeed=0; try{ netLateBtn(); }catch(_lb){} }   // v17.46: his pick 3, the host is out
'@

SubRx @'
  if(m.t==='gift') return netGiftTake(peer,m);   // v17.44: his pick 4, an offer, a yes, a hand-over or a no
'@ @'
  if(m.t==='gift') return netGiftTake(peer,m);   // v17.44: his pick 4, an offer, a yes, a hand-over or a no
  if(m.t==='raidq') return netLateReply(peer);   // v17.46: his pick 3, a teammate asks to join late
  if(m.t==='raidno'){ NET.status='Player 1 is not up top.'; netRefresh(); return 'raidno'; }
'@

SubRx @'
var VER='17.45';
'@ @'
var VER='17.46';
'@

$pat = "(?m)^  now:'v17\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.46: DROP-IN, his pick from the feature list: a teammate in the Undercroft while the host is up top gets JOIN THE RAID IN PROGRESS; the host answers with its raid, clock, time left, position and the bodies already down, and the teammate comes up beside it on the same surface. Dropping out is as before. Check 17.46 fails on v17.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

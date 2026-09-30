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

# THE CO-OP SCORE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netUpEnd(how){
'@ @'
// v17.39, HIS PICK 5 (2026-09-30): THE CO-OP SCORE SCREEN. When a player's raid ends his window sends the party a score word
// {t:'sc'}: how it ended, kills, what he carried out and its worth, downs and revives, on that raid's seed. Every window's
// end card shows a PARTY block, one row per player; a teammate still up top reads so until his word comes, and the block
// fills in when it does. The host passes a teammate's word on to the rest of the party. Nothing is banked from it.
function netScoreSend(how){
  if(!NET.on||typeof G==='undefined'||!G||G.sim) return false;
  var T=G.tel||{}, k=0, q, h=0, i, sc, sd=(NET.upSeed>>>0)||(G.seed>>>0);
  for(q in (T.kills||{})) k+=(T.kills[q]|0);
  if(how==='extract') for(i=0;i<(G.bag||[]).length;i++) h+=ival(G.bag[i]);
  sc={how:netClean(how,12),k:k,h:Math.round(h),it:(how==='extract')?(G.bag||[]).length:0,dn:T.downs|0,rv:T.revives|0,sd:sd};
  if(!NET.sc) NET.sc={};
  for(q in NET.sc) if(!NET.sc[q]||NET.sc[q].sd!==sd) delete NET.sc[q];
  NET.sc[NET.seat]=sc; NET.scSd=sd;
  netBroadcast({t:'sc',sc:sc});
  return true;
}
function netScoreTake(peer,m){
  var s, sc, i, out;
  if(!peer||peer.state!=='in'||!m||!m.sc||typeof m.sc!=='object') return 'bad';
  if(NET.role==='host') s=peer.seat; else if(typeof m.s==='number'&&m.s===(m.s|0)) s=m.s; else s=0;
  if(s<0||s>=NET.max||s===NET.seat) return 'ignored';
  sc={how:netClean(m.sc.how,12),k:Math.max(0,m.sc.k|0),h:Math.max(0,m.sc.h|0),it:Math.max(0,m.sc.it|0),dn:Math.max(0,m.sc.dn|0),rv:Math.max(0,m.sc.rv|0),sd:(m.sc.sd>>>0)};
  if(!NET.sc) NET.sc={};
  NET.sc[s]=sc;
  if(NET.role==='host'){ out={t:'sc',s:s,sc:sc}; for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],out); }
  try{ netScoreDraw(); }catch(_d){}
  return 'sc';
}
function netScoreDraw(){
  var man=document.getElementById('oc_manifest'), el=document.getElementById('oc_party'), s, sc, nm, h='', n=0, HOW={extract:'EXTRACTED',dead:'KILLED',abandon:'ABANDONED'};
  if(!man) return '';
  if(!el){ el=document.createElement('div'); el.id='oc_party'; man.parentNode.insertBefore(el,man.nextSibling); }
  if(!NET.on||!NET.sc||NET.scSd===undefined){ el.innerHTML=''; return ''; }
  for(s=0;s<(NET.max||4);s++){
    nm=(s===NET.seat)?'YOU':netSeatName(s);
    if(nm===null||nm===undefined) continue;
    sc=NET.sc[s]; n++;
    h+='<div style="display:flex;gap:10px;font-size:11.5px;padding:2px 0;color:var(--bone)"><span style="flex:1">'+escHtml(String(nm))+'</span>'+
      ((sc&&sc.sd===NET.scSd)
        ? '<span style="width:92px">'+(HOW[sc.how]||escHtml(String(sc.how||'OUT').toUpperCase()))+'</span>'+
          '<span style="width:64px;text-align:right">'+sc.k+' kills</span>'+
          '<span style="width:120px;text-align:right">$'+sc.h.toLocaleString()+' ('+sc.it+' items)</span>'+
          '<span style="width:64px;text-align:right">'+sc.dn+' downs</span>'+
          '<span style="width:74px;text-align:right">'+sc.rv+' revives</span>'
        : '<span style="width:434px;color:var(--ash)">still up top</span>')+'</div>';
  }
  el.innerHTML=(n>1)?('<div style="margin-top:12px;border-top:1px solid var(--steel-hi);padding-top:9px"><div style="font-size:10.5px;letter-spacing:.2em;color:var(--ash);margin-bottom:6px">PARTY</div>'+h+'</div>'):'';
  return el.innerHTML;
}function netUpEnd(how){
'@

SubRx @'
  if(NET.on&&!G.sim){ try{ if(!netSpecStart(how)) netUpEnd(how); }catch(_ue){} }   // v15.79: the party is told this raid ended; v16.14: unless the host spectates for the party still up top
'@ @'
  if(NET.on&&!G.sim){ try{ netScoreSend(how); }catch(_nss){} }   // v17.39: his pick 5, the score word goes before the out word
  if(NET.on&&!G.sim){ try{ if(!netSpecStart(how)) netUpEnd(how); }catch(_ue){} }   // v15.79: the party is told this raid ended; v16.14: unless the host spectates for the party still up top
'@

SubRx @'
    (DEATH_FEED_HTML||'')+lines.join('<br>');
'@ @'
    (DEATH_FEED_HTML||'')+lines.join('<br>');
   try{ netScoreDraw(); }catch(_nsd){}   // v17.39: the PARTY block under the manifest
'@

SubRx @'
  if(m.t==='thr') return netThrTake(peer,m);   // v17.29, co-op hunt 2026-09-28: a smoke, a decoy or a charge blast one of the party threw
'@ @'
  if(m.t==='thr') return netThrTake(peer,m);   // v17.29, co-op hunt 2026-09-28: a smoke, a decoy or a charge blast one of the party threw
  if(m.t==='sc') return netScoreTake(peer,m);   // v17.39: a teammate score for the end card
'@

SubRx @'
var VER='17.38';
'@ @'
var VER='17.39';
'@

$pat = "(?m)^  now:'v17\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.39: THE CO-OP SCORE SCREEN, his pick from the feature list. A party raid that ends sends the party a score word (how it ended, kills, what was carried out and its worth, downs, revives), and every end card shows a PARTY block, one row per player; a teammate still up top reads so until his score arrives, then his row fills in. Check 17.39 fails on v17.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

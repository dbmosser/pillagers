$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'17.46',what:")) { throw "check 17.46 is in the fixture already" }

SubRx @'
  {v:'17.45',what:
'@ @'
  {v:'17.46',what:'drop-in: the host answers a join request with its raid word, the clock, the time left, where the host stands and the bodies already down; a late window takes those bodies out, sets the clock and stands beside the host; the Undercroft shows JOIN THE RAID IN PROGRESS while the host is up',
   run:function(){
     if(typeof netLateReply!=='function'||typeof netLateApply!=='function'||typeof netLateBtn!=='function') return 'this build has no drop-in';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, sent=[], bad=[], oSend=netSend, oSay=say, peer={seat:1,state:'in'}, w, dead=null, id, i, st0=state, btn;
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       netSend=function(p,m){ sent.push(m); return true; };
       say=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer];
       netUpAnnounce(G);
       for(i=0;i<G.ents.length;i++) if(G.ents[i]&&G.ents[i].nid){ dead=G.ents[i]; break; }
       if(!dead) return 'SKIP: staging: no numbered body';
       id=dead.nid; delete NET.entMap[id]; G.ents.splice(G.ents.indexOf(dead),1);
       G.t=123.4; G.timeLeft=456.7; sent.length=0;
       netLateReply(peer);
       w=sent.filter(function(m){ return m&&m.t==='raid'; })[0];
       if(!w) bad.push('the host sent no raid word to a late teammate');
       else{
         if(!w.late||w.late.t!==123.4||w.late.left!==456.7) bad.push('the late word does not carry the clock and the time left ('+JSON.stringify(w.late)+')');
         if(!w.gone||w.gone.indexOf(id)<0) bad.push('the late word does not name the body already down');
         if(w.seed!==(G.seed>>>0)) bad.push('the late word names another seed');
       }
       __endRaid('abandon'); __topClear();
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       NET.role='join'; NET.seat=1; netEntsInit(G);
       var had=G.ents.some(function(e){ return e&&e.nid===id; });
       netLateApply({late:{t:200,left:99,x:Math.round(G.player.x+400),y:Math.round(G.player.y)},gone:[id]});
       if(had&&G.ents.some(function(e){ return e&&e.nid===id; })) bad.push('a body the host had down stayed in the late window');
       if(G.t!==200||G.timeLeft!==99) bad.push('the late window did not take the host clock and time left');
       __endRaid('abandon'); __topClear();
       G=null; state='hub'; NET.role='join'; NET.hostSeed=4242;
       netLateBtn(); btn=document.getElementById('joinlate');
       if(!btn) bad.push('no JOIN THE RAID IN PROGRESS button while the host is up');
       NET.hostSeed=0; netLateBtn();
       if(document.getElementById('joinlate')) bad.push('the join button stayed after the host came out');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; say=oSay; state=st0;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var jb=document.getElementById('joinlate'); if(jb&&jb.parentNode) jb.parentNode.removeChild(jb); }catch(_j){}
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

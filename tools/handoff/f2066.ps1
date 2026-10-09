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

if ($s.Contains("  {v:'20.66',what:")) { throw "check 20.66 is in the fixture already" }

SubRx @'
  {v:'20.65',what:
'@ @'
  {v:'20.66',what:'the co-op run card shows the PARTY score block with downs and revives, and the older party summary sent right after it no longer wipes it, on this window and when a teammate finishes',
   run:function(){
     if(typeof netScoreSend!=='function'||typeof netScoreTake!=='function'||typeof netScoreDraw!=='function'||typeof netSumTake!=='function'||typeof netSumDraw!=='function') return 'SKIP: no co-op score screen here';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, sent=[], bad=[], oSend=netSend, peer={seat:1,state:'in',name:'ZQX MATE'}, seed, t;
     for(k in NET) NK[k]=NET[k];
     function txt(){ var e=document.getElementById('oc_party'); return e?String(e.textContent||''):''; }
     function shown(){ var e=document.getElementById('oc_party'); return !!e&&e.style.display!=='none'; }
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       netSend=function(p,m){ sent.push(m); return true; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; NET.up=[]; NET.upSeed=G.seed>>>0; seed=NET.upSeed; NET.sc={}; NET.sum={};
       NET.roster=[{seat:0,name:'ZQX HOST',host:1},{seat:1,name:'ZQX MATE'}];
       __endRaid('extract');
       if(!sent.some(function(m){ return m&&m.t==='sc'; })||!sent.some(function(m){ return m&&m.t==='sum'; })) return 'SKIP: staging: the ended raid did not send both party words';
       t=txt();
       if(!/revives/.test(t)||!/downs/.test(t)) bad.push('the run card has no PARTY score block with downs and revives ('+t.slice(0,100)+')');
       if(!shown()) bad.push('the party block on the run card is hidden');
       netScoreTake(peer,{t:'sc',sc:{how:'dead',k:7,h:0,it:0,dn:3,rv:2,sd:seed}});
       netSumTake(peer,{t:'sum',how:'dead',k:7,v:0});
       t=txt();
       if(!/3 downs/.test(t)||!/2 revives/.test(t)||!/ZQX MATE/.test(t)) bad.push('after the teammate finished, the card does not show his 3 downs and 2 revives ('+t.slice(0,140)+')');
       if(!shown()) bad.push('after the teammate finished, the party block is hidden');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var pe=document.getElementById('oc_party'); if(pe){ pe.innerHTML=''; pe.style.display='none'; } }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

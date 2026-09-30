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

if ($s.Contains("  {v:'17.39',what:")) { throw "check 17.39 is in the fixture already" }

SubRx @'
  {v:'17.38',what:
'@ @'
  {v:'17.39',what:'the co-op score screen: a party raid that ends sends the party a score word and the end card shows a PARTY block, own row filled in, a teammate reading still up top until his word comes, then his result',
   run:function(){
     if(typeof netScoreSend!=='function'||typeof netScoreTake!=='function') return 'this build has no co-op score screen';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, sent=[], bad=[], oSend=netSend, oName=netSeatName, peer={seat:1,state:'in',name:'ZQX MATE'}, seed, el;
     for(k in NET) NK[k]=NET[k];
     function txt(){ var e=document.getElementById('oc_party'); return e?(e.textContent||''):''; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       netSend=function(p,m){ sent.push(m); return true; };
       netSeatName=function(s){ return s===0?'ZQX HOST':(s===1?'ZQX MATE':null); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; NET.up=[]; NET.upSeed=G.seed>>>0; seed=NET.upSeed; NET.sc={};
       __endRaid('extract');
       try{ netScoreDraw(); }catch(_d0){}   // the card itself may draw a beat later; the block is drawn from the same state
       if(!sent.some(function(m){ return m&&m.t==='sc'&&m.sc&&m.sc.how==='extract'; })) bad.push('an ended party raid sent no score word');
       if(!/YOU/.test(txt())||!/EXTRACTED/.test(txt())) bad.push('the end card shows no PARTY row for this player ('+txt().slice(0,80)+'; on '+NET.on+', seat '+NET.seat+', scSd '+NET.scSd+', sc '+JSON.stringify(NET.sc)+', manifest '+!!document.getElementById('oc_manifest')+', party el '+!!document.getElementById('oc_party')+')');
       if(!/still up top/.test(txt())) bad.push('a teammate whose word has not come does not read still up top');
       netScoreTake(peer,{t:'sc',sc:{how:'dead',k:3,h:0,it:0,dn:1,rv:0,sd:seed}});
       if(!/KILLED/.test(txt())||!/3 kills/.test(txt())) bad.push('the teammate word did not fill his row ('+txt().slice(0,120)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netSeatName=oName;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var pe=document.getElementById('oc_party'); if(pe) pe.innerHTML=''; }catch(_p){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

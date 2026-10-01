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

if ($s.Contains("  {v:'17.53',what:")) { throw "check 17.53 is in the fixture already" }

SubRx @'
  {v:'17.52',what:
'@ @'
  {v:'17.53',what:'drop-in after a window comes back: a teammate who links while the host is up top is told the raid it is in, keeps it for JOIN THE RAID IN PROGRESS and is told to go up at the lift; with the host below, nothing changes',
   run:function(){
     if(typeof netOnMsg0!=='function'||typeof netLateBtn!=='function') return 'SKIP: this build has no drop-in';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, sent=[], bad=[], oSend=netSend, oSay=netSay, peer, w;
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       netSend=function(p,m){ sent.push(m); return true; };
       netSay=function(){};
       peer={state:'open'}; NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; NET.upWord={t:'raid',seed:G.seed>>>0};
       netOnMsg0(peer,JSON.stringify({t:'hello',proto:NET.proto,ver:VER,pid:'tst1',name:'TESTER'}));
       w=sent.filter(function(m){ return m&&m.t==='welcome'; })[0];
       if(!w) bad.push('the host sent no welcome ('+JSON.stringify(sent).slice(0,160)+')');
       else if(w.up!==(G.seed>>>0)) bad.push('the welcome from a host up top does not carry its raid ('+JSON.stringify(w.up)+')');
       __endRaid('abandon'); __topClear(); G=null;
       sent.length=0; peer={state:'open'}; NET.peers=[peer];
       netOnMsg0(peer,JSON.stringify({t:'hello',proto:NET.proto,ver:VER,pid:'tst2',name:'TESTER'}));
       w=sent.filter(function(m){ return m&&m.t==='welcome'; })[0];
       if(w&&w.up) bad.push('the welcome from a host in the Undercroft says it is up top');
       peer={state:'open'}; NET.role='join'; NET.seat=1; NET.peers=[peer]; NET.hostSeed=0;
       netOnMsg0(peer,JSON.stringify({t:'welcome',you:1,roster:[{seat:0,host:1,name:'HOST',pid:'h0'},{seat:1,name:'TESTER',pid:'tst1'}],ver:VER,up:4242}));
       if(NET.hostSeed!==4242) bad.push('a teammate welcomed by a host up top did not keep the raid ('+NET.hostSeed+')');
       if(!/lift/.test(NET.status||'')) bad.push('a teammate welcomed by a host up top was not told to go up at the lift ('+NET.status+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netSay=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var jb=document.getElementById('joinlate'); if(jb&&jb.parentNode) jb.parentNode.removeChild(jb); }catch(_j){}
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

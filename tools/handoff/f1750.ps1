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

if ($s.Contains("  {v:'17.50',what:")) { throw "check 17.50 is in the fixture already" }

SubRx @'
  {v:'17.49',what:
'@ @'
  {v:'17.50',what:'drop-in: a teammate who joins late is also told about every body that came up after the build (THE OVERSEER with its name and size), after the raid word and only those bodies',
   run:function(){
     if(typeof netLateReply!=='function'||typeof bossTick!=='function') return 'SKIP: this build has no drop-in or no boss';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, sent=[], bad=[], oSend=netSend, oSay=say, peer={seat:1,state:'in'}, b, news, ix;
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       netSend=function(p,m){ sent.push(m); return true; };
       say=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer];
       netUpAnnounce(G);
       G.t=2.5; b=bossTick();
       if(!b) return 'SKIP: staging: no boss came up';
       b.nid=G.nidN++; NET.entMap[b.nid]=b;
       sent.length=0;
       netLateReply(peer);
       ix=-1; sent.forEach(function(m,i){ if(m&&m.t==='raid'&&ix<0) ix=i; });
       news=sent.filter(function(m){ return m&&m.t==='ent'&&m.op==='new'; });
       if(ix<0) bad.push('no raid word went to the late teammate');
       if(!news.length) bad.push('the late teammate was told about no body that came up after the build');
       else{
         if(news.length!==1) bad.push(news.length+' bodies were announced, not the one that came up after the build');
         if(news[0].id!==b.nid||news[0].n!=='THE OVERSEER'||news[0].r!==44) bad.push('the word about the boss is wrong ('+JSON.stringify(news[0]).slice(0,120)+')');
         if(sent.indexOf(news[0])<ix) bad.push('the body word went before the raid word');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; say=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

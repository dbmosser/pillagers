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

if ($s.Contains("  {v:'33.57',what:")) { throw "check 33.57 is in the fixture already" }

SubRx @'
  {v:'33.56',what:
'@ @'
  {v:'33.57',what:'a same machine pair that nobody joins says so: 15 s after the pick with no one in, the status reads player 2 not linked with RETRY offered (before 15 s it still waits; a link clears it)',
   run:function(){
     if(typeof netSameWatch!=='function') return 'FAIL: this build has no netSameWatch (a pair that never links says nothing)';
     var nk=['on','role','same','pair','mode','peers','p2win','p2url','pick','status','bc','sameBusy','err','sameT0','noLink'], keep={}, i, bad=[], k, r;
     for(i=0;i<nk.length;i++) keep[nk[i]]=NET[nk[i]];
     var oEmb=reportEmbedded, oSay=netSay, said=[], oOpen=window.open, oHL=netSameHostLink, oPI=netPadInit, oSI=netSndInit, oRef=netRefresh;
     var chan={posted:[],postMessage:function(m){ this.posted.push(m); },close:function(){},onmessage:null};
     var msg=document.getElementById('modemsg'), rt=document.getElementById('moderetry');
     try{
       netSay=function(t){ said.push(String(t)); }; netRefresh=function(){};
       for(k=0;k<2;k++){
         reportEmbedded=function(){ return k===1; };
         NET.on=true; NET.role='host'; NET.same='host'; NET.pair='zqxpair'; NET.mode='coop'; NET.peers=[]; NET.bc=chan; NET.status='waiting for player 2'; NET.sameT0=1000; NET.noLink=0; said.length=0; netModeMsg('');
         r=netSameWatch(1000+14000);
         if(r!=='wait'||NET.status!=='waiting for player 2') bad.push('run '+k+': at 14 s the watch already gave up ('+r+', '+NET.status+')');
         r=netSameWatch(1000+15500);
         if(r!=='nolink'||NET.status!=='player 2 not linked') bad.push('run '+k+': at 15.5 s with nobody in the status is "'+NET.status+'" ('+r+')');
         if(!msg||msg.style.display==='none'||String(msg.textContent||'').toLowerCase().indexOf('player 2 not linked')<0) bad.push('run '+k+': the title note does not say player 2 not linked');
         if(!rt||rt.style.display==='none') bad.push('run '+k+': RETRY is not offered');
         if(said.length!==1) bad.push('run '+k+': the hub feed said it '+said.length+' times');
         r=netSameWatch(1000+20000);
         if(r!=='shown'||said.length!==1) bad.push('run '+k+': the callout repeats ('+r+', '+said.length+')');
         NET.peers=[{state:'in',seat:1,pid:'zqxmate',name:'ZQX',timers:[],dc:{readyState:'open',send:function(){},close:function(){}}}];
         r=netSameWatch(1000+21000);
         if(r!=='linked'||NET.status==='player 2 not linked'||NET.noLink) bad.push('run '+k+': a link did not clear the note ('+r+', '+NET.status+')');
         if(msg&&msg.style.display!=='none'&&String(msg.textContent||'').toLowerCase().indexOf('not linked')>=0) bad.push('run '+k+': the title note stayed after the link');
         NET.peers=[]; NET.noLink=0; NET.sameT0=0;
         if(netSameWatch(1000+99000)!=='off') bad.push('run '+k+': the watch runs with no pick time');
       }
       // the pick itself starts the watch
       reportEmbedded=oEmb;
       window.open=function(){ return {closed:false,focus:function(){}}; };
       netSameHostLink=function(){ return 'x'; }; netPadInit=function(){}; netSndInit=function(){};
       NET.on=true; NET.role='host'; NET.same=''; NET.pair='zqxpair'; NET.peers=[]; NET.bc=chan; NET.sameT0=0; NET.noLink=0; NET.p2win=null;
       r=netSamePick('coop',function(){});
       if(r!=='opened') bad.push('control: the pick did not open ('+r+')');
       else if(!(NET.sameT0>0)) bad.push('the pick did not start the no-link watch');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally {
       reportEmbedded=oEmb; netSay=oSay; netRefresh=oRef; window.open=oOpen; netSameHostLink=oHL; netPadInit=oPI; netSndInit=oSI;
       for(i=0;i<nk.length;i++) NET[nk[i]]=keep[nk[i]];
       try{ netModeMsg(''); }catch(_m){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

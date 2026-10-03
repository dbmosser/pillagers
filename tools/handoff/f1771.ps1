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

if ($s.Contains("  {v:'17.71',what:")) { throw "check 17.71 is in the fixture already" }

SubRx @'
  {v:'17.70',what:
'@ @'
  {v:'17.71',what:'the kid menu: a KID MODE heading in Settings with a PLAYER 2 COMES BACK AFTER DEATH row; on, a teammate who died is not kept out of the raid (neither his window nor the host marks him); off, he is',
   run:function(){
     if(typeof kbCycle!=='function'||typeof kidHeadHtml!=='function') return 'Settings has no kid menu and no way back after death for player 2';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof renderSettings!=='function') return 'SKIP: no raid, party or Settings in this fixture';
     var NK={}, k, bad=[], kb0=P.kidBack, oB=netBroadcast, oSend=netSend, oSay=netSay, oSwf=sayWhenFree, host, peer, sd;
     for(k in NET) NK[k]=NET[k];
     try{
       P.kidBack=0; renderSettings(); host=document.getElementById('settings')||document.body;
       if(!/KID MODE/.test(document.body.innerHTML)) bad.push('Settings has no KID MODE heading');
       if(!document.getElementById('set_kb')) bad.push('Settings has no comes-back-after-death button');
       else{ document.getElementById('set_kb').onclick(); if(!kbOwn()) bad.push('the button did not turn it on'); }
       NET.on=false; NET.role=null; NET.peers=[];
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       sd=G.seed>>>0; netBroadcast=function(){}; netSend=function(){ return true; }; netSay=function(){}; sayWhenFree=function(){};
       P.kidBack=1; NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.lateBan=0; NET.upSeed=sd;
       netUpEnd('dead'); if(NET.lateBan) bad.push('with it on, a teammate who died was kept out of the raid');
       P.kidBack=0; NET.upSeed=sd; netUpEnd('dead'); if(!NET.lateBan) bad.push('with it off, a teammate who died was not kept out');
       NET.lateBan=0; NET.upSeed=sd; P.kidBack=1; netUpEnd('extract'); if(!NET.lateBan) bad.push('with it on, a teammate who extracted was let back in');
       peer={seat:1,state:'in'}; NET.role='host'; NET.seat=0; NET.peers=[peer]; NET.lateOut={}; NET.upWord={t:'raid',seed:sd}; if(!NET.up) NET.up=[];
       P.kidBack=1; netUpWord(peer,{t:'up',st:'out',how:'dead'}); if(NET.lateOut&&NET.lateOut[1]) bad.push('with it on, the host kept the teammate who died out');
       P.kidBack=0; NET.lateOut={}; netUpWord(peer,{t:'up',st:'out',how:'dead'}); if(!(NET.lateOut&&NET.lateOut[1])) bad.push('with it off, the host did not keep the teammate who died out');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       P.kidBack=kb0; try{ saveProfile(); }catch(_s){}
       netBroadcast=oB; netSend=oSend; netSay=oSay; sayWhenFree=oSwf;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

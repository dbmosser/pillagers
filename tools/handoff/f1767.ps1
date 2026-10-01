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

if ($s.Contains("  {v:'17.67',what:")) { throw "check 17.67 is in the fixture already" }

SubRx @'
  {v:'17.66',what:
'@ @'
  {v:'17.67',what:'his ruling holds for that raid only: a new raid from the host clears who sat the last one out, on the host and on the teammate, even on the same seed',
   run:function(){
     if(typeof netUpAnnounce!=='function'||typeof netUpTake!=='function') return 'SKIP: this build has no party raid';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], oB=netBroadcast, oSend=netSend, oSay=netSay, peer={seat:0,state:'in'};
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       netBroadcast=function(){}; netSend=function(){ return true; }; netSay=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[]; NET.lateOut={1:G.seed>>>0};
       netUpAnnounce(G);
       if(NET.lateOut&&NET.lateOut[1]) bad.push('a new host raid kept the teammate who died in the last one out');
       NET.role='join'; NET.seat=1; NET.peers=[peer]; NET.lateBan=4242;
       netUpTake(peer,{t:'raid',seed:4242});
       if(NET.lateBan) bad.push('a new raid word from the host left the teammate out of it');
       NET.lateBan=4242;
       netUpTake(peer,{t:'raid',seed:4242,late:{t:5,left:100,x:0,y:0}});
       if(NET.lateBan!==4242) bad.push('a late join answer cleared the mark it is refused on');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netBroadcast=oB; netSend=oSend; netSay=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

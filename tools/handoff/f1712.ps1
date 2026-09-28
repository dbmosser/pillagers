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

if ($s.Contains("  {v:'17.12',what:")) { throw "check 17.12 is in the fixture already" }

SubRx @'
  {v:'17.11',what:
'@ @'
  {v:'17.12',what:'a kill word from the host that reaches player 2 after his raid has ended is refused: his finished run gains no kill and his contracts do not step; while he is up top the word still counts',
   run:function(){
     if(typeof netKillTake!=='function'||typeof netEntsPeer!=='function'||typeof contractKill!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no party kill word';
     var keep={}, k, oSend=netSend, oRef=netRefresh, oSay=say, oSWF=sayWhenFree, oSave=saveProfile, oCK=contractKill,
         bad=[], g=null, ck=0, r, n0, k0=0, peer={state:'in',seat:0};
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=G;
       if(!g||!g.player||!g.tel||!g.tel.kills) return 'SKIP: staging: no live raid';
       k0=g.tel.kills.sentry;
       netSend=function(){ return true; }; netRefresh=function(){}; say=function(){}; sayWhenFree=function(){}; saveProfile=function(){}; contractKill=function(){ ck++; };
       NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[peer]; NET.up=[]; NET.entMap={}; NET.entDead={};
       n0=g.tel.kills.sentry||0;
       r=netKillTake(peer,{t:'kill',seat:1,id:987654,k:'sentry',el:0});
       if(r!=='kill'||(g.tel.kills.sentry||0)!==n0+1||ck!==1) return 'SKIP: staging: a kill word while player 2 is up top was not counted ('+r+', kills '+n0+' to '+g.tel.kills.sentry+', contract steps '+ck+')';
       g.over=true; ck=0; n0=g.tel.kills.sentry||0;
       r=netKillTake(peer,{t:'kill',seat:1,id:987655,k:'sentry',el:0});
       if(r==='kill') bad.push('the kill word was taken on a raid that had already ended');
       if((g.tel.kills.sentry||0)!==n0) bad.push('the finished run gained a kill ('+n0+' to '+g.tel.kills.sentry+')');
       if(ck) bad.push('a kill contract stepped '+ck+' time(s) after the run ended');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netRefresh=oRef; say=oSay; sayWhenFree=oSWF; saveProfile=oSave; contractKill=oCK;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ if(g&&g.tel&&g.tel.kills) g.tel.kills.sentry=k0; if(g&&g===G) g.over=false; __endRaid('abandon'); __topClear(); }catch(e2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

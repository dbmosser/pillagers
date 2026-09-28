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

if ($s.Contains("  {v:'17.11',what:")) { throw "check 17.11 is in the fixture already" }

SubRx @'
  {v:'17.10',what:
'@ @'
  {v:'17.11',what:'a pillager the host downed who bleeds out in the raid the host keeps running after he left it is not his kill: no kill count, contract step or grudge, and a survivor his round dropped adds no notoriety; in his own raid both still count',
   run:function(){
     if(typeof netSpecTick!=='function'||typeof netSpecStart!=='function'||typeof mkRaider!=='function'||typeof updateEnts!=='function'||typeof contractKill!=='function'||typeof sayWhenFree!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no spectating host';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,up:NET.up,peers:NET.peers,specAcc:NET.specAcc,specIdle:NET.specIdle,specHow:NET.specHow,status:NET.status,specErr:NET.specErr},
         oSend=netSend, oBc=netBroadcast, oShown=netUpShown, oRef=netRefresh, oSay=say, oSWF=sayWhenFree, oSave=saveProfile, oCK=contractKill, oNS=notoStamp,
         bad=[], k, g=null, p=null, ck=0, ID='zqx_late_kill_rival', hadNoto=false, noto0=0, c0=-1, n0, r0, kr0=0;
     function lay(kind){
       var R=mkRaider(p.x+300,p.y,null,false);
       R.hostile=true; R.merc=0; R.roll=0; R.ident=ID; R.name='ZQX LATE'; R.elite=0; R.bySeat=0; R.byPlayer=true; R.hp=0;
       if(kind==='stray'){ R.kind='stray'; R.want='scrap'; R.downed=0; R.finished=0; }
       else { R.downed=0; R.finished=1; R.state='down'; }
       g.ents.length=0; g.ents.push(R); g.bullets.length=0;
       return R;
     }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=G; p=g&&g.player;
       if(!g||!p||!g.tel||!g.tel.kills) return 'SKIP: staging: no live raid';
       kr0=g.tel.kills.raider;
       hadNoto=Object.prototype.hasOwnProperty.call(P,'notoriety'); noto0=P.notoriety;
       if(Array.isArray(P.crashes)) c0=P.crashes.length;
       if(P.rivals) delete P.rivals[ID];
       say=function(){}; sayWhenFree=function(){}; saveProfile=function(){}; notoStamp=function(){}; contractKill=function(){ ck++; };
       netSend=function(){ return true; }; netBroadcast=function(){}; netUpShown=function(q){ return !!q; }; netRefresh=function(){};
       NET.on=false;
       n0=g.tel.kills.raider||0; lay('raider'); updateEnts(0.02);
       if((g.tel.kills.raider||0)!==n0+1||ck!==1||!(P.rivals&&P.rivals[ID])) return 'SKIP: staging: a pillager the host downed who bled out in his own raid was not credited to him (kills '+n0+' to '+g.tel.kills.raider+', contract steps '+ck+')';
       r0=P.notoriety||0; lay('stray'); updateEnts(0.02);
       if((P.notoriety||0)!==r0+1) return 'SKIP: staging: a survivor the host dropped in his own raid added no notoriety';
       if(hadNoto) P.notoriety=noto0; else delete P.notoriety;
       delete P.rivals[ID]; ck=0;
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.peers=[{state:'in',seat:1}]; NET.up=[{seat:1,n:1,tx:p.x+3000,ty:p.y+3000,tf:0}];
       if(!netSpecStart('dead')) return 'SKIP: staging: the host did not start to spectate';
       g.over=true;
       n0=g.tel.kills.raider||0; var LR=lay('raider'); netSpecTick(0.02);
       if(g.ents.indexOf(LR)>=0) return 'SKIP: staging: the kept raid did not take the bled out man off the map';
       if(NET.specErr) bad.push('the kept raid threw while the check ran');
       if((g.tel.kills.raider||0)!==n0) bad.push('the host run gained a kill ('+n0+' to '+g.tel.kills.raider+') for a man who bled out after the host left the raid');
       if(ck) bad.push('a kill contract of the host stepped '+ck+' time(s) for it');
       if(P.rivals&&P.rivals[ID]) bad.push('a grudge was written into the host save for it');
       r0=P.notoriety||0; lay('stray'); netSpecTick(0.02);
       if((P.notoriety||0)!==r0) bad.push('a survivor who died in the kept raid charged the host notoriety ('+r0+' to '+P.notoriety+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netBroadcast=oBc; netUpShown=oShown; netRefresh=oRef; say=oSay; sayWhenFree=oSWF; saveProfile=oSave; contractKill=oCK; notoStamp=oNS;
       for(k in keep) NET[k]=keep[k];
       try{ if(hadNoto) P.notoriety=noto0; else delete P.notoriety; if(P.rivals) delete P.rivals[ID]; if(c0>=0&&Array.isArray(P.crashes)&&P.crashes.length>c0) P.crashes.length=c0; }catch(e2){}
       try{ if(g){ if(g.tel&&g.tel.kills) g.tel.kills.raider=kr0; g.ents.length=0; g.bullets.length=0; if(g.player) g.player.specOut=0; } }catch(e3){}
       try{ __endRaid('abandon'); __topClear(); }catch(e4){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

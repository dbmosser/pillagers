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

if ($s.Contains("  {v:'28.42',what:")) { throw "check 28.42 is in the fixture already" }

SubRx @'
  {v:'28.41',what:
'@ @'
  {v:'28.42',what:'cloud-coop-spectate-event-buffs-end: when the host extracts or dies in a career co-op raid and spectates while player 2 plays on, a live Overseer rampage ends on the host body too: the Overseer is back at its own speed and its own lair, not fast and roaming for the rest of the raid',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof netSpecStart!=='function'||typeof netSpecTick!=='function'||typeof evLaunch!=='function'||typeof evTick!=='function'||typeof flowTick!=='function'||typeof bossTick!=='function'||typeof CAREER_ON==='undefined') return 'SKIP: no career, party or events in this fixture';
     var g=null, S=null, NK={}, k, staged=false, c0=CAREER_ON, oS=netSend, oF=netSendFast, oSh=netUpShown, oRef=netRefresh, oET=netEntsTick, oCT=netContTick, oWS=netWorldSend, oSay=say, oSWF=sayWhenFree, rp, b, i, L0, bs0, oIv=null;
     try{
       __topClear(); __runPrep(); CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(!g.career) return 'SKIP: the raid is not a career raid';
       oIv=g.player.iv; g.player.iv=99; g.t=60; flowTick(0.01);
       if(!g.flow) return 'SKIP: the career raid has no flow';
       say=function(){}; sayWhenFree=function(){};
       g.flow.ev={plan:[],live:[],n:0,wrecks:[]};
       if(!g.bossRef) bossTick(true);
       rp=evLaunch('rampage'); if(!rp) return 'SKIP: no Overseer rampage launched';
       rp.t=rp.warn; evTick(0.01); b=rp.d.b; if(rp.ph!=='live'||!b||!b.rmp||!b.rmpL) return 'SKIP: the rampage did not go live';
       evTick(1); L0=[b.rmpL[0],b.rmpL[1]]; bs0=b.rmpSpd;
       if(b.lairX===L0[0]&&b.lairY===L0[1]) return 'SKIP: the rampage did not move the lair';
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) NK[k]=NET[k]; staged=true;
       netSend=function(){return true;}; netSendFast=function(){return true;}; netUpShown=function(x){return !!x;}; netRefresh=function(){};
       netEntsTick=function(){return 0;}; netContTick=function(){return 0;}; netWorldSend=function(){return 0;};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.upOut=undefined; NET.specG=null; NET.specTick=false;
       NET.peers=[{state:'in',seat:1,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}}}];
       NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}];
       NET.up=[{seat:1,n:1,age:0,sd:g.seed>>>0,tx:g.player.x+600,ty:g.player.y,tf:0,dn:0}];
       g.over='dead';
       if(!netSpecStart('dead')) return 'SKIP: the host did not start spectating';
       S=g;
       for(i=0;i<300;i++){ NET.up[0].age=0; netSpecTick(0.1); }
       if(b.rmp) return 'thirty seconds after the host went down, the Overseer is still on its rampage';
       if(Math.abs(b.spd-bs0)>1e-6) return 'thirty seconds after the host went down, the Overseer still runs at '+(b.spd/bs0).toFixed(2)+'x speed';
       if(b.lairX!==L0[0]||b.lairY!==L0[1]) return 'thirty seconds after the host went down, the Overseer lair is still moved';
       if(rp.ph!=='end') return 'after the host went down, the rampage is '+rp.ph+', not ended';
       return null;
     }catch(x){ return 'threw: '+(x&&x.message||x); }
     finally{
       netSend=oS; netSendFast=oF; netUpShown=oSh; netRefresh=oRef; netEntsTick=oET; netContTick=oCT; netWorldSend=oWS; say=oSay; sayWhenFree=oSWF; CAREER_ON=c0;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; NET.specG=null; }
       try{ if(S) G=S; if(g&&g.player&&oIv!==null) g.player.iv=oIv; if(G){ G.over=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
   }},
  {v:'28.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

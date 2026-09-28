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

if ($s.Contains("  {v:'17.05',what:")) { throw "check 17.05 is in the fixture already" }

SubRx @'
  {v:'17.04',what:
'@ @'
  {v:'17.05',what:'a teammate pick-up stops when the one picking him up goes down or rolls: the pick-up clock and its REVIVING bar are cleared, and E held on once he is up again starts the pick-up from the start',
   run:function(){
     if(typeof netRevHold!=='function'||typeof updatePlayer!=='function'||typeof netSend!=='function'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no teammate pick-up';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,up:NET.up,peers:NET.peers,roster:NET.roster},
         oSend=netSend, oSay=say, oBlip=blip, k0=keys, bad=[], said=[], p=null, i, k, n;
     function step(){ keys['KeyE']=true; updatePlayer(0.05); if(G.netRevEat){ G.netRevEat=0; keys['KeyE']=true; } }
     function starts(){ return said.filter(function(m){ return m.indexOf('Reviving ZQX')===0; }).length; }
     function mate(){ NET.up[1]={seat:1,x:p.x+30,y:p.y,f:0,tx:p.x+30,ty:p.y,tf:0,n:5,age:0,dn:1,hp:0,mh:100,sd:NET.upSeed>>>0}; }
     function hold(){ G.netRevT=0; G.netRevS=-1; G.netRevDone=-1; G.netRevWait=-1; mate(); for(i=0;i<40;i++) step(); return G.netRevT||0; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       p=G.player; keys={}; G.sim=0; G.over=false; p.downed=false; p.roll=0;
       netSend=function(){ return true; }; say=function(m){ said.push(String(m)); }; blip=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.up=[]; NET.peers=[{state:'in',seat:1}];
       NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       // CONTROL: 2 s of E held beside a downed teammate runs the pick-up clock on him.
       if(!(hold()>1.5)||G.netRevS!==1) return 'SKIP: staging: 2 s of E held beside a downed teammate did not run the pick-up clock on him ('+G.netRevT+', seat '+G.netRevS+')';
       // ONE: he goes down 2 s into the pick-up, E still held.
       p.downed=true; p.downT=60; p.healLock=true; keys['KeyE']=true; updatePlayer(0.05);
       if(G.netRevT>0&&G.netRevS>=0) bad.push('he went down 2 s into a pick-up and the pick-up clock and its REVIVING bar stayed at '+G.netRevT.toFixed(2)+' s on the teammate');
       // TWO: up again with E still held beside him: the pick-up starts again from the start.
       p.downed=false; p.healLock=false; n=starts(); step();
       if(G.netRevT>1) bad.push('up again with E held, the pick-up carried on from '+G.netRevT.toFixed(2)+' s instead of starting again');
       if(starts()!==n+1) bad.push('up again with E held, the pick-up did not start again with its Reviving line');
       // THREE: a roll 2 s into a pick-up.
       if(!(hold()>1.5)) return bad.length?bad.join('; '):'SKIP: staging: the second 2 s hold did not run the pick-up clock';
       p.roll=0.3; p.rollDir={x:0,y:0}; keys['KeyE']=true; updatePlayer(0.05);
       if(G.netRevT>0) bad.push('a roll 2 s into a pick-up left the pick-up clock and its REVIVING bar at '+G.netRevT.toFixed(2)+' s');
       p.roll=0;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; say=oSay; blip=oBlip; keys=k0||{};
       for(k in keep) NET[k]=keep[k];
       try{ if(G){ G.netRevEat=0; G.netRevWait=-1; G.netRevDone=-1; G.netRevT=0; G.netRevS=-1; if(G.player){ G.player.downed=false; G.player.roll=0; } } __endRaid('abandon'); __topClear(); }catch(e2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

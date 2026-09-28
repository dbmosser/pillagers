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

if ($s.Contains("  {v:'16.94',what:")) { throw "check 16.94 is in the fixture already" }

SubRx @'
  {v:'16.93',what:
'@ @'
  {v:'16.94',what:'a teammate whose raid ended while he was down is never picked up: his late position word that still says down no longer takes E from a player pulling in a landed ring beside that spot, a downed teammate whose word went stale is offered for no pick-up, and one down with a fresh word still is',
   run:function(){
     if(typeof netMateDown!=='function'||typeof netRevHold!=='function'||typeof netUpWord!=='function'||typeof netOnState!=='function'||typeof netUpShown!=='function'||typeof tryExtractTick!=='function'||typeof updatePlayer!=='function'||typeof NET_HUB_STALE!=='number'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no teammate pick-up or no party words';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,up:NET.up,upOut:NET.upOut,peers:NET.peers,roster:NET.roster,status:NET.status,srch:NET.srch,holds:NET.holds},
         oSend=netSend, oRef=netRefresh, oSay=say, oBlip=blip, oER=endRaid, k0=keys, bad=[], k, peer, z, p, w, i, s, ended=null;
     function ring(){ z.open=true; z.beaconT=0; z.hold=20; z.holdMax=30; z.pullT=null; z.pullFloor=0; z.boardT=0; G.active=z; G.beaconT=0; G.shipHold=20; p.x=z.x; p.y=z.y; p.downed=false; p.roll=0; }
     function pull(){ ended=null; ring(); for(i=0;i<80&&ended===null;i++){ keys['KeyE']=true; updatePlayer(0.05); if(G.netRevEat){ G.netRevEat=0; keys['KeyE']=true; } } keys['KeyE']=false; return ended; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player||!G.zones||!G.zones.length) return 'SKIP: staging: no raid or no ring';
       p=G.player; z=G.zones[0]; keys={}; G.sim=0; G.over=false;
       netSend=function(){ return true; }; netRefresh=function(){}; say=function(){}; blip=function(){};
       endRaid=function(how){ ended=how; };
       peer={state:'in',seat:1};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}]; NET.up=[]; NET.upOut=undefined; NET.specG=null; NET.holds={}; NET.srch=null;
       // CONTROL: with nobody down beside him, E held in the landed ring pulls him out
       if(pull()!=='extract') return 'SKIP: staging: alone in the landed ring E held 4 s did not extract (ended '+ended+')';
       if(p.downed) return 'SKIP: staging: he went down in the ring';
       ring();
       w={t:'st',k:'r',sd:G.seed>>>0,x:z.x+20,y:z.y,f:0,m:0,r:0,c:0,sp:0,dn:1,w:'',pz:0,hp:0,mh:100,ar:0,ac:0,dt:9,sa:1};
       netOnState(peer,w);
       if(!NET.up[1]||!NET.up[1].dn||!netUpShown(NET.up[1])) return 'SKIP: staging: the downed teammate word was not filed up top';
       // CONTROL: a teammate down beside him with a fresh word is still offered for a pick-up
       s=netMateDown(p);
       if(s!==1) bad.push('a teammate down beside him with a fresh word was not offered for a pick-up ('+s+')');
       // A WORD GONE STALE: he is no longer drawn, so he is nobody to pick up
       NET.up[1].age=NET_HUB_STALE+1;
       s=netMateDown(p);
       if(s>=0) bad.push('a downed teammate whose word went stale '+(NET_HUB_STALE+1)+' s ago, no longer drawn, was still offered for a pick-up');
       NET.up[1].age=0;
       // HIS RAID ENDED WHILE DOWN, and his last word, still down, lands after his out word
       try{ netUpWord(peer,{t:'up',st:'out',how:'extract'}); }catch(e){}
       if(NET.up[1]) return 'SKIP: staging: the out word did not take him off the list';
       netOnState(peer,w);
       if(!NET.up[1]||!NET.up[1].dn) return 'SKIP: staging: the late position word was not filed up top again';
       if(pull()!=='extract') bad.push('in the landed ring E held 4 s beside the spot of a teammate whose raid ended while down never pulled him out: the late word kept taking E for a pick-up (ended '+ended+')');
     } finally {
       endRaid=oER; netSend=oSend; netRefresh=oRef; say=oSay; blip=oBlip; keys=k0;
       for(k in keep) NET[k]=keep[k];
       try{ if(G){ G.netRevEat=0; G.netRevWait=-1; G.netRevDone=-1; G.netRevT=0; G.netRevS=-1; if(G.player){ G.player.specOut=0; G.player.downed=false; } } }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

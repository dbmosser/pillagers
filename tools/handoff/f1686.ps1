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

if ($s.Contains("  {v:'16.86',what:")) { throw "check 16.86 is in the fixture already" }

SubRx @'
  {v:'16.85',what:
'@ @'
  {v:'16.86',what:'a downed host holding E in a landed ring after his teammate extracted ends his own raid outright: a position word of that teammate landing after his out word still draws him for a moment but never parks the host spectating for a party that has left',
   run:function(){
     if(typeof netUpWord!=='function'||typeof netOnState!=='function'||typeof netSpecStart!=='function'||typeof netUpShown!=='function'||typeof tryExtractTick!=='function'||typeof updatePlayer!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no party words';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,specHow:NET.specHow,up:NET.up,upOut:NET.upOut,peers:NET.peers,roster:NET.roster,status:NET.status,srch:NET.srch,holds:NET.holds},
         oSend=netSend, oRef=netRefresh, oSay=say, oBlip=blip, oER=endRaid, bad=[], k, peer, z, p, i, w, ended=null, spec=null;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player||!G.zones||!G.zones.length) return 'SKIP: staging: no raid or no ring';
       netSend=function(){ return true; }; netRefresh=function(){}; say=function(){}; blip=function(){};
       peer={state:'in',seat:1};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}]; NET.up=[]; NET.upOut=undefined; NET.specG=null; NET.holds={}; NET.srch=null;
       w={t:'st',k:'r',sd:G.seed>>>0,x:100,y:100,f:0,m:0,r:0,c:0,sp:0,dn:0,w:'',pz:0,hp:80,mh:100,ar:0,ac:0,dt:0,sa:1};
       netOnState(peer,w);
       if(!netUpShown(NET.up[1])) return 'SKIP: staging: the teammate word did not file him up top';
       try{ netUpWord(peer,{t:'up',st:'out',how:'extract'}); }catch(e){}
       if(NET.up[1]) return 'SKIP: staging: the out word did not take him off the list';
       netOnState(peer,w);   // his last position word, landing after his out word on the fast channel
       if(!netUpShown(NET.up[1])) return 'SKIP: staging: the late position word was not filed up top again';
       z=G.zones[0]; p=G.player; p.x=z.x; p.y=z.y; z.open=true; z.beaconT=0; z.hold=20; z.holdMax=30; z.pullT=null; z.pullFloor=0; G.active=z; G.beaconT=0; G.shipHold=20;
       p.downed=true; p.downT=12; p.hp=0;
       endRaid=function(how){ ended=how; spec=netSpecStart(how); };
       keys['KeyE']=true;
       for(i=0;i<60&&ended===null;i++) updatePlayer(0.05);
       if(ended!=='extract') bad.push('the downed host holding E in the landed ring did not extract (ended '+ended+')');
       else if(spec) bad.push('the host extraction was parked spectating for a teammate who had already extracted');
     } finally {
       endRaid=oER; netSend=oSend; netRefresh=oRef; say=oSay; blip=oBlip; keys['KeyE']=false;
       for(k in keep) NET[k]=keep[k];
       try{ if(G&&G.player){ G.player.specOut=0; G.player.downed=false; } }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

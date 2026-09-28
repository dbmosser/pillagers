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

if ($s.Contains("  {v:'17.03',what:")) { throw "check 17.03 is in the fixture already" }

SubRx @'
  {v:'17.02',what:
'@ @'
  {v:'17.03',what:'on a controller in a raid, letting go of both sticks ends right stick aiming, so Superhot time can stop and kid firing comes back; a take-over time left from an earlier raid does not hold kid firing off, and a fresh one still does',
   run:function(){
     if(typeof pollPad!=='function'||typeof netAutoFire!=='function'||typeof PAD==='undefined'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no right stick aim flag or no kid firing';
     var NGA=navigator.getGamepads, ax=[0,0,0,0], padK={}, pk, k0=null, keep={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,same:NET.same,af:NET.afHost,p2:P.p2Auto,lc:losClear,mx:mouse.x,my:mouse.y,md:mouse.down,mi:mouse.init}, bad=[], p=null, pw=null, ents=null, e, r;
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
     function pad(){ var b=[],q; for(q=0;q<17;q++) b.push({pressed:false,value:0,touched:false}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:ax.slice()}]; }
     try{
       NET.on=false; NET.role=null;
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player||typeof WEAPONS==='undefined'||!WEAPONS.pistol) return 'SKIP: staging: no raid';
       k0=keys; keys={};
       NET.same=false; PAD.announced=true; PAD.aiming=false; navigator.getGamepads=pad;
       ax=[0,0,0.9,0]; pollPad();
       if(!PAD.aiming) bad.push('the right stick pushed did not set the aiming flag');
       ax=[0,0,0,0]; pollPad(); pollPad();
       if(PAD.aiming) bad.push('with both sticks let go the aiming flag stayed on, so Superhot time runs on and kid firing stays off');
       navigator.getGamepads=NGA;
       p=G.player; pw={wep:p.wep,ammo:p.ammo,res:p.reserve,hot:G.hot,fired:p.fired};
       p.wep=WEAPONS.pistol; p.ammo=12; p.reserve=24; p.fired=false; G.hot=0;
       ents=G.ents; G.ents=[];
       NET.on=true; NET.role='join'; NET.peers=[{state:'in',seat:0}]; NET.upSeed=G.seed; NET.afHost=undefined; P.p2Auto=1;
       losClear=function(){ return true; };
       G.bagOpen=false; G.mapOpen=false; G.paused=false; p.downed=0; p.reloading=0; p.jam=0; p.cooking=false;
       e={kind:'sentry',x:p.x+200,y:p.y,r:14,hp:60,maxhp:60,face:0,nid:901,net:1};
       G.ents=[e]; mouse.down=false; PAD.firing=0; PAD.afire=0; PAD.adsT=0;
       PAD.aiming=false; PAD.afRsT=(G.t||0)+400; r=netAutoFire(p);
       if(r!==e||!mouse.down) bad.push('a take-over time 400 s ahead of the raid clock, left from an earlier raid, held kid firing off');
       PAD.aiming=false; PAD.afRsT=G.t; r=netAutoFire(p);
       if(r||mouse.down) bad.push('kid firing came back the moment the right stick was let go');
     } finally {
       navigator.getGamepads=NGA;
       losClear=keep.lc;
       if(p&&pw){ p.wep=pw.wep; p.ammo=pw.ammo; p.reserve=pw.res; p.fired=pw.fired; G.hot=pw.hot; }
       if(G&&ents) G.ents=ents;
       NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.upSeed=keep.upSeed; NET.same=keep.same; NET.afHost=keep.af; P.p2Auto=keep.p2;
       for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk];
       for(pk in padK) PAD[pk]=padK[pk];
       mouse.x=keep.mx; mouse.y=keep.my; mouse.down=keep.md; mouse.init=keep.mi;
       if(k0) keys=k0;
       try{ if(G&&!G.over) __endRaid('abandon'); }catch(e3){}
       try{ __topClear(); }catch(e4){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

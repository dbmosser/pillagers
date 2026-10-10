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

if ($s.Contains("  {v:'22.15',what:")) { throw "check 22.15 is in the fixture already" }

SubRx @'
  {v:'22.14',what:
'@ @'
  {v:'22.15',what:'kid firing never shoots through the open Peddler stall: with the stall open the trigger is let go and the cursor is left alone, and with it shut the same machine is still fired at',
   run:function(){
     if(typeof netAutoFire!=='function'||typeof afTarget!=='function'||typeof netAfOn!=='function'||typeof PAD==='undefined'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: no kid firing here';
     var NK={}, k, padK={}, pk, bad=[], p=null, pw=null, ents=null, oLos=losClear, p2a=P.p2Auto, m0={x:mouse.x,y:mouse.y,down:mouse.down,init:mouse.init}, e, r;
     for(k in NET) NK[k]=NET[k];
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player||typeof WEAPONS==='undefined'||!WEAPONS.pistol) return 'SKIP: staging: no raid';
       p=G.player; pw={wep:p.wep,ammo:p.ammo,res:p.reserve,hot:G.hot,fired:p.fired};
       p.wep=WEAPONS.pistol; p.ammo=12; p.reserve=24; p.fired=false; G.hot=0;
       ents=G.ents;
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[{state:'in',seat:0}]; NET.upSeed=G.seed>>>0; NET.afHost=undefined; P.p2Auto=1;
       if(!netAfOn()) return 'SKIP: staging: kid firing is not on in this window';
       losClear=function(){ return true; };
       G.bagOpen=false; G.mapOpen=false; G.paused=false; G.trade=null; p.downed=false; p.reloading=0; p.jam=0; p.cooking=false;
       e={kind:'sentry',x:p.x+180,y:p.y,r:14,hp:60,maxhp:60,face:0,nid:9026,net:1};
       G.ents=[e]; mouse.down=false; PAD.firing=0; PAD.afire=0; PAD.adsT=0; PAD.aiming=false; PAD.afRsT=null;
       // CONTROL: the stall shut, a machine in range and in sight is fired at
       r=netAutoFire(p);
       if(r!==e||!mouse.down) return 'SKIP: staging: kid firing did not fire at a machine in range with the stall shut';
       // The stall opens: G.trade is the Peddler and the open lets go of the mouse, as X at the Peddler does
       G.trade={kind:'peddler',x:p.x-30,y:p.y,hp:100,maxhp:100,nid:9027}; mouse.down=false;
       mouse.x=11; mouse.y=13;
       r=netAutoFire(p);
       if(r) bad.push('with the Peddler stall open kid firing still picked a target');
       if(mouse.down) bad.push('with the Peddler stall open kid firing held the trigger, so the gun fires through the panel');
       if(PAD.afire) bad.push('with the Peddler stall open kid firing still marked the trigger as its own');
       if(mouse.x!==11||mouse.y!==13) bad.push('with the Peddler stall open kid firing moved the cursor and turned player 2');
       // and the stall shut again: the same machine is fired at
       G.trade=null;
       r=netAutoFire(p);
       if(r!==e||!mouse.down) bad.push('with the stall shut again kid firing did not fire at the machine');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       losClear=oLos;
       if(p&&pw){ p.wep=pw.wep; p.ammo=pw.ammo; p.reserve=pw.res; p.fired=pw.fired; G.hot=pw.hot; }
       try{ if(G){ G.trade=null; if(ents) G.ents=ents; } }catch(_g){}
       P.p2Auto=p2a;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; }catch(_pk){}
       mouse.x=m0.x; mouse.y=m0.y; mouse.down=m0.down; mouse.init=m0.init;
       try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

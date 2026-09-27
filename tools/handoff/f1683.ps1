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

if ($s.Contains("  {v:'16.83',what:")) { throw "check 16.83 is in the fixture already" }

SubRx @'
  {v:'16.82',what:
'@ @'
  {v:'16.83',what:'kid firing for player 2: a Settings row beside Kid mode that player 2 can set himself, never firing while he aims with the right stick, OFF out of the box, carried by the host word; on a linked window it puts the cursor on the nearest enemy in gun range with a clear line and holds the trigger, lets go with none in sight, past range, dead, behind a wall, under the open backpack, at the Peddler or on the host window, and never with the row off',
   run:function(){
     if(typeof netAutoFire!=='function'||typeof afRowHtml!=='function'||typeof afCycle!=='function'||typeof netWorldTake!=='function'||typeof mouseWorld!=='function'||!window.__deploy||!window.__endRaid) return 'this build has no auto-fire for player 2';
     var keep={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,af:NET.afHost,p2:P.p2Auto,fire:PAD.firing,afire:PAD.afire,ads:PAD.adsT,lc:losClear,mx:mouse.x,my:mouse.y,md:mouse.down,mi:mouse.init}, bad=[], p=null, e, w, r, ents=null, pw=null, ss, src='', i, cut, needle;
     try{
       NET.on=false; NET.role=null;
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player||typeof WEAPONS==='undefined'||!WEAPONS.pistol) return 'SKIP: staging: no raid';
       p=G.player; pw={wep:p.wep,ammo:p.ammo,res:p.reserve,hot:G.hot,fired:p.fired};
       p.wep=WEAPONS.pistol; p.ammo=12; p.reserve=24; p.fired=false; G.hot=0;
       ents=G.ents; G.ents=[];
       NET.on=true; NET.role='join'; NET.peers=[{state:'in',seat:0}]; NET.upSeed=G.seed; NET.afHost=undefined;
       losClear=function(){ return true; };
       G.bagOpen=false; G.mapOpen=false; G.paused=false; p.downed=0; p.reloading=0; p.jam=0; p.cooking=false;
       e={kind:'sentry',x:p.x+200,y:p.y,r:14,hp:60,maxhp:60,face:0,nid:901,net:1};
       G.ents=[e]; mouse.down=false; PAD.firing=0; PAD.afire=0; PAD.adsT=0;
       P.p2Auto=0; r=netAutoFire(p);
       if(r||mouse.down) bad.push('with the row OFF the trigger went down');
       P.p2Auto=1; r=netAutoFire(p);
       if(r!==e||!mouse.down) bad.push('with the row ON and an enemy in range and in sight the trigger stayed up');
       w=mouseWorld();
       if(!w||Math.abs(w.x-e.x)>4||Math.abs(w.y-e.y)>4) bad.push('the cursor did not land on the enemy ('+Math.round(w.x)+','+Math.round(w.y)+' for '+Math.round(e.x)+','+Math.round(e.y)+')');
       if(!(PAD.adsT>0)) bad.push('focus aim did not follow the trigger');
       losClear=function(){ return false; }; r=netAutoFire(p);
       if(r||mouse.down) bad.push('a wall between did not lift the trigger');
       losClear=function(){ return true; };
       e.x=p.x+p.wep.rng+80; r=netAutoFire(p);
       if(r||mouse.down) bad.push('an enemy past gun range held the trigger');
       e.x=p.x+200; e.hp=0; r=netAutoFire(p);
       if(r||mouse.down) bad.push('a dead body held the trigger');
       e.hp=60; G.bagOpen=true; r=netAutoFire(p);
       if(r||mouse.down) bad.push('the trigger went down under the open backpack');
       G.bagOpen=false; G.ents=[{kind:'peddler',x:p.x+200,y:p.y,r:12,hp:150,maxhp:150,face:0,nid:902,net:1}]; r=netAutoFire(p);
       if(r||mouse.down) bad.push('the Peddler was shot at');
       G.ents=[e]; NET.role='host'; r=netAutoFire(p);
       if(r||mouse.down) bad.push('the host window fired by itself');
       NET.role='join'; P.p2Auto=0; NET.afHost=undefined;
       r=netWorldTake(NET.peers[0],{t:'wd',sd:G.seed>>>0,wx:(G.wx&&G.wx.id)||'',wn:(G.wxNext&&G.wxNext.id)||'',wt:G.wxT||0,af:1});
       if(r!=='wd'||NET.afHost!==1) bad.push('the host word did not carry the row ('+r+', '+NET.afHost+')');
       r=netAutoFire(p);
       if(r!==e||!mouse.down) bad.push('the row set on the host window did not fire on player 2');
       NET.afHost=undefined; P.p2Auto=1; PAD.afRsT=null; PAD.aiming=true; r=netAutoFire(p);
       if(r||mouse.down) bad.push('player 2 aiming with the right stick did not take over from kid firing');
       PAD.aiming=false; r=netAutoFire(p);
       if(r||mouse.down) bad.push('kid firing came back the moment the right stick was let go');
       PAD.afRsT=null; r=netAutoFire(p);
       if(r!==e||!mouse.down) bad.push('kid firing did not come back after the right stick rested');
       if(afRowHtml().indexOf('Kid firing')<0||afRowHtml().indexOf('set_af')<0) bad.push('no Kid firing row in Settings');
       try{ ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e2){ src=''; }
       cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
       needle='netAutoFire(p);   // v16.'+'83, his order';
       if(src&&src.indexOf(needle)<0) bad.push('the player update does not call the auto-fire step');
     } finally {
       losClear=keep.lc;
       if(p&&pw){ p.wep=pw.wep; p.ammo=pw.ammo; p.reserve=pw.res; p.fired=pw.fired; G.hot=pw.hot; }
       if(G&&ents) G.ents=ents;
       NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.upSeed=keep.upSeed; NET.afHost=keep.af; P.p2Auto=keep.p2;
       PAD.aiming=false; PAD.afRsT=null; PAD.firing=keep.fire; PAD.afire=keep.afire; PAD.adsT=keep.ads; mouse.x=keep.mx; mouse.y=keep.my; mouse.down=keep.md; mouse.init=keep.mi;
       try{ if(G&&!G.over) __endRaid('abandon'); }catch(e3){}
       try{ __topClear(); }catch(e4){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

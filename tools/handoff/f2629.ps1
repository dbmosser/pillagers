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

if ($s.Contains("  {v:'26.29',what:")) { throw "check 26.29 is in the fixture already" }

SubRx @'
  {v:'26.28',what:
'@ @'
  {v:'26.29',what:'wheel6, his bar for looks: the open wheel draws every name, count, the line of what the picked item does (HEALS TO 85, COOK AND THROW) and the key to let go of; a gun being drawn fills a ring on the reticle that is gone when it is ready; the magazine ring waits for it; with an item out the body shows bare hands',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid or frame here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be drawn';
     if(typeof drawWheel!=='function'||typeof updatePlayer!=='function') return 'SKIP: no wheel here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, oArc=proto.arc, txt=[], arcs=0, modes=[], oOp=drawOp, w0, i, an, m;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function frame(){
       txt=[]; arcs=0; modes=[];
       proto.fillText=function(s){ txt.push(String(s)); return oFT.apply(this,arguments); };
       proto.arc=function(){ var ss=String(this.strokeStyle).replace(/\s/g,''); if(ss.indexOf('230,240,246,0.22)')>=0) arcs++; return oArc.apply(this,arguments); };
       drawOp=function(x,y,face,ph,coat,pk,muzzle,mode,iv,st){ if(st&&st.hero) modes.push(mode); return oOp.apply(this,arguments); };
       try{ __frame(0); __frame(0); } finally { proto.fillText=oFT; proto.arc=oArc; drawOp=oOp; }
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={}; mouse.down=false; mouse.x=700; mouse.y=400;
       w0=cl('rifle'); p.wep=w0; p.ammo=w0.mag; p.reserve=60; p.swapped=false; g.hot=0;
       g.bag=['bandage','medkit']; g.pouch.frag=2; g.pouch.smoke=1; g.pouch.decoy=0; g.pouch.trip=0;
       for(i=0;i<40;i++) updatePlayer(0.02);
       // ONE: the wheel
       keys['KeyQ']=true; raidKey('KeyQ',false,null);
       if(!g.wheel) return 'ONE: the wheel did not open';
       m=g.wheel.list.length; an=-Math.PI/2+2*(Math.PI*2/m); mouse.x=g.wheel.mx+Math.cos(an)*220; mouse.y=g.wheel.my+Math.sin(an)*220; updatePlayer(0.2);
       frame();
       ['FRAG CHARGE','SMOKE CANISTER','BANDAGE','MEDKIT','RELEASE TO TAKE OUT','x2','x1'].forEach(function(s){ if(txt.indexOf(s)<0) bad.push('ONE: the open wheel drew no '+s); });
       if(txt.indexOf('HEALS TO 85')<0) bad.push('ONE: the picked bandage showed no HEALS TO 85 ('+txt.filter(function(s){ return /HEAL|COOK|THROW/.test(s); }).join('|')+')');
       if(wheelBlurb('frag')!=='COOK AND THROW'||wheelBlurb('medkit')!=='HEALS TO 100'||wheelBlurb('plate')!=='ARMOUR +20') bad.push('ONE: the blurbs read '+wheelBlurb('frag')+' / '+wheelBlurb('medkit')+' / '+wheelBlurb('plate'));
       keys['KeyQ']=false; wheelRelease(); p.hand=null;
       for(i=0;i<40;i++) updatePlayer(0.02);
       // TWO: the draw ring (an arc more) while the gun is drawn, none when ready
       frame(); var a0=arcs;
       p.drawLen=0.55; p.drawT=0.3; frame(); var a1=arcs;
       if(!(a1>a0)) bad.push('TWO: a gun being drawn drew no ring on the reticle (arcs '+a0+' ready, '+a1+' drawing)');
       p.drawT=0; p.drawLen=0;
       // THREE: with an item out the body shows bare hands, with the gun it does not
       frame(); var mGun=modes.slice();
       p.hand={k:'bandage',t:0,len:0.3,armed:0,used:0,prev:false};
       frame(); var mHand=modes.slice();
       p.hand=null;
       if(!mHand.length||mHand.some(function(q){ return q!=='none'; })) bad.push('THREE: with the bandage out the body mode was '+JSON.stringify(mHand)+', not none');
       if(mGun.length&&mGun.every(function(q){ return q==='none'; })) bad.push('THREE: with the rifle up the body showed bare hands');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oFT; proto.arc=oArc; drawOp=oOp; }catch(_f){}
       try{ mouse.down=false; keys={}; var g2=__state(); if(g2){ g2.wheel=null; if(!g2.over){ g2.player.iv=0; g2.player.hand=null; g2.player.drawT=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

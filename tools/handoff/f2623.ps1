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

if ($s.Contains("  {v:'26.23',what:")) { throw "check 26.23 is in the fixture already" }

SubRx @'
  {v:'26.22',what:
'@ @'
  {v:'26.23',what:'wheel2, his order: HOLD Q opens an item wheel with one segment for each type carried (frag, smoke, bandage, medkit...), the mouse direction from where it was picks a segment, letting go of Q picks it (the middle cancels), the trigger is dead while it is open, and melee moved to V',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     if(typeof raidKey!=='function'||typeof updatePlayer!=='function'||!ITEMS.frag||!ITEMS.smoke||!ITEMS.bandage||!ITEMS.medkit) return 'SKIP: no keys or items here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, w=null, w0=null, j, m, seg, ang, a0, t0, names=[], proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, txt=[], tsel0;
     function cl(q){ var o={}, k; for(k in WEAPONS[q]) o[k]=WEAPONS[q][k]; o.q='field'; o.qRank=1; return o; }
     function stock(){ g.bag=['bandage','medkit']; g.pouch.frag=2; g.pouch.smoke=1; g.pouch.decoy=0; g.pouch.trip=0; }
     function aim(jx,len){ var an=-Math.PI/2+jx*(Math.PI*2/m); mouse.x=w.mx+Math.cos(an)*len; mouse.y=w.my+Math.sin(an)*len; updatePlayer(0.016); }
     function open(){ keys['KeyQ']=true; raidKey('KeyQ',false,null); w=g.wheel; return w; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={}; mouse.down=false; mouse.x=700; mouse.y=400;
       stock(); w0=cl('pistol'); p.wep=w0; p.ammo=w0.mag; p.reserve=60; p.swapped=false; g.hot=0;
       for(j=0;j<30;j++) updatePlayer(0.02);
       p.reloading=0; p.jam=0; p.fired=false; p.lastShot=-1e9; p.trigYield=false; p.cooking=false; var am1=p.ammo; mouse.down=true;
       for(j=0;j<6;j++) updatePlayer(0.05);
       mouse.down=false; updatePlayer(0.016);
       if(!(p.ammo<am1)) return 'SKIP: staging: the pistol does not fire here';
       p.ammo=w0.mag;
       // ONE: Q opens the wheel with the carried types in order, and does not swing the crowbar
       a0=g.barT||0;
       if(!open()) { bad.push('ONE: Q opened nothing'); return bad.join('; '); }
       if(w.list.map(function(q){ return q.k; }).join(',')!=='frag,smoke,bandage,medkit') bad.push('ONE: the wheel lists '+w.list.map(function(q){ return q.k+q.n; }).join(',')+', not frag,smoke,bandage,medkit');
       if((g.barT||0)>a0) bad.push('ONE: Q swung the crowbar');
       m=w.list.length;
       // TWO: the trigger is dead while it is open
       p.reloading=0; p.jam=0; p.fired=false; p.lastShot=-1e9; p.trigYield=false; p.cooking=false; var am0=p.ammo; mouse.down=true;
       for(j=0;j<8;j++) updatePlayer(0.05);
       mouse.down=false; updatePlayer(0.016);
       if(p.ammo<am0) bad.push('TWO: the gun fired with the wheel open');
       // THREE: each direction picks its own segment, and a small move picks none
       for(j=0;j<m;j++){ aim(j,220); if(g.wheel.sel!==j) bad.push('THREE: segment '+j+' read as '+g.wheel.sel); }
       aim(1,6); if(g.wheel.sel!==-1) bad.push('THREE: a move of six pixels picked segment '+g.wheel.sel);
       // FOUR: letting go on the smoke picks the smoke for G; the wheel closes
       tsel0=g.tsel;
       aim(1,220); keys['KeyQ']=false; wheelRelease();
       if(g.wheel) bad.push('FOUR: the wheel stayed open after Q was let go');
       if(THROWKEYS[g.tsel]!=='smoke'&&!(p.hand&&p.hand.k==='smoke')) bad.push('FOUR: letting go on the smoke left the pick on '+THROWKEYS[g.tsel]);   /* wheel3: and from then on the pick takes the item out */
       p.hand=null;
       // FIVE: the medkit sets the heal H uses
       open(); aim(3,220); keys['KeyQ']=false; wheelRelease();
       if(g.msel!=='medkit'&&!(p.hand&&p.hand.k==='medkit')) bad.push('FIVE: letting go on the medkit left the heal pick on '+g.msel);
       p.hand=null;
       // SIX: letting go in the middle cancels and changes nothing
       g.tsel=THROWKEYS.indexOf('frag'); g.msel='bandage';
       open(); aim(2,4); keys['KeyQ']=false; wheelRelease();
       if(THROWKEYS[g.tsel]!=='frag'||g.msel!=='bandage'||p.hand) bad.push('SIX: a release in the middle changed the picks ('+THROWKEYS[g.tsel]+', '+g.msel+')');
       // SEVEN: the key being up closes it by itself on the next step
       open(); keys['KeyQ']=false; updatePlayer(0.016);
       if(g.wheel) bad.push('SEVEN: the wheel stayed open with Q up');
       // EIGHT: V swings the crowbar
       a0=g.barT||0; g.barT=0; p.meleeAt=-9; raidKey('KeyV',false,null);
       if(!(g.barT>0)) bad.push('EIGHT: V did not swing the crowbar');
       // NINE: it draws the names and counts
       open(); aim(0,220);
       txt=[]; proto.fillText=function(s,x,y){ txt.push(String(s)); return oFT.apply(this,arguments); };
       try{ if(window.__frame){ __frame(0); __frame(0); } } finally { proto.fillText=oFT; }
       if(window.__frame){
         names=['FRAG CHARGE','SMOKE CANISTER','BANDAGE','MEDKIT','x2','x1'];
         for(j=0;j<names.length;j++) if(txt.indexOf(names[j])<0) bad.push('NINE: the open wheel drew no '+names[j]);
       }
       keys['KeyQ']=false; wheelRelease();
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oFT; }catch(_f){}
       try{ mouse.down=false; keys={}; var g2=__state(); if(g2){ g2.wheel=null; if(!g2.over){ g2.player.iv=0; g2.msel=undefined; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

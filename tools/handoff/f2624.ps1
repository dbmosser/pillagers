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

if ($s.Contains("  {v:'26.24',what:")) { throw "check 26.24 is in the fixture already" }

SubRx @'
  {v:'26.23',what:
'@ @'
  {v:'26.24',what:'wheel3, his order: a wheel pick takes the item out (the gun is put away), a fresh pull of the trigger uses ONE (a grenade is cooked and thrown on release, a bandage starts its wind-up), then the gun comes back by itself with its draw time and cannot fire until the trigger is let go and pulled again; a gun key or the wheel again puts the item away',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     if(typeof wheelOpen!=='function'||typeof updatePlayer!=='function') return 'SKIP: no wheel here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, w=null, w0=null, j, m, a1, f, fr0, thr0;
     function cl(q){ var o={}, k; for(k in WEAPONS[q]) o[k]=WEAPONS[q][k]; o.q='field'; o.qRank=1; return o; }
     function cnt(k2){ var c=0, i; for(i=0;i<g.bag.length;i++) if(g.bag[i]===k2) c++; return c; }
     function stock(){ g.bag=['bandage','bandage','medkit']; g.pouch.frag=2; g.pouch.smoke=1; g.pouch.decoy=0; g.pouch.trip=0; p.hp=50; p.healQ=0; p.healRate=0; p.healCap=undefined; p.prep=null; p.prepA=null; p.cooking=0; p.hand=null; p.reloading=0; p.jam=0; p.ammo=p.wep.mag; g.msel=undefined; }
     function run(sec,down){ var n=Math.round(sec/0.02), i; mouse.down=!!down; for(i=0;i<n;i++) updatePlayer(0.02); }
     function pick(k){
       keys['KeyQ']=true; raidKey('KeyQ',false,null); w=g.wheel; if(!w) return false;
       m=w.list.length; for(j=0;j<m;j++) if(w.list[j].k===k) break;
       if(j>=m) return false;
       var an=-Math.PI/2+j*(Math.PI*2/m); mouse.x=w.mx+Math.cos(an)*220; mouse.y=w.my+Math.sin(an)*220; updatePlayer(0.016);
       keys['KeyQ']=false; wheelRelease(); return true;
     }
     function shoots(sec){ var a0=p.ammo; p.lastShot=-1e9; p.fired=false; run(sec,true); return p.ammo<a0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={}; mouse.down=false; mouse.x=700; mouse.y=400;
       w0=cl('pistol'); p.wep=w0; p.ammo=w0.mag; p.reserve=60; p.swapped=false; g.hot=0;
       run(0.6,false); stock();
       // ONE: a pick takes the frag out, the gun is put away, the pull-out takes time
       if(!pick('frag')) return 'ONE: the wheel would not pick the frag';
       if(!p.hand||p.hand.k!=='frag') bad.push('ONE: the pick left no frag in hand');
       if(shoots(0.2)) bad.push('ONE: the gun fired with a frag out');
       run(0.05,false); if(p.cooking) bad.push('ONE: the frag cooked with no pull of the trigger');
       // TWO: a pull before the pull-out is over does nothing; held over the end of it, it is not a fresh pull... but a fresh one after it cooks
       stock(); pick('frag'); fr0=g.pouch.frag;
       mouse.down=true; updatePlayer(0.02);   // pulled at once, inside the pull-out
       if(p.cooking||g.pouch.frag!==fr0) bad.push('TWO: the frag cooked inside its pull-out');
       run(0.6,true);
       if(!p.cooking||g.pouch.frag!==fr0-1) bad.push('TWO: a trigger pulled inside the pull-out and held did not cook the frag when it was ready (cooking '+p.cooking+', frag '+g.pouch.frag+')');
       // THREE: letting go throws it, takes ONE, the gun comes back with its draw time, the next pull is a fresh one
       run(0.1,true); mouse.down=false; run(0.04,false);
       if(g.pouch.frag!==fr0-1) bad.push('THREE: the throw left '+g.pouch.frag+' frags, not '+(fr0-1));
       if(p.cooking) bad.push('THREE: still cooking after the release');
       if(p.hand) bad.push('THREE: the frag is still in hand after the throw');
       if(!(p.drawT>0)) bad.push('THREE: the gun came back with no draw time ('+p.drawT+')');
       if(shoots(0.1)) bad.push('THREE: the pistol fired before its 0.25 s draw was over');
       run(0.4,false);
       if(!shoots(0.2)) bad.push('THREE: the pistol did not fire after the draw');
       // FOUR: a heal: the pull starts it, ONE bandage goes, the gun returns, and a HELD trigger does not fire it
       stock(); run(0.4,false); pick('bandage');
       if(!p.hand||p.hand.k!=='bandage') bad.push('FOUR: the pick left no bandage in hand');
       run(0.4,false); a1=p.ammo;
       mouse.down=true; updatePlayer(0.02);
       if(cnt('bandage')!==1||!p.prep) bad.push('FOUR: the pull left '+cnt('bandage')+' bandages and a wind-up of '+(p.prep?'yes':'no')+', not 1 and yes');
       if(p.hand) bad.push('FOUR: the bandage is still in hand after the use');
       run(1.0,true);
       if(p.ammo<a1) bad.push('FOUR: the gun fired on the same held trigger that used the bandage');
       mouse.down=false; run(0.1,false);
       if(!shoots(0.2)) bad.push('FOUR: the gun did not fire after the trigger was let go and pulled again');
       // FIVE: another heal needs another trip to the wheel
       stock(); run(0.4,false); pick('bandage'); run(0.4,false); mouse.down=true; updatePlayer(0.02); mouse.down=false; run(0.05,false);
       p.prep=null; mouse.down=true; updatePlayer(0.02); mouse.down=false; updatePlayer(0.02);
       if(cnt('bandage')!==1) bad.push('FIVE: a second pull used another bandage ('+cnt('bandage')+' left, not 1)');
       // SIX: a gun key puts the item away with no use
       stock(); run(0.4,false); pick('medkit'); if(!p.hand) bad.push('SIX: no medkit in hand');
       raidKey('Digit1',false,null); keys={};
       if(p.hand) bad.push('SIX: a gun key left the medkit in hand');
       if(cnt('medkit')!==1) bad.push('SIX: putting the medkit away used it');
       // SEVEN: the wheel again puts it away
       run(0.4,false); pick('bandage'); keys['KeyQ']=true; raidKey('KeyQ',false,null);
       if(p.hand) bad.push('SEVEN: opening the wheel again left the bandage in hand');
       keys['KeyQ']=false; wheelRelease();
       // EIGHT: a refused use (full health) puts it away and brings the gun back
       stock(); p.hp=100; run(0.4,false); pick('bandage'); run(0.4,false); mouse.down=true; updatePlayer(0.02); mouse.down=false; updatePlayer(0.02);
       if(p.hand) bad.push('EIGHT: a bandage at full health stayed in hand');
       if(cnt('bandage')!==2) bad.push('EIGHT: a refused bandage was used ('+cnt('bandage')+' left, not 2)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ mouse.down=false; keys={}; var g2=__state(); if(g2){ g2.wheel=null; if(!g2.over){ g2.player.iv=0; g2.player.hand=null; g2.player.prep=null; g2.msel=undefined; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

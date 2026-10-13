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

if ($s.Contains("  {v:'25.92',what:")) { throw "check 25.92 is in the fixture already" }

SubRx @'
  {v:'25.91',what:
'@ @'
  {v:'25.92',what:'his order (grenades their own class, 2 slots): a third kind of grenade has no throwable key, so it is carried in the backpack as items: with frag and smoke on the two keys, a found Decoy lands in the backpack (row tag BACKPACK, three items in the grid), the frag and smoke counts stay on their keys, a throw takes from the pouch and then the backpack, a Decoy tile dragged onto key 5 takes the key and the Frag moves to the backpack, and the Undercroft belt keeps its counts',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof grantLoot!=='function'||typeof doThrow!=='function'||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: no belt or throw here';
     if(!ITEMS.frag||!ITEMS.smoke||!ITEMS.decoy||typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: no grenades here, or a raid or a sim is live';
     var bad=[], mx0=mouse.x, my0=mouse.y, s0=say, said=[], g=null, p=null, sl, i, n, K5={x:500,y:700,w:40,h:40,i:4};
     function cnt(k){ var c=0, j; for(j=0;j<g.bag.length;j++) if(g.bag[j]===k) c++; return c; }
     function tick(){ if(typeof beltThrowTick==='function') beltThrowTick(); }
     function row(item){ for(var j=0;j<said.length;j++) if(said[j].o&&said[j].o.item===item) return said[j]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; p.downed=false; p.roll=0; p.cooking=0; keys={};
       say=function(m,k,o){ said.push({m:String(m),k:k,o:o||{}}); };
       g.bag=[]; g.pouch.frag=2; g.pouch.smoke=1; g.pouch.decoy=0; g.pouch.trip=0; g.hotAssign={}; g.hotAuto={}; g.hotPruned={};
       if(typeof classKeysSettle==='function') classKeysSettle({deploy:1});
       // ONE: a found Decoy, with frag and smoke on the two keys, is carried in the backpack
       said.length=0;
       grantLoot({x:p.x,y:p.y,loot:[]},['decoy','decoy','decoy']); tick();
       if(cnt('decoy')!==3||(g.pouch.decoy|0)!==0) bad.push('ONE: three found Decoys are '+cnt('decoy')+' in the backpack and '+g.pouch.decoy+' in the pouch, not 3 and 0');
       if((g.pouch.frag|0)!==2||(g.pouch.smoke|0)!==1) bad.push('ONE: the frag and smoke counts moved (pouch frag '+g.pouch.frag+', smoke '+g.pouch.smoke+')');
       if(!row('decoy')||String(row('decoy').o.tag||'')!=='BACKPACK') bad.push('ONE: the Decoy row says '+JSON.stringify(row('decoy')&&row('decoy').o.tag)+', not BACKPACK');
       sl=hotbarSlots();
       if(!(sl[4]&&sl[4].k==='throw:frag'&&sl[4].count===2&&sl[5]&&sl[5].k==='throw:smoke'&&sl[5].count===1)) bad.push('ONE: keys 5 and 6 are '+(sl[4]&&sl[4].k)+' x'+(sl[4]&&sl[4].count)+' and '+(sl[5]&&sl[5].k)+' x'+(sl[5]&&sl[5].count));
       // TWO: a Decoy tile dragged onto key 5 takes the key; the Frag it pushed out is carried in the backpack
       g.hotCells=[K5]; g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false; said.length=0;
       g.drag={key:'decoy',bagIx:g.bag.indexOf('decoy'),px:0,py:0};
       mouse.x=K5.x+20; mouse.y=K5.y+20; window.dispatchEvent(new MouseEvent('mouseup',{button:0})); g.drag=null; tick();
       if(g.hotAssign[4]!=='decoy') bad.push('TWO: the Decoy did not take key 5 (keys '+JSON.stringify(g.hotAssign)+')');
       if(cnt('frag')!==2||(g.pouch.frag|0)!==0) bad.push('TWO: the Frag he pushed out is '+cnt('frag')+' in the backpack and '+g.pouch.frag+' in the pouch, not 2 and 0');
       sl=hotbarSlots();
       if(!(sl[4]&&sl[4].k==='throw:decoy'&&sl[4].count===3)) bad.push('TWO: key 5 shows '+(sl[4]&&sl[4].k)+' x'+(sl[4]&&sl[4].count)+', not the Decoy x3');
       // THREE: a throw takes from the pouch and then the backpack
       g.bagOpen=false; g.hotCells=[]; p.cooking=0; g.tsel=THROWKEYS.indexOf('decoy'); n=cnt('decoy');
       doThrow();
       if(cnt('decoy')!==n-1) bad.push('THREE: a Decoy thrown left '+cnt('decoy')+' in the backpack, not '+(n-1));
       // FOUR: with nothing but the pouch (the Undercroft belt, the sim) the count is the pouch alone
       if(typeof throwHave==='function'){
         g.sim=1; g.pouch.smoke=5; i=throwHave('decoy'); g.sim=0;
         if(i!==(g.pouch.decoy|0)) bad.push('FOUR: in the sim a count of Decoys read '+i+', not the pouch '+g.pouch.decoy);
       } else bad.push('FOUR: no throwHave');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0; mouse.x=mx0; mouse.y=my0; mouse.down=false;
       try{ var g2=__state(); if(g2){ g2.sim=0; g2.drag=null; g2.bagOpen=false; g2.hotCells=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; g2.player.cooking=0; } if(g2.throws) g2.throws.length=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

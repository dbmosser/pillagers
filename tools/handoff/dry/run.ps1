$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\handoff\dry\mk.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v12.28 CHECK, inserted before the v12.27 entry. A stall with a fixed stock
# is opened in a raid (the Peddler ent the game makes, its stock replaced so
# the check does not depend on the roll) and three purchases go through the
# real pedBuy: a rifle, which autoBelt pins to a belt key, so the line must
# name that key; a medkit with no key set, which must say In your backpack;
# and a medkit with key 6 set to medkit, which must say key 6. Credits must
# fall by the three prices (the purchase itself, unchanged).
SubRx @'
  {v:'12.27',what:'a stash drop onto the backpack for an item bound to a key with nothing packed lands on that key with a count and words, a bound key with nothing packed shows a 0 on the plan, and a spent belt key in a raid says No Bandage left (his note of 2026-09-07: bandages did not come over)',
'@ @'
  {v:'12.28',what:'a Peddler purchase says where it went: a bought rifle names the belt key autoBelt pinned it to, a medkit with no key set says In your backpack, and a medkit on key 6 says key 6, with the credits falling by the prices (his note of 2026-09-07: purchases did not show up in the inventory)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkPeddler!=='function'||typeof pedBuy!=='function') return 'SKIP: no Peddler in this build';
     var bad=[], P2=__P(), keepC=P2.credits;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       var pd=mkPeddler(p.x+40,p.y,g.map);
       pd.stock=[{k:'gun_rifle',price:10,sold:false},{k:'medkit',price:20,sold:false},{k:'medkit',price:30,sold:false}];
       g.trade=pd; g.hotAssign={}; g.hotAuto={}; g.bag=[];
       P2.credits=5000;
       // THE RIFLE: autoBelt pins it to the first free belt cell, so the line must name that key.
       g.msg=''; pedBuy(0);
       var m1=g.msg||'';
       if(m1.indexOf('Bought')<0) bad.push('control: the rifle purchase did not say Bought (said "'+m1+'")');
       var onBelt=false; for(var bi in (g.hotAssign||{})) if(g.hotAssign[bi]==='gun_rifle') onBelt=true;
       if(!onBelt) bad.push('staging: autoBelt did not pin the bought rifle to a belt cell, so the line has no key to name');
       else if(!/tactical belt, key [1-9]/.test(m1)) bad.push('the rifle line said "'+m1+'" and not which belt key it went to');
       if(g.bag.indexOf('gun_rifle')<0) bad.push('control: the bought rifle is not in the bag');
       // THE MEDKIT WITH NO KEY SET: the backpack.
       g.msg=''; pedBuy(1);
       var m2=g.msg||'';
       if(!/In your backpack/.test(m2)) bad.push('a medkit bought with no key set said "'+m2+'" and not In your backpack');
       // THE MEDKIT ON KEY 6.
       g.hotAssign[5]='medkit'; g.msg=''; pedBuy(2);
       var m3=g.msg||'';
       if(!/tactical belt, key 6/.test(m3)) bad.push('a medkit bought with key 6 set to medkit said "'+m3+'" and not key 6');
       // THE PURCHASE ITSELF, unchanged: the credits fell by the three prices.
       if(P2.credits!==5000-60) bad.push('control: credits are '+P2.credits+' after three purchases priced 10, 20 and 30 from 5000');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       P2.credits=keepC; try{ saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.trade=null; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.27',what:'a stash drop onto the backpack for an item bound to a key with nothing packed lands on that key with a count and words, a bound key with nothing packed shows a 0 on the plan, and a spent belt key in a raid says No Bandage left (his note of 2026-09-07: bandages did not come over)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

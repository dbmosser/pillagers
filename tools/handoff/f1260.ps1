$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v12.60 CHECK, inserted before the v12.59 entry. It buys through the real
# purchase at a real stall, the same staging the shipped v12.28 check uses. The
# reserve starts at zero and the count comes off the item's own record rather
# than out of this check, so a retune of the box moves the check with it. Two
# controls: an ordinary item must still land in the backpack, and a backpack too
# full to hold a brick must not refuse a man his ammunition.
SubRx @'
  {v:'12.59',what:'the open Undercroft backpack stops the floor: standing on the lift with it open, the key that starts a raid does nothing and no station is armed underneath, while with the backpack shut the same key still sends him up (2026-09-08 audit of the unlooked-at regions)',
'@ @'
  {v:'12.60',what:'an Ammo Box bought from the Peddler puts its rounds in the reserve where they can be used, not a brick in the backpack where nothing can touch it, and the line says how many; an ordinary purchase still goes to the backpack and a full backpack no longer refuses ammunition (2026-09-08 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkPeddler!=='function'||typeof pedBuy!=='function') return 'SKIP: no Peddler in this build';
     if(!(ITEMS&&ITEMS.ammobox&&ITEMS.ammobox.use==='ammo'&&ITEMS.ammobox.amt>0)) return 'SKIP: this build has no Ammo Box to buy';
     var bad=[], P2=__P(), keepC=P2.credits;
     var WANT=ITEMS.ammobox.amt;      // the box own count, so a retune moves this check with it
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       var pd=mkPeddler(p.x+40,p.y,g.map);
       pd.stock=[{k:'ammobox',price:171,sold:false},{k:'medkit',price:20,sold:false},{k:'ammobox',price:171,sold:false}];
       g.trade=pd; g.hotAssign={}; g.hotAuto={}; g.bag=[];
       P2.credits=5000; p.reserve=0;
       // THE FINDING: he is dry, and he buys the box that says it refills a magazine.
       g.msg=''; pedBuy(0);
       if((p.reserve|0)!==WANT)
         bad.push('an Ammo Box bought at the stall put '+(p.reserve|0)+' rounds in the reserve and not the '+WANT+' it carries: he paid at the moment he had nothing to shoot with and the reserve did not move');
       if(g.bag.indexOf('ammobox')>=0)
         bad.push('the bought Ammo Box is sitting in the backpack, where the belt use verb falls straight past it without a word, so it is a brick he cannot spend');
       var m1=String(g.msg||'');
       if(m1.indexOf('backpack')>=0)
         bad.push('the purchase line says the ammunition went into the backpack: "'+m1+'"');
       if(m1.indexOf(String(WANT))<0)
         bad.push('the purchase line does not say how many rounds he got: "'+m1+'"');
       // CONTROL ONE: an ordinary item still goes to the backpack, so this build
       // has not simply stopped the stall delivering anything.
       g.msg=''; pedBuy(1);
       if(g.bag.indexOf('medkit')<0) bad.push('control: an ordinary purchase no longer arrives in the backpack at all');
       // CONTROL TWO: and a backpack with no room left must not refuse him his
       // ammunition, since rounds in the reserve take no room in a backpack.
       p.reserve=0;
       var cap=PACKCAP[P2.pack], guard=0;
       while(bagWeight()+1<=cap&&guard++<400) g.bag.push('scrap');
       g.msg=''; pedBuy(2);
       if((p.reserve|0)!==WANT)
         bad.push('with the backpack full the stall refused him ammunition: the reserve reads '+(p.reserve|0)+' and the line said "'+(g.msg||'')+'", though rounds take no room in a backpack');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gz=__state(); if(gz){ gz.trade=null; if(gz.bag) gz.bag.length=0; gz.hotAssign={};
         if(gz.player) gz.player.reserve=0; } }catch(_a){}
       try{ P2.credits=keepC; saveProfile(); }catch(_c){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.59',what:'the open Undercroft backpack stops the floor: standing on the lift with it open, the key that starts a raid does nothing and no station is armed underneath, while with the backpack shut the same key still sends him up (2026-09-08 audit of the unlooked-at regions)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

SubRx @'
  {v:'15.35',what:
'@ @'
  {v:'15.36',what:'selling found Bandages never turns issued Bandages into found ones: with the two issued Bandages and three found ones in the backpack, key 1 at the open stall keeps the pair and a frame later both still count as issued, a second press sells nothing, a Bandage used after that still spends an issued one, and extracting hands the issued one left back while a find picked up after the sale is banked (peddler audit finding 8)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy, end a raid and restore the profile';
     if(typeof pedSellAll!=='function'||typeof pedBuyRate!=='function'||typeof raidKey!=='function'||typeof updatePlayer!=='function'||typeof mkPeddler!=='function'||typeof trackIssuedBandages!=='function'||typeof ival!=='function'||!ITEMS.bandage) return 'SKIP: no stall, number keys or issued Bandage count in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined') return 'SKIP: no keys or mouse in this build';
     var bad=[], g=null, p=null, snap=null, keepEnts=null, keepHot=null, keepAuto=null, shut=[], X=null, k;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     for(k in ITEMS){ var it=ITEMS[k]; if(it&&k!=='medkit'&&k!=='bandage'&&it.use!=='key'&&it.use!=='gun'&&it.use!=='heal'&&it.use!=='throw'&&it.use!=='ammo'&&ival(k)>=40){ X=k; break; } }
     if(!X) return 'SKIP: nothing plain to sell beside the Bandages';
     function count(a,key){ var c=0; a=a||[]; for(var i=0;i<a.length;i++) if(a[i]===key) c++; return c; }
     // One player frame with every key up, E held when asked. The stall tick and the issued Bandage count both run in it.
     function frame(e){ var kk; for(kk in keys) keys[kk]=false; if(e) keys['KeyE']=true; mouse.down=false; p.iv=99; updatePlayer(1/60); for(kk in keys) keys[kk]=false; }
     // Key 1 on the open stall, as the keyboard sends it: SELL BACKPACK.
     function press(){ raidKey('Digit1',false,null); keys['Digit1']=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       p=g.player;
       // CONTROL: nothing was packed, so the raid came up with the two issued Bandages.
       if(g.issuedBandages!==2||count(g.bag,'bandage')!==2) return 'SKIP: the raid came up with '+count(g.bag,'bandage')+' Bandages, '+g.issuedBandages+' of them issued, not the issued pair';
       p.downed=false; p.dying=false; p.roll=0;
       g.bagOpen=false; g.mapOpen=false; g.drag=null; g.trade=null; g.pedLock=0; g.pedCarry=0; g.pedSold=0;
       keepHot=g.hotAssign; keepAuto=g.hotAuto; g.hotAssign={}; g.hotAuto={};
       // Only the Peddler, 40 units to his right, and no crate under his feet to take E from the stall.
       keepEnts=g.ents.slice(); g.ents.length=0;
       for(var ci=0;ci<g.containers.length;ci++){ var CU=g.containers[ci]; if(!CU.opened&&dist(CU,p)<60){ CU.opened=true; shut.push(CU); } }
       var pd=mkPeddler(p.x+40,p.y,g.map); g.ents.push(pd);
       // Open the stall the way he does: one frame with E down beside the Peddler, one with it up.
       frame(true); frame(false);
       // CONTROL: the stall is open.
       if(g.trade!==pd) return 'SKIP: E beside the Peddler did not open the stall here';
       // CONTROL: three plain finds sold at the stall leave the issued pair issued on the next frame, on either build.
       g.bag.push(X,X,X); frame(false);
       var xp=Math.round(ival(X)*pedBuyRate()), c0=g.pedCarry||0;
       press(); frame(false);
       if(count(g.bag,X)!==0||(g.pedCarry||0)-c0!==3*xp) return 'SKIP: key 1 on the open stall did not sell the three '+X+' for '+(3*xp)+' here (carried '+((g.pedCarry||0)-c0)+')';
       if(g.trade!==pd) return 'SKIP: the stall shut after a sale here';
       if(g.issuedBandages!==2||count(g.bag,'bandage')!==2) return 'SKIP: after selling three plain finds the backpack held '+count(g.bag,'bandage')+' Bandages and '+g.issuedBandages+' issued, so the issued pair was not staged';
       // THE FINDING: three Bandages he found, a frame to count them, then SELL BACKPACK and the frame after.
       g.bag.push('bandage','bandage','bandage'); frame(false);
       // CONTROL: the frame read the find as a rise, so the issued pair is still two and the count saw five.
       if(g.issuedBandages!==2||g.bandSeen!==5) return 'SKIP: the frame after finding three Bandages read '+g.bandSeen+' Bandages and '+g.issuedBandages+' issued here';
       if(typeof pedBeltClaims==='function'&&pedBeltClaims().bandage) return 'SKIP: a Bandage is on a tactical belt key here, so the sale would keep it';
       var bp=Math.round(ival('bandage')*pedBuyRate()), c1=g.pedCarry||0;
       press();
       // CONTROL: the sale kept the issued pair and bought the three found ones (v13.71), on either build.
       if(count(g.bag,'bandage')!==2||(g.pedCarry||0)-c1!==3*bp) return 'SKIP: key 1 left '+count(g.bag,'bandage')+' Bandages and carried '+((g.pedCarry||0)-c1)+' more where the three found ones are '+(3*bp)+' here';
       frame(false);
       if(g.trade!==pd) return 'SKIP: the stall shut on the frame after the Bandage sale here';
       // THE FIX, ONE: the frame after the sale still counts both Bandages left as issued.
       var iss1=g.issuedBandages;
       if(iss1!==2) bad.push('selling the three found Bandages at the stall turned '+(2-iss1)+' of the 2 issued Bandages into found ones on the next frame (issued now '+iss1+')');
       // THE FIX, TWO: a second press finds nothing to buy, because both Bandages left are the issued pair.
       var keepBag=g.bag.slice(), c2=g.pedCarry||0, s2=g.pedSold||0, b2=g.bandSeen;
       press();
       if(count(g.bag,'bandage')!==2||(g.pedCarry||0)!==c2) bad.push('a second press of key 1 sold '+(2-count(g.bag,'bandage'))+' issued Bandages for '+((g.pedCarry||0)-c2)+' more carried, the loaners the stall refuses to buy');
       // Put back what a second sale took, so the arms below read the same backpack on either build.
       g.bag=keepBag; g.pedCarry=c2; g.pedSold=s2; g.bandSeen=b2;
       // GUARD: a Bandage used after the sale still spends an issued one, so the frame still counts a real fall.
       g.bag.splice(g.bag.indexOf('bandage'),1); frame(false);
       if(iss1===2&&g.issuedBandages!==1) bad.push('a Bandage used after the sale left the issued count at '+g.issuedBandages+', not 1, so the frame no longer counts a use');
       // THE FIX, THREE: extracting hands the issued Bandage left back. A find picked up after the sale is banked, as the control.
       g.bag.push(X); g.trade=null; g.pedLock=0; p.downed=false;
       var left=count(g.bag,'bandage'), sb=count(__P().stash,'bandage'), sx=count(__P().stash,X);
       __endRaid('extract');
       if(!g.over) return skip('the raid did not end on an extraction here');
       var gx=count(__P().stash,X)-sx, gb=count(__P().stash,'bandage')-sb;
       if(gx!==1) return skip('the extraction banked '+gx+' of the '+X+' found after the sale, so the stash cannot be read here');
       if(gb!==0) bad.push('extracting after the sale banked '+gb+' of the '+left+' issued Bandage'+(left===1?'':'s')+' still carried into the stash, where issued kit is never banked');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ for(var kf in keys) keys[kf]=false; mouse.down=false; }catch(_k){}
       try{ if(g){ g.trade=null; g.pedLock=0; if(keepHot) g.hotAssign=keepHot; if(keepAuto) g.hotAuto=keepAuto; } if(p) p.iv=0; }catch(_t){}
       try{ for(var sh=0;sh<shut.length;sh++) shut[sh].opened=false; }catch(_o){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

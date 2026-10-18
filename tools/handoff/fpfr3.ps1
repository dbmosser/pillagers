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

if ($s.Contains("  {v:'31.08',what:")) { throw "check 31.08 is in the fixture already" }

SubRx @'
  {v:'31.07',what:
'@ @'
  {v:'31.08',what:'cw-nobagfull, his ruling (no bag limit, no weight, ever): with the old pack cap forced tiny and the bag weight forced huge, a stall sale still goes through, a crate search still starts, the gun swaps never drop a gun for room, and nothing says backpack full',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy or step the loop';
     if(typeof pedBuy!=='function'||typeof bagWeight!=='function'||typeof PACKCAP==='undefined') return 'SKIP: no stall or backpack here';
     if(!ITEMS.scrap) return 'SKIP: no Scrap Metal item';
     var bad=[], g=null, p, ct=null, kp=null, i, c, t0, f=0, st, n0, said=[], rs=say, keepCr=P.credits, keepAuto=P.autoloot, keepBW=bagWeight, cap0=PACKCAP.slice(), BF=['backpack','full'].join(' ');
     function fullSaid(){ var j, q=(g&&g.pick)||[]; for(j=0;j<said.length;j++) if(said[j].toLowerCase().indexOf(BF)>=0) return said[j]; for(j=0;j<q.length;j++) if(q[j]&&q[j].key==='bagfull') return 'a pickup row '+q[j].tag; return ''; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       p=g.player; g.ents.length=0; g.waveT=-1e9; g.mapOpen=false; g.bagOpen=false; p.iv=99; p.downed=false;
       if(CFG.raidSec>0&&g.timeLeft<600) g.timeLeft=600;
       say=function(m,k,o){ said.push(String(m)); };
       PACKCAP[P.pack]=0.5; bagWeight=function(){ return 1e9; };   // the old cap and weight tests read a bag that is full by the numbers
       // ONE: a stall sale
       g.bag=['scrap']; g.pick=[]; g.msgLog=[]; P.credits=1e6;
       st={k:'scrap',price:1,sold:false}; g.trade={x:p.x,y:p.y,stock:[st]}; n0=g.bag.length;
       pedBuy(0);
       if(!st.sold||g.bag.length!==n0+1) bad.push('ONE: the stall sale was refused for a full backpack (sold '+st.sold+', backpack '+g.bag.length+' of '+(n0+1)+')');
       if(fullSaid()) bad.push('ONE: the stall said ['+fullSaid()+']');
       g.trade=null; P.credits=keepCr;
       // TWO: a crate search, hold E on a crate beside him
       for(i=0;i<g.zones.length;i++) if(Math.hypot(p.x-g.zones[i].x,p.y-g.zones[i].y)<(g.zones[i].r||0)+40) bad.push('TWO: staging: a ring is on top of the spawn');
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c&&!c.opened&&!c.strong&&!c.cache&&!c.dropped&&!c.auto&&!c.mercSrc&&c.loot&&(c.type==='crate'||c.type==='locker')){ ct=c; break; } }
       if(!ct) bad.push('TWO: staging: no crate to search');
       else {
         kp={x:ct.x,y:ct.y};
         ct.x=p.x+14; ct.y=p.y; ct.loot=['scrap','scrap']; ct.opened=false; ct.prog=0; ct.pulled=0; ct.time=5; ct.hotPaid=1;
         g.bag=[]; P.autoloot=1; g.pick=[]; g.msgLog=[]; said.length=0;
         t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
         for(i=0;i<40;i++){ keys['KeyE']=true; __loop(t0+(++f)*16.7); if(__state()!==g||g.over) break; }
         keys={};
         if(!(ct.prog>0.2)) bad.push('TWO: holding E on a crate for 40 frames moved the search to '+(+ct.prog||0).toFixed(2)+' s: it was refused for a full backpack');
         if(fullSaid()) bad.push('TWO: the search said ['+fullSaid()+']');
       }
       // THREE: the gun swaps drop nothing for room any more (read from the live functions: the path needs a swap with nine gun keys full)
       if(typeof gunClassSwapIn==='function'&&/PACKCAP/.test(String(gunClassSwapIn))) bad.push('THREE: gunClassSwapIn still tests the pack cap');
       if(typeof beltGunFull==='function'&&/PACKCAP/.test(String(beltGunFull))) bad.push('THREE: beltGunFull still tests the pack cap');
       if(typeof bagDropHint!=='undefined') bad.push('THREE: bagDropHint (the detail under the backpack full row) is still there');
       return bad.length?bad.join('; '):null;
     }catch(err){ return 'threw: '+(err&&err.message||err); }
     finally{
       keys={}; say=rs;
       bagWeight=keepBW; P.autoloot=keepAuto; P.credits=keepCr;
       try{ for(i=0;i<cap0.length;i++) PACKCAP[i]=cap0[i]; }catch(_pc){}
       try{ if(ct&&kp){ ct.x=kp.x; ct.y=kp.y; } }catch(_k){}
       try{ var g2=__state(); if(g2){ g2.trade=null; g2.pedCarry=0; g2.pick=[]; if(!g2.over){ g2.player.downed=false; g2.player.iv=0; g2.searching=null; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     } }},
  {v:'31.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

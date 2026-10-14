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

if ($s.Contains("  {v:'26.27',what:")) { throw "check 26.27 is in the fixture already" }

SubRx @'
  {v:'26.26',what:
'@ @'
  {v:'26.27',what:'wheel4, his order: the bar holds nine gun slots and nothing else; G, U, J, H, hold H and the item digits do nothing, a digit is a gun key, an item dropped on the belt is refused (ITEMS GO ON THE WHEEL), an automatic pin is never an item, nine guns fill the nine keys, and an old plan loses its items once',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     if(typeof raidKey!=='function'||typeof updatePlayer!=='function'||typeof gunKeysSettle!=='function'||typeof beltDropRefusal!=='function') return 'SKIP: no belt here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, sl, i, gk=[], k, icons, nr, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, txt=[], pl, hot0;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function cnt(k2){ var c=0, j; for(j=0;j<g.bag.length;j++) if(g.bag[j]===k2) c++; return c; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={}; mouse.down=false;
       for(k in ITEMS) if(ITEMS[k].use==='gun'&&ITEMS[k].gk&&WEAPONS[ITEMS[k].gk]&&WEAPONS[ITEMS[k].gk].mag>0&&gk.length<16) gk.push(k);
       if(gk.length<10) return 'SKIP: fewer than ten guns here';
       // ONE: nine keys, all guns
       sl=hotbarSlots();
       if(GUNKEYS!==9) bad.push('ONE: GUNKEYS is '+GUNKEYS+', not 9');
       if(sl.length!==9) bad.push('ONE: the belt has '+sl.length+' keys, not 9');
       for(i=0;i<sl.length;i++) if(sl[i].kind!=='gun') bad.push('ONE: key '+(i+1)+' is a '+sl[i].kind+', not a gun');
       // TWO: no item key does anything
       g.bag=['bandage','bandage','medkit','plate','stim']; g.pouch.frag=2; g.pouch.smoke=1; g.pouch.decoy=1; g.pouch.trip=1; p.hp=50; p.healQ=0; p.prep=null; p.prepA=null; p.cooking=0;
       var ks=['KeyG','KeyU','KeyJ','KeyH','Digit5','Digit6','Digit7','Digit8','Digit9'];
       for(i=0;i<ks.length;i++){ keys[ks[i]]=true; raidKey(ks[i],false,null); updatePlayer(0.2); keys={}; updatePlayer(0.05); }
       if(g.pouch.frag!==2||g.pouch.smoke!==1||g.pouch.decoy!==1||g.pouch.trip!==1) bad.push('TWO: a key threw a grenade (frag '+g.pouch.frag+', smoke '+g.pouch.smoke+')');
       if(cnt('bandage')!==2||cnt('medkit')!==1||cnt('plate')!==1||cnt('stim')!==1) bad.push('TWO: a key used an item (bag '+g.bag.join(',')+')');
       if(p.prep||p.prepA||p.cooking||p.stimT>0) bad.push('TWO: a key started a heal, a plate or a cook');
       // THREE: nine real guns fill the nine keys at the deploy
       p.wep=cl(ITEMS[gk[0]].gk); p.ammo=p.wep.mag; p.sec=cl(ITEMS[gk[1]].gk); p.secAmmo=p.sec.mag; p.swapped=false; p.reloading=0; p.reserve=60;
       g.bag=gk.slice(2); g.hotAssign={}; g.hotAuto={}; g.hotPruned={};
       gunKeysSettle({deploy:1});
       sl=hotbarSlots(); icons=[]; nr=0;
       for(i=0;i<sl.length;i++){ icons.push(sl[i].icon||'-'); if(sl[i].kind==='gun'&&!sl[i].vacant&&sl[i].icon&&sl[i].icon!=='fists') nr++; }
       if(nr!==9) bad.push('THREE: '+nr+' of the nine keys show a real gun ('+icons.join(',')+')');
       // FOUR: a digit is a gun key: key 7 draws the gun on it
       hot0=sl[6]&&sl[6].icon; if(hot0&&ITEMS[hot0]&&ITEMS[hot0].gk) hot0=ITEMS[hot0].gk;
       if(hot0){ raidKey('Digit7',false,null); keys={}; updatePlayer(0.05);
         if(!p.wep||p.wep.id!==hot0) bad.push('FOUR: key 7 left '+(p.wep&&p.wep.id)+' in hand, not '+hot0); }
       // FIVE: an item dropped on the belt is refused in words; a gun is not
       for(i=0;i<['frag','smoke','bandage','medkit','plate','stim'].length;i++){ k=['frag','smoke','bandage','medkit','plate','stim'][i]; pl=beltDropRefusal(k,2); if(!pl||!/WHEEL/.test(pl)) bad.push('FIVE: '+k+' on key 3 was answered '+JSON.stringify(pl)); }
       if(beltDropRefusal(gk[2],8)!=='') bad.push('FIVE: a gun on key 9 was refused ('+beltDropRefusal(gk[2],8)+')');
       // SIX: picking up an item pins nothing
       g.hotAssign={}; g.hotAuto={}; autoBelt('bandage',true); autoBelt('frag',true); autoBelt('plate',true);
       for(k in g.hotAssign) if(ITEMS[g.hotAssign[k]]&&ITEMS[g.hotAssign[k]].use!=='gun') bad.push('SIX: an item was pinned to key '+(+k+1)+' ('+g.hotAssign[k]+')');
       // SEVEN: an old plan loses its items once, and keeps its gun
       pl=beltItemsOff({0:'gun_pistol',4:'frag',5:'smoke',6:'bandage',8:'plate'});
       if(JSON.stringify(pl)!=='{"0":"gun_pistol"}') bad.push('SEVEN: the old plan became '+JSON.stringify(pl));
       // NINE: with nine real guns on the nine keys, a stronger find takes the key of the weakest gun not in his hands, and that gun goes to the backpack with no key
       var rk=gk.slice().sort(function(a,b){ var wa=cl(ITEMS[a].gk), wb=cl(ITEMS[b].gk); return beltGunLow(wa,wb)?-1:(beltGunLow(wb,wa)?1:0); });
       var rs=[]; for(i=0;i<rk.length;i++) if(!rs.length||beltGunLow(cl(ITEMS[rs[rs.length-1]].gk),cl(ITEMS[rk[i]].gk))) rs.push(rk[i]);
       if(rs.length>=10){
         p.wep=cl(ITEMS[rs[8]].gk); p.ammo=p.wep.mag; p.sec=cl(ITEMS[rs[7]].gk); p.secAmmo=p.sec.mag; p.swapped=false; p.reloading=0;
         g.bag=rs.slice(0,7); g.stowQ={}; g.stowAmmo={}; g.hotAssign={}; g.hotAuto={}; g.hotPruned={};
         gunKeysSettle({deploy:1});
         sl=hotbarSlots(); nr=0; for(i=0;i<sl.length;i++) if(sl[i].kind==='gun'&&!sl[i].vacant&&sl[i].icon&&sl[i].icon!=='fists') nr++;
         if(nr!==9) bad.push('NINE: staging shows '+nr+' real guns, not 9');
         else {
           grantLoot({x:p.x,y:p.y,loot:[],dropped:1},[rs[9]]);
           var pinOf9=function(key){ var q; for(q in g.hotAssign) if(g.hotAssign[q]===key) return +q; return -1; };
           if(pinOf9(rs[9])<0) bad.push('NINE: the stronger find took no key ('+JSON.stringify(g.hotAssign)+')');
           if(pinOf9(rs[0])!==-1||g.bag.indexOf(rs[0])<0) bad.push('NINE: the weakest gun is not in the backpack with no key ('+JSON.stringify(g.hotAssign)+')');
           if(!(p.wep.id===ITEMS[rs[8]].gk&&p.sec&&p.sec.id===ITEMS[rs[7]].gk)) bad.push('NINE: the guns in his hands changed');
         }
       }
       // EIGHT: the belt draws no group labels
       txt=[]; proto.fillText=function(s,x,y){ txt.push(String(s)); return oFT.apply(this,arguments); };
       try{ if(window.__frame){ __frame(0); __frame(0); } } finally { proto.fillText=oFT; }
       if(window.__frame){
         ['THROW','MEDICAL','ARMOUR'].forEach(function(w){ if(txt.indexOf(w)>=0) bad.push('EIGHT: the belt still draws the label '+w); });
         if(!g.hotCells||g.hotCells.length!==9) bad.push('EIGHT: the belt drew '+(g.hotCells?g.hotCells.length:0)+' keys, not 9');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oFT; }catch(_f){}
       try{ mouse.down=false; keys={}; var g2=__state(); if(g2){ g2.wheel=null; g2.hot=0; g2.hotAssign={}; g2.hotAuto={}; if(!g2.over){ g2.player.iv=0; g2.player.prep=null; g2.player.prepA=null; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

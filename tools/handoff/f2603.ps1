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

if ($s.Contains("  {v:'26.03',what:")) { throw "check 26.03 is in the fixture already" }

SubRx @'
  {v:'26.02',what:
'@ @'
  {v:'26.03',what:'his order (selected throwable and heal outlined in gold like the selected gun): the belt rings the gun in hand, the grenade G throws and the heal H uses in the same gold, so three keys can wear it at once; the other grenade, the other heal, the plate and an empty key are not ringed, and the rings follow U and J',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the belt cannot be drawn';
     if(typeof raidKey!=='function'||typeof medSelIx!=='function'||!ITEMS.frag||!ITEMS.smoke||!ITEMS.bandage||!ITEMS.medkit||!ITEMS.plate) return 'SKIP: no keys or belt items here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, gk=[], k, SX=THROWKEYS.indexOf('smoke'), FX=THROWKEYS.indexOf('frag'), cx=null, rec=[], last=null, C=null, ref=null, own=['roundRect','rect','stroke','strokeRect'];
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function hurt(hp){ p.hp=hp; p.healQ=0; p.healRate=0; p.healCap=undefined; p.prep=null; p.prepA=null; p.downed=false; p.dying=false; p.roll=0; p.cooking=0; }
     function stock(){ g.bag=['bandage','bandage','medkit','medkit','plate','plate',gk[2]]; g.pouch.frag=2; g.pouch.smoke=2; g.pouch.decoy=0; g.pouch.trip=0; hurt(50); p.armor=0; p.armorCap=60; g.hot=0; g.tsel=SX; g.msel=undefined; keys={}; }
     function unstub(){ var j; try{ if(cx) for(j=0;j<own.length;j++) delete cx[own[j]]; }catch(_u){} }
     function draw(){
       var proto=CanvasRenderingContext2D.prototype, oRR=proto.roundRect, oR=proto.rect, oS=proto.stroke, oSR=proto.strokeRect;
       rec=[]; last=null; cx=ctx;
       if(oRR) cx.roundRect=function(x,y,w,h){ last={x:x,y:y,w:w,h:h}; return oRR.apply(this,arguments); };
       cx.rect=function(x,y,w,h){ last={x:x,y:y,w:w,h:h}; return oR.apply(this,arguments); };
       cx.strokeRect=function(x,y,w,h){ rec.push({r:{x:x,y:y,w:w,h:h},st:String(this.strokeStyle),lw:this.lineWidth}); return oSR.apply(this,arguments); };
       cx.stroke=function(){ rec.push({r:last,st:String(this.strokeStyle),lw:this.lineWidth}); return oS.apply(this,arguments); };
       try{ __frame(0); __frame(0); } finally { unstub(); }
       C=g.hotCells; ref=null;
       if(C&&C.length) ref=ringOf(0);
     }
     function ringOf(i){ var j, c=C&&C[i], q, r=null; for(j=0;j<rec.length;j++){ q=rec[j].r; if(q&&c&&Math.abs(q.x-(c.x+.5))<.01&&Math.abs(q.y-(c.y+.5))<.01&&Math.abs(q.w-(c.w-1))<.01) r=rec[j]; } return r; }
     function gold(i){ var r=ringOf(i); return !!(r&&ref&&r.st===ref.st&&r.lw===ref.lw); }
     function expectGold(tag,want){
       var i, w, r;
       if(!C||C.length!==9){ bad.push(tag+': the belt drew '+(C?C.length:0)+' keys, not 9'); return; }
       if(!ref||ref.st!=='#ffc04a'||ref.lw!==2) bad.push(tag+': the gun in hand is not ringed in the gold ('+JSON.stringify(ref&&{st:ref.st,lw:ref.lw})+')');
       for(i=0;i<9;i++){
         w=want.indexOf(i)>=0;
         if(gold(i)!==w){ r=ringOf(i); bad.push(tag+': key '+(i+1)+(w?' is not ringed in the gun gold':' is ringed in the gun gold')+' ('+JSON.stringify(r&&{st:r.st,lw:r.lw})+')'); }
       }
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={};
       for(k in ITEMS) if(ITEMS[k].use==='gun'&&ITEMS[k].gk&&WEAPONS[ITEMS[k].gk]&&WEAPONS[ITEMS[k].gk].mag>0&&gk.length<3) gk.push(k);
       if(gk.length<3) return 'SKIP: fewer than three guns here';
       if(Object.prototype.hasOwnProperty.call(ctx,'stroke')||Object.prototype.hasOwnProperty.call(ctx,'roundRect')) return 'SKIP: the HUD context already carries own stubs';
       p.wep=cl(ITEMS[gk[0]].gk); p.ammo=p.wep.mag; p.sec=cl(ITEMS[gk[1]].gk); p.secAmmo=p.sec.mag; p.swapped=false; p.reloading=0; p.reserve=30;
       g.hotAssign={0:gk[0],1:gk[1],2:gk[2],4:'frag',5:'smoke',6:'bandage',7:'medkit',8:'plate'}; g.hotAuto={}; g.hotPruned={};
       // ONE: Smoke is the G pick (key 6), J has chosen the Medkit (key 8), the rifle is in hand (key 1): those three are ringed and nothing else
       stock(); raidKey('KeyJ',false,null); keys={};
       if(g.msel!=='medkit') bad.push('ONE: J left the heal pick on '+g.msel+', not medkit');
       draw(); expectGold('ONE',[0,5,7]);
       // TWO: U picks Frag (key 5) and with no J the Bandage (key 7) is the cheapest heal at 50 health: the rings move with the picks
       stock(); raidKey('KeyU',false,null); keys={};
       if(g.tsel!==FX) bad.push('TWO: U left the grenade pick on '+THROWKEYS[g.tsel]+', not frag');
       draw(); expectGold('TWO',[0,4,6]);
       // THREE: no Frag left: its key is not ringed, Smoke still is
       stock(); g.pouch.frag=0;
       draw(); expectGold('THREE',[0,5,6]);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       unstub();
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hot=0; g2.hotAssign={}; g2.hotAuto={}; g2.msel=undefined; if(g2.player){ g2.player.iv=0; g2.player.downed=false; g2.player.prep=null; g2.player.prepA=null; g2.player.healQ=0; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; if(typeof BELTHOV!=='undefined'){ BELTHOV.box=null; BELTHOV.i=-1; } }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

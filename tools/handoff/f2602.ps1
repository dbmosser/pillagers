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

if ($s.Contains("  {v:'26.02',what:")) { throw "check 26.02 is in the fixture already" }

SubRx @'
  {v:'26.01',what:
'@ @'
  {v:'26.02',what:'his orders (cycle keys, instant keys and keycaps on the belt): 5 to 9 use the item on their key at once with the gun still in hand and leave the G and H picks alone; U picks the next grenade and G throws it; J picks the next heal and H uses it, not the cheapest; the belt keycaps read G and U on the two grenades, H and J on the two heals, HOLD H on the plate and F on the next gun; and J reads K once it is rebound',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the belt cannot be drawn';
     if(typeof raidKey!=='function'||typeof quickHeal!=='function'||typeof keysBind!=='function'||!ITEMS.frag||!ITEMS.smoke||!ITEMS.bandage||!ITEMS.medkit||!ITEMS.plate) return 'SKIP: no keys or belt items here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, txt=[], C=null, caps=[], gk=[], k, SX=THROWKEYS.indexOf('smoke'), FX=THROWKEYS.indexOf('frag'), km0=null, w0='', r;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function inC(c,x,y){ return x>=c.x&&x<=c.x+c.w&&y>=c.y&&y<=c.y+c.h; }
     function cnt(k2){ var c=0, j; for(j=0;j<g.bag.length;j++) if(g.bag[j]===k2) c++; return c; }
     function hurt(hp){ p.hp=hp; p.healQ=0; p.healRate=0; p.healCap=undefined; p.prep=null; p.prepA=null; p.downed=false; p.dying=false; p.roll=0; p.cooking=0; }
     function stock(){ g.bag=['bandage','bandage','medkit','medkit','plate','plate',gk[2]]; g.pouch.frag=2; g.pouch.smoke=2; g.pouch.decoy=0; g.pouch.trip=0; hurt(50); p.armor=0; p.armorCap=60; g.hot=0; g.tsel=SX; g.msel=undefined; keys={}; }
     function draw(){
       txt=[]; proto.fillText=function(s,x,y){ txt.push({s:String(s),x:x,y:y}); return oFT.apply(this,arguments); };
       try{ __frame(0); __frame(0); } finally { proto.fillText=oFT; }
       C=g.hotCells; caps=g.beltCaps||[];
     }
     function capsOn(ix){ var o=[], j; for(j=0;j<caps.length;j++) if(caps[j].i===ix) o.push(caps[j].s); return o.join('+'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={};
       for(k in ITEMS) if(ITEMS[k].use==='gun'&&ITEMS[k].gk&&WEAPONS[ITEMS[k].gk]&&WEAPONS[ITEMS[k].gk].mag>0&&gk.length<3) gk.push(k);
       if(gk.length<3) return 'SKIP: fewer than three guns here';
       p.wep=cl(ITEMS[gk[0]].gk); p.ammo=p.wep.mag; p.sec=cl(ITEMS[gk[1]].gk); p.secAmmo=p.sec.mag; p.swapped=false; p.reloading=0; p.reserve=30;
       g.hotAssign={0:gk[0],1:gk[1],2:gk[2],4:'frag',5:'smoke',6:'bandage',7:'medkit',8:'plate'}; g.hotAuto={}; g.hotPruned={};
       w0=p.wep.id;
       // ONE: the keycaps, on the right cells (Smoke is the pick, a Bandage the cheapest heal at 50 health, the rifle in hand)
       stock(); draw();
       if(!C||C.length!==9) return 'the belt drew '+(C?C.length:0)+' keys, not 9';
       r={4:'U',5:'G',6:'H',7:'J',8:'HOLD H',1:'F'};
       for(k in r) if(capsOn(+k)!==r[k]) bad.push('ONE: key '+(+k+1)+' wears '+JSON.stringify(capsOn(+k))+', not '+r[k]);
       if(caps.length!==6) bad.push('ONE: the belt wears '+caps.length+' keycaps ('+caps.map(function(q){ return (q.i+1)+q.s; }).join(',')+'), not 6');
       if(C[8]&&!txt.some(function(t){ return t.s==='HOLD H'&&inC(C[8],t.x,t.y); })) bad.push('ONE: no HOLD H is drawn on the plate key');
       if(C[4]&&!txt.some(function(t){ return t.s==='U'&&inC(C[4],t.x,t.y); })) bad.push('ONE: no U is drawn on the other grenade key');
       // TWO: 5 and 6 throw at once, the gun stays up, the G pick stays on Smoke
       stock(); raidKey('Digit6',false,null); keys={};
       if(g.pouch.smoke!==1||g.pouch.frag!==2) bad.push('TWO: key 6 left Smoke '+g.pouch.smoke+' and Frag '+g.pouch.frag+', not 1 and 2');
       raidKey('Digit5',false,null); keys={};
       if(g.pouch.frag!==1||g.pouch.smoke!==1) bad.push('TWO: key 5 left Smoke '+g.pouch.smoke+' and Frag '+g.pouch.frag+', not 1 and 1');
       if(!p.wep||p.wep.id!==w0||g.hot!==0||p.cooking) bad.push('TWO: a number key took the gun out of the hand (gun '+(p.wep&&p.wep.id)+', highlight '+g.hot+')');
       if(g.tsel!==SX) bad.push('TWO: the number keys moved the G pick to '+THROWKEYS[g.tsel]);
       // THREE: 7 and 8 use their own heal at once, the gun stays up, the H pick stays unset
       stock(); raidKey('Digit7',false,null); keys={};
       if(cnt('bandage')!==1||cnt('medkit')!==2||!p.prep) bad.push('THREE: key 7 left '+cnt('bandage')+' Bandage and '+cnt('medkit')+' Medkit (prep '+(p.prep?p.prep.key:'none')+'), not 1 and 2 with a heal started');
       hurt(50); raidKey('Digit8',false,null); keys={};
       if(cnt('medkit')!==1||cnt('bandage')!==1||!p.prep) bad.push('THREE: key 8 left '+cnt('bandage')+' Bandage and '+cnt('medkit')+' Medkit, not 1 and 1 with a heal started');
       if(!p.wep||p.wep.id!==w0||g.hot!==0) bad.push('THREE: a number key took the gun out of the hand');
       if(g.msel) bad.push('THREE: the number keys moved the H pick to '+g.msel);
       // FOUR: 9 slots a plate
       stock(); raidKey('Digit9',false,null); keys={};
       if(cnt('plate')!==1||!p.prepA) bad.push('FOUR: key 9 left '+cnt('plate')+' plates and slotting '+(p.prepA?'yes':'no')+', not 1 and yes');
       // FIVE: U picks the other grenade and G throws it, the gun stays up
       stock(); raidKey('KeyU',false,null); keys={};
       if(g.tsel!==FX) bad.push('FIVE: U left the pick on '+THROWKEYS[g.tsel]+', not frag');
       raidKey('KeyG',false,null); keys={};
       if(g.pouch.frag!==1||g.pouch.smoke!==2) bad.push('FIVE: U then G left Frag '+g.pouch.frag+' and Smoke '+g.pouch.smoke+', not 1 and 2');
       if(!p.wep||p.wep.id!==w0||g.hot!==0) bad.push('FIVE: G took the gun out of the hand');
       // SIX: J picks the other heal, the caps follow, and H uses that one and not the cheapest
       stock(); raidKey('KeyJ',false,null); keys={};
       if(g.msel!=='medkit') bad.push('SIX: J left the heal pick on '+g.msel+', not medkit');
       draw();
       if(capsOn(7)!=='H'||capsOn(6)!=='J') bad.push('SIX: after J the caps read '+JSON.stringify(capsOn(6))+' on key 7 and '+JSON.stringify(capsOn(7))+' on key 8, not J and H');
       quickHeal();
       if(cnt('medkit')!==1||cnt('bandage')!==2) bad.push('SIX: H after J left '+cnt('bandage')+' Bandages and '+cnt('medkit')+' Medkits, not 2 and 1');
       stock(); quickHeal();
       if(cnt('bandage')!==1||cnt('medkit')!==2) bad.push('SIX: H with no J left '+cnt('bandage')+' Bandages and '+cnt('medkit')+' Medkits, not 1 and 2 (the cheapest)');
       // SEVEN: a rebound key prints its new name
       stock(); km0=(typeof P!=='undefined'&&P.keymap&&typeof P.keymap==='object')?JSON.stringify(P.keymap):null;
       keysBind('KeyJ','KeyK');
       draw();
       if(capsOn(7)!=='K') bad.push('SEVEN: after J was rebound to K the cap reads '+JSON.stringify(capsOn(7)));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oFT; }catch(_f){}
       try{ P.keymap=km0?JSON.parse(km0):{}; if(typeof KEYS==='object'&&KEYS) KEYS.inv=null; }catch(_k){}
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hot=0; g2.hotAssign={}; g2.hotAuto={}; g2.msel=undefined; if(g2.player){ g2.player.iv=0; g2.player.downed=false; g2.player.prep=null; g2.player.prepA=null; g2.player.healQ=0; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; if(typeof BELTHOV!=='undefined'){ BELTHOV.box=null; BELTHOV.i=-1; } }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

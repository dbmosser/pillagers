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

if ($s.Contains("  {v:'25.97',what:")) { throw "check 25.97 is in the fixture already" }

SubRx @'
  {v:'25.96',what:
'@ @'
  {v:'25.97',what:'his answer (bar for magazine, number for reserve additional rounds): the rifle in hand with 22 rounds loaded of 30 and 37 in reserve shows a light bar three quarters full along the foot of its key and the number 37, and not the 22; the throwable key G throws (Smoke after U) wears a G keycap and the Frag key does not; and the hover cards read THROW for a grenade, HEAL for a Bandage and PLATE for the armour plate',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the belt cannot be drawn';
     if(typeof beltInfoCard!=='function'||!ITEMS.frag||!ITEMS.smoke||!ITEMS.bandage||!ITEMS.plate||!WEAPONS.rifle) return 'SKIP: no hover card or belt items here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, oFR=proto.fillRect, txt=[], rects=[], C, sl, i, M, tr, fl, SX=THROWKEYS.indexOf('smoke'), r, inside;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function inC(c,x,y){ return x>=c.x&&x<=c.x+c.w&&y>=c.y&&y<=c.y+c.h; }
     function spy(fn){
       txt=[]; rects=[];
       proto.fillText=function(s,x,y){ txt.push({s:String(s),x:x,y:y}); return oFT.apply(this,arguments); };
       proto.fillRect=function(x,y,w,h){ rects.push({x:x,y:y,w:w,h:h,st:String(this.fillStyle)}); return oFR.apply(this,arguments); };
       try{ fn(); } finally { proto.fillText=oFT; proto.fillRect=oFR; }
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={};
       p.wep=cl('rifle'); M=p.wep.mag; p.ammo=Math.round(M*0.75); p.reserve=37; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0;
       p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false; p.swapped=false;
       g.bag=['bandage','plate']; g.pouch.frag=2; g.pouch.smoke=1; g.pouch.decoy=0; g.pouch.trip=0;
       g.hotAssign={4:'frag',5:'smoke',6:'bandage',8:'plate'}; g.hotAuto={}; g.hotPruned={}; g.hot=0; g.tsel=SX;
       spy(function(){ __frame(0); __frame(0); });
       C=g.hotCells; if(!C||C.length!==9) return 'the belt drew '+(C?C.length:0)+' keys, not 9';
       // ONE: the reserve is the number, the magazine is the bar
       r=txt.filter(function(t){ return t.s==='37'&&inC(C[0],t.x,t.y); });
       if(!r.length) bad.push('ONE: the rifle key shows no 37 (the rounds in reserve)');
       if(txt.some(function(t){ return t.s===String(p.ammo)&&inC(C[0],t.x,t.y); })) bad.push('ONE: the rifle key still prints the magazine count '+p.ammo+' as a number');
       tr=rects.filter(function(q){ return /255,\s*255,\s*255,\s*0?\.14/.test(q.st)&&q.h<=C[0].h*0.1&&q.h>=3&&q.x>=C[0].x&&q.x<=C[0].x+C[0].w&&q.y>C[0].y+C[0].h*0.7; })[0];
       fl=rects.filter(function(q){ return /^#e6f0f6$/i.test(q.st)&&q.h<=C[0].h*0.1&&q.h>=3&&q.x>=C[0].x&&q.x<=C[0].x+C[0].w&&q.y>C[0].y+C[0].h*0.7; })[0];
       if(!tr||!fl) bad.push('ONE: no magazine bar along the foot of the rifle key (track '+!!tr+', fill '+!!fl+')');
       else if(Math.abs(fl.w/tr.w-p.ammo/M)>0.06) bad.push('ONE: the bar is '+(fl.w/tr.w).toFixed(2)+' full, not '+(p.ammo/M).toFixed(2));
       // TWO: the G keycap is on the kind G throws
       if(!txt.some(function(t){ return t.s==='G'&&inC(C[5],t.x,t.y); })) bad.push('TWO: no G keycap on the Smoke key, which G throws');
       if(txt.some(function(t){ return t.s==='G'&&inC(C[4],t.x,t.y); })) bad.push('TWO: a G keycap on the Frag key, which G does not throw');
       // THREE: the hover cards name the class key
       sl=hotbarSlots();
       function cardTexts(ix){ var out=[]; spy(function(){ beltInfoCard(sl[ix],C[ix]); }); out=txt.map(function(t){ return t.s; }); return out; }
       r=cardTexts(4); if(r.indexOf('THROW')<0) bad.push('THREE: the Frag card has no THROW key row ('+r.join('|')+')');
       r=cardTexts(6); if(r.indexOf('HEAL')<0) bad.push('THREE: the Bandage card has no HEAL key row ('+r.join('|')+')');
       r=cardTexts(8); if(r.indexOf('PLATE')<0) bad.push('THREE: the plate card has no PLATE key row ('+r.join('|')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oFT; proto.fillRect=oFR; }catch(_f){}
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hot=0; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; if(typeof BELTHOV!=='undefined'){ BELTHOV.box=null; BELTHOV.i=-1; } }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'25.98',what:")) { throw "check 25.98 is in the fixture already" }

SubRx @'
  {v:'25.97',what:
'@ @'
  {v:'25.98',what:'his answer (the CAREER LOADOUT screen gets the same groups as the raid bar): the belt plan row of the Stash screen has its nine keys in four groups labelled GUNS (keys 1 to 4), THROW (5, 6), MEDICAL (7, 8) and ARMOUR (9), and with a Frag and a Bandage packed and nothing bound, keys 5 and 7 show them dimmed as the floor belt does; and a vacant gun key on the raid belt prints no 0',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__frame)) return 'SKIP: this fixture cannot deploy, draw or load a profile';
     if(typeof hotPlanHTML!=='function'||!ITEMS.frag||!ITEMS.bandage||!WEAPONS.rifle||!WEAPONS.smg) return 'SKIP: no belt plan row or items here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the belt cannot be drawn';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], snap=null, d, cells, i, NM=['GUNS','GUNS','GUNS','GUNS','THROW','THROW','MEDICAL','MEDICAL','ARMOUR'], nm, g=null, p=null, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, txt=[], C;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function inC(c,x,y){ return x>=c.x&&x<=c.x+c.w&&y>=c.y&&y<=c.y+c.h; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // ONE: the plan row
       P.kit=['frag','bandage']; P.stash=['frag','bandage']; P.hotAssign={}; P.freeKit=0;
       d=document.createElement('div'); d.innerHTML=hotPlanHTML();
       cells=d.querySelectorAll('[data-plan]');
       if(cells.length!==9) bad.push('ONE: the plan row has '+cells.length+' keys, not 9');
       for(i=0;i<cells.length;i++){
         var grp=cells[i].parentNode&&cells[i].parentNode.parentNode, lb=grp&&grp.lastElementChild;
         nm=lb?String(lb.textContent||'').trim():'';
         if(nm!==NM[+cells[i].getAttribute('data-plan')]) bad.push('ONE: key '+(+cells[i].getAttribute('data-plan')+1)+' is in a group labelled '+JSON.stringify(nm)+', not '+NM[+cells[i].getAttribute('data-plan')]);
       }
       if(cells.length===9){
         if((cells[4].getAttribute('title')||'').indexOf(ITEMS.frag.name)<0) bad.push('ONE: key 5 of the plan row reads '+JSON.stringify(cells[4].getAttribute('title'))+', not the Frag the floor belt shows there');
         if((cells[6].getAttribute('title')||'').indexOf(ITEMS.bandage.name)<0) bad.push('ONE: key 7 of the plan row reads '+JSON.stringify(cells[6].getAttribute('title'))+', not the Bandage the floor belt shows there');
       }
       // TWO: a vacant gun key on the raid belt prints no 0
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return bad.length?bad.join('; '):'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={};
       p.wep=cl('rifle'); p.ammo=10; p.sec=cl('smg'); p.secAmmo=5; p.swapped=false; p.reserve=20; g.bag=[]; g.hotAssign={}; g.hotAuto={}; g.hot=0;
       txt=[]; proto.fillText=function(s,x,y){ txt.push({s:String(s),x:x,y:y}); return oFT.apply(this,arguments); };
       try{ __frame(0); __frame(0); } finally { proto.fillText=oFT; }
       C=g.hotCells;
       if(!C||C.length!==9) bad.push('TWO: the belt drew '+(C?C.length:0)+' keys');
       else {
         if(!(g.hotAssign&&true)) bad.push('TWO: no belt');
         if(txt.some(function(t){ return t.s==='0'&&(inC(C[2],t.x,t.y)||inC(C[3],t.x,t.y)); })) bad.push('TWO: a vacant gun key prints a 0');
         if(!txt.some(function(t){ return t.s==='20'&&inC(C[0],t.x,t.y); })) bad.push('TWO: the rifle key does not show the reserve (20), so the vacant keys are not the ones read');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oFT; }catch(_f){}
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; if(snap) __applyLoaded(snap); }catch(_r){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

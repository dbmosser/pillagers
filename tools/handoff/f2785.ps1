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

if ($s.Contains("  {v:'27.85',what:")) { throw "check 27.85 is in the fixture already" }

SubRx @'
  {v:'27.84',what:
'@ @'
  {v:'27.85',what:'feel2f, his words: damage numbers are coloured by what the hit was. A weak point hit is that weak point own colour (a Sentry vent orange, its optic cyan), a forged element round its element colour, a hit a pillager plate soaked is grey, and a plain hit stays white',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof updateBullets!=='function'||typeof mkSentry!=='function'||typeof weakOf!=='function'||typeof weakPos!=='function') return 'SKIP: no weak points here';
     var bad=[], g=null, p=null, all=null, e, L, W, pt, ux, uy, n, c, rd, oCrawl, oNum;
     function shoot(en,x0,y0,vx,vy,el,dt){
       g.ents.length=0; g.ents.push(en); g.dmgN=[]; en.hp=en.maxhp=1e6; en.roll=0; en.state='patrol'; en.weakLblT=undefined;
       g.bullets.length=0;
       g.bullets.push({x:x0,y:y0,vx:vx,vy:vy,dmg:20,life:0.5,player:true,owner:p,tint:'#ffd48a',thru:0,el:el||''});
       updateBullets(dt||0.01);
       g.bullets.length=0;
       return g.dmgN.length?String(g.dmgN[g.dmgN.length-1].c).toLowerCase():'(no number)';
     }
     function at(id){ var q; for(q=0;q<L.length;q++) if(L[q].id===id) return L[q]; return null; }
     function weakShot(id){
       e=mkSentry(p.x+260,p.y); L=weakOf(e); W=at(id); pt=weakPos(e,W); ux=pt.x-e.x; uy=pt.y-e.y; n=Math.sqrt(ux*ux+uy*uy)||1; ux/=n; uy/=n;
       return {c:shoot(e,e.x+ux*(e.r+2.5),e.y+uy*(e.r+2.5),-ux*1180,-uy*1180),want:String(W.c).toLowerCase()};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; all=g.ents.slice(); p.iv=99; keys={}; oNum=CFG.dmgNumbers; CFG.dmgNumbers=1;
       // ONE: a weak point is its own colour
       c=weakShot('vent'); if(c.c!==c.want) bad.push('ONE: a Sentry vent hit is '+c.c+', not its colour '+c.want);
       c=weakShot('optic'); if(c.c!==c.want) bad.push('TWO: a Sentry optic hit is '+c.c+', not its colour '+c.want);
       // THREE: a pillager: plain white, soaked grey, an element its colour
       rd=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC; })[0];
       if(!rd) bad.push('(no pillager on this map: the armour and element cases are not staged)');
       else {
         oCrawl=CFG.raiderCrawl; rd.x=p.x+200; rd.y=p.y; rd.downed=0; rd.armor=0; rd.rig='heavy';
         c=shoot(rd,rd.x,rd.y,0.01,0,''); if(c!=='#fff6dc') bad.push('THREE: a plain hit on an unarmoured pillager is '+c+', not white');
         rd.armor=400; c=shoot(rd,rd.x,rd.y,0.01,0,''); if(c!=='#9aa3ab') bad.push('FOUR: a hit his plate soaked is '+c+', not grey');
         rd.armor=0; c=shoot(rd,rd.x,rd.y,0.01,0,'cryo'); if(c!==String(ELEM.cryo.c).toLowerCase()) bad.push('FIVE: a CRYO round is '+c+', not '+ELEM.cryo.c);
         rd.armor=400; c=shoot(rd,rd.x,rd.y,0.01,0,'fire'); if(c!==String(ELEM.fire.c).toLowerCase()) bad.push('SIX: a FIRE round into armour is '+c+', not its element colour');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ CFG.dmgNumbers=oNum; var g2=__state(); if(g2){ g2.dmgN=[]; if(all&&g2.ents) g2.ents=all.slice(); if(!g2.over){ g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

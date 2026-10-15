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

if ($s.Contains("  {v:'28.22',what:")) { throw "check 28.22 is in the fixture already" }

SubRx @'
  {v:'28.21',what:
'@ @'
  {v:'28.22',what:'his order: a weak point hit says its multiplier: a Sentry vent hit reads WEAK SPOT 3.4x and its optic WEAK SPOT 2.0x, and a round into the exposed core of a venting boss reads WEAK SPOT 1.5x',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof updateBullets!=='function'||typeof weakOf!=='function'||typeof weakPos!=='function'||typeof mkSentry!=='function') return 'SKIP: no weak points here';
     var bad=[], g=null, p=null, e, L, W, i, pt, ux, uy, n, tx, off;
     function shoot(en,x0,y0,vx,vy,dt){
       g.ents.length=0; g.ents.push(en); g.labels.length=0; en.weakLblT=undefined; en.hp=en.maxhp=1e6; en.roll=0; en.state='patrol';
       g.bullets.length=0;
       g.bullets.push({x:x0,y:y0,vx:vx,vy:vy,dmg:1,life:0.5,player:true,owner:p,tint:'#ffd48a',thru:0});
       updateBullets(dt||0.01);
       g.bullets.length=0;
       var t=''; for(var j=0;j<g.labels.length;j++) if(String(g.labels[j].txt).indexOf('WEAK '+'SPOT')===0) t=String(g.labels[j].txt);
       return t;
     }
     function at(id){ var q; for(q=0;q<L.length;q++) if(L[q].id===id) return L[q]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; keys={};
       e=mkSentry(p.x+260,p.y); L=weakOf(e); if(!L||!L.length) return 'SKIP: a Sentry has no weak point here';
       // the vent, from outside the body along the line through its centre
       W=at('vent'); pt=weakPos(e,W); ux=pt.x-e.x; uy=pt.y-e.y; n=Math.sqrt(ux*ux+uy*uy)||1; ux/=n; uy/=n;
       tx=shoot(e,e.x+ux*(e.r+2.5),e.y+uy*(e.r+2.5),-ux*1180,-uy*1180);
       if(tx!=='WEAK'+' SPOT 3.4x') bad.push('a Sentry vent hit says "'+tx+'", not WEAK SPOT 3.4x');
       // the optic, the same way
       e=mkSentry(p.x+260,p.y); W=at('optic'); pt=weakPos(e,W); ux=pt.x-e.x; uy=pt.y-e.y; n=Math.sqrt(ux*ux+uy*uy)||1; ux/=n; uy/=n;
       tx=shoot(e,e.x+ux*(e.r+2.5),e.y+uy*(e.r+2.5),-ux*1180,-uy*1180);
       if(tx!=='WEAK'+' SPOT 2.0x') bad.push('a Sentry optic hit says "'+tx+'", not WEAK SPOT 2.0x');
       // a venting boss body: the core is exposed and pays 1.5, away from both openings
       e=mkSentry(p.x+260,p.y); e.boss=1; e.overheat=4;
       // fire in from twelve directions, straight at the centre: the vent and the optic are small openings on one side, so some of the twelve rounds reach the bare exposed
       // core (1.5), and a round that hits an opening on the way pays the opening times 1.5 (5.1x on the vent, 3.0x on the optic)
       var seen=[], ang, ca, sa, got15=0;
       for(ang=0;ang<12;ang++){
         ca=Math.cos(ang*0.5236); sa=Math.sin(ang*0.5236);
         tx=shoot(e,e.x+ca*(e.r+12),e.y+sa*(e.r+12),-ca*1180,-sa*1180,0.03); seen.push(tx||'none');
         if(tx==='WEAK'+' SPOT 1.5x') got15++;
       }
       if(!got15) bad.push('no round into an exposed core says WEAK SPOT 1.5x (12 directions said: '+seen.join(' | ')+')');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.labels.length=0; if(!g2.over){ g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

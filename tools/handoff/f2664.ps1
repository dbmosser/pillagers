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

if ($s.Contains("  {v:'26.64',what:")) { throw "check 26.64 is in the fixture already" }

SubRx @'
  {v:'26.63',what:
'@ @'
  {v:'26.64',what:'feel16, his order: hold V on a downed pillager in reach and he is finished after 0.55 s (a tap or a standing pillager does nothing), the kill is the player, the finisher adds 100 to the run score, and FINISH is drawn over a downed pillager in reach',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)) return 'SKIP: no raid here';
     var bad=[], g, p, all, rd, X0, Y0, dx=0, dy=0, ok=false, k, ux, uy, i, oCrawl, oCareer, oCs, cap=[], proto, oArc, s, hit, n0;
     function step(n){ for(var q=0;q<n;q++){ g.t+=0.016; __sim(0.016); } }
     function down(){ rd.x=X0+dx*30; rd.y=Y0+dy*30; rd.hp=40; rd.maxhp=100; rd.downed=1; rd.finished=0; rd.downT=14; rd.hostile=true; rd.state='down'; rd.getUpOn=1; rd.getUpIn=3; rd.getUp=0; rd.byPlayer=false; rd.crawlTo=null; rd.reviveT=0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); X0=p.x; Y0=p.y; oCrawl=CFG.raiderCrawl; oCareer=g.career; oCs=g.cs;
       for(k=0;k<8;k++){ ux=Math.cos(k*0.7854); uy=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ux*80,Y0+uy*80,g.map.segs)){ dx=ux; dy=uy; ok=true; break; } }
       if(!ok) return 'SKIP: staging: no open line from the drop point';
       rd=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC; })[0];
       if(!rd) return 'SKIP: no pillager on this map';
       CFG.raiderCrawl=0; g.ents=[rd]; keys['KeyV']=false; mouse.down=false;
       // ONE: a downed pillager, no key: he stays
       down(); step(40);
       if(!(rd.hp>0)||!rd.downed) bad.push('ONE: the downed pillager died or got up with no key held');
       // TWO: a tap does nothing
       down(); keys['KeyV']=true; step(12); keys['KeyV']=false; step(3);
       if(!(rd.hp>0)||!rd.downed) bad.push('TWO: a short press on V finished him');
       // THREE: the prompt is drawn over him (before the finish)
       down(); mouse.x=W/2; mouse.y=H/2; render2D(0);
       s=w2s(rd.x,0,rd.y); proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ drawHUD(); } finally { proto.arc=oArc; }
       hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<1.5&&Math.abs(cap[i][1]-s.y)<1.5) hit++;
       if(!hit) bad.push('THREE: no FINISH ring was drawn over a downed pillager in reach ('+cap.length+' arcs)');
       // FOUR: hold V, and he is finished
       down(); keys['KeyV']=true; step(20);
       if(!(rd.hp>0)||!rd.downed) bad.push('FOUR: he was finished before the 0.55 s hold ran out');
       step(25); keys['KeyV']=false;
       if(g.ents.indexOf(rd)>=0&&rd.hp>0&&rd.downed) bad.push('FOUR: holding V for 0.8 s did not finish a downed pillager');
       // FIVE: a standing pillager is not touched
       down(); rd.downed=0; rd.hostile=false; rd.state='patrol'; rd.hp=rd.maxhp=100; keys['KeyV']=true; step(50); keys['KeyV']=false;
       if(!(rd.hp>0)) bad.push('FIVE: holding V near a standing pillager hurt him');
       // SIX: the score, in a CAREER run
       down(); g.career=true; g.cs={s:0,k:0}; finishHim(p,rd);
       if((g.cs.s|0)<100) bad.push('SIX: the finisher added '+(g.cs.s|0)+' to the CAREER score, not 100');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keys['KeyV']=false; if(typeof oCrawl!=='undefined') CFG.raiderCrawl=oCrawl; if(g){ g.career=oCareer; g.cs=oCs; if(all) g.ents=all.slice(); g.bullets.length=0; g.finT=0; g.finE=null; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

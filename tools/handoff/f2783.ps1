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

if ($s.Contains("  {v:'27.83',what:")) { throw "check 27.83 is in the fixture already" }

SubRx @'
  {v:'27.82',what:
'@ @'
  {v:'27.83',what:'feel2e, his words: a downed pillager in finisher reach shows the standard world prompt, HOLD [V] FINISH, over him (the key as a keycap, stacked under the REVIVE prompt when both are up) and nothing for a standing pillager or when you are down',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)) return 'SKIP: no raid here';
     var bad=[], g, p, all, rd, X0, Y0, dx=0, dy=0, ok=false, k, ux, uy, i, oCrawl, cap, proto, oFill, an, fin, rev, vk, oPad=PAD.on;
     function step(n){ for(var q=0;q<n;q++){ g.t+=0.016; __sim(0.016); } }
     function down(){ rd.x=X0+dx*30; rd.y=Y0+dy*30; rd.hp=40; rd.maxhp=100; rd.downed=1; rd.finished=0; rd.downT=14; rd.hostile=true; rd.state='down'; rd.getUpOn=1; rd.getUpIn=3; rd.getUp=0; rd.byPlayer=false; rd.crawlTo=null; rd.reviveT=0; }
     function draw(){
       cap=[]; mouse.x=W/2; mouse.y=H/2; render2D(0);
       proto=CanvasRenderingContext2D.prototype; oFill=proto.fillText;
       proto.fillText=function(t,x,y){ cap.push({t:String(t),x:x,y:y}); return oFill.apply(this,arguments); };
       try{ drawHUD(); } finally { proto.fillText=oFill; }
     }
     function find(sub){ var q; for(q=0;q<cap.length;q++) if(cap[q].t.indexOf(sub)>=0) return cap[q]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); X0=p.x; Y0=p.y; oCrawl=CFG.raiderCrawl; p.iv=99;
       for(k=0;k<8;k++){ ux=Math.cos(k*0.7854); uy=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ux*80,Y0+uy*80,g.map.segs)){ dx=ux; dy=uy; ok=true; break; } }
       if(!ok) return 'SKIP: staging: no open line from the drop point';
       rd=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC; })[0];
       if(!rd) return 'SKIP: no pillager on this map';
       CFG.raiderCrawl=0; g.ents=[rd]; keys['KeyV']=false; mouse.down=false;
       // ONE: the prompt is on the screen with its keycap, over him
       down(); step(2); down(); draw();
       an=w2s(rd.x,26,rd.y);
       fin=find('HOLD [V] FINISH'); vk=null; for(i=0;i<cap.length;i++) if(cap[i].t==='V'&&Math.abs(cap[i].x-an.x)<80){ vk=cap[i]; }
       if(!fin) bad.push('ONE: no HOLD [V] FINISH prompt was drawn over a downed pillager in reach');
       else {
         if(!(Math.abs(fin.x-an.x)<4)) bad.push('ONE: the FINISH prompt is '+Math.round(fin.x-an.x)+' px to the side of him');
         if(!(fin.y>an.y-30&&fin.y<an.y+80)) bad.push('ONE: the FINISH prompt is '+Math.round(fin.y-an.y)+' px from where his prompts sit');
         if(!vk) bad.push('ONE: the V was not drawn as a keycap');
       }
       // TWO: stacked under the revive prompt when both are up
       rev=find('REVIVE');
       if(rev&&fin&&!(fin.y>=rev.y+12)) bad.push('TWO: FINISH is '+Math.round(fin.y-rev.y)+' px under REVIVE, not 12 or more');
       // THREE: none for a standing pillager, none when you are down
       rd.downed=0; rd.hostile=false; rd.state='patrol'; rd.hp=rd.maxhp=100; step(2); draw();
       if(find('FINISH')) bad.push('THREE: a standing pillager got a FINISH prompt');
       down(); step(2); down(); p.downed=true; draw(); p.downed=false;
       if(find('HOLD [V] FINISH')) bad.push('THREE: a downed player got a FINISH prompt');
       // FOUR: on a controller the prompt names the button as bound
       PAD.on=true; down(); step(2); down(); draw();
       if(!find('HOLD [Y] FINISH')) bad.push('FOUR: on a pad the prompt does not name the Y button');
       PAD.on=false;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ PAD.on=oPad; if(proto&&oFill) proto.fillText=oFill; keys['KeyV']=false; if(typeof oCrawl!=='undefined') CFG.raiderCrawl=oCrawl; if(g){ if(p) p.downed=false; if(all) g.ents=all.slice(); g.bullets.length=0; g.finT=0; g.finE=null; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

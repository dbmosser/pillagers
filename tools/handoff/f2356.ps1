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

if ($s.Contains("  {v:'23.56',what:")) { throw "check 23.56 is in the fixture already" }

SubRx @'
  {v:'23.55',what:
'@ @'
  {v:'23.56',what:'arcade31, his order 2026-10-11 evening (in arcade mode, credits and points should be synonymous): in an arcade raid a valuable searched from a crate raises the score and the pot by exactly its credit value with a +$N pickup tag, the HUD shows the score as $N with YOU $N, a crawler kill popup reads +$50, and the attract board rows and BEST EVER read in $',
   run:function(){
     var bad=[], g=null, p, ct=null, offs=[[20,0],[-20,0],[0,20],[0,-20]], i, f, t0, k, V=0, key=null, pot0, mine0, rows=[], rs=say, own=false, tagd='', cx=null, ft=null, ownF=false, seen=[], bT=null, bB=null, ownB=false, pg, tx, d, D='$';
     function hasLbl(gg,s){ var j; for(j=0;j<(gg.labels||[]).length;j++) if(gg.labels[j]&&gg.labels[j].txt===s) return true; return false; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       for(k in ITEMS){ if(ITEMS[k]&&!ITEMS[k].use&&ival(k)>=60){ key=k; break; } }
       if(!key) return 'SKIP: no valuable worth 60 or more';
       V=ival(key);
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player;
       if(typeof arcadeShieldOff==='function') arcadeShieldOff();
       ARCADE.holdT=0; ARCADE.waveT=0; keys={};
       for(i=0;i<offs.length&&!ct;i++) if(losClear(p.x,p.y,p.x+offs[i][0],p.y+offs[i][1],g.vseg)) ct=mkContainer(p.x+offs[i][0],p.y+offs[i][1],'crate');
       if(!ct) return 'SKIP: no clear spot 20 units from the arcade drop';
       ct.loot=[key]; ct.best=bestRarity(ct.loot); ct.pulled=0; ct.prog=0; ct.opened=false;
       g.containers.push(ct);
       pot0=ARCADE.pot|0; mine0=ARCADE.mine|0;
       say=function(m,l,o){ rows.push({m:String(m),l:l,tag:(o&&o.tag)||''}); }; own=true;
       t0=performance.now();
       keys={KeyE:true};
       for(f=0;f<600&&!ct.opened;f++) __loop(t0+f*16.7);
       keys={};
       say=rs; own=false;
       if(__state()!==g||g.over) return 'the arcade raid ended during the search';
       if(!ct.opened) return 'SKIP: the staged crate was not searched in 600 frames';
       if((ARCADE.pot|0)-pot0!==V) bad.push('a valuable worth '+V+' raised the pot by '+((ARCADE.pot|0)-pot0)+', not '+V);
       if((ARCADE.mine|0)-mine0!==V) bad.push('a valuable worth '+V+' raised the score by '+((ARCADE.mine|0)-mine0)+', not '+V);
       for(i=0;i<rows.length;i++) if(rows[i].l==='pick'&&rows[i].tag) tagd=rows[i].tag;
       if(tagd.indexOf('+'+D)!==0) bad.push('the pickup tag reads '+(tagd||'nothing')+', not +'+D+'N');
       ARCADE.banner=null; ARCADE.solo=0; ARCADE.mine=1234; ARCADE.mate=0; ARCADE.streak=null;
       cx=hcv.getContext('2d'); ft=cx.fillText; ownF=true;
       cx.fillText=function(s){ seen.push(String(s)); return ft.apply(this,arguments); };
       for(f=0;f<3;f++) __loop(performance.now()+(f+40)*16.7);
       if(!seen.length){ try{ drawHUD(); }catch(_dh){} }
       delete cx.fillText; ownF=false;
       if(seen.indexOf(D+'1,2'+'34')<0) bad.push('the HUD score is not drawn as '+D+'1,234');
       if(seen.indexOf('YOU '+D+'1,2'+'34')<0) bad.push('the HUD does not show YOU '+D+'1,234');
       if(__state()===g&&!g.over){
         g.labels=[]; ARCADE.streak=null;
         d=arcadeKill('crawler',false,false,p.x+300,p.y);
         if(d!==50) bad.push('a crawler kill scored '+d+', not 50');
         if(!hasLbl(g,'+'+D+'50')) bad.push('the crawler kill popup is not +'+D+'50 ('+(g.labels||[]).map(function(l){ return l&&l.txt; }).join(',')+')');
       } else bad.push('the arcade raid ended');
       bT=arcadeBoardTonight; bB=arcadeBoardBest; ownB=true;
       arcadeBoardTonight=function(){ return [{run:'zz31',i:'QXZ',s:4321,t:Date.now()}]; };
       arcadeBoardBest=function(){ return 98765; };
       pg=document.createElement('div');
       arcadeAttBoard(pg);
       arcadeBoardTonight=bT; arcadeBoardBest=bB; ownB=false;
       tx=pg.textContent||'';
       if(tx.indexOf(D+'4,3'+'21')<0) bad.push('the attract board row does not read '+D+'4,321 ('+tx+')');
       if(tx.indexOf('BEST EVER '+D+'98,7'+'65')<0) bad.push('the attract board does not read BEST EVER '+D+'98,765 ('+tx+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       if(ownF&&cx){ try{ delete cx.fillText; }catch(_df){} }
       if(ownB){ try{ arcadeBoardTonight=bT; arcadeBoardBest=bB; }catch(_bb){} }
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.streak=null; ARCADE.mine=0; ARCADE.mate=0; ARCADE.pot=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.banner=null; ARCADE.solo=0; } }catch(_m){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

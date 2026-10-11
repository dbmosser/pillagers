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

if ($s.Contains("  {v:'22.50',what:")) { throw "check 22.50 is in the fixture already" }

SubRx @'
  {v:'22.49',what:
'@ @'
  {v:'22.50',what:'the pickup stack: searching a crate of three items with X held through the frame loop draws all three names on the right of the screen in one frame after the search, and no feed row names any of them',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__forceSize)) return 'SKIP: this fixture cannot deploy, step the loop or size the screen';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     var bad=[], g=null, p, ct=null, kp=null, i, j, c, oFT=ctx.fillText, ev=[], t0, f=0, KS=['blackbox','reactor','codex'], NM=[], fr=[], hit, r1, drawn;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __forceSize(1920,1080);
       keys={};
       for(i=0;i<KS.length;i++){ if(!ITEMS[KS[i]]) return 'SKIP: no '+KS[i]+' item here'; NM.push(ITEMS[KS[i]].name); }
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       p=g.player; g.ents.length=0; g.waveT=-1e9; g.mapOpen=false; g.bagOpen=false; p.iv=99; p.downed=false;
       if(CFG.raidSec>0&&g.timeLeft<600) g.timeLeft=600;
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c&&!c.opened&&!c.strong&&!c.cache&&!c.dropped&&!c.auto&&!c.mercSrc&&c.loot&&(c.type==='crate'||c.type==='locker')){ ct=c; break; } }
       if(!ct) return 'SKIP: no plain crate on this seed';
       kp={x:ct.x,y:ct.y};
       ct.x=p.x+14; ct.y=p.y; ct.loot=KS.slice(); ct.opened=false; ct.prog=0; ct.pulled=0; ct.time=1.5; ct.hotPaid=1;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[]; g.pick=[];
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       keys['KeyX']=true;
       for(i=0;i<600&&!ct.opened;i++){ __loop(t0+(++f)*16.7); if(__state()!==g||g.over) break; }
       keys={};
       if(!ct.opened) return 'SKIP: staging: holding X beside the crate for 10 s never finished the search (prog '+(+(ct.prog||0)).toFixed(2)+')';
       ctx.fillText=function(t,x){ ev.push({t:String(t),x:+x}); return oFT.apply(this,arguments); };
       try{ __loop(t0+(++f)*16.7); } finally { unspy(); }
       for(i=0;i<NM.length;i++){
         hit=null; for(j=0;j<ev.length;j++) if(ev[j].t.indexOf(NM[i])>=0&&ev[j].x>0.6*W){ hit=ev[j]; break; }
         if(!hit){
           drawn=ev.filter(function(e){ return e.t.indexOf(NM[i])>=0; }).map(function(e){ return Math.round(e.x); });
           bad.push(NM[i]+' is not drawn on the right of the screen in the frame after the search'+(drawn.length?' (drawn at x '+drawn.join(',')+' of '+W+')':' (not drawn at all)'));
         }
       }
       if(g.msg&&g.msgT>0) fr.push(String(g.msg)+' '+(g.msgSub||''));
       r1=g.feed&&g.feed[1]; if(r1&&r1.T>0&&r1.m) fr.push(String(r1.m)+' '+(r1.sub||''));
       for(i=0;i<NM.length;i++) for(j=0;j<fr.length;j++) if(fr[j].indexOf(NM[i])>=0) bad.push('a feed row names '+NM[i]+': '+fr[j]);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); keys={};
       try{ if(ct&&kp){ ct.x=kp.x; ct.y=kp.y; } }catch(_k){}
       try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_f){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

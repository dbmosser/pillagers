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

if ($s.Contains("  {v:'22.59',what:")) { throw "check 22.59 is in the fixture already" }

SubRx @'
  {v:'22.58',what:
'@ @'
  {v:'22.59',what:'backpack full is one red row: with a controller connected, E held for 3 s beside a crate on a full backpack draws exactly one BACKPACK FULL row in the pickup stack, and no line said names the Z key',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy or step the loop';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     if(typeof pollPad!=='function'||typeof PAD==='undefined'||typeof bagWeight!=='function'||typeof padOn!=='function') return 'SKIP: no controller or backpack weight here';
     var bad=[], g=null, p, ct=null, kp=null, i, c, t0, f=0, oFT=ctx.fillText, ev=[], NG=navigator.getGamepads, ownNG=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),
         padK={}, pk, keepAuto=P.autoloot, keepBW=bagWeight, nBF=0, nRow=0, lg, s, zs=[], BF=['BACKPACK','FULL'].join(' ');
     function pad(){ var b=[], n; for(n=0;n<17;n++) b.push({pressed:false,value:0,touched:false}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
     padK.prev=(PAD.prev||[]).slice(); if(PAD.held){ padK.held={}; for(pk in PAD.held) padK.held[pk]=PAD.held[pk]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       p=g.player; g.ents.length=0; g.waveT=-1e9; g.mapOpen=false; g.bagOpen=false; p.iv=99; p.downed=false;
       if(CFG.raidSec>0&&g.timeLeft<600) g.timeLeft=600;
       for(i=0;i<g.zones.length;i++) if(Math.hypot(p.x-g.zones[i].x,p.y-g.zones[i].y)<(g.zones[i].r||0)+40) return 'SKIP: staging: he landed in an extraction ring, where E calls for extraction';
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c&&!c.opened&&!c.strong&&!c.cache&&!c.dropped&&!c.auto&&!c.mercSrc&&c.loot&&(c.type==='crate'||c.type==='locker')){ ct=c; break; } }
       if(!ct) return 'SKIP: no plain crate on this seed';
       kp={x:ct.x,y:ct.y};
       ct.x=p.x+14; ct.y=p.y; ct.loot=['scrap']; ct.opened=false; ct.prog=0; ct.pulled=0; ct.time=5; ct.hotPaid=1;
       P.autoloot=0; bagWeight=function(){ return 1e9; };
       PAD.announced=true; PAD.prev=[]; PAD.held={};
       navigator.getGamepads=pad;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[]; g.pick=[]; g.msgLog=[];
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       keys['KeyE']=true;
       for(i=0;i<180;i++){ keys['KeyE']=true; __loop(t0+(++f)*16.7); if(__state()!==g||g.over) break; }
       if(!padOn()) return 'SKIP: staging: the stub controller did not register';
       keys['KeyE']=true;
       ctx.fillText=function(t){ ev.push(String(t)); return oFT.apply(this,arguments); };
       try{ __loop(t0+(++f)*16.7); } finally { unspy(); }
       keys={};
       for(i=0;i<ev.length;i++) if(ev[i].indexOf(BF)>=0) nBF++;
       for(i=0;i<(g.pick||[]).length;i++) if(String(g.pick[i].m).toUpperCase().indexOf(BF)===0) nRow++;
       if(nBF!==1||nRow!==1) bad.push('E held 3 s on a full backpack draws '+nBF+' BACKPACK FULL lines with '+nRow+' such rows in the pickup stack, not one');
       lg=g.msgLog||[];
       for(i=0;i<lg.length;i++){ s=' '+String(lg[i].m)+' '+String(lg[i].sub||'')+' '; if(s.indexOf(' Z ')>=0||s.indexOf('[Z]')>=0) zs.push(s.trim()); }
       if(zs.length) bad.push('with a controller in hand a line names the Z key: '+zs[0]);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); keys={};
       bagWeight=keepBW; P.autoloot=keepAuto;
       try{ if(ownNG) navigator.getGamepads=NG; else { try{ delete navigator.getGamepads; }catch(_d){} if(navigator.getGamepads!==NG) navigator.getGamepads=NG; } }catch(_n){}
       try{ pollPad(); }catch(_p){}
       try{ for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; }catch(_pk){}
       try{ if(ct&&kp){ ct.x=kp.x; ct.y=kp.y; } }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; g2.searching=null; __endRaid('abandon'); } }catch(_e){}
       keys={};
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'27.44',what:")) { throw "check 27.44 is in the fixture already" }

SubRx @'
  {v:'27.43',what:
'@ @'
  {v:'27.44',what:'feel2g, a cloud review finding (#5): the finisher works on a controller. Y held with a downed pillager in reach finishes him in 0.55 s (a tap does not, a standing pillager is not touched, and it does not swing the crowbar), the prompt names the Y button on a pad and V on a keyboard, and the pad list says so',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof pollPad!=='function'||typeof PAD==='undefined'||typeof finTarget!=='function') return 'SKIP: no raid or pad here';
     var bad=[], g, p, all, rd, X0, Y0, dx=0, dy=0, ok=false, k, ux, uy, i, oCrawl, gp, hadOwn=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), kNG=navigator.getGamepads, kPAD={on:PAD.on,aiming:PAD.aiming,curOwn:PAD.curOwn,brand:PAD.brand,aimA:PAD.aimA}, oMelee, lab, row;
     function mkpad(down){ var bt=[], q, d; for(q=0;q<17;q++){ d=down.indexOf(q)>=0; bt.push({pressed:d,value:d?1:0}); } return {connected:true,id:'Xbox Wireless Controller',index:0,axes:[0,0,0,0],buttons:bt,mapping:'standard'}; }
     function frame(down){ gp=mkpad(down); navigator.getGamepads=function(){ return [gp]; }; pollPad(); g.t+=0.016; __sim(0.016); }
     function down(){ rd.x=X0+dx*30; rd.y=Y0+dy*30; rd.hp=40; rd.maxhp=100; rd.downed=1; rd.finished=0; rd.downT=14; rd.hostile=true; rd.state='down'; rd.getUpOn=1; rd.getUpIn=3; rd.getUp=0; rd.byPlayer=false; rd.crawlTo=null; rd.reviveT=0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); X0=p.x; Y0=p.y; oCrawl=CFG.raiderCrawl; p.iv=99; oMelee=p.meleeAt;
       for(k=0;k<8;k++){ ux=Math.cos(k*0.7854); uy=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ux*80,Y0+uy*80,g.map.segs)){ dx=ux; dy=uy; ok=true; break; } }
       if(!ok) return 'SKIP: staging: no open line from the drop point';
       rd=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC; })[0];
       if(!rd) return 'SKIP: no pillager on this map';
       CFG.raiderCrawl=0; g.ents=[rd]; keys={}; mouse.down=false; PAD.prev=[]; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.wheel=null; g.trade=null;
       frame([]);
       // ONE: Y held on a downed pillager in reach finishes him
       down(); for(i=0;i<20;i++){ down(); frame([3]); }
       if(!(rd.hp>0)||!rd.downed) bad.push('ONE: Y finished him before the 0.55 s hold ran out');
       for(i=0;i<26;i++){ if(!(rd.hp>0)) break; frame([3]); }
       if(rd.hp>0&&rd.downed&&g.ents.indexOf(rd)>=0) bad.push('ONE: holding Y for 0.8 s did not finish a downed pillager');
       frame([]);
       // TWO: a tap does nothing
       down(); for(i=0;i<8;i++){ down(); frame([3]); } frame([]); frame([]);
       if(!(rd.hp>0)||!rd.downed) bad.push('TWO: a short press on Y finished him');
       // THREE: Y held near a standing pillager touches nothing, and the crowbar is not swung
       down(); rd.downed=0; rd.hostile=false; rd.state='patrol'; rd.hp=rd.maxhp=100; p.meleeAt=undefined;
       for(i=0;i<50;i++) frame([3]);
       frame([]);
       if(!(rd.hp>0)) bad.push('THREE: holding Y near a standing pillager hurt him');
       if(p.meleeAt!==undefined) bad.push('THREE: Y swung the crowbar');
       // FOUR: the prompt names the button as bound
       PAD.on=true;
       lab=keyLabel('KeyV','V');
       if(lab!=='Y') bad.push('FOUR: on a pad the finisher is named '+lab+', not Y');
       row=''; for(i=0;i<PAD_ACTS.length;i++) if(PAD_ACTS[i][0]===3) row=String(PAD_ACTS[i][1]);
       if(row.indexOf('finish')<0) bad.push('FOUR: the CHANGE PAD BUTTONS row for Y says "'+row+'"');
       PAD.on=false;
       if(keyLabel('KeyV','V')!=='V') bad.push('FOUR: with no pad the finisher is named '+keyLabel('KeyV','V')+', not V');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(hadOwn) navigator.getGamepads=kNG; else delete navigator.getGamepads; }catch(_n){}
       try{ PAD.prev=[]; PAD.on=kPAD.on; PAD.aiming=kPAD.aiming; PAD.curOwn=kPAD.curOwn; PAD.brand=kPAD.brand; PAD.aimA=kPAD.aimA; if(typeof padRelease==='function') padRelease(); }catch(_p){}
       keys={}; mouse.down=false;
       try{ if(typeof oCrawl!=='undefined') CFG.raiderCrawl=oCrawl; if(g){ if(p) p.meleeAt=oMelee; if(all) g.ents=all.slice(); g.bullets.length=0; g.finT=0; g.finE=null; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

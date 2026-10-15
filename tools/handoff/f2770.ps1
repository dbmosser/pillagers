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

if ($s.Contains("  {v:'27.70',what:")) { throw "check 27.70 is in the fixture already" }

SubRx @'
  {v:'27.69',what:
'@ @'
  {v:'27.70',what:'cloud-menus-pad-prompts-follow-binds: after CHANGE PAD BUTTONS every raid prompt names the button as set (v26.53): the backpack cue, NO HEAL ON BELT, TO DRAW, the swap line and the ring SEARCH; the default layout reads exactly as before',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pbn!=='function'||typeof pollPad!=='function'||typeof PAD==='undefined'||typeof beltStep!=='function'||typeof say!=='function') return 'SKIP: no pad code here';
     var bad=[], g=null, kPM=JSON.stringify(P.padmap||{}), kPV=P.padmapV, hadOwn=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), kNG=navigator.getGamepads,
         kPAD={on:PAD.on,aimA:PAD.aimA,reach:PAD.reach,aiming:PAD.aiming,curOwn:PAD.curOwn,brand:PAD.brand}, oF=ctx.fillText, oS=say, gp, tx=[], subs=[], i, sc, src;
     function mkpad(down){ var bt=[], q, d; for(q=0;q<17;q++){ d=down.indexOf(q)>=0; bt.push({pressed:d,value:d?1:0}); } return {connected:true,id:'Xbox Wireless Controller',index:0,axes:[0,0,0,0],buttons:bt,mapping:'standard'}; }
     function poll(down){ gp=mkpad(down); navigator.getGamepads=function(){ return [gp]; }; pollPad(); }
     function cue(){ tx=[]; ctx.fillText=function(s){ tx.push(String(s)); return oF.apply(this,arguments); }; try{ __frame(0.016); }finally{ ctx.fillText=oF; } return tx.filter(function(s){ return (/BACKPACK$/).test(s); }).join('|'); }
     function draws(){ subs=[]; say=function(m,k,op){ subs.push(String((op&&op.sub)||'')); return oS.apply(this,arguments); }; try{ for(var j=0;j<9;j++) beltStep(1); }finally{ say=oS; } return subs.filter(function(s){ return (/TO DRAW$/).test(s); }); }
     try{
       sc=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).filter(function(t){ return t.indexOf('function pbn'+'(i)')>=0; });
       src=sc.length?sc[0]:'';
       if(!src) bad.push('the game script was not found');
       else {
         if(src.indexOf("padOn()?padB('VIEW"+"  BACKPACK')")>=0) bad.push('a backpack prompt still names VIEW whatever the backpack is on');
         if(src.indexOf("padB('RT"+" TO DRAW')")>=0) bad.push('TO DRAW still names RT whatever fire is on');
         if(src.indexOf("padB('LB"+" or RB to swap')")>=0) bad.push('the swap line still names LB or RB whatever the belt is on');
         if(src.indexOf("padOn())?padB('Y"+"'):keyLabel('KeyE','E')")>=0) bad.push('the ring SEARCH still names Y whatever the ring search is on');
       }
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.player.iv=99; g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false;
       P.padmap={}; if(typeof padLabelsApply==='function') padLabelsApply(); PAD.prev=[]; poll([]); poll([]);
       if(!padOn()) return 'SKIP: the fake controller did not register';
       i=cue(); if(i!=='VIEW  BACKPACK') bad.push('default: the backpack cue reads '+JSON.stringify(i)+', not VIEW  BACKPACK');
       i=draws(); if(!i.length||i.some(function(s){ return s!=='RT TO DRAW'; })) bad.push('default: the belt says '+JSON.stringify(i.slice(0,2))+', not RT TO DRAW');
       if(pbn(4)+' or '+pbn(5)!=='LB or RB'||pbn(3)!=='Y') bad.push('default: the belt and ring buttons read '+pbn(4)+' '+pbn(5)+' '+pbn(3));
       P.padmap={8:3,3:8,7:0,0:7}; if(typeof padLabelsApply==='function') padLabelsApply(); PAD.prev=[]; poll([]); poll([]);
       i=cue(); if(i!=='Y  BACKPACK') bad.push('backpack on Y: the cue reads '+JSON.stringify(i)+', not Y  BACKPACK');
       i=draws(); if(!i.length||i.some(function(s){ return s!=='A TO DRAW'; })) bad.push('fire on A: the belt says '+JSON.stringify(i.slice(0,2))+', not A TO DRAW');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       ctx.fillText=oF; say=oS;
       try{ if(hadOwn) navigator.getGamepads=kNG; else delete navigator.getGamepads; }catch(_n){}
       try{ P.padmap=JSON.parse(kPM); if(kPV===undefined) delete P.padmapV; else P.padmapV=kPV; if(typeof padLabelsApply==='function') padLabelsApply(); }catch(_p){}
       try{ pollPad(); PAD.on=kPAD.on; PAD.aimA=kPAD.aimA; PAD.reach=kPAD.reach; PAD.aiming=kPAD.aiming; PAD.curOwn=kPAD.curOwn; PAD.brand=kPAD.brand; PAD.prev=[]; PAD.announced=false; mouse.down=false; keys={}; }catch(_q){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

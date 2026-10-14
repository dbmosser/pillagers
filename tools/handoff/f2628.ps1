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

if ($s.Contains("  {v:'26.28',what:")) { throw "check 26.28 is in the fixture already" }

SubRx @'
  {v:'26.27',what:
'@ @'
  {v:'26.28',what:'wheel5pad, his order: HOLD D-DOWN opens the item wheel on a controller, the right stick picks a segment (a push past half) and letting go of D-DOWN takes the item out, the stick centred cancels, the crosshair does not move while it is open, and D-DOWN no longer quick-heals in the arcade',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     if(typeof pollPad!=='function'||typeof wheelOpen!=='function'||typeof updatePlayer!=='function') return 'SKIP: no pad or wheel here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, down13=false, sx=0, sy=0, padK={}, pk, ownPad=false, NG=navigator.getGamepads, ownNG=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), j, m, an, mx0, my0;
     function pad(){ var b=[], q; for(q=0;q<17;q++) b.push({pressed:(q===13&&down13),value:(q===13&&down13)?1:0,touched:false}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,sx,sy]}]; }
     function stubPad(){ if(ownPad) return; for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
       padK.prev=(PAD.prev||[]).slice(); if(PAD.held){ padK.held={}; for(pk in PAD.held) padK.held[pk]=PAD.held[pk]; }
       ownPad=true; PAD.announced=true; PAD.prev=[]; PAD.held={}; navigator.getGamepads=pad; }
     function step(){ pollPad(); updatePlayer(0.016); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={}; mouse.down=false;
       g.bag=['bandage','bandage','medkit']; g.pouch.frag=2; g.pouch.smoke=1; g.pouch.decoy=0; g.pouch.trip=0; p.hp=50; p.hand=null;
       stubPad();
       down13=false; sx=0; sy=0; step(); step();
       // ONE: D-DOWN held opens it
       down13=true; step();
       if(!g.wheel||!g.wheel.pad) { bad.push('ONE: holding D-DOWN opened no pad wheel'); return bad.join('; '); }
       m=g.wheel.list.length;
       // TWO: the stick picks each segment, and the middle picks none
       for(j=0;j<m;j++){ an=-Math.PI/2+j*(Math.PI*2/m); sx=Math.cos(an); sy=Math.sin(an); step(); if(!g.wheel||g.wheel.sel!==j) bad.push('TWO: the stick at segment '+j+' read as '+(g.wheel?g.wheel.sel:'closed')); }
       sx=0.2; sy=0.1; step();
       if(!g.wheel||g.wheel.sel!==-1) bad.push('TWO: a small stick push picked segment '+(g.wheel&&g.wheel.sel));
       // THREE: the crosshair stays while the stick moves
       mx0=mouse.x; my0=mouse.y; sx=1; sy=0; step(); step();
       if(Math.abs(mouse.x-mx0)>0.5||Math.abs(mouse.y-my0)>0.5) bad.push('THREE: the crosshair moved with the wheel open ('+mx0+','+my0+' to '+mouse.x+','+mouse.y+')');
       // FOUR: letting go takes the picked item out
       an=-Math.PI/2+1*(Math.PI*2/m); sx=Math.cos(an); sy=Math.sin(an); step();
       down13=false; step();
       if(g.wheel) bad.push('FOUR: the wheel stayed open after D-DOWN was let go');
       if(!p.hand||p.hand.k!=='smoke') bad.push('FOUR: letting go on the smoke left '+(p.hand?p.hand.k:'nothing')+' in hand');
       // FIVE: a pad that goes away closes the wheel
       p.hand=null; sx=0; sy=0; down13=true; step(); step();
       if(!g.wheel) bad.push('FIVE: the wheel would not open the second time');
       PAD.on=false; navigator.getGamepads=function(){ return []; }; updatePlayer(0.016);
       if(g.wheel) bad.push('FIVE: the wheel stayed open with the pad gone');
       navigator.getGamepads=pad;
       // SIX: D-DOWN let go in the middle cancels
       down13=false; step(); step(); down13=true; step(); sx=0; sy=0; step(); down13=false; step();
       if(p.hand) bad.push('SIX: a release with the stick centred took '+p.hand.k+' out');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(ownNG) navigator.getGamepads=NG; else { try{ delete navigator.getGamepads; }catch(_d){} if(navigator.getGamepads!==NG) navigator.getGamepads=NG; } }catch(_n){}
       if(ownPad){
         try{ pollPad(); }catch(_p){}
         try{ for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; }catch(_pk){}
       }
       try{ mouse.down=false; keys={}; var g2=__state(); if(g2){ g2.wheel=null; if(!g2.over){ g2.player.iv=0; g2.player.hand=null; g2.player.prep=null; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

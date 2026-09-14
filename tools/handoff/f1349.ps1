$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'13.48',what:
'@ @'
  {v:'13.49',what:'on a controller the Peddler stall trades: D-pad down moves a marker to his first item, A buys the marked item, and X walks away as the stall prompt says, while the keyboard number keys still buy (audit item 5, 2026-09-13)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof mkPeddler!=='function'||typeof pedBuy!=='function'||typeof raidKey!=='function') return 'SKIP: no pad poll or Peddler in this build';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, P2=__P(), keepCr=P2.credits;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padWith(down){
       var bts=[],i;
       for(i=0;i<16;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     function tap(b){ padWith(b); pollPad(); padWith(-1); pollPad(); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; p.downed=false; p.iv=99;
       var pd=mkPeddler(p.x+40,p.y,g.map);
       pd.stock=[{k:'medkit',price:20,sold:false},{k:'bandage',price:10,sold:false}];
       padWith(-1); pollPad();
       g.trade=pd; g.pedSel=0; P2.credits=5000; g.bag=[];
       tap(13);
       if((g.pedSel||0)!==1) bad.push('D-pad down on the open stall did not move the marker to his first item (marker '+g.pedSel+')');
       tap(0);
       if(!pd.stock[0].sold) bad.push('A on the marked first item did not buy it');
       if(!g.trade) bad.push('A closed the stall instead of buying');
       tap(2);
       if(g.trade) bad.push('X on the open stall did not walk away, while the stall prompt names X for it');
       // CONTROL: the keyboard number key still buys, so the zeros above are the pad.
       g.trade=pd; P2.credits=5000;
       raidKey('Digit3',false,null);
       if(!pd.stock[1].sold) bad.push('control: the keyboard 3 no longer buys his second item');
       g.trade=null;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var g3=__state(); if(g3){ g3.trade=null; if(g3.player){ g3.player.iv=0; g3.player.downed=false; } if(!g3.over) __endRaid('abandon'); } }catch(_e){}
       try{ P2.credits=keepCr; }catch(_c0){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

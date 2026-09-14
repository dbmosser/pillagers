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
  {v:'14.18',what:
'@ @'
  {v:'14.19',what:'the stall reads real presses on a pad: X held from raid frames into a stall that just opened sends no E, and A held to fire into a stall takes no row, while X let go and pressed again in the stall still sends E (controller audit finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof mkPeddler!=='function'||typeof raidKey!=='function'||typeof PAD==='undefined') return 'SKIP: no pad poll or Peddler in this build';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, sent=[], _rk=raidKey;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padWith(down){
       var bts=[],i;
       for(i=0;i<16;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     var rows=function(){ return sent.filter(function(c){ return /^Digit/.test(c); }); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.containers.length=0; p.downed=false; p.iv=99;
       var pd=mkPeddler(p.x+40,p.y,g.map);
       if(g.ents.indexOf(pd)<0) g.ents.push(pd);
       g.trade=null; PAD.xAfterTrade=0;
       padWith(-1); pollPad();
       var K=__keysRef(); for(var k0 in K) K[k0]=false;
       raidKey=function(c){ sent.push(String(c)); };
       // ARM 1: the Undercroft left X and A recorded as up. X is held through three raid frames, then the stall opens.
       PAD.prev[2]=false; PAD.prev[0]=false;
       padWith(2); pollPad(); pollPad(); pollPad();
       sent.length=0; g.trade=pd; g.pedLock=0; g.pedSel=0;
       pollPad();
       if(sent.indexOf('KeyE')>=0) bad.push('X held from the raid into the stall that just opened read as a fresh press and sent E, which shuts the stall');
       // ARM 2: a stall closed with A up. A is held to fire through three raid frames, then a stall opens.
       g.trade=null; PAD.xAfterTrade=0; padWith(-1); pollPad(); pollPad();
       PAD.prev[0]=false;
       padWith(0); pollPad(); pollPad(); pollPad();
       sent.length=0; g.trade=pd; g.pedLock=0; g.pedSel=0;
       pollPad();
       if(rows().length) bad.push('A held from the raid into the stall read as a fresh press and took row '+rows().join(',')+', which starts on SELL BACKPACK');
       // CONTROL: in the open stall, X let go and pressed again still sends E.
       padWith(-1); pollPad();
       sent.length=0; padWith(2); pollPad();
       if(sent.indexOf('KeyE')<0) bad.push('control: a fresh X in the open stall sent no E ('+sent.join(',')+'), so this check cannot see a press');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       raidKey=_rk;
       try{ var g2=__state(); if(g2) g2.trade=null; PAD.xAfterTrade=0; }catch(_t){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var g3=__state(); if(g3){ if(g3.player){ g3.player.iv=0; g3.player.downed=false; } if(!g3.over) __endRaid('abandon'); } }catch(_e){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

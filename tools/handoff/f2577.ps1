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

if ($s.Contains("  {v:'25.77',what:")) { throw "check 25.77 is in the fixture already" }

SubRx @'
  {v:'25.76',what:
'@ @'
  {v:'25.77',what:'his order (middle mouse = ping / mark): the middle button is an action on the rebind list, claimed in a raid, and alone it opens and closes the V signal strip as V does, in a party it makes the ping the N key makes, V still works, and the action can be rebound to a key',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof keysBind!=='function'||typeof raidKey!=='function'||typeof netPingMake!=='function'||typeof KEYS_ACTS==='undefined'||typeof NET==='undefined') return 'SKIP: this fixture cannot stage the middle button';
     var bad=[], g=null, p=null, km0=null, kmv0, kPing=netPingMake, kOn=NET.on, calls=0, me;
     function dn(code){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }
     function upk(code){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }
     function mdn(b){ var ev=new MouseEvent('mousedown',{button:b,bubbles:true,cancelable:true}); window.dispatchEvent(ev); return ev; }
     function mup(b){ window.dispatchEvent(new MouseEvent('mouseup',{button:b,bubbles:true,cancelable:true})); }
     function clr(){ for(var z in keys) keys[z]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       km0=P.keymap?JSON.parse(JSON.stringify(P.keymap)):null; kmv0=P.keymapV;
       P.keymap={}; KEYS.inv=null; keysInv();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       g.paused=false; g.trade=null; p.downed=false; p.dying=false; p.roll=0; p.iv=99; g.emoteBar=false; clr(); NET.on=false;
       // 1. on the rebind list, and named
       if(!KEYS_ACTS.some(function(a){ return a[0]==='Mouse1'; })) bad.push('the middle button is not on the rebind list');
       if(keyName('Mouse1')!=='MIDDLE MOUSE') bad.push('the middle button is named '+keyName('Mouse1'));
       // 2. V opens and closes the signal strip (the control)
       dn('KeyV'); upk('KeyV');
       if(!g.emoteBar) bad.push('V did not open the signal strip here');
       dn('KeyV'); upk('KeyV');
       if(g.emoteBar) bad.push('V did not close the signal strip');
       // 3. alone, the middle button does what V does, and its press is claimed (no browser autoscroll)
       me=mdn(1); mup(1);
       if(!me.defaultPrevented) bad.push('the middle press in a raid was not claimed');
       if(!g.emoteBar) bad.push('the middle button opened no signal strip');
       mdn(1); mup(1);
       if(g.emoteBar) bad.push('a second middle press did not close the signal strip');
       // 4. in a party, it makes the ping the N key makes, and opens no strip
       NET.on=true; netPingMake=function(){ calls++; return null; };
       g.emoteBar=false; raidKey('Mouse1',false,null); keys['Mouse1']=false;
       if(calls!==1) bad.push('in a party the middle button made '+calls+' pings, not one');
       if(g.emoteBar) bad.push('in a party the middle button also opened the signal strip');
       netPingMake=kPing; NET.on=false;
       // 5. rebound to J, J does it and the list says so
       if(!keysBind('Mouse1','KeyJ')) bad.push('the middle button action could not be rebound');
       if(keysOf('Mouse1')!=='KeyJ') bad.push('the action reads '+keysOf('Mouse1')+' after being put on J');
       g.emoteBar=false; dn('KeyJ'); upk('KeyJ');
       if(!g.emoteBar) bad.push('after the action was put on J, J did not open the signal strip');
       g.emoteBar=false; keysReset();
       if(keysOf('Mouse1')!=='Mouse1') bad.push('RESET TO DEFAULTS left the middle button action on '+keysOf('Mouse1'));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ netPingMake=kPing; NET.on=kOn; }catch(_n){}
       try{ if(km0) P.keymap=km0; else P.keymap={}; P.keymapV=kmv0; KEYS.inv=null; keysInv(); keysLegendApply(); }catch(_k){}
       try{ clr(); }catch(_c){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.emoteBar=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'25.83',what:")) { throw "check 25.83 is in the fixture already" }

SubRx @'
  {v:'25.82',what:
'@ @'
  {v:'25.83',what:'his order (get rid of the emote system): no emote function, list, bubble, strip or cooldown is left; V opens nothing, is not on the keys list and a saved key map that moved it leaves no key dead; the belt caption offers no signal; the middle button, claimed in a raid, makes the ping in a party and nothing alone, and opens no strip',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof keysBind!=='function'||typeof raidKey!=='function'||typeof netPingMake!=='function'||typeof KEYS_ACTS==='undefined'||typeof NET==='undefined'||typeof drawHUD!=='function') return 'SKIP: this fixture cannot stage the middle button';
     var EB='emote'+'Bar', bad=[], g=null, p=null, km0=null, kmv0, kPing=netPingMake, kOn=NET.on, calls=0, me, i, src, nd, rec=[], proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText;
     function dn(code){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }
     function upk(code){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }
     function mdn(b){ var ev=new MouseEvent('mousedown',{button:b,bubbles:true,cancelable:true}); window.dispatchEvent(ev); return ev; }
     function mup(b){ window.dispatchEvent(new MouseEvent('mouseup',{button:b,bubbles:true,cancelable:true})); }
     function clr(){ for(var z in keys) keys[z]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       km0=P.keymap?JSON.parse(JSON.stringify(P.keymap)):null; kmv0=P.keymapV;
       P.keymap={}; KEYS.inv=null; keysInv();
       // 1. nothing of the emote system is left in the page
       if(typeof doEmote!=='undefined') bad.push('doEmote is still in the game');
       if(typeof EMOTES!=='undefined') bad.push('the EMOTES list is still in the game');
       if(typeof emoteBubble!=='undefined') bad.push('emoteBubble is still in the game');
       if(typeof weaponDown!=='undefined') bad.push('weaponDown (the hail test) is still in the game');
       if(typeof emoteStripY!=='undefined') bad.push('emoteStripY is still in the game');
       src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       nd=['function doEmo'+'te(','var EMO'+'TES=','function emote'+'Bubble(','function emoteStrip'+'Y(','G.bub'+'bles'];
       for(i=0;i<nd.length;i++) if(src.indexOf(nd[i])>=0) bad.push('the page still holds '+nd[i]);
       if(KEYS_ACTS.some(function(a){ return a[0]==='KeyV'; })) bad.push('V is still an action on the keys list');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return bad.length?bad.join('; '):'SKIP: no live raid';
       g.paused=false; g.trade=null; g.bagOpen=false; g.mapOpen=false; p.downed=false; p.dying=false; p.roll=0; p.iv=99; clr(); NET.on=false; delete g[EB];
       // 2. V and the strip's number row do nothing; the belt caption offers no signal
       dn('KeyV'); upk('KeyV'); dn('Digit1'); upk('Digit1');
       if(g[EB]) bad.push('V opened a strip');
       proto.fillText=function(s){ rec.push(String(s)); return oFT.apply(this,arguments); };
       try{ drawHUD(); } finally { proto.fillText=oFT; }
       if(rec.some(function(s){ return /signal/i.test(s)||/lower your weapon first/i.test(s); })) bad.push('the HUD still draws a signal line or the strip caption');
       // 3. the middle button: claimed, opens no strip alone, makes the ping in a party
       me=mdn(1); mup(1);
       if(!me.defaultPrevented) bad.push('the middle press in a raid was not claimed');
       if(g[EB]) bad.push('the middle button opened a strip');
       NET.on=true; netPingMake=function(){ calls++; return null; };
       raidKey('Mouse1',false,null); keys['Mouse1']=false;
       if(calls!==1) bad.push('in a party the middle button made '+calls+' pings, not one');
       if(g[EB]) bad.push('in a party the middle button opened a strip');
       netPingMake=kPing; NET.on=false;
       // 4. a saved key map from the days V was an action leaves no key dead
       P.keymap={KeyV:'KeyJ'}; KEYS.inv=null; keysInv();
       if(keyRemap('KeyJ')!=='KeyJ') bad.push('an old map that put the V action on J still turns J into '+keyRemap('KeyJ'));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oFT; }catch(_f){}
       try{ netPingMake=kPing; NET.on=kOn; }catch(_n){}
       try{ if(km0) P.keymap=km0; else P.keymap={}; P.keymapV=kmv0; KEYS.inv=null; keysInv(); keysLegendApply(); }catch(_k){}
       try{ clr(); }catch(_c){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

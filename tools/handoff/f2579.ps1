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

if ($s.Contains("  {v:'25.79',what:")) { throw "check 25.79 is in the fixture already" }

SubRx @'
  {v:'25.78',what:
'@ @'
  {v:'25.79',what:'his order (hold ALT for the raid status): ALT is an action on the rebind list; while it is held a plate headed RAID STATUS shows the CURRENT PILLAGERS board with YOU, the score or haul and credits (CAREER SCORE in a career raid), the raid clock, the extraction and the nearest ring; its press and release are claimed so the page keeps the focus; letting go removes it; it stays off while the backpack is open; and the status key can be moved to another key',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function'||typeof KEYS_ACTS==='undefined'||typeof keysBind!=='function') return 'SKIP: this fixture cannot stage the raid status';
     var bad=[], g=null, p=null, km0=null, kmv0, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, rec=[], on0, ev, car0, cs0, bag0, i, lines;
     function rec0(){ rec=[]; proto.fillText=function(s){ rec.push(String(s)); return oFT.apply(this,arguments); }; }
     function hud(){ rec0(); try{ drawHUD(); } finally { proto.fillText=oFT; } }
     function has(re){ for(var j=0;j<rec.length;j++) if(re.test(rec[j])) return true; return false; }
     function inL(re){ var L=(typeof RSTAT==='object'&&RSTAT&&RSTAT.lines)||[]; for(var j=0;j<L.length;j++) if(re.test(L[j])) return true; return false; }
     function kev(type,code,key,alt){ var e=new KeyboardEvent(type,{code:code,key:key||code,altKey:!!alt,bubbles:true,cancelable:true}); window.dispatchEvent(e); return e; }
     function clr(){ for(var z in keys) keys[z]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       km0=P.keymap?JSON.parse(JSON.stringify(P.keymap)):null; kmv0=P.keymapV;
       P.keymap={}; KEYS.inv=null; keysInv();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       if(g.arcade) return 'SKIP: an arcade raid has no pillagers board';
       g.paused=false; g.trade=null; g.bagOpen=false; g.mapOpen=false; p.downed=false; p.dying=false; p.iv=99; clr();
       car0=g.career; cs0=g.cs; bag0=g.bag.slice();
       // 1. the key is on the rebind list, named ALT
       if(!KEYS_ACTS.some(function(a){ return a[0]==='AltLeft'; })) bad.push('ALT is not on the rebind list');
       if(keyName('AltLeft')!=='ALT') bad.push('the key is named '+keyName('AltLeft'));
       // 2. nothing before the key
       hud();
       if(typeof RSTAT==='object'&&RSTAT&&RSTAT.on) bad.push('the raid status was up with no key held');
       if(has(/^RAID STATUS$/)) bad.push('RAID STATUS was drawn with no key held');
       // 3. ALT down: claimed, and the plate is drawn with the board, the haul, the clock and the extraction
       ev=kev('keydown','AltLeft','Alt',true);
       if(!ev.defaultPrevented) bad.push('the ALT press was not claimed (the browser would take the menu focus)');
       if(!keys['AltLeft']) bad.push('the ALT press set no key');
       g.bag.length=0; g.bag.push('scrap');
       hud();
       if(!has(/^RAID STATUS$/)) bad.push('holding ALT drew no RAID STATUS plate');
       if(!has(/^CURRENT PILLAGERS\s+\d+$/)) bad.push('the plate drew no CURRENT PILLAGERS board');
       if(!has(/^YOU$/)) bad.push('the board on the plate has no YOU row');
       if(!has(/^CARRIED$/)||!has(/^\$[\d,]+$/)) bad.push('the plate drew no haul');
       if(!has(/^CREDITS \$/)) bad.push('the plate drew no credits');
       if(!has(/^(RAID CLOCK|RAID TIME)$/)||!has(/^\d+:\d\d$/)) bad.push('the plate drew no clock');
       if(!has(/^EXTRACTION$/)) bad.push('the plate drew no extraction tile');
       if(!has(/^NEAREST /)&&!has(/^ALL CLOSED$/)&&!has(/^EXTRACTION [A-Z?]? ?(INBOUND|AVAILABLE|CLOSED)/)) bad.push('the extraction tile named neither a nearest ring nor a state');
       if(typeof RSTAT==='object'&&RSTAT&&!RSTAT.on) bad.push('RSTAT.on was not set while ALT is held');
       // 4. in a career raid the score reads CAREER SCORE with the credits
       g.career=true; g.cs={s:1234};
       hud();
       if(!inL(/^CAREER SCORE$/)||!inL(/^\$1,234$/)) bad.push('a career raid drew no CAREER SCORE of $1,234 on the plate ('+((typeof RSTAT==='object'&&RSTAT&&RSTAT.lines)||[]).slice(0,8).join(' | ')+')');
       g.career=car0; g.cs=cs0;
       // 5. the backpack open: nothing
       g.bagOpen=true; hud(); g.bagOpen=false;
       if(has(/^RAID STATUS$/)) bad.push('the plate was drawn over the open backpack');
       // 6. ALT up: claimed, and the plate is gone
       ev=kev('keyup','AltLeft','Alt',false);
       if(!ev.defaultPrevented) bad.push('the ALT release was not claimed');
       if(keys['AltLeft']) bad.push('the ALT release left the key down');
       hud();
       if(has(/^RAID STATUS$/)) bad.push('the plate stayed up after ALT was let go');
       if(typeof RSTAT==='object'&&RSTAT&&RSTAT.on) bad.push('RSTAT.on stayed set after ALT was let go');
       // 7. rebound to J, J shows it and ALT does not
       if(!keysBind('AltLeft','KeyJ')) bad.push('the status key could not be rebound');
       kev('keydown','KeyJ','j',false); hud();
       if(!has(/^RAID STATUS$/)) bad.push('with the status key on J, holding J drew no plate');
       kev('keyup','KeyJ','j',false); clr(); hud();
       if(has(/^RAID STATUS$/)) bad.push('the plate stayed up after J was let go');
       keysReset();
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oFT; }catch(_f){}
       try{ if(g){ g.career=car0; g.cs=cs0; g.bagOpen=false; if(bag0) g.bag=bag0; } }catch(_g){}
       try{ if(km0) P.keymap=km0; else P.keymap={}; P.keymapV=kmv0; KEYS.inv=null; keysInv(); keysLegendApply(); }catch(_k){}
       try{ clr(); }catch(_c){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

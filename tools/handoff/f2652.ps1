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

if ($s.Contains("  {v:'26.52',what:")) { throw "check 26.52 is in the fixture already" }

SubRx @'
  {v:'26.51',what:
'@ @'
  {v:'26.52',what:'settings11, his order 2026-10-14: the Keys window covers every key the raid answers: H (heal, armour plate), CAPS LOCK (auto-jog), the HUD size pair, the zoom pair and the zoom reset are on the list, in sections with no OTHER heap, the locked keys (1 to 9, P, TAB, ESC, BACKSPACE, the key left of 1, F11) are listed, no key the raid code reads is left off the list (a scan of the code), and a bind onto a new one works and swaps',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof KEYS_ACTS==='undefined'||typeof keysListBody!=='function'||typeof raidKey!=='function'||typeof keysBind!=='function'||typeof keyRemap!=='function') return 'SKIP: no key map here';
     if(typeof keysFixedHtml!=='function') return 'the Keys window lists no locked keys and misses keys the raid answers';
     var bad=[], acts={}, i, m, h, src, c, re, seen={}, k, km0=JSON.stringify(P.keymap||{}), kv0=P.keymapV, g=null, press, rel,
         WANT=['KeyW','KeyA','KeyS','KeyD','Space','ShiftLeft','ControlLeft','KeyC','KeyE','KeyR','KeyQ','KeyV','KeyF','KeyX','KeyB','KeyI','Enter','KeyM','F1','KeyT','KeyN','Mouse1','KeyZ','KeyO','AltLeft','KeyH','CapsLock','Equal','Minus','NumpadAdd','NumpadSubtract','Digit0'],
         EXEMPT={KeyG:1,KeyU:1,KeyJ:1,NumpadEnter:1,Numpad0:1,ControlRight:1,ShiftRight:1,ArrowUp:1,ArrowDown:1,ArrowLeft:1,ArrowRight:1,PadX:1,PadSearch:1,Backquote:1};
     KEYS_ACTS.forEach(function(a){ acts[a[0]]=1; });
     function kd(code){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }
     function ku(code){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }
     try{
       // ONE: the list names every key
       for(i=0;i<WANT.length;i++) if(!acts[WANT[i]]) bad.push('ONE: '+WANT[i]+' is not on the Keys list');
       h=keysListBody();
       if(/class="keysec">OTHER</.test(h)) bad.push('ONE: a key is left in an OTHER heap');
       for(i=0;i<WANT.length;i++) if(h.indexOf('data-k="'+WANT[i]+'"')<0) bad.push('ONE: the Keys window draws no row for '+WANT[i]);
       if(h.indexOf('1 - 9')<0||h.indexOf('keyfixed')<0||h.indexOf('BACKSPACE')<0) bad.push('ONE: the locked keys are not listed');
       // TWO: no key the raid reads is left off (a scan of the code that reads keys)
       src=String(raidKey)+String(holdHTick)+String(updatePlayer);
       re=/code===?'([A-Za-z0-9]+)'/g; while((m=re.exec(src))) seen[m[1]]=1;
       re=/keys\['([A-Za-z0-9]+)'\]/g; while((m=re.exec(src))) seen[m[1]]=1;
       for(k in seen){ if(acts[k]||KEYS_FIXED[k]||/^Digit[1-9]$/.test(k)||EXEMPT[k]) continue; bad.push('TWO: the raid code reads '+k+' and it is not on the Keys list'); }
       // THREE: a bind onto a new action works and swaps, in a live raid
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: staging: no live raid';
       P.keymap={}; KEYS.inv=null; keysInv();
       if(!keysBind('KeyH','KeyY')) bad.push('THREE: H would not bind to Y');
       if(keyRemap('KeyY')!=='KeyH') bad.push('THREE: Y does not read as H after the bind');
       keys={}; kd('KeyY'); if(!keys['KeyH']) bad.push('THREE: pressing Y did not press H'); ku('KeyY'); if(keys['KeyH']) bad.push('THREE: letting go of Y left H down'); try{ HHOLD.arm=0; }catch(_h){}
       if(!keysBind('CapsLock','KeyY')) bad.push('THREE: Caps Lock would not bind to Y');
       if(keyRemap('KeyY')!=='CapsLock') bad.push('THREE: Y does not read as Caps Lock after the clash ('+keyRemap('KeyY')+')');
       if(keyRemap('CapsLock')!=='KeyH') bad.push('THREE: the clash did not swap: Caps Lock now reads as '+keyRemap('CapsLock')+', not H');
       keys={}; kd('KeyY'); if(!keys['CapsLock']) bad.push('THREE: pressing Y did not press Caps Lock'); ku('KeyY');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keys={}; HHOLD.arm=0; P.keymap=JSON.parse(km0); P.keymapV=kv0; KEYS.inv=null; keysInv(); try{ saveProfile(); }catch(_s){} }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

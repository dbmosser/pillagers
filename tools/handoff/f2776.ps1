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

if ($s.Contains("  {v:'27.76',what:")) { throw "check 27.76 is in the fixture already" }

SubRx @'
  {v:'27.75',what:
'@ @'
  {v:'27.76',what:'cloud-menus-tab-closes-keys: TAB does what ESC does in the Keys and Pad buttons windows: it cancels a waiting press, else it shuts the window',
   run:function(){
     if(typeof keysOpen!=='function'||typeof KEYS==='undefined'||typeof PADB==='undefined'||!KEYS_ACTS||!KEYS_ACTS.length) return 'SKIP: this fixture has no Keys window';
     var bad=[], P2=__P(), km0=JSON.stringify(P2.keymap===undefined?null:P2.keymap), kv0=P2.keymapV, pm0=JSON.stringify(P2.padmap===undefined?null:P2.padmap), m;
     function key(c){ document.body.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:c,bubbles:true,cancelable:true})); document.body.dispatchEvent(new KeyboardEvent('keyup',{code:c,key:c,bubbles:true,cancelable:true})); }
     function on(){ m=document.getElementById('keysmodal'); return !!(m&&m.classList.contains('on')); }
     try{
       __topClear(); __runPrep();
       keysOpen(false);
       if(!on()) return 'SKIP: the Keys window did not open';
       key('Tab'); if(on()) bad.push('TAB left the Keys window open');
       keysOpen(false); KEYS.waiting=KEYS_ACTS[0][0];
       key('Tab');
       if(KEYS.waiting) bad.push('TAB did not cancel a waiting key press');
       else if(!on()) bad.push('TAB with a key press waiting shut the whole Keys window instead of only cancelling the wait');
       if(KEYS.waiting===null&&on()){ key('Tab'); if(on()) bad.push('the second TAB left the Keys window open'); }
       keysOpen(true);
       if(!on()) return 'SKIP: the Pad buttons window did not open';
       PADB.waiting=0;
       key('Tab');
       if(PADB.waiting!==null) bad.push('TAB did not cancel a waiting pad button');
       else if(!on()) bad.push('TAB with a pad button waiting shut the whole Pad buttons window instead of only cancelling the wait');
       if(PADB.waiting===null&&on()){ key('Tab'); if(on()) bad.push('TAB left the Pad buttons window open'); }
       if(JSON.stringify(P2.keymap===undefined?null:P2.keymap)!==km0) bad.push('TAB changed a key binding');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ KEYS.waiting=null; KEYS.note=null; PADB.waiting=null; PADB.armed=0; PADB.note=null; KEYS.pad=false; }catch(_k){}
       try{ if(m) m.classList.remove('on'); }catch(_m){}
       try{ var _k0=JSON.parse(km0); if(_k0===null) delete P2.keymap; else P2.keymap=_k0; if(kv0===undefined) delete P2.keymapV; else P2.keymapV=kv0; var _p0=JSON.parse(pm0); if(_p0===null) delete P2.padmap; else P2.padmap=_p0; }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'21.99',what:")) { throw "check 21.99 is in the fixture already" }

SubRx @'
  {v:'21.98',what:
'@ @'
  {v:'21.99',what:'ESC on the Keys window opened over the pause box cancels a waiting press or shuts the Keys window only: the pause box stays up with the raid paused, and a player 2 window hands none of those keys to player 1',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof keysOpen!=='function'||typeof togglePauseBox!=='function'||typeof KEYS!=='object'||!KEYS||typeof KEYS_ACTS==='undefined'||!KEYS_ACTS.length||typeof NET!=='object'||!NET||typeof netSamePost!=='function') return 'SKIP: no raid or Keys window here';
     if(typeof SAVE_STALE!=='undefined'&&SAVE_STALE) return 'SKIP: this tab holds a stale save, and ESC would reload it';
     var NK={}, k, bad=[], g, m, pb, oPost=netSamePost, posts=[], km0, act=KEYS_ACTS[KEYS_ACTS.length-1][0];
     function press(code){ var ev=new KeyboardEvent('keydown',{code:code,key:(code==='Escape'?'Escape':'j'),bubbles:true,cancelable:true}); window.dispatchEvent(ev); return ev; }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[]; NET.same=null;
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       km0=JSON.stringify(P.keymap||{});
       togglePauseBox(true);
       pb=document.getElementById('pausebox');
       if(!pb||!pb.classList.contains('on')||!g.paused) return 'SKIP: staging: the pause box did not open';
       keysOpen(); m=document.getElementById('keysmodal');
       if(!m||!m.classList.contains('on')) return 'SKIP: staging: the Keys window did not open';
       KEYS.waiting=act;
       press('Escape');
       if(KEYS.waiting) bad.push('ESC did not cancel the waiting press');
       if(!m.classList.contains('on')) bad.push('ESC on a waiting press shut the whole Keys window');
       if(!pb.classList.contains('on')||!pauseOpen) bad.push('ESC on a waiting press shut the pause box');
       if(!pb.classList.contains('on')) togglePauseBox(true);
       if(!m.classList.contains('on')) keysOpen();
       KEYS.waiting=null;
       press('Escape');
       if(m.classList.contains('on')) bad.push('ESC did not shut the Keys window');
       if(!pb.classList.contains('on')||!pauseOpen) bad.push('ESC on the Keys window shut the pause box too');
       if(!g.paused) bad.push('the raid ran again behind the Keys window');
       if(!pb.classList.contains('on')) togglePauseBox(true);
       keysOpen();
       NET.same='p2'; NET.pair='keys-chk-7731'; netSamePost=function(q){ posts.push(q); return true; };
       press('KeyJ');
       if(posts.length) bad.push('in a player 2 window a key pressed on the Keys window went on to player 1 ('+posts.length+' words)');
       if(JSON.stringify(P.keymap||{})!==km0) bad.push('a key binding changed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSamePost=oPost;
       try{ if(typeof netKeyHeld==='object'&&netKeyHeld) delete netKeyHeld.KeyJ; }catch(_h){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ KEYS.waiting=null; var m2=document.getElementById('keysmodal'); if(m2) m2.classList.remove('on'); }catch(_m){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

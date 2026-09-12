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

# v12.99 CHECK, inserted before the v12.98 entry.
#
# IT DISPATCHES ON THE BOX, not on window, and that is the point rather than a
# convenience: the handler under test is a CAPTURE listener on the document, so it
# sees an event aimed at the box on the way down, exactly as a real keypress in a
# focused input arrives. Dispatching on window would never travel through the
# document to the input and would prove nothing about the real path.
#
# BOTH HALVES ARE REQUIRED. The box must go, and the window must STAY: closing both
# is the defect with one extra step, not a fix.
#
# THE CONTROL IS ESCAPE WITH NO BOX, which must still close the front window. The
# whole point of that handler is that a window owns Escape, and a guard placed at the
# top of it is exactly where that could be taken away.
SubRx @'
  {v:'12.98',what:'THE LAST POUR shows the one bonus it actually pays
'@ @'
  {v:'12.99',what:'ESC out of an edit box closes the edit box and leaves the window it was opened over standing, rather than shutting that window and leaving the box over the game holding the keyboard, while ESC with no box open still closes the front window (audit finding 14, 2026-09-11)',
   run:function(){
     if(typeof txOpen!=='function'||typeof txClose!=='function'||typeof TXBOX==='undefined')
       return 'SKIP: this build has no text editor to open';
     var md=document.getElementById('settingsmodal');
     if(!md) return 'SKIP: this fixture has no settings window to open the editor over';
     var bad=[], wasOn=md.classList.contains('on');
     function esc(target){
       (target||document).dispatchEvent(new KeyboardEvent('keydown',
         {code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
     }
     try{
       __topClear();
       // A WINDOW, AND THE EDITOR OVER IT.
       md.classList.add('on');
       if(!md.classList.contains('on')) return 'SKIP: the settings window would not open';
       txOpen('a probe line','a probe line',100,100,200,16);
       if(!TXBOX) return 'SKIP: the editor would not open';
       try{ TXBOX.focus(); }catch(_f){}
       if(document.activeElement!==TXBOX) return 'SKIP: the editor would not take focus, so this cannot be read';
       // The real path: a capture listener on the document sees the key on its way
       // down to the focused input.
       esc(TXBOX);
       if(TXBOX)
         bad.push('ESC in the edit box did not close the box: the handler that gives Escape to the front window took the key first, so the one gesture that means cancel this edit left the editor sitting over the game with the keyboard');
       if(!md.classList.contains('on'))
         bad.push('ESC in the edit box closed the window he was editing instead, so backing out of an edit destroys the panel the edit was being made in');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ txClose(); }catch(_t){}
     }
     // CONTROL: WITH NO BOX, A WINDOW STILL OWNS ESCAPE. A guard at the top of that
     // handler is exactly where this could be taken away.
     try{
       md.classList.add('on');
       esc(document);
       if(md.classList.contains('on'))
         bad.push('control: with no edit box open ESC no longer closes the window in front, so the guard has taken the key from every window rather than from one case');
     }catch(e2){ bad.push('control threw: '+(e2&&e2.message||e2)); }
     try{ txClose(); if(!wasOn) md.classList.remove('on'); else md.classList.add('on'); }catch(_c){}
     try{ __topClear(); }catch(_c2){}
     return bad.length?bad.join('; '):null; }},
  {v:'12.98',what:'THE LAST POUR shows the one bonus it actually pays
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

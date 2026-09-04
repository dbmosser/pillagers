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

# ==== AND MY NEW CHECK BROKE AN OLD ONE BY TIDYING UP AFTER ITSELF.
# ==== The full run failed v9.17 with "the column is only 0px wide". v9.17 has
# ==== always measured the title column WITHOUT OPENING THE TITLE SCREEN: it
# ==== worked only because something earlier in the corpus happened to leave it
# ==== open. v10.77 opens the screen, measures it and closes it again, which is
# ==== the right manners, and that took away the accident v9.17 was standing on.
# ==== This is the v9.82 lesson again: a check that CLEANS owes the same duty as
# ==== one that dirties. The honest fix is not to stop cleaning, it is for v9.17
# ==== to open the screen it wants to measure, and put it back.
SubRx @'
     if(!col) return 'the title column has no class to target, so no screen wider than 16:9 can be given more room';
     var cs=getComputedStyle(col), mw=cs.maxWidth;
'@ @'
     if(!col) return 'the title column has no class to target, so no screen wider than 16:9 can be given more room';
     // v10.77: OPEN IT FIRST. This measured a hidden element and passed only
     // while some earlier check left the title screen up; the moment one of them
     // tidied up after itself, offsetWidth read 0 and this failed the build.
     var _t9was=t.classList.contains('on'), _t9shut=[];
     Array.prototype.forEach.call(document.querySelectorAll('.modal.on'),function(e){ _t9shut.push(e); e.classList.remove('on'); });
     t.classList.add('on');
     try{ if(typeof applyMenuZoom==='function') applyMenuZoom(); }catch(_z9){}
     function _t9done(msg){
       if(!_t9was) t.classList.remove('on');
       for(var _i9=0;_i9<_t9shut.length;_i9++) _t9shut[_i9].classList.add('on');
       return msg;
     }
     var cs=getComputedStyle(col), mw=cs.maxWidth;
'@

SubRx @'
     if(col.offsetWidth>window.innerWidth*0.9)
       bad.push('control: the column is '+Math.round(col.offsetWidth/window.innerWidth*100)+' percent of the screen, lines that wide are unreadable');
     return bad.length?bad.join('; '):null; }},
'@ @'
     if(col.offsetWidth>window.innerWidth*0.9)
       bad.push('control: the column is '+Math.round(col.offsetWidth/window.innerWidth*100)+' percent of the screen, lines that wide are unreadable');
     return _t9done(bad.length?bad.join('; '):null); }},
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

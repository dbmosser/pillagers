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

# TWO REPAIRS TO CHECKS I WROTE, BOTH OF THEM MY INSTRUMENT AND NOT THE BUILD.
#
# 13.01 READ TOO SOON. A panel writes its raw sentences and the pass that puts his
# wording over them runs from a mutation observer, which is a microtask: it has not
# run yet when the check reads textContent in the same synchronous turn. So the check
# saw the game's words on a build that shows his. Driving txDom directly is what the
# observer would have done a moment later.
#
# 12.98 READ THE WRONG ELEMENTS. v13.01 moved the live dose total off the line he
# edited and into its own element, precisely so a number can never take his wording
# off the screen again, and 12.98 was still looking only at the old two.
SubRx @'
     function barText(){
       try{ renderBar(); }catch(_r){}
       var a=document.getElementById('bar_line'), b=document.getElementById('barlist');
       return (((a&&a.textContent)||'')+' '+((b&&b.textContent)||''));
     }
'@ @'
     function barText(){
       try{ renderBar(); }catch(_r){}
       // v13.01 moved the live total into its own element, so a number can never take
       // his edited sentence off the screen; all three are what he sees.
       var a=document.getElementById('bar_line'), b=document.getElementById('barlist'),
           c=document.getElementById('bar_now');
       return (((a&&a.textContent)||'')+' '+((c&&c.textContent)||'')+' '+((b&&b.textContent)||''));
     }
'@

SubRx @'
       P2.credits=1000000; P2.buzz=[];
       try{ renderBar(); }catch(_r){}
       var bl=document.getElementById('bar_line'), got=((bl&&bl.textContent)||'');
'@ @'
       P2.credits=1000000; P2.buzz=[];
       // The panel writes its raw sentences; the pass that puts HIS wording over them
       // runs from a mutation observer, which is a microtask and has not run yet in
       // this synchronous turn. Driving it is what the observer would do a moment
       // later, and reading before it is reading the game mid-sentence.
       function draw(){
         try{ renderBar(); }catch(_r){}
         try{ if(typeof txDom==='function') txDom(document.getElementById('root')); }catch(_d){}
       }
       draw();
       var bl=document.getElementById('bar_line'), got=((bl&&bl.textContent)||'');
'@

SubRx @'
       for(var d=0;d<3;d++) P2.buzz.push({id:'drunk',tag:'drunk',t:180,dur:180});
       try{ renderBar(); }catch(_r2){}
       var nowEl=document.getElementById('bar_now');
'@ @'
       for(var d=0;d<3;d++) P2.buzz.push({id:'drunk',tag:'drunk',t:180,dur:180});
       draw();
       var nowEl=document.getElementById('bar_now');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

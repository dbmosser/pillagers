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

# v13.00 CHECK, inserted before the v12.99 entry.
#
# IT MEASURES WHAT THE REWRITER IS HANDED, by wrapping the one function txDom calls
# for every node it visits and recording the length of each string. That is the defect
# stated as a number: a label is a few dozen characters, and on the old build one of
# those strings is the entire program.
#
# NO TIMING. A stopwatch on a browser in a hidden pane is noise, and the cost here is
# not a mystery to be sampled: it is a string length that either is or is not the size
# of the file.
#
# THE CONTROL IS A REAL LABEL. A filter that skipped everything would pass the arms
# above and silently kill the feature, so a node planted on screen must still be
# visited and its text must still arrive at the rewriter.
SubRx @'
  {v:'12.99',what:'ESC out of an edit box closes the edit box
'@ @'
  {v:'13.00',what:'the text rewriter reads what is on screen and not the whole file: no string it is handed is program or stylesheet text, the total is a screenful rather than a fileful, and a label planted on screen still reaches it (audit finding 13, 2026-09-11)',
   run:function(){
     if(typeof txDom!=='function'||typeof TX!=='function') return 'SKIP: this build has no text rewriter to measure';
     var root=document.getElementById('root');
     if(!root) return 'SKIP: this fixture has no root element to walk';
     var bad=[], oTX=TX, probe=null;
     try{
       // A REAL LABEL ON SCREEN, with text nothing else in the game says.
       probe=document.createElement('div');
       probe.textContent='probe label alpha 4242';
       root.appendChild(probe);
       var seen=[];
       TX=function(o){ seen.push(String(o||'')); return oTX.apply(null,arguments); };
       try{ txDom(root); } finally { TX=oTX; }
       if(!seen.length) return 'SKIP: the rewriter visited nothing at all, so there is nothing here to measure';
       var mx=0, tot=0, i;
       for(i=0;i<seen.length;i++){ tot+=seen[i].length; if(seen[i].length>mx) mx=seen[i].length; }
       // A LABEL IS NEVER THIS LONG. On the old build one of these strings is the
       // entire program text, and it is handed over on every toast, every credits
       // change and every panel rebuild.
       if(mx>20000)
         bad.push('the text rewriter is handed a single string of '+mx+' characters, which is the program or the stylesheet rather than a label: the whole game is one file and both live inside the element it walks, so every toast, every credits change and every panel rebuild runs two full-source passes and a full-source lookup key');
       if(tot>400000)
         bad.push('the text rewriter is handed '+tot+' characters in one pass, which is a fileful rather than a screenful');
       // NAMED, not just measured: the program and the stylesheet by their own text.
       var prog=0, sty=0;
       for(i=0;i<seen.length;i++){
         if(seen[i].length<2000) continue;
         if(/function\s+\w+\s*\(/.test(seen[i])&&/\bvar\b/.test(seen[i])) prog++;
         else if(/\{[^{}]*:[^{}]*;[^{}]*\}/.test(seen[i])&&/#[0-9a-fA-F]{3,6}/.test(seen[i])) sty++;
       }
       if(prog) bad.push('the rewriter was handed the program text itself, which is not a label and can never be edited');
       if(sty) bad.push('the rewriter was handed the stylesheet, which is not a label and can never be edited');
       // CONTROL: the label planted on screen must still reach it, or the filter has
       // killed the feature it was meant to make cheap.
       var found=0;
       for(i=0;i<seen.length;i++) if(seen[i].indexOf('probe label alpha 4242')>=0) found=1;
       if(!found)
         bad.push('control: a label planted on screen never reached the rewriter, so the walk has been narrowed until it sees nothing');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ TX=oTX; }catch(_t){}
       try{ if(probe&&probe.parentNode) probe.parentNode.removeChild(probe); }catch(_r){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.99',what:'ESC out of an edit box closes the edit box
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

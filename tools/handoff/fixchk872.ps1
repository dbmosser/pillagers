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

# CHECK 8.72 WENT RED ONCE IN THE v11.77 CORPUS AND GREEN ON EVERY RE-RUN.
# The drag lands through document.elementFromPoint on the stash grid; under
# a hidden pane with the machine busy the first attempt can miss. A second
# attempt is made before the verdict; it still requires the belt slot to
# empty, so a build that really keeps the item fails twice, not once.
SubRx @'
     cell.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,clientX:cr.left+cr.width/2,clientY:cr.top+cr.height/2}));
     document.dispatchEvent(new MouseEvent('mousemove',{bubbles:true,clientX:gr.left+40,clientY:gr.top+40}));
     document.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,clientX:gr.left+40,clientY:gr.top+40}));
     var P2=__P();
     if(P2.hotAssign&&P2.hotAssign[0]!==undefined) return 'the belt slot still holds the item after dragging it to the stash';
'@ @'
     function dragOnce(){
       var c2=visCell(0); if(!c2) return;
       var cr2=c2.getBoundingClientRect(), gr2=grid.getBoundingClientRect();
       c2.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,clientX:cr2.left+cr2.width/2,clientY:cr2.top+cr2.height/2}));
       document.dispatchEvent(new MouseEvent('mousemove',{bubbles:true,clientX:gr2.left+40,clientY:gr2.top+40}));
       document.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,clientX:gr2.left+40,clientY:gr2.top+40}));
     }
     dragOnce();
     var P2=__P();
     // v11.77 harness repair: one miss under a busy, hidden pane is a second
     // attempt, not a verdict; the slot still has to empty.
     if(P2.hotAssign&&P2.hotAssign[0]!==undefined){ try{ renderHub(); }catch(_rh){} dragOnce(); P2=__P(); }
     if(P2.hotAssign&&P2.hotAssign[0]!==undefined) return 'the belt slot still holds the item after dragging it to the stash (twice)';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

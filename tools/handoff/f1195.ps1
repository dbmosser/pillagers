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

# v11.95 CHECK, inserted before the v11.94 entry. The loader is handed the
# null record storeGet resolves to when nothing is saved, with the menu zoom
# and the wording watcher cleared first; both must come back set.
SubRx @'
  {v:'11.94',what:'a note typed into the pause box during a raid is kept when ESC closes the box, the same as the resume button (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'11.95',what:'a load with no save sets the menu zoom to 1.3 and runs the Settings pass that arms the wording watcher, the same as a load with a save (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(typeof applyLoadedProfile!=='function'||typeof applyGameOpts!=='function') return 'SKIP: no profile loader in this build';
     if(typeof MutationObserver!=='function') return 'SKIP: no MutationObserver here';
     var bad=[], keepZ=P.menuZoom, keepObs=TXOBS;
     try{
       __topClear(); __runPrep();
       P.menuZoom=0;
       if(TXOBS){ try{ TXOBS.disconnect(); }catch(_d){} TXOBS=null; }
       applyLoadedProfile(null);   // what storeGet resolves to when nothing is saved
       if(P.menuZoom!==1.3) bad.push('a load with no save left the menu zoom at '+P.menuZoom);
       if(!TXOBS) bad.push('a load with no save did not arm the wording watcher');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       P.menuZoom=keepZ||1.3;
       if(!TXOBS&&keepObs){ TXOBS=keepObs; try{ TXOBS.observe(document.getElementById('root'),{childList:true,subtree:true,characterData:true}); }catch(_o){} }
       try{ applyMenuZoom(); }catch(_z){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.94',what:'a note typed into the pause box during a raid is kept when ESC closes the box, the same as the resume button (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

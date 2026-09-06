$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Check 11.72 SKIPPED inside the corpus while passing four times alone: an
# earlier check leaves a raid in memory, and this one declined rather than
# putting itself on the floor. A skip is not a pass. It now clears the raid and
# shows the hub the way the game does, and only skips if that genuinely fails.
# Applied to the live fixture source and to the v11.72 draft.
$files = @('C:\claudecode\dark raiders\tools\mkfixture.ps1',
           'C:\claudecode\dark raiders\tools\handoff\f1172.ps1')
$old = @'
       if(window.__hubEnter){ try{ __hubEnter(); }catch(_h){} }
       if(G) return 'SKIP: a raid is running, so this is not the floor';
       if(typeof state!=='undefined'&&state!=='hub') return 'SKIP: not on the floor (state '+state+'), so the box cannot open';
'@
$new = @'
       // v11.72: PUT yourself on the floor rather than declining. A raid left in
       // memory by an earlier check is not a reason to skip; it is a reason to
       // end it, which is exactly what leaving a raid does in the game.
       try{ if(G){ G=null; keys={}; } }catch(_g){}
       try{ if(window.__showScreen) __showScreen('hub'); }catch(_s){}
       if(window.__hubEnter){ try{ __hubEnter(); }catch(_h){} }
       if(G) return 'SKIP: a raid is still running after clearing it, so this is not the floor';
       if(typeof state!=='undefined'&&state!=='hub') return 'SKIP: not on the floor (state '+state+') even after showing the hub';
'@
foreach ($f in $files) {
  $s = [IO.File]::ReadAllText($f)
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne 1) { throw "$f : matched $c" }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
  Write-Output "patched $f"
}

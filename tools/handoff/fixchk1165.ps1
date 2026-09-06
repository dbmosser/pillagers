$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Check 11.65 assumed Copy report is what writes the run row. A probe shows the
# row is already written when the raid ends in this harness (the log grew from
# 24 to 25 inside __endRaid), so Copy added nothing and the check failed its own
# control on every build. What matters for this fix is not WHICH press wrote the
# row but that a tag and a note chosen AFTERWARDS reach it, so the baseline
# moves above endRaid and the control asks for exactly one row however it got
# there. Applied to the live fixture source and to the v11.65 draft.
$files = @('C:\claudecode\dark raiders\tools\mkfixture.ps1',
           'C:\claudecode\dark raiders\tools\handoff\f1165.ps1')
$old = @'
       __endRaid('extract');
       document.execCommand=function(){ return true; };
       var n0=(prof.log||[]).length;
       document.getElementById('oc_copy').click();   // logs the run, with no tags yet
       var log=prof.log||[], rec=log[log.length-1];
       if(log.length!==n0+1||!rec) bad.push('control: Copy report did not log the run ('+(log.length-n0)+' rows added)');
'@
$new = @'
       var n0=(prof.log||[]).length;
       __endRaid('extract');
       document.execCommand=function(){ return true; };
       // The row may already be written by the time the card is up; Copy report
       // writes it when it is not. Either way exactly ONE row must exist, and
       // that is the row a tag chosen afterwards has to reach.
       document.getElementById('oc_copy').click();
       var log=prof.log||[], rec=log[log.length-1];
       if(log.length!==n0+1||!rec) bad.push('control: ending the raid and pressing Copy report did not log exactly one run ('+(log.length-n0)+' rows added)');
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

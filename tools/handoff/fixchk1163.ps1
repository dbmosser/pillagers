$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Check 11.63 forced hard weather by writing g.wx.id. G.wx IS a row of the
# shared WEATHER table, so that renamed the row for the whole page: run one
# passed, run two failed its own control because the banked record carried no
# hard-weather flag, and run three skipped outright because the table no longer
# held the id it was looking for. It also left a weather TURN in progress
# untouched, and wx() blends across a turn, so the forced row could be ignored.
# It now finds the hard row and INSTALLS it, mutating nothing, and clears the
# turn. Applied to the live fixture source and to the v11.63 draft.
$files = @('C:\claudecode\dark raiders\tools\mkfixture.ps1',
           'C:\claudecode\dark raiders\tools\handoff\f1163.ps1')
$old = @'
     var hard=null; if(window.__wxHard('storm')) hard='storm'; else if(window.__wxHard('fog')) hard='fog';
     if(!hard) return 'SKIP: no weather counts as hard, so there is no multiplier to disagree on';
     if(!g.wx) g.wx={}; g.wx.id=hard;
'@
$new = @'
     // v11.63: find the hard row and INSTALL it. Writing g.wx.id renamed a row of
     // the shared WEATHER table for the whole page, which poisoned every later
     // run of this check; and a weather turn in progress makes wx() blend, so the
     // turn is cleared too.
     var hardRow=null;
     for(var wi=0;wi<WEATHER.length;wi++){ if(window.__wxHard(WEATHER[wi].id)){ hardRow=WEATHER[wi]; break; } }
     if(!hardRow) return 'SKIP: no weather counts as hard, so there is no multiplier to disagree on';
     g.wx=hardRow; g.wxNext=null; g.wxT=0;
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

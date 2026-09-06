$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Check 11.56 SKIPPED: it guarded on window.__wxHard, a hook added by the
# outcome-card XP build, which was renumbered out of the way and has not
# shipped. A skip is not a pass. It does not need that hook at all: wx()
# returns G.wx itself, so the check installs the WEATHER entry that carries
# lightning and strikeTick proceeds. Applied to the live fixture source and to
# the handoff draft, so the two can never drift.
$old1 = @'
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__wxHard)) return 'SKIP: this fixture cannot deploy under a storm';
'@
$new1 = @'
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
'@
$old2 = @'
       if(!__wxHard('storm')) return 'SKIP: storm is not a weather here';
       if(!g.wx) g.wx={}; g.wx.id='storm';
'@
$new2 = @'
       // wx() hands back G.wx itself, so the storm has to BE the weather.
       var storm=null;
       for(var wi=0;wi<WEATHER.length;wi++) if(WEATHER[wi].lightning){ storm=WEATHER[wi]; break; }
       if(!storm) return 'SKIP: no weather in this build carries lightning';
       g.wx=storm; g.wxNext=null; g.wxT=0;
'@
$files = @('C:\claudecode\dark raiders\tools\mkfixture.ps1',
           'C:\claudecode\dark raiders\tools\handoff\f1156.ps1')
foreach ($f in $files) {
  $t = [IO.File]::ReadAllText($f)
  foreach ($pair in @(@($old1,$new1), @($old2,$new2))) {
    $o = $pair[0]; $w = $pair[1]
    if ($t.IndexOf($o) -lt 0) { $o = $o.Replace("`r`n","`n"); $w = $w.Replace("`r`n","`n") }
    $c = ([regex]::Matches($t, [regex]::Escape($o))).Count
    if ($c -ne 1) { throw "$f : matched $c for $($o.Substring(0,[Math]::Min(50,$o.Length)))" }
    $t = $t.Replace($o, $w)
  }
  [IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false))
  Write-Output "patched $f"
}

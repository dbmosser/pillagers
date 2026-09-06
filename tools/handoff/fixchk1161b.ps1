$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Second cut. The armoury branch was wrong: the run itself printed "stash holds
# gun_shotgun", so a Wirt lot whose headline is a gun is delivered INTO THE
# STASH under its own item key, exactly like every other lot. The original
# check had the right shelf and the wrong position: it read the LAST item, and
# a lot is a headline plus extras, so the last item is an extra. It asks
# whether the stash CONTAINS what the card named.
$files = @('C:\claudecode\dark raiders\tools\mkfixture.ps1',
           'C:\claudecode\dark raiders\tools\handoff\f1161.ps1')
$old = @'
     var want=shown[0], wit=(typeof ITEMS!=='undefined')?ITEMS[want]:null, delivered=false;
     if(wit&&wit.use==='gun'&&wit.gk) delivered=((P.weapons||[]).indexOf(wit.gk)>=0&&gunsBefore.indexOf(wit.gk)<0);
     else delivered=((P.stash||[]).indexOf(want)>=0);
'@
$new = @'
     var want=shown[0], delivered=((P.stash||[]).indexOf(want)>=0);
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

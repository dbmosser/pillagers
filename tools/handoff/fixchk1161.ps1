$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Check 11.61 judged delivery by the LAST ITEM IN THE STASH. A Wirt lot is a
# headline item plus extras, and when the headline is a gun the buy puts it in
# the armoury and only the extras reach the stash, so the check read an extra
# (a medkit) and called it a wrong delivery. It passed standalone only because
# that run happened to draw a non-gun lot. It now asks the right shelf: a gun
# lot is delivered into P.weapons under its gun key, anything else into the
# stash. Applied to the live fixture source and to the v11.61 draft.
$files = @('C:\claudecode\dark raiders\tools\mkfixture.ps1',
           'C:\claudecode\dark raiders\tools\handoff\f1161.ps1')
$old1 = @'
     P.credits=999999; P.stash=[];
'@
$new1 = @'
     P.credits=999999; P.stash=[];
     var gunsBefore=((P.weapons||[]).slice());
'@
$old2 = @'
     var got=(P.stash||[]).length?P.stash[P.stash.length-1]:null;
     // THE FIX: he receives what the card NAMED AND PRICED.
     if(got!==shown[0]) bad.push('after the window rolled, Buy delivered '+got+' instead of the shown '+shown[0]);
'@
$new2 = @'
     // THE FIX: he receives what the card NAMED AND PRICED. A lot whose headline
     // is a GUN is delivered into the armoury and only its extras reach the
     // stash, so ask the shelf the thing actually lands on.
     var want=shown[0], wit=(typeof ITEMS!=='undefined')?ITEMS[want]:null, delivered=false;
     if(wit&&wit.use==='gun'&&wit.gk) delivered=((P.weapons||[]).indexOf(wit.gk)>=0&&gunsBefore.indexOf(wit.gk)<0);
     else delivered=((P.stash||[]).indexOf(want)>=0);
     if(!delivered) bad.push('after the window rolled, Buy did not deliver the shown '+want+' (stash holds '+((P.stash||[]).join(',')||'nothing')+', armoury holds '+((P.weapons||[]).join(',')||'nothing')+')');
'@
foreach ($f in $files) {
  $s = [IO.File]::ReadAllText($f)
  foreach ($pair in @(@($old1,$new1), @($old2,$new2))) {
    $pat = ($pair[0] -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
    $c = ([regex]::Matches($s, $pat)).Count
    if ($c -ne 1) { throw "$f : matched $c for $($pair[0].Trim().Substring(0,[Math]::Min(44,$pair[0].Trim().Length)))" }
    $rep = $pair[1]
    $s = [regex]::Replace($s, $pat, { param($m) $rep })
  }
  [IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
  Write-Output "patched $f"
}

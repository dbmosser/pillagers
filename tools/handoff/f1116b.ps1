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

# TWENTY FIVE SECONDS FOR THIS BUILDING. With the door next door closed to it
# the honest route goes round the north, about 2,200 units, and the crawler is
# on the player at 35 units by frame 1500. At fifteen seconds it was still 313
# off and walking. The old carve stands at 313 forever, so the control holds.
SubRx @'
     var on=drive(1,20,1,900,'3380,3130,300,220');
     if(on.err) return 'SKIP: '+on.err;
     if(on.best>60) bad.push('the crawler out of building 20 on THE COLD MILE got no closer than '+on.best.toFixed(0)+' units in fifteen seconds'+(on.exitF<0?' and never left the building':''));
     // CONTROL ONE: the old carve must still show the fault. Measured 313 at
     // fifteen seconds, standing at 3000,3178.
     var off=drive(1,20,0,900,'3380,3130,300,220');
'@ @'
     // Twenty five seconds: with the door next door closed to it the honest
     // route goes round the north, about 2,200 units, and the crawler is on
     // the player at 35 by frame 1500. At fifteen it was 313 off and walking.
     var on=drive(1,20,1,1500,'3380,3130,300,220');
     if(on.err) return 'SKIP: '+on.err;
     if(on.best>60) bad.push('the crawler out of building 20 on THE COLD MILE got no closer than '+on.best.toFixed(0)+' units in twenty five seconds'+(on.exitF<0?' and never left the building':''));
     // CONTROL ONE: the old carve must still show the fault. Measured 313 at
     // fifteen seconds and at twenty five, standing at 2985,3178.
     var off=drive(1,20,0,1500,'3380,3130,300,220');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

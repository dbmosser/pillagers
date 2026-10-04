$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'18.35',what:")) { throw "check 18.35 is in the fixture already" }

SubRx @'
  {v:'18.34',what:
'@ @'
  {v:'18.35',what:'one siege size: the call promises the number of machines the ring sends (check 9.34 passes), and the size is 5 + 7 x greed everywhere it is counted',
   run:function(){
     if(typeof siegeBase!=='function') return 'the siege size is written out in several places';
     var bad=[], t=(typeof __REGRESS!=='undefined')?__REGRESS.find(function(x){ return x.v==='9.34'; }):null, r;
     if(Math.abs(siegeBase(0)-5)>1e-9||Math.abs(siegeBase(1)-12)>1e-9) bad.push('the siege size reads '+siegeBase(0)+' to '+siegeBase(1));
     if(!t) return bad.length?bad.join('; '):'SKIP: no promise check to run';
     try{ __runPrep(); __topClear(); r=t.run(); }catch(e){ r='threw: '+(e&&e.message||e); }
     if(r&&String(r).indexOf('SKIP')!==0) bad.push('the promise and the arrivals still differ: '+String(r).slice(0,120));
     return bad.length?bad.join('; '):null; }},
  {v:'18.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

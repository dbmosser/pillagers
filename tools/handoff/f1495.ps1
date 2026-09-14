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

SubRx @'
  {v:'14.94',what:
'@ @'
  {v:'14.95',what:'the SHORT WINDOW term does not promise to cut a raid clock that is off: with the clock on it names the full clock, and with the clock off it names neither the full clock nor the cut one (falsy-zero audit finding 1)',
   run:function(){
     if(typeof TERMS==='undefined'||typeof CFG==='undefined'||typeof DEF==='undefined') return 'SKIP: no terms in this build';
     var T=TERMS.filter(function(t){ return t.id==='window'; })[0];
     if(!T||typeof T.desc!=='function'||!(DEF.raidSec>0)) return 'SKIP: no SHORT WINDOW term here';
     var bad=[], keep=CFG.raidSec;
     try{
       CFG.raidSec=DEF.raidSec; var on=String(T.desc());
       // CONTROL: with the clock on, the words name the full clock.
       if(on.indexOf(String(DEF.raidSec))<0) return 'SKIP: with the clock on the term did not name the full clock ('+on.slice(0,80)+')';
       CFG.raidSec=0; var off=String(T.desc());
       if(off.indexOf(String(DEF.raidSec))>=0||off.indexOf(String(Math.round(DEF.raidSec*0.66)))>=0) bad.push('with the raid clock off the term still reads: '+off.slice(0,100));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ CFG.raidSec=keep; }
     return bad.length?bad.join('; '):null; }},
  {v:'14.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

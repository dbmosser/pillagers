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

# CHECK 13.20 WAS TESTING THE FIXTURE, NOT THE BUILD. Mine.
#
# mkfixture replaces downloadExport outright so tests never dribble report files
# into his Downloads, and that stub has to stay. So the check called the stub,
# saw no anchor click, and reported that a normal page no longer saves the
# report. The build was fine; the ruler was the fixture, which this file has
# recorded lying twice before under "grep mkfixture for name=function".
#
# THE STUB STAYS AND THE ORIGINAL IS KEPT. __realDownloadExport is the real
# function, reachable only by a check that asks for it by name, so the default
# behaviour of every other check is unchanged.
#
# AND THE ANCHOR CLICK IS NO LONGER CALLED THROUGH. Counting the click and then
# performing it would have written a file to his Downloads on every corpus run,
# which is the exact thing the stub exists to prevent.
SubRx @'
try{ downloadExport=function(){ if(typeof P!=='undefined'&&P) P.lastReport='fixture-dl-stub'; }; }catch(e){}
'@ @'
// v13.20: KEEP THE REAL ONE. The stub below stays, because a corpus run must
// never write files into his Downloads; but a check that is specifically about
// what downloadExport does needs the real function, and it can only have it if
// something saved it before the stub landed.
try{ window.__realDownloadExport=downloadExport; }catch(e){}
try{ downloadExport=function(){ if(typeof P!=='undefined'&&P) P.lastReport='fixture-dl-stub'; }; }catch(e){}
'@

SubRx @'
     if(typeof downloadExport!=='function') return 'SKIP: this fixture cannot reach the report saver';
'@ @'
     // THE REAL ONE, kept by the fixture before it stubbed the name. Calling the
     // stub would measure the fixture, which is what the first version of this
     // check did.
     var dl=window.__realDownloadExport;
     if(typeof dl!=='function') return 'SKIP: this fixture did not keep the real report saver';
'@

SubRx @'
       HTMLAnchorElement.prototype.click=function(){
         if(this.hasAttribute('download')) clicks++;
         return _ac.apply(this,arguments);
       };
'@ @'
       // COUNT IT AND SWALLOW IT. Calling through would save a file into his
       // Downloads on every corpus run, which is what the fixture stub exists to
       // prevent in the first place.
       HTMLAnchorElement.prototype.click=function(){
         if(this.hasAttribute('download')){ clicks++; return; }
         return _ac.apply(this,arguments);
       };
'@

SubRx @'
       P.lastReport=null; clicks=0;
       downloadExport();
       if(clicks>0)
'@ @'
       P.lastReport=null; clicks=0;
       dl();
       if(clicks>0)
'@

SubRx @'
       P.lastReport=null; clicks=0;
       downloadExport();
       if(clicks===0)
'@ @'
       P.lastReport=null; clicks=0;
       dl();
       if(clicks===0)
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

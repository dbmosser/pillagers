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

if ($s.Contains("  {v:'30.30',what:")) { throw "check 30.30 is in the fixture already" }

SubRx @'
  {v:'30.29',what:
'@ @'
  {v:'30.30',what:'the pause card has no plain Esc Resume hint under the buttons, the header X is the one way shown to close (critic 49)',
   run:function(){
     var pb=document.getElementById('pausebox'), padWas=document.body.classList.contains('padon'), cs, c;
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()||__state().over) return 'SKIP: no live raid';
       togglePauseBox(true); pauseFrameFit();
       if(!pb||!pb.offsetHeight) return 'SKIP: the pause card did not open';
       if(!document.getElementById('pausex')||!document.getElementById('pausex').offsetWidth) return 'the pause card lost its header X';
       cs=getComputedStyle(pb,'::after'); c=cs.content||'';
       if(cs.display!=='none'&&/Esc/.test(c)) return 'the pause card still draws the plain hint '+c+' ('+cs.display+')';
       return null;
     } finally { try{ togglePauseBox(false); }catch(_t){} document.body.classList.toggle('padon',padWas); }
   }},
  {v:'30.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'32.10',what:")) { throw "check 32.10 is in the fixture already" }

SubRx @'
  {v:'32.09',what:
'@ @'
  {v:'32.10',what:'the pause box report a problem field is on the 48px small tier',
   run:function(){
     var bad=null, f, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()||__state().over) return 'SKIP: no live raid';
       togglePauseBox(true); pauseFrameFit();
       f=document.getElementById('pausefb');
       if(!f||!f.offsetWidth) return 'SKIP: no report field';
       if(f.offsetHeight>48) bad='the report field is '+f.offsetHeight+' tall';
     }catch(e){ bad='threw: '+(e&&e.message||e); }
     finally{ try{ togglePauseBox(false); }catch(_t){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad; }},
  {v:'32.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

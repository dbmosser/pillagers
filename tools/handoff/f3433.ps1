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

if ($s.Contains("  {v:'34.33',what:")) { throw "check 34.33 is in the fixture already" }

SubRx @'
  {v:'34.32',what:
'@ @'
  {v:'34.33',what:'the page toast hides while the abandon question is up (the critic: a running slowly toast shines over the scrim)',
   run:function(){
     var pb, t, w, bad=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('hubtoast'); pb=document.getElementById('pausebox');
       if(!t||!pb) return 'SKIP: no toast or pause box';
       w=pb.classList.contains('asking'); pb.classList.add('asking');
       if(getComputedStyle(t).visibility!=='hidden') bad='the page toast still shows while the abandon question is up';
       if(!w) pb.classList.remove('asking');
       return bad;
     } finally {
       try{ var _p=document.getElementById('pausebox'); if(_p) _p.classList.remove('asking'); }catch(_e){}
       __topClear();
     } }},
  {v:'34.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

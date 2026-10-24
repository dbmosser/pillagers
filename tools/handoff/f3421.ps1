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

if ($s.Contains("  {v:'34.21',what:")) { throw "check 34.21 is in the fixture already" }

SubRx @'
  {v:'34.20',what:
'@ @'
  {v:'34.21',what:'the racks intro sentence stays hidden after the two column layout',
   run:function(){
     var oldP=null,bad=[],m;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();oldP=JSON.stringify(P);
       __hubEnter();openOps('mf');
       m=document.querySelector('#opane_mf > .msub');
       if(m&&getComputedStyle(m).display!=='none')bad.push('the racks intro sentence is showing again: display '+getComputedStyle(m).display);
       return bad.length?bad.join('; '):null;
     }finally{
       try{__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();if(oldP)P=JSON.parse(oldP);
     }
   }},
  {v:'34.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

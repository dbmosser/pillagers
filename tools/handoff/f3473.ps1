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

if ($s.Contains("  {v:'34.73',what:")) { throw "check 34.73 is in the fixture already" }

SubRx @'
  {v:'34.72',what:
'@ @'
  {v:'34.73',what:'the pixel gun and shoulders kick back on a shot (heavy guns more), and not at rest or with EFFECT INTENSITY off',
   run:function(){
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     if(typeof pxKick!=='function') return 'FAIL: no pxKick';
     var bad=[], fi=CFG.fxInt;
     try{
       CFG.fxInt=1;
       if(pxKick(0,'rifle')!==0) bad.push('kick at rest');
       if(pxKick(0.06,'rifle')!==1) bad.push('rifle kick not 1');
       if(pxKick(0.06,'shotgun')!==2) bad.push('shotgun kick not 2');
       if(pxKick(0.06,'sniper')<=pxKick(0.06,'smg')) bad.push('heavy not more than smg');
       CFG.fxInt=0.5; if(pxKick(0.06,'shotgun')!==1) bad.push('half intensity shotgun not 1');
       CFG.fxInt=0; if(pxKick(0.06,'shotgun')!==0) bad.push('kick with intensity off');
     }finally{ CFG.fxInt=fi; }
     return bad.length?bad.join('; '):null; }},
  {v:'34.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'35.19',what:")) { throw "check 35.19 is in the fixture already" }

SubRx @'
  {v:'35.18',what:
'@ @'
  {v:'35.19',what:'cw-figone, his note of 2026-10-27 ("Character is too small now. Increase size to get him back to the original size that we had him at for a long long time (weeks)"): the pillager is drawn at size 1 again (FIG_SCALE 1, FIG_UP 12, as from launch to 10-25), a lean figure keeps its build of 0.92 by 1.08 with the smooth look, and the world canvas draws him at 1',
   run:function(){ var bad=[], keepPix=(typeof CFG!=='undefined')?CFG.xfPix:null, k;
     try{
       if(typeof FIG_SCALE==='undefined') bad.push('no FIG_SCALE in this build');
       else if(FIG_SCALE!==1) bad.push('the pillager is drawn at FIG_SCALE '+FIG_SCALE+', not 1');
       if(typeof FIG_UP==='undefined') bad.push('no FIG_UP in this build');
       else if(FIG_UP!==12) bad.push('FIG_UP is '+FIG_UP+', not 12 (the lift he had at size 1)');
       if(typeof figKS==='function'&&typeof CFG!=='undefined'){
         CFG.xfPix=0; k=figKS('lean');
         if(!k||Math.abs(k[0]-0.92)>1e-6||Math.abs(k[1]-1.08)>1e-6) bad.push('a lean figure is scaled '+JSON.stringify(k)+', not [0.92,1.08]');
       }
       if(typeof figK1==='function'){ k=figK1(); if(Math.abs(k-1)>1e-6) bad.push('the world canvas draws the figure at '+k+', not 1'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(keepPix!==null) CFG.xfPix=keepPix; }catch(_p){} }
     return bad.length?bad.join('; '):null; }},
  {v:'35.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

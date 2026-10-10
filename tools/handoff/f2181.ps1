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

if ($s.Contains("  {v:'21.81',what:")) { throw "check 21.81 is in the fixture already" }

SubRx @'
  {v:'21.80',what:
'@ @'
  {v:'21.81',what:'the raid text rewrite: measureText measures the words that are drawn (his rewording included), so plates fit them',
   run:function(){
     if(typeof TX!=='function'||typeof P!=='object'||!P) return 'SKIP: no profile here';
     var bad=[], keep=P.txt, cv, c, wa, wb, wc2, k, v, n=0;
     try{
       cv=document.createElement('canvas'); cv.width=400; cv.height=60; c=cv.getContext('2d');
       c.font=(typeof FS==='function'&&typeof TYPE==='object'&&TYPE.label)?FS(TYPE.label):'16px sans-serif';
       P.txt={}; for(k in (keep||{})) P.txt[k]=keep[k];
       wb=c.measureText('zq a much longer replacement').width;
       wc2=c.measureText('zq short').width;
       P.txt['zq short']='zq a much longer replacement';
       wa=c.measureText('zq short').width;
       if(!(wb>wc2+20)) bad.push('the probe strings do not differ in width ('+wb+' / '+wc2+')');
       if(Math.abs(wa-wb)>0.5) bad.push('a reworded line measures '+Math.round(wa)+' px but draws '+Math.round(wb)+' px wide');
       // The empty string, a number and a non-string still measure without throwing.
       c.measureText(''); c.measureText(String(12345));
       // No shipped rewording is itself a shipped line, so a string measured twice through TX is the string drawn.
       P.txt={};
       for(k in TXSHIP){ if(!TXSHIP.hasOwnProperty(k)) continue; v=TXSHIP[k]; n++; if(TX(v)!==v){ bad.push('the shipped rewording of a line translates again: '+String(v).slice(0,50)); break; } }
       if(!n) bad.push('no shipped lines to read');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ P.txt=keep; }
     return bad.length?bad.join('; '):null; }},
  {v:'21.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

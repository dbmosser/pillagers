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

if ($s.Contains("  {v:'31.36',what:")) { throw "check 31.36 is in the fixture already" }

SubRx @'
  {v:'31.35',what:
'@ @'
  {v:'31.36',what:'the pause report box is a 56px row, and the two long pad labels are short',
   run:function(){
     var bad=[], f, h, i, a2='', a3='';
     try{
       f=document.getElementById('pausefb');
       if(!f) bad.push('no pause report box');
       else{ h=parseFloat(getComputedStyle(f).height); if(Math.abs(h-56)>1) bad.push('the report box is '+h+'px high, not 56'); }
       for(i=0;i<PAD_ACTS.length;i++){ if(PAD_ACTS[i][0]===2) a2=String(PAD_ACTS[i][1]); if(PAD_ACTS[i][0]===3) a3=String(PAD_ACTS[i][1]); }
       if(a2.length>20) bad.push('pad row X is long: '+a2);
       if(a3.length>20||a3.indexOf('finish')<0) bad.push('pad row Y is long or lost finish: '+a3);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

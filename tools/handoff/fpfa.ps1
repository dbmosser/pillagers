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

if ($s.Contains("  {v:'30.43',what:")) { throw "check 30.43 is in the fixture already" }

SubRx @'
  {v:'30.42',what:
'@ @'
  {v:'30.43',what:'the title line sits at least 20px under the fullscreen row and 12px above the key row',
   run:function(){
     var t=document.getElementById('title'), tg=document.getElementById('titletag'), was, bad=[];
     if(!t||!tg) return 'SKIP: no title here';
     was=t.classList.contains('on'); if(!was) t.classList.add('on');
     try{
       var cs=getComputedStyle(tg);
       if(parseFloat(cs.marginTop)<24) bad.push('the line has '+cs.marginTop+' above it, not 24px');
       if(parseFloat(cs.marginBottom)<16) bad.push('the line has '+cs.marginBottom+' below it, not 16px');
     } finally { if(!was) t.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

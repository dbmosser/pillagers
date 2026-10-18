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

if ($s.Contains("  {v:'30.48',what:")) { throw "check 30.48 is in the fixture already" }

SubRx @'
  {v:'30.47',what:
'@ @'
  {v:'30.48',what:'the title line is centred on the title column and quieter than the logo',
   run:function(){
     var t=document.getElementById('title'), tg=document.getElementById('titletag'), wm=t&&t.querySelector('.wordmark'), was, bad=[];
     if(!t||!tg) return 'SKIP: no title here';
     was=t.classList.contains('on'); if(!was) t.classList.add('on');
     try{
       var r=tg.getBoundingClientRect(), p=tg.parentNode.getBoundingClientRect(), tr=document.createRange();
       tr.selectNodeContents(tg); var q=tr.getBoundingClientRect();
       var dx=Math.abs((q.left+q.right)/2-(p.left+p.right)/2);
       if(dx>6) bad.push('the line is '+dx.toFixed(0)+'px off the centre of the title column');
       if(parseFloat(getComputedStyle(tg).fontSize)>24) bad.push('the line is over 24px, it competes with the logo');
     } finally { if(!was) t.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

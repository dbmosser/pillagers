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

if ($s.Contains("  {v:'17.79',what:")) { throw "check 17.79 is in the fixture already" }

SubRx @'
  {v:'17.78',what:
'@ @'
  {v:'17.79',what:'the sector page draws a map of each sector in its row (zones, buildings, extraction rings), one canvas per sector with something on it',
   run:function(){
     if(typeof sectorPreviewDraw!=='function'||typeof renderSector!=='function') return 'the sector page is text over an empty page';
     if(!document.getElementById('sectorlist')) return 'SKIP: no sector page in this fixture';
     var bad=[], cvs, i, c, d, lit, k;
     try{
       renderSector();
       cvs=document.querySelectorAll('#sectorlist canvas.secprev');
       if(cvs.length!==FIXED_MAPS.length) bad.push('the sector page has '+cvs.length+' maps for '+FIXED_MAPS.length+' sectors');
       for(i=0;i<cvs.length;i++){
         c=cvs[i].getContext('2d'); d=c.getImageData(0,0,cvs[i].width,cvs[i].height).data; lit=0;
         for(k=3;k<d.length;k+=4*37) if(d[k]>0) lit++;
         if(lit<50) bad.push('sector '+i+' map is blank ('+lit+' lit samples)');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'17.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'17.82',what:")) { throw "check 17.82 is in the fixture already" }

SubRx @'
  {v:'17.81',what:
'@ @'
  {v:'17.82',what:'each sector row on the sector page is tall enough to hold its map (the map does not spill into the row below), and the zone names are 11 px',
   run:function(){
     if(typeof sectorPreviewDraw!=='function'||typeof renderSector!=='function') return 'SKIP: this build has no sector maps';
     if(!document.getElementById('sectorlist')) return 'SKIP: no sector page in this fixture';
     var bad=[], rows, i, cv, r, c;
     try{
       renderSector();
       rows=document.querySelectorAll('#sectorlist .sectorpick');
       if(!rows.length) return 'SKIP: staging: no sector rows';
       for(i=0;i<rows.length;i++){ cv=rows[i].querySelector('canvas.secprev'); if(!cv) continue; r=rows[i].getBoundingClientRect(); c=cv.getBoundingClientRect(); if(c.bottom>r.bottom+1) bad.push('sector '+i+' map spills '+Math.round(c.bottom-r.bottom)+' px below its row'); }
       if(String(sectorPreviewDraw).indexOf('11px')<0) bad.push('the zone names are not 11 px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'17.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

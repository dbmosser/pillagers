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

if ($s.Contains("  {v:'25.75',what:")) { throw "check 25.75 is in the fixture already" }

SubRx @'
  {v:'25.74',what:
'@ @'
  {v:'25.75',what:'the compact controls list keeps 1-9 TACTICAL BELT in the left column beside B / I (the v17.76 rule) and names the new keys in pairs: Q melee, F next gun, G throw, H heal, E search, X extract',
   run:function(){
     if(typeof LEGEND_MINI==='undefined') return 'SKIP: no compact legend here';
     var bad=[], rows=LEGEND_MINI, i, ix=-1, k, found, want={'Q':'melee','F':'next gun','G':'throw','H':'heal','E':'search','X':'extract'};
     for(i=0;i<rows.length;i++) if(rows[i][0]==='1-9') ix=i;
     if(ix<0) bad.push('the compact list has no 1-9 row');
     else{
       if(ix%2!==0) bad.push('1-9 TACTICAL BELT sits in the right hand column (entry '+ix+'), so its label has no next column to be measured against');
       if(!rows[ix+1]||rows[ix+1][0]!=='B / I') bad.push('B / I does not follow 1-9 on the same row');
     }
     for(k in want){ found=false; for(i=0;i<rows.length;i++) if(rows[i][0]===k&&rows[i][1]===want[k]) found=true; if(!found) bad.push('the compact list lacks '+k+' '+want[k]); }
     if(rows.length%2!==0) bad.push('the compact list has an odd number of entries ('+rows.length+'), so its last row has one hole');
     return bad.length?bad.join('; '):null; }},
  {v:'25.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

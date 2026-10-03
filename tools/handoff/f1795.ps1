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

if ($s.Contains("  {v:'17.95',what:")) { throw "check 17.95 is in the fixture already" }

SubRx @'
  {v:'17.94',what:
'@ @'
  {v:'17.95',what:'the boarding window reads EXTRACT IN PROGRESS, his words of 2026-10-03, in the banner line, the ring badge and the sector map line, and the old EXTRACT NOW is gone from all three',
   run:function(){
     if(typeof extractNowLine!=='function'||typeof zoneBadge!=='function') return 'SKIP: no boarding line here';
     var bad=[], neu='EXTRACT IN '+'PROGRESS!', old='EXTRACT '+'NOW', l=String(extractNowLine('B',11.4)), b=String(zoneBadge({open:true,beaconT:0,hold:11.4})), src='';
     if(l.indexOf(neu)!==0) bad.push('the banner reads "'+l+'"');
     if(b.indexOf(neu)<0) bad.push('the ring badge reads "'+b+'"');
     try{ src=drawMapOverlay.toString(); }catch(e){ src=''; }
     if(src.indexOf("'"+neu)<0) bad.push('the sector map line does not say '+neu);
     if(src.indexOf("'"+old)>=0) bad.push('the sector map still says '+old);
     if(l.indexOf(old)>=0||b.indexOf(old)>=0) bad.push('the old words are still there');
     return bad.length?bad.join('; '):null; }},
  {v:'17.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

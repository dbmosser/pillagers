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

if ($s.Contains("  {v:'24.88',what:")) { throw "check 24.88 is in the fixture already" }

SubRx @'
  {v:'24.87',what:
'@ @'
  {v:'24.88',what:'his #50 (UI redesign ui5q1x, from the visual QA of the Mainframe RACKS and REWARDS tabs): the RACKS and REWARDS panes start on the left edge of the tabs, not centred',
   run:function(){
     var bad=[], ids=['opane_mf','opane_rew'], i, p, s;
     for(i=0;i<ids.length;i++){
       p=document.getElementById(ids[i]); if(!p) continue;
       s=getComputedStyle(p);
       if(s.marginLeft==='auto'||(parseFloat(s.marginLeft)>2&&s.display!=='none')) bad.push(ids[i]+' is centred (margin-left '+s.marginLeft+')');
       if(!(parseFloat(s.maxWidth)>=1300)) bad.push(ids[i]+' is held to '+s.maxWidth);
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

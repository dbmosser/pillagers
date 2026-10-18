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

if ($s.Contains("  {v:'30.73',what:")) { throw "check 30.73 is in the fixture already" }

SubRx @'
  {v:'30.72',what:
'@ @'
  {v:'30.73',what:'behind the scoreboard and how-to pages the live fight can be seen: no floor labels or HUD drawn there, a light blur, the fights at mid height (his Q52/Q54)',
   run:function(){
     if(typeof tskInit!=='function'||typeof hubStationNames!=='function'||typeof drawHubHUD!=='function') return 'missing functions';
     if(String(hubStationNames).indexOf('tskOn()')<0) return 'the station names still draw behind the attract pages';
     if(String(drawHubHUD).indexOf('tskOn()')<0) return 'the floor HUD still draws behind the attract pages';
     var was=TSK;
     try{ tskInit(); if(!(TSK.ents[0].y<=330&&TSK.ents[2].y<=330)) return 'the fights stand too low: '+TSK.ents[0].y; } finally { TSK=was; }
     var blur='', ss, rr, i, j;
     try{ for(i=0;i<document.styleSheets.length;i++){ rr=document.styleSheets[i].cssRules; for(j=0;j<rr.length;j++){ if(rr[j].selectorText==='body #attract'&&rr[j].style.backdropFilter) blur=rr[j].style.backdropFilter; } } }catch(e){}
     if(blur.indexOf('blur(5px)')<0) return 'the attract blur is '+blur;
     return null; }},
  {v:'30.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'31.19',what:")) { throw "check 31.19 is in the fixture already" }

SubRx @'
  {v:'31.18',what:
'@ @'
  {v:'31.19',what:'cw-title-sharp, his Q52/Q54: the glass behind the scoreboard and how-to blurs 2px so the live fight reads and the 4K frame stays cheap',
   run:function(){
     var blur='', rr, i, j;
     try{ for(i=0;i<document.styleSheets.length;i++){ rr=document.styleSheets[i].cssRules; for(j=0;j<rr.length;j++){ if(rr[j].selectorText==='body #attract'&&rr[j].style.backdropFilter) blur=rr[j].style.backdropFilter; } } }catch(e){}
     if(blur.indexOf('blur(2px)')<0) return 'the attract blur is '+blur;
     return null; }},
  {v:'31.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

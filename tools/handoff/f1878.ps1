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

if ($s.Contains("  {v:'18.78',what:")) { throw "check 18.78 is in the fixture already" }

SubRx @'
  {v:'18.77',what:
'@ @'
  {v:'18.78',what:'text in the framed windows stays inside the frame: the text lines of the Terms, Party, gambler and bar windows are capped at 1060 like their lists, not the general 1180',
   run:function(){
     var bad=[], ids=['termsmodal','partymodal','gamblemodal','barmodal'], n=0;
     ids.forEach(function(id){ var m=document.getElementById(id); if(!m) return; var s=m.querySelector('.msub'); if(!s) return; n++; var mw=getComputedStyle(s).maxWidth; if(mw!=='1060px') bad.push(id+' text lines are capped at '+mw); });
     if(!n) return 'SKIP: no framed windows here';
     return bad.length?bad.join('; '):null; }},
  {v:'18.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

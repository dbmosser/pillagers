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

if ($s.Contains("  {v:'16.91',what:")) { throw "check 16.91 is in the fixture already" }

SubRx @'
  {v:'16.90',what:
'@ @'
  {v:'16.91',what:'the PARTY window invite code boxes are set in the game font, as every text box is',
   run:function(){
     var ids=['partyin','partycode','partyreplyin'], bad=[], i, el, f;
     for(i=0;i<ids.length;i++){
       el=document.getElementById(ids[i]); if(!el) continue;
       f=getComputedStyle(el).fontFamily||'';
       if(f.indexOf('Rubik')<0) bad.push(ids[i]+' is set in '+f);
     }
     if(!document.getElementById('partycode')) return 'SKIP: this build has no party code box';
     return bad.length?bad.join('; '):null; }},
  {v:'16.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

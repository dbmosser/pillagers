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

if ($s.Contains("  {v:'17.09',what:")) { throw "check 17.09 is in the fixture already" }

SubRx @'
  {v:'17.08',what:
'@ @'
  {v:'17.09',what:'the what is new card is stamped within 0.15 of the build and has a line on the two-player fixes of the co-op hunt',
   run:function(){
     if(typeof WHATSNEW==='undefined'||typeof WHATSNEW_VER==='undefined'||typeof VER==='undefined') return 'SKIP: this build has no what is new card';
     var bad=[], d=parseFloat(VER)-parseFloat(WHATSNEW_VER), needle='TWO-PLAYER GAMES'+' ON ONE PC';
     if(!(d<=0.15+1e-9)) bad.push('the card is stamped v'+WHATSNEW_VER+', '+d.toFixed(2)+' behind v'+VER);
     if(!WHATSNEW.some(function(l){ return String(l).indexOf(needle)>=0; })) bad.push('no line of the card names the two-player fixes');
     return bad.length?bad.join('; '):null; }},
  {v:'17.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

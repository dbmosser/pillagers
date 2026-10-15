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

if ($s.Contains("  {v:'27.88',what:")) { throw "check 27.88 is in the fixture already" }

SubRx @'
  {v:'27.87',what:
'@ @'
  {v:'27.88',what:'partyp6, from the cloud review (19): the What is New card does not say power-ups are shared (each window drops for its own kills and the pickups are its own); it says each player has his own',
   run:function(){
     if(typeof WHATSNEW==='undefined'||!WHATSNEW||!WHATSNEW.length) return 'SKIP: no What is New card here';
     var bad=[], txt=WHATSNEW.join('|'), line=null, i;
     for(i=0;i<WHATSNEW.length;i++) if(/^TWO PLAYER FLOW/.test(WHATSNEW[i])) line=WHATSNEW[i];
     if(!line) return 'SKIP: the card has no two player line';
     if(txt.indexOf('Power-ups'+' are shared')>=0) bad.push('the card still says power-ups are shared');
     if(!/Each player has his own power-ups/.test(line)) bad.push('the two player line does not say each player has his own power-ups: '+line);
     return bad.length?bad.join('; '):null; }},
  {v:'27.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

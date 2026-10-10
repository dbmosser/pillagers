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

if ($s.Contains("  {v:'21.89',what:")) { throw "check 21.89 is in the fixture already" }

SubRx @'
  {v:'21.88',what:
'@ @'
  {v:'21.89',what:'the what is new card is stamped within 0.15 of the build and leads with the raid text news, shown whole',
   run:function(){
     if(typeof WHATSNEW==='undefined'||typeof WHATSNEW_VER==='undefined'||typeof VER==='undefined'||typeof wnShort!=='function') return 'SKIP: this build has no what is new card';
     if(parseFloat(WHATSNEW_VER)>21.89+0.001) return 'SKIP: the card has moved on, a later card check covers it';
     var bad=[], d=parseFloat(VER)-parseFloat(WHATSNEW_VER);
     if(!(d<=0.15+1e-9)) bad.push('the card is stamped v'+WHATSNEW_VER+', '+d.toFixed(2)+' behind v'+VER);
     if(String(WHATSNEW[1]).indexOf('RAID'+' TEXT')!==0) bad.push('the card does not lead with the raid text news');
     else if(wnShort(WHATSNEW[1]).slice(-3)==='...') bad.push('the new line is cut on the card');
     if(String(WHATSNEW[0]).indexOf('THIS IS AN'+' ALPHA')!==0) bad.push('the card no longer opens with the alpha line');
     return bad.length?bad.join('; '):null; }},
  {v:'21.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

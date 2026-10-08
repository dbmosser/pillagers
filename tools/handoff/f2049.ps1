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

if ($s.Contains("  {v:'20.49',what:")) { throw "check 20.49 is in the fixture already" }

SubRx @'
  {v:'20.48',what:
'@ @'
  {v:'20.49',what:'the what is new card is stamped within 0.15 of the build and its co-op line is shown whole, not cut off with dots',
   run:function(){
     if(typeof WHATSNEW==='undefined'||typeof WHATSNEW_VER==='undefined'||typeof wnShort!=='function') return 'SKIP: this build has no what is new card';
     if(parseFloat(WHATSNEW_VER)>20.49+0.001) return 'SKIP: the card has moved on, a later card check covers it';
     var bad=[], d=parseFloat(VER)-parseFloat(WHATSNEW_VER), s=String(WHATSNEW[1]||''), w;
     if(!(d<=0.15+1e-9)) bad.push('the card is stamped v'+WHATSNEW_VER+', '+d.toFixed(2)+' behind v'+VER);
     if(s.indexOf('CO-OP HOLDS'+' TOGETHER')!==0) bad.push('the card does not lead with the co-op news');
     w=wnShort(s);
     if(w.slice(-3)==='...') bad.push('the co-op line is cut on the card: '+w.slice(-60));
     return bad.length?bad.join('; '):null; }},
  {v:'20.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

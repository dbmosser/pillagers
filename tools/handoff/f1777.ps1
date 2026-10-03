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

if ($s.Contains("  {v:'17.77',what:")) { throw "check 17.77 is in the fixture already" }

SubRx @'
  {v:'17.76',what:
'@ @'
  {v:'17.77',what:'the new-in card shows the newest five notes, each cut to its headline and the start of what follows, and the party note no longer says a host leaving abandons the run for everyone',
   run:function(){
     if(typeof wnShort!=='function'||typeof WN_SHOW==='undefined') return 'the card draws every note in full';
     var bad=[], long='A HEADLINE IN CAPS. '+new Array(60).join('word ')+'end.', s=wnShort(long), needle='abandoned for '+'everyone';
     if(WN_SHOW!==5) bad.push('the card shows '+WN_SHOW+' notes');
     if(s.indexOf('A HEADLINE IN CAPS.')!==0) bad.push('the headline was lost: '+s.slice(0,40));
     if(s.length>200||s.slice(-3)!=='...') bad.push('a long note was not cut ('+s.length+' chars)');
     if(wnShort('SHORT ONE. And a tail.')!=='SHORT ONE. And a tail.') bad.push('a short note was changed');
     if(WHATSNEW.some(function(l){ return String(l).indexOf(needle)>=0; })) bad.push('a note still says a host leaving abandons the run for everyone');
     return bad.length?bad.join('; '):null; }},
  {v:'17.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

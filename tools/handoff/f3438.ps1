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

if ($s.Contains("  {v:'34.38',what:")) { throw "check 34.38 is in the fixture already" }

SubRx @'
  {v:'34.37',what:
'@ @'
  {v:'34.38',what:'the Settings pane hint keeps its first clause whole and marks a cut with an ellipsis, never a bare mid-sentence stop',
   run:function(){
     var long1='this words go on and on and on and on and on and on and on and on and on and on and on and on and on and on and on', s, bad=[];
     if(typeof setHintShort!=='function') return 'no setHintShort';
     s=setHintShort('turns the words on: click any word to rewrite it');
     if(s!=='turns the words on') bad.push('a hint with a colon is not cut at the clause: '+s);
     s=setHintShort('a short hint that fits whole, with a comma');
     if(s!=='a short hint that fits whole, with a comma') bad.push('a short hint was changed: '+s);
     s=setHintShort(long1);
     if(s.charAt(s.length-1)!=='\u2026') bad.push('a cut hint has no ellipsis: '+s);
     if(s.length>91) bad.push('a cut hint is still long: '+s.length);
     return bad.length?bad.join('; '):null;
   }},
  {v:'34.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

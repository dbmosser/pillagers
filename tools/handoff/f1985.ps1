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

if ($s.Contains("  {v:'19.85',what:")) { throw "check 19.85 is in the fixture already" }

SubRx @'
  {v:'19.84',what:
'@ @'
  {v:'19.85',what:'a What is New line ends at a whole sentence when one fits: a long line is cut at its last full stop inside the limit, not mid-sentence with dots',
   run:function(){
     if(typeof wnShort!=='function'||typeof WN_TAIL!=='number') return 'SKIP: no card shortener here';
     var bad=[], s1, s2, r1, r2, pad=function(n){ return new Array(n+1).join('zq '); };
     s1='ZQHEAD. '+pad(Math.round(WN_TAIL*0.25))+'zqend. '+pad(WN_TAIL);
     r1=wnShort(s1);
     if(!/zqend\.$/.test(r1)) bad.push('a line with a sentence end inside the limit ends as ...'+r1.slice(-24));
     s2='ZQHEAD. '+pad(WN_TAIL);
     r2=wnShort(s2);
     if(!/\.\.\.$/.test(r2)) bad.push('control: a line with no sentence end inside the limit lost its dots');
     return bad.length?bad.join('; '):null; }},
  {v:'19.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

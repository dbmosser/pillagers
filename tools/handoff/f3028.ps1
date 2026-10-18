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

if ($s.Contains("  {v:'30.28',what:")) { throw "check 30.28 is in the fixture already" }

SubRx @'
  {v:'30.27',what:
'@ @'
  {v:'30.28',what:'no swearing in the baked on-screen lines (his answer Q76): the three lines that had it keep their attitude without it',
   run:function(){
     if(typeof TXSHIP!=='object'||!TXSHIP) return 'no TXSHIP table';
     var bad=[], k, v, rx=/\b(shit\w*|fuck\w*|bastards?|damn\w*|hell|bitch\w*|crap\w*|asshole|ass|piss\w*)\b/i, n=0, sw=0;
     for(k in TXSHIP){ v=String(TXSHIP[k]); n++; if(rx.test(v)){ sw++; bad.push('swearing in: '+v.slice(0,60)); } }
     if(n<20) bad.push('the table is gone ('+n+' lines)');
     var cs=0, rg=0, wi=0;
     for(k in TXSHIP){ v=String(TXSHIP[k]); if(/cheapskate/.test(v)) cs++; if(/about to get real/.test(v)) rg++; if(/wild idea Claude/.test(v)) wi++; }
     if(cs!==1||rg!==1||wi!==1) bad.push('the cleaned lines lost their attitude (cheapskate '+cs+', get real '+rg+', wild idea '+wi+')');
     return bad.length?bad.join('; '):null; }},
  {v:'30.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

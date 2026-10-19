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

if ($s.Contains("  {v:'31.97',what:")) { throw "check 31.97 is in the fixture already" }

SubRx @'
  {v:'31.96',what:
'@ @'
  {v:'31.97',what:'the what is new card shows each of its three notes whole (the same text wnShort gives), never cut at a clause (the critic on 40)',
   run:function(){
     if(typeof wnHead!=='function'||typeof wnList!=='function'||typeof wnShort!=='function') return 'SKIP: no what is new helpers in this build';
     var bad=[], L2=wnList(), k, a, b;
     for(k=0;k<Math.min(3,L2.length);k++){ a=wnHead(L2[k]); b=wnShort(L2[k]); if(a!==b) bad.push('note '+(k+1)+' is cut to "'+a+'" not the whole "'+b+'"'); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

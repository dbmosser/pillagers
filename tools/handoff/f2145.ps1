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

if ($s.Contains("  {v:'21.45',what:")) { throw "check 21.45 is in the fixture already" }

SubRx @'
  {v:'21.44',what:
'@ @'
  {v:'21.45',what:'the YOUR STATS heading says what its number counts: the runs logged',
   run:function(){
     if(typeof renderHub!=='function') return 'SKIP: no stats here';
     var el=document.getElementById('logct'), n;
     if(!el) return 'SKIP: no run count on the stats heading';
     try{ renderHub(); }catch(e){ return 'threw: '+(e&&e.message||e); }
     n=(P.log||[]).length;
     if(String(el.textContent).indexOf(String(n))!==0) return 'SKIP: the heading count is not the run count ('+el.textContent+')';
     if(!/RUNS?$/.test(String(el.textContent))) return 'the stats heading shows '+JSON.stringify(el.textContent)+' with nothing saying it counts runs';
     return null; }},
  {v:'21.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

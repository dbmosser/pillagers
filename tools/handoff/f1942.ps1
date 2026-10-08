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

if ($s.Contains("  {v:'19.42',what:")) { throw "check 19.42 is in the fixture already" }

SubRx @'
  {v:'19.41',what:
'@ @'
  {v:'19.42',what:'the PARTY window TRADING line stays in the window: it is no wider than the other lines of the window',
   run:function(){
     if(!window.__station||!window.__hubEnter) return 'SKIP: this fixture cannot open the PARTY window';
     var bad=[], t, tr, st, a, b;
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('lift','KeyF');
       tr=document.getElementById('partytrade'); st=document.querySelector('#partymodal .msub');
       if(!tr||!st||!document.getElementById('partymodal').classList.contains('on')) return 'SKIP: the PARTY window did not open';
       a=tr.getBoundingClientRect(); b=st.getBoundingClientRect();
       if(a.width>b.width+2) bad.push('the TRADING line is '+Math.round(a.width)+' px wide against '+Math.round(b.width)+' for the other lines');
       if(a.left<b.left-2) bad.push('the TRADING line starts left of the window text');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

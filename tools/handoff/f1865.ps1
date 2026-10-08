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

if ($s.Contains("  {v:'18.65',what:")) { throw "check 18.65 is in the fixture already" }

SubRx @'
  {v:'18.64',what:
'@ @'
  {v:'18.65',what:'the sector cards read at a glance: on the lift page the sector name is a heading of 24 pixels or more and its facts line 15 or more',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function') return 'SKIP: no stations here';
     var bad=[], t, row, b, hs, f;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('lift','KeyE');
       row=document.querySelector('.modal.on .sectorpick');
       if(!row) return 'SKIP: the lift page drew no sector card';
       b=row.querySelector('b'); hs=row.querySelectorAll('.hint');
       if(!b||hs.length<2) return 'SKIP: the sector card has another shape';
       f=parseFloat(getComputedStyle(b).fontSize); if(!(f>=24)) bad.push('the sector name is '+f+'px');
       f=parseFloat(getComputedStyle(hs[hs.length-1]).fontSize); if(!(f>=15)) bad.push('the facts line is '+f+'px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

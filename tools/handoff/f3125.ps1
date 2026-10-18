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

if ($s.Contains("  {v:'31.25',what:")) { throw "check 31.25 is in the fixture already" }

SubRx @'
  {v:'31.24',what:
'@ @'
  {v:'31.25',what:'the career corner readout is one row: credits, XP, stash and bag sit on the same line, the stash and bag figures are not a second line under it (his answer Q58)',
   run:function(){
     if(typeof syncTopRight!=='function') return 'SKIP: no syncTopRight';
     var el=document.getElementById('topright'); if(!el) return 'SKIP: no corner readout';
     var bad=[], sub, r, rs, cs;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       _trLast=''; syncTopRight();
       sub=el.querySelector('.trsub'); if(!sub) return 'the readout has no stash and bag part';
       cs=getComputedStyle(sub);
       if(cs.position==='absolute') bad.push('the stash and bag part is still positioned under the readout');
       r=el.getBoundingClientRect(); rs=sub.getBoundingClientRect();
       if(!(rs.height>0)) bad.push('the stash and bag part has no size');
       if(rs.bottom>r.bottom+2||rs.top<r.top-2) bad.push('the stash and bag part is outside the readout row (top '+Math.round(rs.top)+' bottom '+Math.round(rs.bottom)+' against '+Math.round(r.top)+'..'+Math.round(r.bottom)+')');
       if(!/CREDITS/.test(el.textContent)||!/\bXP\b/.test(el.textContent)||!/STASH/.test(el.textContent)||!/BAG/.test(el.textContent)) bad.push('the one row lost a label ("'+el.textContent+'")');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

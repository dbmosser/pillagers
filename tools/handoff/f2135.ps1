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

if ($s.Contains("  {v:'21.35',what:")) { throw "check 21.35 is in the fixture already" }

SubRx @'
  {v:'21.34',what:
'@ @'
  {v:'21.35',what:'on the Mainframe CONTRACTS tab the CLAIM ALL bar has a gap under it: the contract list and the detail card start clear of its bottom edge instead of sitting flush on it',
   run:function(){
     if(!(window.__hubEnter&&window.__station)) return 'SKIP: no Undercroft here';
     var bad=[], r, cb, cl, cd, pane, a, b, c, gap;
     try{
       __topClear(); __hubEnter();
       r=__station('mf','KeyE');
       cb=document.getElementById('conclaimall'); cl=document.getElementById('contracts'); cd=document.getElementById('condetail'); pane=document.getElementById('opane_con');
       if(!cb||!cl||!pane) return 'SKIP: no CONTRACTS tab in this build';
       if(getComputedStyle(pane).display==='none') return 'SKIP: staging: the CONTRACTS tab did not open ('+JSON.stringify(r)+')';
       a=cb.getBoundingClientRect(); b=cl.getBoundingClientRect();
       if(!(a.height>0&&b.height>0)) return 'SKIP: staging: the claim bar or the list has no size here';
       gap=b.top-a.bottom;
       if(!(gap>=5)) bad.push('the contract list starts '+gap.toFixed(1)+' px below the CLAIM ALL bar (flush on it)');
       if(cd){ c=cd.getBoundingClientRect(); if(c.height>0&&!(c.top-a.bottom>=5)) bad.push('the detail card starts '+(c.top-a.bottom).toFixed(1)+' px below the CLAIM ALL bar'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __hubEnter(); }catch(_h){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'24.99',what:")) { throw "check 24.99 is in the fixture already" }

SubRx @'
  {v:'24.98',what:
'@ @'
  {v:'24.99',what:'his #50 (UI redesign ui5q2n): the Mainframe CLAIM ALL bar and the stash SELL bar fold away when there is nothing to claim or sell, and the claim bar is back when a contract is done',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], cb, c=null, p0, i, sb;
     try{
       __topClear(); __hubEnter(); __station('mf','KeyE');
       cb=document.getElementById('conclaimall');
       if(!cb) return 'SKIP: no CLAIM ALL here';
       for(i=0;i<P.contracts.length;i++) if(P.contracts[i]&&P.contracts[i].prog<P.contracts[i].n){ c=P.contracts[i]; break; }
       var anyDone=false; for(i=0;i<P.contracts.length;i++) if(P.contracts[i]&&P.contracts[i].prog>=P.contracts[i].n) anyDone=true;
       if(!anyDone&&getComputedStyle(cb).display!=='none') bad.push('the greyed CLAIM ALL bar shows with nothing to claim');
       if(c){ p0=c.prog; c.prog=c.n; renderHub(); if(getComputedStyle(document.getElementById('conclaimall')).display==='none') bad.push('CLAIM ALL is hidden with a contract done'); c.prog=p0; renderHub(); }
       __topClear(); __hubEnter();
       var nsell=0; for(i=0;i<P.stash.length;i++) if(sellable(P.stash[i])) nsell++;
       __station('term','KeyE');
       sb=document.getElementById('sellall');
       if(!nsell&&sb&&getComputedStyle(sb).display!=='none') bad.push('the greyed SELL bar shows with nothing to sell');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ renderHub(); }catch(_r){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

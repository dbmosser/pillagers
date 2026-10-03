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

if ($s.Contains("  {v:'17.89',what:")) { throw "check 17.89 is in the fixture already" }

SubRx @'
  {v:'17.88',what:
'@ @'
  {v:'17.89',what:'a first raid is pointed at: in the stash, a player with no runs and nothing packed sees FIRST RAID: drag a gun and two heals in here, then go up at ENTER RAID!; a player with runs behind him does not',
   run:function(){
     if(typeof renderKitCol!=='function') return 'SKIP: no stash in this fixture';
     var el=document.getElementById('firstkit'); if(!el) return 'the stash gives a first raid no pointer';
     var bad=[], r0=P.runs, k0=P.kit, shown;
     try{
       P.runs=0; P.kit=[]; renderKitCol(); shown=el.style.display!=='none';
       if(!shown) bad.push('a new player with nothing packed does not see the first raid pointer');
       if(!/FIRST RAID/.test(el.textContent)||!/ENTER RAID/.test(el.textContent)) bad.push('the pointer reads '+JSON.stringify(el.textContent));
       P.runs=3; renderKitCol(); if(el.style.display!=='none') bad.push('a player with three runs still sees the first raid pointer');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.runs=r0; P.kit=k0; try{ renderKitCol(); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

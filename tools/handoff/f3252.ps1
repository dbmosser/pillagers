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

if ($s.Contains("  {v:'32.52',what:")) { throw "check 32.52 is in the fixture already" }

SubRx @'
  {v:'32.51',what:
'@ @'
  {v:'32.52',what:'the pre-raid page second pass: the map canvas is drawn at 960 so its names are sharp, the selected chip is a quiet fill with a left bar and not a lime outline, and the ascend plate is 60 px',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__applyLoaded)||typeof renderSector!=='function') return 'SKIP: no pre-raid page';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), cv, d, on, bc;
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.freeKit=0; q.kitPick='mine'; q.stash=['medkit']; q.kit=[]; q.cond='day';
       __hubEnter(); shut(); renderSector(); openModal('sectormodal');
       cv=sm.querySelector('canvas.secprev'); d=document.getElementById('sectordeploy'); on=document.getElementById('condday');
       if(!cv||!d||!on) return 'the pre-raid page is not drawn';
       if(cv._lw!==960) bad.push('the map canvas is drawn at '+cv._lw+' wide, not 960');
       if(parseFloat(getComputedStyle(d).height)>62) bad.push('the ascend plate is '+getComputedStyle(d).height+' high, not 60');
       bc=getComputedStyle(on).borderTopColor;
       if(bc==='rgb(230, 255, 61)') bad.push('the selected day chip still has a full lime outline');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ shut(); }catch(_s){} try{ if(snap) __applyLoaded(snap); }catch(_a){} try{ __cleanProfile(); }catch(_c){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

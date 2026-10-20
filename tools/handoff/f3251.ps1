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

if ($s.Contains("  {v:'32.51',what:")) { throw "check 32.51 is in the fixture already" }

SubRx @'
  {v:'32.50',what:
'@ @'
  {v:'32.51',what:'the pre-raid page fixes from the critic: pack rows are 46 px with 36 px steppers, one gun chip, a quiet no armour row with no amber fill, and no saves as you go line',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__applyLoaded)||typeof renderSector!=='function') return 'SKIP: no pre-raid page';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), row, wn, st, h;
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.freeKit=0; q.kitPick='mine'; q.stash=['medkit']; q.kit=[]; q.equipped='fists';
       __hubEnter(); shut(); renderSector(); openModal('sectormodal');
       row=sm.querySelector('.srprow[data-pk]'); wn=sm.querySelector('#sectorkit .wn'); st=sm.querySelector('.srprow .st button');
       if(!row||!wn||!st) return 'the pre-raid rows or the armour row are not drawn';
       if(parseFloat(getComputedStyle(row).height)<45) bad.push('a pack row is '+getComputedStyle(row).height+' high, not 46');
       if(parseFloat(getComputedStyle(st).height)<35) bad.push('a stepper is '+getComputedStyle(st).height+' high, not 36');
       if(!/rgba\(0, 0, 0, 0\)|transparent/.test(getComputedStyle(wn).backgroundColor)) bad.push('the no armour row still has a fill '+getComputedStyle(wn).backgroundColor);
       if(sm.querySelectorAll('#sectorkit .gc').length!==1) bad.push('the going up line has '+sm.querySelectorAll('#sectorkit .gc').length+' chips, not one');
       h=document.getElementById('srhints'); if(h&&/saves as you go/i.test(h.textContent)) bad.push('saves as you go is still on the page');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ shut(); }catch(_s){} try{ if(snap) __applyLoaded(snap); }catch(_a){} try{ __cleanProfile(); }catch(_c){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

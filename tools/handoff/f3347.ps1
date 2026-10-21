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

if ($s.Contains("  {v:'33.47',what:")) { throw "check 33.47 is in the fixture already" }

SubRx @'
  {v:'33.46',what:
'@ @'
  {v:'33.47',what:'the pre-raid pack rows keep one buy slot each, so a row the counter does not sell still lines its stepper up with the rest',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__applyLoaded)||typeof renderSector!=='function'||typeof packBuyHtml!=='function') return 'SKIP: no pack buy control';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), a, b, d;
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.freeKit=0; q.kitPick='mine'; q.stash=['bandage','gun_carbine']; q.kit=[]; q.equipped='fists'; q.credits=5000;
       __hubEnter(); shut(); renderSector(); openModal('sectormodal');
       a=sm.querySelector('#sectorpack [data-pk="bandage"] .st'); b=sm.querySelector('#sectorpack [data-pk="gun_carbine"] .st');
       if(!a||!b) return 'the pack rows are not drawn';
       d=Math.abs(a.getBoundingClientRect().right-b.getBoundingClientRect().right);
       if(d>1) bad.push('the steppers of a sold and an unsold row end '+d.toFixed(1)+' px apart');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ shut(); }catch(_s){} try{ if(snap) __applyLoaded(snap); }catch(_a){} try{ __cleanProfile(); }catch(_c){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'33.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'33.48',what:")) { throw "check 33.48 is in the fixture already" }

SubRx @'
  {v:'33.47',what:
'@ @'
  {v:'33.48',what:'the pre-raid pack names are shown whole beside the buy slot (the kit column is 480 px wide at most) and a buy control is never lime, which is the ascend colour',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__applyLoaded)||typeof renderSector!=='function'||typeof packBuyHtml!=='function') return 'SKIP: no pack buy control';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), n, b, k, cut=[];
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.freeKit=0; q.kitPick='mine'; q.stash=['medkit','bandage','smoke','frag','plate','gun_carbine','gun_smg']; q.kit=[]; q.equipped='fists'; q.credits=900;
       __hubEnter(); shut(); renderSector(); openModal('sectormodal');
       n=sm.querySelectorAll('#sectorpack .srprow[data-pk] .nm');
       for(k=0;k<n.length;k++) if(n[k].scrollWidth>n[k].clientWidth+1) cut.push(n[k].textContent);
       if(cut.length) bad.push('names cut to dots: '+cut.join(', '));
       b=sm.querySelector('#sectorpack .srbuy[data-pb]');
       if(!b) bad.push('no buy control drawn');
       else if(getComputedStyle(b).color==='rgb(201, 242, 59)'||getComputedStyle(b).borderTopColor===getComputedStyle(document.getElementById('sectordeploy')).backgroundColor) bad.push('the buy control uses the ascend colour');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ shut(); }catch(_s){} try{ if(snap) __applyLoaded(snap); }catch(_a){} try{ __cleanProfile(); }catch(_c){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'33.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

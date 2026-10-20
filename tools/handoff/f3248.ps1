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

if ($s.Contains("  {v:'32.48',what:")) { throw "check 32.48 is in the fixture already" }

SubRx @'
  {v:'32.47',what:
'@ @'
  {v:'32.48',what:'the pre-raid going-up chips are not cut off: the no armour chip and the kit tile sublines fit their boxes',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__applyLoaded)||typeof renderSector!=='function') return 'SKIP: no pre-raid page';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), els, i;
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.freeKit=0; q.kitPick='mine'; q.stash=['medkit']; q.kit=[];
       __hubEnter(); shut(); renderSector(); openModal('sectormodal');
       els=sm.querySelectorAll('#sectorkit .wn, #sectorkit .gc, #sectorkitpick .kitb');
       if(!els.length) return 'the pre-raid chips are not drawn';
       for(i=0;i<els.length;i++) if(els[i].scrollWidth>els[i].clientWidth+1) bad.push('a pre-raid chip is cut: '+String(els[i].textContent).trim().slice(0,40)+' ('+els[i].scrollWidth+' in '+els[i].clientWidth+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ shut(); }catch(_s){} try{ if(snap) __applyLoaded(snap); }catch(_a){} try{ __cleanProfile(); }catch(_c){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

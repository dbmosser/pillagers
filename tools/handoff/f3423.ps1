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

if ($s.Contains("  {v:'34.23',what:")) { throw "check 34.23 is in the fixture already" }

SubRx @'
  {v:'34.22',what:
'@ @'
  {v:'34.23',what:'the extracted card leads with the haul figure above the tiles, shows no season total or recovered sentence as visible text, draws an unrevealed tile as a dashed slot, and the lime button has a focus ring (the critic on 76)',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot end a raid';
     var bad=[], g, oc, st, ht, its, hid, gk, vis, cl, txt, ok=false, i, rs, j, rl;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       gk=ITEMS.gun_smg&&ITEMS.gun_smg.gk; if(gk&&P.weapons) P.weapons=P.weapons.filter(function(w){ return w!==gk; });
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bag.push('core','core','scrap','wire','cell','core','scrap','wire','cell','core','gun_smg');
       __endRaid('extract');
       oc=document.getElementById('outcome'); st=oc&&oc.querySelector('.haulstrip'); ht=document.getElementById('haultot');
       if(!st||!ht) bad.push('the card has no strip or no haul figure in the check');
       else {
         if(!(ht.compareDocumentPosition(st)&Node.DOCUMENT_POSITION_FOLLOWING)) bad.push('the haul figure sits under the tiles, not above them');
         if(+getComputedStyle(ht).fontWeight<800) bad.push('the haul figure weight is '+getComputedStyle(ht).fontWeight+', not 800');
       }
       cl=document.getElementById('oc_manifest').cloneNode(true); rs=cl.querySelectorAll('.ocsr'); for(j=0;j<rs.length;j++) rs[j].parentNode.removeChild(rs[j]);
       txt=cl.textContent||'';
       if(/of [\d,]{5,}/.test(txt)) bad.push('the season total still shows: '+(/.{0,20}of [\d,]{5,}/.exec(txt)||[''])[0]);
       if(/recovered to the armoury/i.test(txt)) bad.push('a recovered sentence still shows');
       its=oc?oc.querySelectorAll('.haulit.hid'):[];
       if(its.length&&getComputedStyle(its[0]).borderTopStyle!=='dashed') bad.push('an unrevealed tile is '+getComputedStyle(its[0]).borderTopStyle+', not a dashed slot');
       for(i=0;i<document.styleSheets.length&&!ok;i++){ try{ rl=document.styleSheets[i].cssRules; for(j=0;j<rl.length;j++){ if(/#oc_btn:focus-visible/.test(rl[j].selectorText||'')&&/solid/.test(rl[j].style.outline||rl[j].style.outlineStyle||'')){ ok=true; break; } } }catch(_s){} }
       if(!ok) bad.push('the lime button has no focus ring rule');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

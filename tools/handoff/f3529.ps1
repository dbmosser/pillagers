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

if ($s.Contains("  {v:'35.29',what:")) { throw "check 35.29 is in the fixture already" }

SubRx @'
  {v:'35.28',what:
'@ @'
  {v:'35.29',what:'cw-gunsfirst, his order 2026-10-27: on the extracted card the haul strip draws every gun first, whatever its rarity or value, the dearest gun first, and the loot after the guns keeps the value order',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot stage an extraction';
     var bad=[], g, oc, its=[], ks=[], vs=[], k, loot=false, isG, r0, ra, rb;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       // a cheap common gun and an uncommon one under nine dearer pieces of loot: by value alone both guns fall past the eight tile cap
       g.bag.push('coil','bloom','gun_pistol','codex','relay','fulgurite','gun_smg','bloom','codex','relay','coil');
       __endRaid('extract');
       oc=document.getElementById('oc_manifest'); its=oc?oc.querySelectorAll('.haulstrip .haulit'):[];
       for(k=0;k<its.length;k++){ ks.push(its[k].getAttribute('data-k')); vs.push(+its[k].getAttribute('data-v')||0); }
       if(its.length<4) bad.push('control: the haul strip drew '+its.length+' tiles');
       else {
         if(ks[0]!=='gun_smg'||ks[1]!=='gun_pistol') bad.push('the strip draws '+ks.join(',')+': not the smg then the pistol first');
         for(k=0;k<ks.length;k++){ isG=!!(ITEMS[ks[k]]&&ITEMS[ks[k]].use==='gun'); if(!isG) loot=true; else if(loot){ bad.push('a gun is drawn after loot at tile '+(k+1)); break; } }
         if(!loot) bad.push('control: no loot tile after the guns');
         for(k=3;k<ks.length;k++) if(vs[k]>vs[k-1]){ bad.push('the loot after the guns is not dearest first at tile '+(k+1)); break; }
         r0=its[0].getBoundingClientRect();
         if(r0.width>0) for(k=1;k<its.length;k++){ ra=its[k-1].getBoundingClientRect(); rb=its[k].getBoundingClientRect(); if(rb.left<=ra.left){ bad.push('tile '+(k+1)+' is not drawn to the right of tile '+k); break; } }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'35.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

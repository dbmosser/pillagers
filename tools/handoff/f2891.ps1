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

if ($s.Contains("  {v:'28.91',what:")) { throw "check 28.91 is in the fixture already" }

SubRx @'
  {v:'28.90',what:
'@ @'
  {v:'28.91',what:'the map select screen is PRE-RAID and packs wheel items, ammo, keys and a data core with plus and minus (his order: quickly pick how many of each wheel item, keys, ammo, and slot a data core there)',
   run:function(){
     if(typeof syncSectorPack!=='function') return 'there is no PRE-RAID pack row (no syncSectorPack)';
     var host, hd, b;
     function clk(k,d){ var x=host.querySelector('[data-pk="'+k+'"] [data-pd="'+d+'"]'); if(!x) return false; x.click(); return true; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.stash=['bandage','bandage','bandage','smoke','ammobox','ammobox','key_dam_vault','core']; P.kit=[]; P.freeKit=0; P.kitPick='mine'; P.intel=0;
       renderSector();
       hd=document.querySelector('#sectormodal h3');
       if(!hd||!/PRE-RAID/.test(hd.textContent)) return 'the map select heading does not say PRE-RAID';
       host=document.getElementById('sectorpack');
       if(!host||host.style.display==='none'||!host.querySelector('[data-pk]')) return 'the pack row is not shown';
       if(!clk('bandage','1')) return 'no plus button on the bandage';
       host=document.getElementById('sectorpack'); clk('bandage','1');
       host=document.getElementById('sectorpack');
       if(packedCount('bandage')!==2) return 'two plus clicks packed '+packedCount('bandage')+' bandages, not 2';
       if(!clk('bandage','max')) return 'no MAX on the bandage';
       host=document.getElementById('sectorpack');
       if(packedCount('bandage')!==3) return 'MAX packed '+packedCount('bandage')+' bandages, not 3';
       clk('bandage','-1'); host=document.getElementById('sectorpack');
       if(packedCount('bandage')!==2) return 'minus left '+packedCount('bandage')+' bandages packed, not 2';
       if(!clk('ammobox','max')) return 'no ammo chip'; host=document.getElementById('sectorpack');
       if(packedCount('ammobox')!==2) return 'MAX packed '+packedCount('ammobox')+' ammo boxes, not 2';
       if(!clk('key_dam_vault','1')) return 'no key chip'; host=document.getElementById('sectorpack');
       if(packedCount('key_dam_vault')!==1) return 'the key was not packed';
       b=host.querySelector('[data-core]'); if(!b||b.disabled) return 'no data core slot button';
       b.click();
       if(!P.intel||heldCount('core')!==0) return 'the data core did not slot (intel '+P.intel+', stash cores '+heldCount('core')+')';
       host=document.getElementById('sectorpack'); host.querySelector('[data-core]').click();
       if(P.intel||heldCount('core')!==1) return 'the data core did not come back out';
       P.kitPick='best'; syncSectorKit();
       if(document.getElementById('sectorpack').style.display!=='none') return 'the pack row still shows with a kit pick';
       return null;
     } finally {
       try{ __cleanProfile(); }catch(_e){}
       __topClear();
     } }},
  {v:'28.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

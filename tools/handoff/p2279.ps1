$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# HEAL AND PLATE LINES IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    say((p.healQ>0)?'Already healing.':'Already at full');
'@ @'
    // v22.79 (tr6fixa), the review of raid text batch 6: HIS ORDER (2026-10-09), a raid line is a short caps callout. The heal and
    // plate refusals and the plate landing were sentences; they are ALREADY HEALING, HEALTH FULL, BANDAGES STOP AT 85 (read from
    // healCeil, with You need a Medkit. as the detail), NO MEDICAL SUPPLIES, ALREADY APPLYING and ARMOUR PLATE SLOTTED.
    say((p.healQ>0)?'ALREADY HEALING':'HEALTH FULL');
'@

SubRx @'
    say(_anyHeal?'Only bandages left, and they will not take you past '+
                 Math.round(healCeil(ITEMS.bandage))+'. You need a Medkit.'
               :'No medical supplies');
'@ @'
    if(_anyHeal) say('BANDAGES STOP AT '+Math.round(healCeil(ITEMS.bandage)),'info',{sub:'You need a Medkit.'});
    else say('NO MEDICAL SUPPLIES');
'@

SubRx @'
  if(p.prep){ say('Already applying '+(ITEMS[p.prep.key]?ITEMS[p.prep.key].name:'something')+'.'); return false; }
'@ @'
  if(p.prep){ say('ALREADY APPLYING','info',{sub:String(ITEMS[p.prep.key]?ITEMS[p.prep.key].name:'Medical').toUpperCase()}); return false; }
'@

SubRx @'
        say((_pp.healQ>0)?'Already healing.':'Already at full'); return;
'@ @'
        say((_pp.healQ>0)?'ALREADY HEALING':'HEALTH FULL'); return;   // v22.79 (tr6fixa): the caps callouts
'@

SubRx @'
      if(healReach(_pp)>=healCeil(ait)){ say(ait.name+' will not take you past '+Math.round(healCeil(ait))+'.'); return; }
'@ @'
      if(healReach(_pp)>=healCeil(ait)){ say((ait.name+' stops at '+Math.round(healCeil(ait))).toUpperCase()); return; }
'@

SubRx @'
      if(_pp.prep){ say('Already applying '+(ITEMS[_pp.prep.key]?ITEMS[_pp.prep.key].name:'something')+'.'); return; }
'@ @'
      if(_pp.prep){ say('ALREADY APPLYING','info',{sub:String(ITEMS[_pp.prep.key]?ITEMS[_pp.prep.key].name:'Medical').toUpperCase()}); return; }
'@

SubRx @'
    if(ix<0&&!(ait.use==='gun')){ say('No '+ait.name+' left.'); return; }
'@ @'
    if(ix<0&&!(ait.use==='gun')){ say(('No '+ait.name+' left').toUpperCase()); return; }   // v22.79 (tr6fixa): NO BANDAGE LEFT
'@

SubRx @'
    say(it.name+' slotted. Armour '+Math.round(p.armor)+'.');
'@ @'
    say((it.name+' slotted').toUpperCase(),'info',{sub:'Armour '+Math.round(p.armor)+'.'});   // v22.79 (tr6fixa): ARMOUR PLATE SLOTTED  .  Armour 60.
'@

SubRx @'
  if(!key||!ITEMS[key]){ if(!quiet) say('Select a Bandage, a Medkit or a plate on your tactical belt to patch up '+nm+'.'); return false; }
'@ @'
  // v22.79 (tr6fixa): the caps callouts. SELECT A HEAL with the three items as the detail; the teammate refusals name him in caps
  // (MOTH ARMOUR FULL, MOTH DOES NOT NEED IT, at most 33 characters with a 16 letter name), and ALREADY SLOTTING or ALREADY APPLYING
  // with the item as the detail, as the plate verb already says it.
  if(!key||!ITEMS[key]){ if(!quiet) say('SELECT A HEAL','info',{sub:'Bandage, Medkit or Armour Plate.'}); return false; }
'@

SubRx @'
  if(arm){ if(g.ac>0&&g.ar>=g.ac){ say('Armour on '+nm+' is full.'); return false; } if(p.prepA){ say('Already slotting a plate.'); return false; } }
'@ @'
  if(arm){ if(g.ac>0&&g.ar>=g.ac){ say(String(nm).toUpperCase()+' ARMOUR FULL'); return false; } if(p.prepA){ say('ALREADY SLOTTING','info',{sub:String(ITEMS[p.prepA.key]?ITEMS[p.prepA.key].name:'Plate').toUpperCase()}); return false; } }
'@

SubRx @'
  else { ceil=it.capHp?Math.min(g.mh||100,it.capHp):(g.mh||100); if(g.hp>=ceil){ say(nm+' does not need a '+it.name+'.'); return false; } if(p.prep){ say('Already applying '+(ITEMS[p.prep.key]?ITEMS[p.prep.key].name:'something')+'.'); return false; } }
'@ @'
  else { ceil=it.capHp?Math.min(g.mh||100,it.capHp):(g.mh||100); if(g.hp>=ceil){ say(String(nm).toUpperCase()+' DOES NOT NEED IT'); return false; } if(p.prep){ say('ALREADY APPLYING','info',{sub:String(ITEMS[p.prep.key]?ITEMS[p.prep.key].name:'Medical').toUpperCase()}); return false; } }
'@

SubRx @'
  bi=G.bag.indexOf(key); if(bi<0){ say('No '+it.name+' left.'); return false; }
'@ @'
  bi=G.bag.indexOf(key); if(bi<0){ say(('No '+it.name+' left').toUpperCase()); return false; }
'@

SubRx @'
var VER='22.78';
'@ @'
var VER='22.79';
'@

$pat = "(?m)^  now:'v22\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.79: The heal and plate refusals read as short caps callouts, such as HEALTH FULL and BANDAGES STOP AT 85. Check 22.79 fails on v22.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

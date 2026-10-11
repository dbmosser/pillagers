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

# HEAL AND ARMOUR LINES IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    say(it&&it.hot>0&&CFG.healOverTime!==0
      ?(it.name+' is healing you, '+fmtMS(Math.max(0,healReach(p)-p.hp)/(p.healRate||10)))
      :'Patched up');
'@ @'
    // v22.xx, the raid text rewrite (R51): HEAL AND ARMOUR LINES IN CAPS. A heal over time said Bandage is healing you, 2 sec, which
    // the status icon on the left already shows as HEALING with its seconds (his v15.40 ring), so it is no longer said. A heal that
    // lands at once still says PATCHED UP.
    if(!(it&&it.hot>0&&CFG.healOverTime!==0)) say('PATCHED UP');
'@

SubRx @'
  if(ix<0){ say('No stim.'); return false; }
'@ @'
  if(ix<0){ say(('No '+((ITEMS.stim&&ITEMS.stim.name)||'Stim')+' left').toUpperCase()); return false; }   // v22.xx (R51): NO STIM INJECTOR LEFT
'@

SubRx @'
  blip('pick'); say('Stim. Ten seconds of legs.');
'@ @'
  blip('pick'); say((((ITEMS.stim&&ITEMS.stim.name)||'Stim')+' active').toUpperCase(),'info',{sub:STIM_SEC+'s of unlimited stamina.'});   // v22.xx (R51): STIM INJECTOR ACTIVE, the seconds from STIM_SEC
'@

SubRx @'
  if(p.stimT>0){ p.stimT-=dt; if(p.stimT<=0){ p.stimT=0; if(!G.sim) say('The stim wears off.'); } }
'@ @'
  if(p.stimT>0){ p.stimT-=dt; if(p.stimT<=0){ p.stimT=0; if(!G.sim) say((((ITEMS.stim&&ITEMS.stim.name)||'Stim')+' wore off').toUpperCase(),'chat'); } }   // v22.xx (R51): STIM INJECTOR WORE OFF
'@

SubRx @'
  G.tel.revives++; blip('pick'); say('Back on your feet. Self-revive used.');
'@ @'
  G.tel.revives++; blip('pick'); say('SELF-REVIVE USED','info',{sub:'Back on your feet.'});   // v22.xx (R51): the caps headline, the rest as the detail
'@

SubRx @'
    say(nm+why+(it?it.name:'It')+' kept.'); return false;
'@ @'
    say(String(nm+why).replace(/[.\s]+$/,'').toUpperCase(),'info',{sub:(it?it.name:'It')+' kept.'}); return false;   // v22.xx (R51): NAME MOVED AWAY with Bandage kept. as the detail
'@

SubRx @'
  say((it&&it.use==='armor')?('Plate slotted for '+nm+'.'):('Patched up '+nm+'.')); blip('pick');
'@ @'
  say(((it&&it.use==='armor')?('Plate slotted for '+nm):('Patched up '+nm)).toUpperCase(),'ally'); blip('pick');   // v22.xx (R51): PLATE SLOTTED FOR NAME, PATCHED UP NAME
'@

SubRx @'
  if(it.use==='armor'){ p.armor=Math.min(armorCap(),(p.armor||0)+(it.amt||0)); say(nm+' slotted a plate for you. Armour '+Math.round(p.armor)+'.'); }
'@ @'
  if(it.use==='armor'){ p.armor=Math.min(armorCap(),(p.armor||0)+(it.amt||0)); say(('Plate from '+nm).toUpperCase(),'ally',{sub:'Armour '+Math.round(p.armor)+'.'}); }   // v22.xx (R51): PLATE FROM NAME, within 34 with a 16 letter name
'@

SubRx @'
    applyHeal(key); say(nm+' patched you up.');
'@ @'
    applyHeal(key); say((nm+' patched you up').toUpperCase(),'ally');   // v22.xx (R51)
'@

SubRx @'
  say(nm+((why==='full')?' is already healing. ':' could not take it. ')+it.name+' kept.'); blip('pick');
'@ @'
  say((nm+((why==='full')?' already healing':' could not take it')).toUpperCase(),'info',{sub:it.name+' kept.'}); blip('pick');   // v22.xx (R51): NAME ALREADY HEALING with Bandage kept. as the detail
'@

SubRx @'
var VER='23.03';
'@ @'
var VER='23.04';
'@

$pat = "(?m)^  now:'v23\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.04: Heal, stim, self-revive and teammate aid lines read as short caps callouts, and a heal over time shows on its status icon instead of a line. Check 23.04 fails on v23.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

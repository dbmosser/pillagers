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

# the key lists and tips name the keys as they are now (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ['WEAPONS','Keys 1 to 4 bring up'],   // v21.93: four gun keys
  ['','your guns.'],
'@ @'
  // v31.33 (cw-gearrules): the gun keys are 1 to 8 and 0 (GUN_CLASSES: a key for each kind of gun, the rocket launcher on 0; key 9 does nothing). Said short, lower case.
  ['WEAPONS','keys 1 to 8 and 0 bring up'],
  ['','your guns, a key for each kind.'],
'@

SubRx @'
  ['','so keep one on a key.'],
'@ @'
  ['','so use one from the item wheel.'],
'@

SubRx @'
  ['TACTICAL BELT','1-4 guns, 5-6 throw,'],
  ['','7-8 heal, 9 plate. G, H use'],
  ['','the pick. U, J pick the next.'],
  ['','Gun stays in hand.'],
'@ @'
  // v31.33 (cw-gearrules): this block taught 1-4 guns, 5-6 throw, 7-8 heal, 9 plate and the G, H, U, J keys. All of them went with the item wheel (wheel4): hold Q.
  ['ITEM WHEEL','hold q, aim at a grenade,'],
  ['','a heal or a plate, and let go.'],
'@

SubRx @'
  ['KeyH','heal (tap), armour plate (hold)'],['KeyG',
'@ @'
  // v31.33 (cw-gearrules): the H row is gone. H tapped a heal and held a plate, but the item wheel (hold Q) took both and nothing arms the H hold any more, so a row for H listed a key that does nothing.
  ['KeyG',
'@

SubRx @'
'KeyV','KeyF','KeyH','KeyG']
'@ @'
'KeyV','KeyF','KeyG']
'@

SubRx @'
['SELECT A GUN','1 - 9']
'@ @'
['SELECT A GUN','1 - 8, 0']
'@

SubRx @'
THE KEY LEFT OF 1 AND 1-9 CANNOT BE REBOUND.
'@ @'
THE KEY LEFT OF 1, 1-8 AND 0 CANNOT BE REBOUND.
'@

SubRx @'
  if(!padOn()){   // v25.xx (belt6b): and the key of its class
    if(state!=='hub'&&(it.use==='throw'||it.use==='heal'||it.use==='stim'||it.use==='armor')){   // v26.02 (beltkeys): the digit acts at once, G and H act on the pick, U and J move it
      var _hk=String(keyLabel(slotKeyCode(c.i),slotKeyName(c.i))), _hh=String(keyLabel('KeyH','H'));
      if(it.use==='throw') o.keys=[[_hk,'THROW'],[String(keyLabel('KeyG','G')),'THROW CHOSEN'],[String(keyLabel('KeyU','U')),'NEXT']];
      else if(it.use==='heal') o.keys=[[_hk,'HEAL'],[_hh,'HEAL CHOSEN'],[String(keyLabel('KeyJ','J')),'NEXT']];
      else if(it.use==='stim') o.keys=[[_hk,'USE'],[_hh,'USE CHOSEN'],[String(keyLabel('KeyJ','J')),'NEXT']];
      else o.keys=[[_hk,'SLOT'],['HOLD '+_hh,'PLATE']];
    }
    else if(it.use==='throw') o.keys.push([String(keyLabel('KeyG','G')),'THROW']);
    else if(it.use==='heal') o.keys.push([String(keyLabel('KeyH','H')),'HEAL']);
    else if(it.use==='armor') o.keys.push(['HOLD '+String(keyLabel('KeyH','H')),'PLATE']);
  }
'@ @'
  if(!padOn()&&state!=='hub'&&(it.use==='throw'||it.use==='heal'||it.use==='stim'||it.use==='armor')){   // v31.33 (cw-gearrules): the card named HEAL on H, THROW on G and PLATE on HOLD H. Those keys do nothing since the item wheel (wheel4), so the card names the wheel.
    o.keys=[[String(keyLabel('KeyQ','Q')),'item wheel']];
  }
'@

SubRx @'
var VER='31.32';
'@ @'
var VER='31.33';
'@

$pat = "(?m)^  now:'v31\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.33: The Keys window no longer lists an H heal row, it says the locked gun keys are 1 - 8, 0, and the controls tips point at the item wheel (hold q) instead of the old belt keys. Check 31.33 fails on v31.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

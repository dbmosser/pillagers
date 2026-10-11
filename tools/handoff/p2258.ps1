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

# BELT LINES IN THE HUD VOICE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          if(!_r8on&&_bx<0){ say(_dit.name+' is no longer in your backpack.'); dropped=true; break; }
'@ @'
          // v22.58, his order of 2026-10-09 (the shooter voice), from the review of the four-gun belt (build 5): THE BELT DRAG LINES
          // READ LIKE A SHOOTER HUD. A drop on a key, a key dragged off the belt, these refusals, a drop out of the backpack, a gift to
          // the hire, the gun swap and the plate still said whole sentences (Medkit to slot 3., Cannot equip a gun while rolling.).
          // Each is now a short capital headline with the detail under it.
          if(!_r8on&&_bx<0){ say('NOT IN BACKPACK','info',{sub:String(_dit.name).toUpperCase()}); dropped=true; break; }
'@

SubRx @'
say(_pp.roll>0?'Cannot equip a gun while rolling.':(G.paused?'Cannot equip a gun while paused.':((_pp.downed||_pp.dying)?'Cannot equip a gun while down.':'Cannot equip that right now.')));
'@ @'
say('CANNOT EQUIP','info',{sub:(_pp.roll>0?'ROLLING':(G.paused?'PAUSED':'DOWNED'))});
'@

SubRx @'
say(((_gNow&&_gNow.name)||_dit.name)+' to slot '+(HC.i+1)+'.'+_gLost);
'@ @'
say((((_gNow&&_gNow.name)||_dit.name)+' on key '+(HC.i+1)).toUpperCase(),'info',_gLost?{sub:_gLost.trim()}:null);
'@

SubRx @'
if(!equipFromBag(_bx,_gSlot)) say('Cannot equip that right now.');
'@ @'
if(!equipFromBag(_bx,_gSlot)) say('CANNOT EQUIP','info',{sub:String(_dit.name).toUpperCase()});
'@

SubRx @'
say(((_gUp&&_gUp.name)||_dit.name)+' to slot '+(HC.i+1)+'.'+_gLost+(_gunKeyHint?' '+_gunKeyHint:''));
'@ @'
var _gSub=[_gLost.trim(),_gunKeyHint].filter(function(_gs){ return !!_gs; }).join(' \u00b7 '); say((((_gUp&&_gUp.name)||_dit.name)+' on key '+(HC.i+1)).toUpperCase(),'info',_gSub?{sub:_gSub}:null);
'@

SubRx @'
say((ITEMS[d.key]?ITEMS[d.key].name:'Item')+' to slot '+(HC.i+1));
'@ @'
say(((ITEMS[d.key]?ITEMS[d.key].name:'Item')+' on key '+(HC.i+1)).toUpperCase());   // v22.58: the shooter voice
'@

SubRx @'
say((ITEMS[d.key]?ITEMS[d.key].name:'Item')+' to '+_gme.name+'.');
'@ @'
say(('Gave '+(ITEMS[d.key]?ITEMS[d.key].name:'Item')).toUpperCase(),'info',{sub:String(_gme.name).toUpperCase()});   // v22.58: the shooter voice
'@

SubRx @'
if(_ddk){ say('Dropped '+ITEMS[_ddk].name+((typeof NET==='object'&&NET&&NET.on)?'. Your teammate can search it.':''));
'@ @'
if(_ddk){ say(('Dropped '+ITEMS[_ddk].name).toUpperCase(),'info',(typeof NET==='object'&&NET&&NET.on)?{sub:'TEAM CAN LOOT'}:null);
'@

SubRx @'
if(dk){ say('Dropped '+ITEMS[dk].name+((typeof NET==='object'&&NET&&NET.on)?'. Your teammate can search it.':''));
'@ @'
if(dk){ say(('Dropped '+ITEMS[dk].name).toUpperCase(),'info',(typeof NET==='object'&&NET&&NET.on)?{sub:'TEAM CAN LOOT'}:null);   /* v22.58: the shooter voice */
'@

SubRx @'
say((ITEMS[_wasKey]?ITEMS[_wasKey].name:'Item')+' off slot '+(d.fromHot+1)+'.');
'@ @'
say(((ITEMS[_wasKey]?ITEMS[_wasKey].name:'Item')+' off key '+(d.fromHot+1)).toUpperCase());   // v22.58: the shooter voice
'@

SubRx @'
  say(pp.wep.name+' up');
'@ @'
  say((pp.wep.name+' up').toUpperCase());   // v22.58: the shooter voice, as drawGun says it
'@

SubRx @'
say('Armour is already full.');
'@ @'
say('ARMOUR FULL');   /* v22.58: the shooter voice */
'@

SubRx @'
say('Already slotting '+(ITEMS[p.prepA.key]?ITEMS[p.prepA.key].name:'a plate')+'.');
'@ @'
say('ALREADY SLOTTING','info',{sub:String(ITEMS[p.prepA.key]?ITEMS[p.prepA.key].name:'Plate').toUpperCase()});
'@

SubRx @'
say('Slotting '+it.name+'...');
'@ @'
say(('Slotting '+it.name).toUpperCase());   // v22.58: the shooter voice
'@

SubRx @'
var VER='22.57';
'@ @'
var VER='22.58';
'@

$pat = "(?m)^  now:'v22\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.58: The belt, drop, gift, swap and plate lines read like a shooter HUD. Check 22.58 fails on v22.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

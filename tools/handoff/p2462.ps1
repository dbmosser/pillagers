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

# THE VAULT KEYCARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  key_cm_deep_freeze:{name:'Deep Freeze Key',val:700,wt:1,r:'rare',c:'#ffc04a',use:'key',door:'cm_deep_freeze'},
'@ @'
  key_cm_deep_freeze:{name:'Deep Freeze Key',val:700,wt:1,r:'rare',c:'#ffc04a',use:'key',door:'cm_deep_freeze'},
  // v23.9x (feat4a), HIS ORDER (2026-10-12): "32 more interiors". The VAULT KEYCARD. door:'arc' is no map door: in a DEMO raid it opens
  // any locked room (the map rooms and the vaults the DEMO seals), anywhere else only a vault door (arc:1). keyFits says which.
  keycard:{name:'Vault Keycard',val:250,wt:1,r:'rare',c:'#7fe3d4',use:'key',door:'arc'},
'@

SubRx @'
function doorKeyIx(door){
  var i, it;
  if(!door||!G||!G.bag) return -1;
  for(i=0;i<G.bag.length;i++){ it=ITEMS[G.bag[i]]; if(it&&it.use==='key'&&it.door===door.id) return i; }
  return -1;
}
'@ @'
// v23.9x (feat4a), HIS ORDER (2026-10-12): "32 more interiors". One test for "does this key open this door", used by the door, the
// lamp on the door and the UNLOCK prompt, so the three never disagree. A map key opens its own door, as before. The Vault Keycard
// (door:'arc') opens a vault door (arc:1) anywhere and, in a DEMO raid, any locked room. door is a locked room ({id, arc}).
function keyFits(it,door){
  if(!it||it.use!=='key'||!door) return false;
  if(it.door===door.id) return true;
  return it.door==='arc'&&!!(door.arc||(G&&G.arcade));
}
function doorKeyIx(door){
  var i, it;
  if(!door||!G||!G.bag) return -1;
  for(i=0;i<G.bag.length;i++){ it=ITEMS[G.bag[i]]; if(it&&it.use==='key'&&it.door===door.id) return i; }
  for(i=0;i<G.bag.length;i++){ if(keyFits(ITEMS[G.bag[i]],door)) return i; }   // v23.9x (feat4a): then a keycard
  return -1;
}
'@

SubRx @'
    var ki=-1;
    for(var kb=0;kb<G.bag.length;kb++){
      var kit=ITEMS[G.bag[kb]];
      if(kit&&kit.use==='key'&&kit.door===doorNear.id){ ki=kb; break; }
    }
'@ @'
    var ki=doorKeyIx(doorNear);   // v23.9x (feat4a): its own key first, then a Vault Keycard where one fits (keyFits)
'@

SubRx @'
          if(_di&&_di.use==='key'&&_di.door===wl2.door){ _dk=true; break; } }
'@ @'
          if(keyFits(_di,{id:wl2.door,arc:wl2.arc})){ _dk=true; break; } }   // v23.9x (feat4a): a keycard lights it too
'@

SubRx @'
        if(hki&&hki.use==='key'&&hki.door===G.nearDoor.id){ haveKey=true; break; } }
'@ @'
        if(keyFits(hki,G.nearDoor)){ haveKey=true; break; } }   // v23.9x (feat4a): a keycard where it fits
'@

SubRx @'
      for(var kk in ITEMS){ if(ITEMS[kk].use==='key'&&ITEMS[kk].door===G.nearDoor.id){ kName=ITEMS[kk].name; break; } }
'@ @'
      for(var kk in ITEMS){ if(ITEMS[kk].use==='key'&&ITEMS[kk].door===G.nearDoor.id){ kName=ITEMS[kk].name; break; } }
      if(!kName&&G.nearDoor.arc&&ITEMS.keycard) kName=ITEMS.keycard.name;   // v23.9x (feat4a): a vault names the keycard
'@

SubRx @'
    default:
      if(it&&it.use==='key'){
'@ @'
    default:
      if(it&&it.use==='key'&&it.door==='arc'){   // v23.9x (feat4a): the Vault Keycard is a card with a stripe and a chip
        shadow(S*.72,S*.48);
        c.fillStyle=dk; c.fillRect(-S*.36,-S*.24,S*.72,S*.48);
        c.fillStyle=col; c.fillRect(-S*.33,-S*.21,S*.66,S*.42);
        c.fillStyle='#0e1420'; c.fillRect(-S*.33,-S*.12,S*.66,S*.09);
        c.fillStyle='#e8d27a'; c.fillRect(-S*.26,S*.03,S*.13,S*.1);
        c.fillStyle=lt; c.fillRect(S*.02,S*.05,S*.24,S*.035); c.fillRect(S*.02,S*.11,S*.16,S*.035);
      } else if(it&&it.use==='key'){
'@

SubRx @'
var VER='24.61';
'@ @'
var VER='24.62';
'@

$pat = "(?m)^  now:'v24\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.62: A Vault Keycard opens any locked room in a DEMO raid. Check 24.62 fails on v24.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

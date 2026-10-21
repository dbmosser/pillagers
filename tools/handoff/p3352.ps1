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

# THE PIXEL LOOK MAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pixReg(nm,fn){ PIX.reg[nm]=fn; return nm; }
'@ @'
function pixReg(nm,fn){ PIX.reg[nm]=fn; return nm; }
// v33.52 (cw-pixlook), HIS ORDERS (2026-10-20 22:50 and 23:05: "3 head options, 3 skin options, 3 clothing (with pack) options, and 3 unique full sets", the sets "full body skins that override whatever
// else the player had set"): THE READ-SIDE LOOK MAP, job 86a ship 2. pixLook maps the 18 field look (netLook(), cosWorn per field) to the 12 pixel picks at draw time, reading the raw fields and never
// cosWorn, so an old unlock rule never hides a pixel pick. Nothing is written: the 18 fields, the 145 rack ids, P.looks and the restore codes stay as they are, and salvagerun:profile is untouched.
// A set overrides head, skin and clothes while it is worn; the picks are still returned so they come back when it is taken off. Mapping table: notes/pixel-plan.md, the dress-up cut.
var PIX_SETS={outskeleton:'skeleton',outtrooper:'trooper',outrobot:'trooper',outandroid:'android'};   // The Machine (outrobot) shows as the trooper
var PIX_OUTFIT={outexplorer:['long','recon'],outpoet:['hood','heavy'],outballer:['short','scav']};   // [head, clothes] of the three outfits that are not sets
var PIX_LONG={long:1,pigtails:1,bob:1,bun:1,tail:1};   // crop, shaved and mohawk are short
var PIX_SKIN={porcelain:'fair',fair:'fair',olive:'tan',tan:'tan',bronze:'tan',umber:'umber',ebony:'umber'};
var PIX_CLOTH={schdrab:'recon',schmoss:'recon',schteal:'recon',schverdant:'recon',schtoxic:'recon',
  schash:'heavy',schcharcoal:'heavy',schindigo:'heavy',schfrost:'heavy',schroyal:'heavy',schnight:'heavy'};   // every other scheme (std, rust, oxblood, sand, bone, ember, crimson, dune, gilded) is scav
function pixPick(t,k,d){ return (typeof k==='string'&&Object.prototype.hasOwnProperty.call(t,k))?t[k]:d; }
function pixLook(lk){
  lk=lk||{};
  var o=lk.outfit, ov=pixPick(PIX_OUTFIT,o,null), sch=lk.scheme, head, clothes;
  if(!sch&&lk.fit&&lk.fit!=='slate') sch='sch'+lk.fit;   // an old save keeps its colour, as cosWorn does
  head=(lk.hat&&lk.hat!=='none')?'hood':(pixPick(PIX_LONG,lk.cut,0)?'long':'short');
  clothes=pixPick(PIX_CLOTH,sch,'scav');
  if(ov){ head=ov[0]; clothes=ov[1]; }
  return {head:head,skin:pixPick(PIX_SKIN,lk.skin,'fair'),clothes:clothes,set:pixPick(PIX_SETS,o,'none')};
}
function pixOwn1(cid){ var c=cosFind(cid); return !!c&&cosOwned(c); }
// what the pixel wardrobe may wear: heads, skins and clothes are always owned; a set is owned by its own rule or by any old item mapped to it (The Machine, warden 3, grants the trooper)
function pixOwned(id){
  var t={head:{short:1,long:1,hood:1},skin:{fair:1,tan:1,umber:1},clothes:{scav:1,recon:1,heavy:1},
         set:{none:1,skeleton:pixOwn1('outskeleton')?1:0,trooper:(pixOwn1('outtrooper')||pixOwn1('outrobot'))?1:0,android:pixOwn1('outandroid')?1:0}}, g, h;
  if(id===undefined) return t;
  for(g in t) if(Object.prototype.hasOwnProperty.call(t[g],id)) return !!t[g][id];
  return false;
}
'@

SubRx @'
var VER='33.51';
'@ @'
var VER='33.52';
'@

$pat = "(?m)^  now:'v33\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.52: The game can now work out a pillager pixel look (head, skin, clothes, set) from any saved look. Nothing on screen changes yet. Check 33.52 fails on v33.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

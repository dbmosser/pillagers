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

# EQUIPPING A GUN SAYS NOTHING ABOUT THE REST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v21.73: the gun card's line for the gun you are NOT holding, or '' when the other slot holds only Bare Hands.
function stowLine(p){
  var s=p&&p.sec;
  if(!s||s.id==='fists') return '';
  return 'OTHER GUN  '+s.name+((s.mag>0)?'  '+p.secAmmo:'');
}
'@ @'
// v24.xx (noequipline), HIS ORDER (2026-10-12): "don't need to tell what else in the backpack when i equip a different gun -- weird
// design choice from you". stowLine (v21.73) built the gun card's OTHER GUN line, naming the gun in the other slot and its rounds, on
// every frame and so on every swap. It is gone with both of its callers: the gun card shows the gun in his hands and its ammo only.
'@

SubRx @'
       if(stowLine(p)){ ctx.font=FS(TYPE.micro); _wtx=Math.max(_wtx,ctx.measureText(stowLine(p)).width); ctx.font=FS(TYPE.head); }
'@ @'
       // v24.xx (noequipline): no OTHER GUN line to measure; the card fits the gun name.
'@

SubRx @'
  if(stowLine(p)){
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#7d8894';
    var _cornStow=stowLine(p);
    _cornMark(_cornStow);
    ctx.fillText(_cornStow,W-16,by-LH(52));
  }
'@ @'
  // v24.xx (noequipline), HIS ORDER (2026-10-12): the OTHER GUN line (v21.73) is gone. The card names the gun in his hands and its
  // ammo, and nothing else on it says what else he carries; the belt shows his keys.
'@

SubRx @'
    if(_pushId&&!_oldLine&&G.bag.indexOf('gun_'+_pushId)>=0&&!((p.wep&&p.wep.id===_pushId)||(p.sec&&p.sec.id===_pushId))&&G.hotAssign)
      for(var _pk in G.hotAssign) if(G.hotAssign[_pk]==='gun_'+_pushId){ _gunKeyHint=(oldW.name+' in backpack \u00b7 slot '+(+_pk+1)).toUpperCase(); break; }   // v22.xx (R52): the slot word
'@ @'
    // v24.xx (noequipline), HIS ORDER (2026-10-12): no hint naming the gun pushed into the backpack and its key (GUN IN BACKPACK, SLOT
    // N). The keys still settle exactly as before; only the words went.
'@

SubRx @'
  var _eqSub=[_oldLine,_gunKeyHint].filter(function(_es){ return !!_es; }).join(' \u00b7 ');
  say(_newLine,'info',_eqSub?{sub:_eqSub}:null);
'@ @'
  // v24.xx (noequipline), HIS ORDER (2026-10-12): "don't need to tell what else in the backpack when i equip a different gun". The
  // detail under the line named what became of the gun it replaced (to backpack, back to the armoury, left behind) and the key it
  // kept in the backpack. The line names the gun he equipped and nothing else; the gun card shows what is in his hands.
  say(_newLine,'info',null);
'@

SubRx @'
  var _newLine=_kept?(g.name+' stowed').toUpperCase()   // v22.43: the shooter voice (the gun in hand is not named: it did not move)
                    :(g.name+(toSec?' stowed':' equipped')).toUpperCase();   // v22.xx (R52): X EQUIPPED, or X STOWED when it went to the other hand
'@ @'
  var _newLine=_kept?(g.name+' stowed').toUpperCase()   // v22.43: the shooter voice (the gun in hand is not named: it did not move)
                    :(g.name+(toSec?' stowed':' equipped')).toUpperCase();   // v22.xx (R52): X EQUIPPED, or X STOWED when it went to the other hand
  // v24.xx (noequipline): a gun drawn off its key (drawGun) is brought straight up into his hands, so its line says EQUIPPED. It said
  // STOWED whenever it landed in the free slot first, and with the GUN UP line under it gone that was the last word on the gun in his hands.
  if(_eqUp) _newLine=(g.name+' equipped').toUpperCase();
'@

SubRx @'
function drawGun(ix){
  var p=G&&G.player, it=ITEMS[G.bag[ix]], h0=G.hot;
  if(!p||!it||it.use!=='gun') return false;
  _gunKeyHint='';
  if(!equipFromBag(ix,giveUpSlot())) return false;
  if(p.wep.id!==it.gk&&p.sec&&p.sec.id===it.gk){ swapGuns(); if(_gunKeyHint) say((p.wep.name+' up').toUpperCase(),'info',{sub:_gunKeyHint}); }
'@ @'
var _eqUp=false;   // v24.xx (noequipline): true while drawGun equips, so the equip line names the gun as up in his hands
function drawGun(ix){
  var p=G&&G.player, it=ITEMS[G.bag[ix]], h0=G.hot, ok=false;
  if(!p||!it||it.use!=='gun') return false;
  _gunKeyHint='';
  _eqUp=true; try{ ok=equipFromBag(ix,giveUpSlot()); } finally { _eqUp=false; }
  if(!ok) return false;
  // v24.xx (noequipline), HIS ORDER (2026-10-12): brought up with no second line naming the gun it pushed into the backpack.
  if(p.wep.id!==it.gk&&p.sec&&p.sec.id===it.gk) swapGuns();
'@

SubRx @'
var VER='25.01';
'@ @'
var VER='25.02';
'@

$pat = "(?m)^  now:'v25\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.02: Equipping or swapping a gun now shows only the gun in your hands, with no line about your other guns or the backpack. Check 25.02 fails on v25.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

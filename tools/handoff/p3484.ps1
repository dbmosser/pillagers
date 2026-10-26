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

# NO GUN LINE ON THE PRE-RAID PAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var w=null;
  try{ w=(P.equipped&&P.equipped!=='fists')?WEAPONS[P.equipped]:null; }catch(_gw){ w=null; }
  if(w) w=hubForged(w);   // v23.xx (forge13): going up with the Auto Rifle MK III
  // v12.75: this says what actually happens: with nothing equipped the raid issues a scav pistol into gun 1 and leaves gun 2 empty.
  var _og=!w&&(P.stash||[]).some(function(k){ var it=ITEMS[k]; return it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]; });
  var line='<div class="srsum"><span class="gc" style="flex-basis:100%"><i>gun</i><b>'+(w?escHtml(w.name):'a scav pistol')+'</b>'+(_og?'<i style="margin-left:auto">own gun in stash</i>':'')+'</span>';
  // v14.67: and his own gun 2, whenever it is his own gun and not the gun in slot 1
  var _s2=P.equippedSec;
  if(_s2&&_s2!=='none'&&_s2!=='fists'&&WEAPONS[_s2]&&(P.weapons||[]).indexOf(_s2)>=0&&_s2!==P.equipped) line+=chip('gun 2',escHtml(WEAPONS[_s2].name));
  // v13.31: a gun waiting in the stash with nothing equipped is said in one chip
  // v10.13, his answer 7: the armour warning lives here, on the way up, and only when it is true: a packed armour item takes it away
  var armed=false;
  try{ packList().forEach(function(k){ if(ITEMS[k].use==='armor'&&packedCount(k)>0) armed=true; }); }catch(_rh){}
  if(!armed) line+='<span class="wn"><svg viewBox="0 0 24 24"><path d="M12 3.5l9.5 16.5h-19z"/><path d="M12 10v4.5M12 17v.5"/></svg><b>NO ARMOUR EQUIPPED</b></span>';
  el.innerHTML=line+'</div>';
'@ @'
  // v28.xx (cw-nogunline), HIS NOTE (2026-10-25): "the 'gun' line on the raid prep screen doesn't really make sense--- not sure what you were going there for but I am taking a bunch of guns into the raid so why does it say gun = compact smg?!? get rid of that". The gun, gun 2 and own gun in stash chips are gone (the pack rows list every gun he takes up); only the armour warning is left, as it was. Armed and armoured, the box is empty and takes no room (#sectorkit:empty).
  var line='<div class="srsum">';
  // v10.13, his answer 7: the armour warning lives here, on the way up, and only when it is true: a packed armour item takes it away
  var armed=false;
  try{ packList().forEach(function(k){ if(ITEMS[k].use==='armor'&&packedCount(k)>0) armed=true; }); }catch(_rh){}
  if(!armed) line+='<span class="wn"><svg viewBox="0 0 24 24"><path d="M12 3.5l9.5 16.5h-19z"/><path d="M12 10v4.5M12 17v.5"/></svg><b>NO ARMOUR EQUIPPED</b></span>';
  el.innerHTML=armed?'':line+'</div>';
'@

SubRx @'
#sectorkit{ flex:none; margin:0 !important; padding:0 !important; border:0 !important; }
'@ @'
#sectorkit{ flex:none; margin:0 !important; padding:0 !important; border:0 !important; } #sectorkit:empty{ display:none; }   /* v28.xx (cw-nogunline): with the gun chips gone the box is empty when he packs armour, and an empty box must not leave a blank band (a 0 px item still costs the column gap) */
'@

SubRx @'
var VER='34.83';
'@ @'
var VER='34.84';
'@

$pat = "(?m)^  now:'v34\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.84: The pre-raid page no longer says gun = something. The no armour warning still shows above ascend when you pack no armour. Watch for: no empty strip above the ascend button when you do pack armour. Check 34.84 fails on v34.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

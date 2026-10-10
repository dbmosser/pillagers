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

# A REJOIN NEVER DOUBLES A DROPPED GUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(P&&Array.isArray(P.gunPiled)&&P.gunPiled.length) P.gunPiled=[];   // v21.44 (R1b): a new raid closes the record of the last one's piled guns
'@ @'
  // v21.96, from the whole-game bug hunt of 2026-10-08 (K6): THE RECORD OF PILED GUNS IS KEPT FOR THE RAID HE JOINS AGAIN. A new raid
  // wiped the whole record (v21.44), so a guest who dropped his armoury gun, abandoned (the gun went home) and pressed JOIN THE RAID IN
  // PROGRESS lost it while the pile still lay in the host's raid: the host taking the gun took nothing out of his armoury, and his own
  // search banked a second copy. On a party build the entries for the raid being joined stay; a gun the abandon put back comes out of
  // the armoury again (it lies in the pile, so he does not also come up holding it) and onto this raid's list below, so another
  // abandon still brings it home. Every other raid closes the record as before, so solo is unchanged.
  var _gpSd=(typeof NET==='object'&&NET&&NET.upHold&&typeof pendSeed==='number')?(pendSeed>>>0):-1, _gpBack=[];
  if(P&&Array.isArray(P.gunPiled)&&P.gunPiled.length){
    P.gunPiled=P.gunPiled.filter(function(e){ return !!(e&&e.gk&&_gpSd>=0&&(e.sd>>>0)===_gpSd); });
    P.gunPiled.forEach(function(e){ if(e.home){ var j=Array.isArray(P.weapons)?P.weapons.indexOf(e.gk):-1; if(j>=0){ P.weapons.splice(j,1); _gpBack.push(e.gk); } e.home=0; } });
    if(_gpBack.length){
      if(P.equipped&&P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
      if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
      if((P.equippedSec||'none')===P.equipped) P.equippedSec='none';
    }
  }
'@

SubRx @'
  G=buildRaid(false);
'@ @'
  G=buildRaid(false);
  if(_gpBack.length&&G&&!G.sim){ G.spliced=G.spliced||[]; for(var _gpi=0;_gpi<_gpBack.length;_gpi++) if(G.spliced.indexOf(_gpBack[_gpi])<0) G.spliced.push(_gpBack[_gpi]); }   // v21.96 (K6): the gun in the pile is this raid's to bring home on an abandon
'@

SubRx @'
    where=openContainer(at,items);
'@ @'
    where=openContainer(at,items);
    // v21.96 (K6): a gun he piled and now takes back out of a pile is his again, so its record goes and a later rejoin cannot strip it
    if(ct&&ct.dropped&&P&&Array.isArray(P.gunPiled)&&P.gunPiled.length){ var _gq, _gz, _gt, _gc=0; for(_gq=0;_gq<items.length;_gq++){ _gt=ITEMS[items[_gq]]; if(!_gt||_gt.use!=='gun'||!_gt.gk) continue; for(_gz=0;_gz<P.gunPiled.length;_gz++) if(P.gunPiled[_gz]&&P.gunPiled[_gz].gk===_gt.gk){ P.gunPiled.splice(_gz,1); _gc++; break; } } if(_gc){ try{ saveProfile(); }catch(_gps){} } }
'@

SubRx @'
var VER='21.95';
'@ @'
var VER='21.96';
'@

$pat = "(?m)^  now:'v21\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.96: In co-op, abandoning and joining the same raid again no longer turns a dropped armoury gun into two. Check 21.96 fails on v21.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

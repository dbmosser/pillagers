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

# A DROPPED ARMOURY GUN IS NEVER IN TWO SAVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      // v21.21, from the review of the night builds (2026-10-09, R1): an armoury gun dropped here stays on this window's list of guns
      // carried up until someone else takes it out of the pile (netGunTold on the host, netGunGoneTake here). v20.34 took it off at
      // the drop, so a gun nobody took, or one he searched back up himself, was gone from his save after an abandon.
'@ @'
      // v21.21, from the review of the night builds (2026-10-09, R1): an armoury gun dropped here stays on this window's list of guns
      // carried up until someone else takes it out of the pile (netGunTold on the host, netGunGoneTake here).
      // v21.44, review round 2 (2026-10-09, R1b): AND IT IS WRITTEN DOWN, SO IT NEVER ENDS UP IN TWO SAVES. Left on the lists, an abandon
      // (or a reload after a closed window) put it back in his armoury while the host could still take it and bank it. It now comes off
      // the saved list at once (a closed window never brings it home), stays on this raid's list (an abandon still does), and goes on a
      // saved record of piled guns; when the host says someone took it, the record says whether the abandon put it back, and if so it
      // comes out of the armoury again.
      var _pk=(/^gun_/.test(key)&&ITEMS[key]&&ITEMS[key].gk)?ITEMS[key].gk:null, _pj;
      if(_pk&&(G.spliced||[]).indexOf(_pk)>=0){
        if(P.raidSpliced){ _pj=P.raidSpliced.indexOf(_pk); if(_pj>=0) P.raidSpliced.splice(_pj,1); }
        (P.gunPiled=Array.isArray(P.gunPiled)?P.gunPiled:[]).push({gk:_pk,sd:(NET.upSeed>>>0)});
        try{ saveProfile(); }catch(_ps){}
      }
'@

SubRx @'
    if(!G.sim&&G.spliced) for(var _sq=0;_sq<G.spliced.length;_sq++) if(P.weapons.indexOf(G.spliced[_sq])<0) P.weapons.push(G.spliced[_sq]);
'@ @'
    if(!G.sim&&G.spliced) for(var _sq=0;_sq<G.spliced.length;_sq++) if(P.weapons.indexOf(G.spliced[_sq])<0) P.weapons.push(G.spliced[_sq]);
    gunPiledHome();   // v21.44 (R1b): a piled gun put back here is marked so
'@

SubRx @'
    if(G.spliced){
      for(i=0;i<G.spliced.length;i++)
        if(P.weapons.indexOf(G.spliced[i])<0) P.weapons.push(G.spliced[i]);
    }
'@ @'
    if(G.spliced){
      for(i=0;i<G.spliced.length;i++)
        if(P.weapons.indexOf(G.spliced[i])<0) P.weapons.push(G.spliced[i]);
    }
    gunPiledHome();   // v21.44 (R1b): a piled gun put back here is marked so
'@

SubRx @'
  if(typeof G!=='undefined'&&G&&G.over==='abandon'&&P&&Array.isArray(P.weapons)){ j=P.weapons.indexOf(gk); if(j>=0){ P.weapons.splice(j,1); back=1; } }
'@ @'
  // v21.44 (R1b): the record of guns he piled says whether an abandon put this one back in his armoury; if it did, it comes out again
  var _gp=(P&&Array.isArray(P.gunPiled))?P.gunPiled:[], _gi, _ge=null;
  for(_gi=0;_gi<_gp.length;_gi++) if(_gp[_gi]&&_gp[_gi].gk===gk){ _ge=_gp[_gi]; _gp.splice(_gi,1); break; }
  if(_ge&&_ge.home&&P&&Array.isArray(P.weapons)){ j=P.weapons.indexOf(gk); if(j>=0){ P.weapons.splice(j,1); back=1; } }
'@

SubRx @'
function netGunGoneTake(peer,m){
'@ @'
function gunPiledHome(){ if(typeof P==='undefined'||!P||!Array.isArray(P.gunPiled)||typeof G==='undefined'||!G||!G.spliced) return 0; var n=0; P.gunPiled.forEach(function(e){ if(e&&G.spliced.indexOf(e.gk)>=0){ e.home=1; n++; } }); return n; }   // v21.44 (R1b)
function netGunGoneTake(peer,m){
'@

SubRx @'
function startRaid(){
  if(netGuestHeld()) return false;   // v15.91: in a party only the host takes the lift; a guest goes up on the host word (the net section)
'@ @'
function startRaid(){
  if(netGuestHeld()) return false;   // v15.91: in a party only the host takes the lift; a guest goes up on the host word (the net section)
  if(P&&Array.isArray(P.gunPiled)&&P.gunPiled.length) P.gunPiled=[];   // v21.44 (R1b): a new raid closes the record of the last one's piled guns
'@

SubRx @'
var VER='21.43';
'@ @'
var VER='21.44';
'@

$pat = "(?m)^  now:'v21\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.44: In co-op, an armoury gun you drop is never copied into both saves. Check 21.44 fails on v21.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

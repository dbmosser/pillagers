$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# SAVING, PROFILE AND SETTINGS AUDIT OF 2026-09-15, finding 1: AN OWNED GUN WAS DELETED FOR GOOD IF THE RAID ENDED
# ANY WAY BUT endRaid. Bagging an armoury gun mid-raid, or a pickup bagging it for you, takes it off the armoury
# list and records it on G.spliced, which lives only in memory; endRaid's abandon paths put it back. But the
# profile is saved mid-raid too (a wheel zoom, the crash catcher and others), so closing the tab, pressing F5,
# a browser crash or a PC freeze after such a save left the gun in neither the armoury nor the stash on the next
# load. The splice is now also recorded on the saved profile, endRaid clears that record on every path (it
# settles the guns itself), and the loader puts back any gun a raid that never ended had taken out.
SubRx @'
            if(_soi>=0){ P.weapons.splice(_soi,1); (G.spliced=G.spliced||[]).push(p.sec.id); }
'@ @'
            if(_soi>=0){ P.weapons.splice(_soi,1); (G.spliced=G.spliced||[]).push(p.sec.id); (P.raidSpliced=P.raidSpliced||[]).push(p.sec.id); }   // v14.03: on the saved profile too
'@
SubRx @'
              if(oi>=0){ P.weapons.splice(oi,1); (G.spliced=G.spliced||[]).push(p.wep.id); }
'@ @'
              if(oi>=0){ P.weapons.splice(oi,1); (G.spliced=G.spliced||[]).push(p.wep.id); (P.raidSpliced=P.raidSpliced||[]).push(p.wep.id); }   // v14.03: on the saved profile too
'@
SubRx @'
  if(!G.sim&&arm){ var oi=P.weapons.indexOf(g.id); if(oi>=0){ P.weapons.splice(oi,1); (G.spliced=G.spliced||[]).push(g.id); } }
'@ @'
  if(!G.sim&&arm){ var oi=P.weapons.indexOf(g.id); if(oi>=0){ P.weapons.splice(oi,1); (G.spliced=G.spliced||[]).push(g.id); (P.raidSpliced=P.raidSpliced||[]).push(g.id); } }   // v14.03: on the saved profile too
'@
SubRx @'
function endRaid(how){
  if(G.over) return;
  G.over=how;
'@ @'
function endRaid(how){
  if(G.over) return;
  G.over=how;
  // v14.03, save audit: the raid is being settled here, and G.spliced drives the settling; the saved record of
  // guns taken out of the armoury is only for a raid that never reaches this line.
  if(!G.sim&&P) delete P.raidSpliced;
'@
SubRx @'
          P.weapons=P.weapons.filter(function(k){ return !!WEAPONS[k]; });
'@ @'
          // v14.03, save audit: a raid that ended by the page going away (a closed tab, F5, a crash, a frozen PC)
          // never settled the armoury guns it had taken out. They go back, as an abandon would put them back.
          if(Array.isArray(P.raidSpliced)){
            for(var _rsi=0;_rsi<P.raidSpliced.length;_rsi++){ var _rsk=P.raidSpliced[_rsi]; if(_rsk&&P.weapons.indexOf(_rsk)<0) P.weapons.push(_rsk); }
          }
          delete P.raidSpliced;
          P.weapons=P.weapons.filter(function(k){ return !!WEAPONS[k]; });
'@
SubRx @'
var VER='14.02';
'@ @'
var VER='14.03';
'@

$pat = "(?m)^  now:'v14\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.03: A GUN TAKEN OUT OF THE ARMOURY COMES BACK IF THE PAGE GOES AWAY MID-RAID. Saving, profile and settings audit of 2026-09-15, finding 1: bagging an armoury gun mid-raid takes it off P.weapons and records it only on G.spliced in memory, and the profile is saved mid-raid, so a closed tab, F5, a crash or a PC freeze after such a save left the gun in neither armoury nor stash on reload. The splice is now also kept on P.raidSpliced, endRaid clears it on every path, and the loader puts those guns back. Check 14.03 bags the armoury carbine, loads the saved profile through the real loader and requires the carbine in the armoury, with an ordinary save of an owned carbine as the control; it fails on v14.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

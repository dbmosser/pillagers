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

# A TEAMMATE GOING DOWN IS SAID AND FELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; g.sa=(m.sa===undefined)?1:(m.sa?1:0); }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour
'@ @'
  // v17.68: A TEAMMATE GOING DOWN IS SAID AND FELT. The word that first carries his downed flag, in the raid this window is up
  // in, says who is down and asks for the pick-up, and gives the controller a rumble; nothing on screen said it before, and a
  // player looking the other way found out when the run card did. Once per fall: the flag must have been clear in the last word.
  if(up&&m.dn&&!g.dn&&g.n>1&&typeof G!=='undefined'&&G&&!G.over&&!G.sim&&(G.seed>>>0)===((+m.sd)>>>0)){ try{ sayWhenFree((netSeatName(s)||'Your teammate')+' is down. Pick them up.'); padRumble(0.55,420); }catch(_md){} }
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; g.sa=(m.sa===undefined)?1:(m.sa?1:0); }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour
'@

SubRx @'
var VER='17.67';
'@ @'
var VER='17.68';
'@

$pat = "(?m)^  now:'v17\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.68: When your teammate goes down you are told (NAME is down. Pick them up.) and a controller rumbles. Check 17.68 fails on v17.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

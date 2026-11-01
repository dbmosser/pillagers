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

# DEAD CODE OUT 5 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // A JAM. The felt consequence of neglect: the trigger does nothing, the gun
  // needs cycling, and you find out in the middle of a fight. Rolled per shot
  // and only on a gun that is actually fouled, so a maintained weapon never
  // does this.
  if(p.jam>0){ p.jam-=dt; if(p.jam<=0&&!G.sim) say('JAM CLEARED'); }   // v22.xx (R52)

'@ @'
  // v28.xx (cw-dead5): the jam tick and its cleared line are out: guns never jam (his answer 14, v9.01).

'@

SubRx @'
        // The jam roll happens on the trigger pull, before the round leaves, so
        // a fouled gun costs you the round AND the second it takes to cycle.
        if(p.wep.jam>0&&rr()<p.wep.jam){
          p.ammo--; p.lastShot=now; p.fired=true; p.jam=0.9;
          // The counter is a FACT and moves out of the presentation guard, v2.09.
          // It was fenced with the say and the blip, so a sim raid could not have
          // reported a jam even once the bot could have one.
          G.tel.jams=(G.tel.jams||0)+1;
          if(!G.sim){
            say((p.wep.name+' jammed').toUpperCase());   // v22.xx (R52)
            blip('clank'); G.shake=Math.max(G.shake,2);
          }
        } else {
          if(!pwrClip()) p.ammo--; p.lastShot=now; p.fired=true;
          fireWeapon(p,p.wep,p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true); lowMagClick(p);   // v36.xx (cw-lowmag): after the shot, p.ammo is what is left
        }

'@ @'
        if(!pwrClip()) p.ammo--; p.lastShot=now; p.fired=true;
        fireWeapon(p,p.wep,p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true); lowMagClick(p);   // v36.xx (cw-lowmag): after the shot, p.ammo is what is left

'@

SubRx @'
        // Same shape as the player path: the roll happens on the trigger pull, so
        // a fouled gun costs the round AND the second it takes to cycle.
        // DRAWN BEFORE THE DIAL IS CONSULTED, and that is not a style choice. Put
        // the rr() inside the dial test and simJam 0 skips a draw that simJam 1
        // takes, which shifts the whole PRNG stream from the first shot onward and
        // makes the two arms different raids rather than the same raid with and
        // without jams. My first measurement did exactly that: 120 of 120 seeds
        // diverged and the per-seed flip counts meant nothing. Drawing whenever the
        // gun CAN jam keeps both arms on one stream, and guns with jam 0, every
        // loaner and every field pickup, never draw at all, so the entire back
        // catalogue of sim numbers stays reproducible.
        var jr=(p.wep.jam>0)?rr():1;
        if(CFG.simJam!==0&&p.wep.jam>0&&jr<p.wep.jam){
          p.ammo--; p.lastShot=now; p.jam=0.9; T.jams=(T.jams||0)+1;
        } else {
          p.ammo--; p.lastShot=now;
          // v3.86: the bot aimed at plus-minus 10 units and shot 72 percent to
          // HIS 43. simAim is the wobble in units, dialled, calibrated against
          // his real accuracy so fights cost the bot what they cost him. The
          // rnd draw count is unchanged, so raid builds stay byte-identical.
          var _aj=(CFG.simAim===undefined?10:CFG.simAim);
          fireWeapon(p,p.wep,threat.x+rnd(-_aj,_aj),threat.y+rnd(-_aj,_aj),true);
        }

'@ @'
        p.ammo--; p.lastShot=now;
        // v3.86: the bot aimed at plus-minus 10 units and shot 72 percent to
        // HIS 43. simAim is the wobble in units, dialled, calibrated against
        // his real accuracy so fights cost the bot what they cost him. The
        // rnd draw count is unchanged, so raid builds stay byte-identical.
        var _aj=(CFG.simAim===undefined?10:CFG.simAim);
        fireWeapon(p,p.wep,threat.x+rnd(-_aj,_aj),threat.y+rnd(-_aj,_aj),true);

'@

SubRx @'
var VER='37.07';
'@ @'
var VER='37.08';
'@

$pat = "(?m)^  now:'v37\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.08: Nothing a player can see changes. Check 37.08 fails on v37.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

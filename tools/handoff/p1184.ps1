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

# HIS NOTE, 2026-09-06 (his 06:26 export, run 3, @248s): "meridian lance
# bullets should travel through crawlers". The round is stamped at the muzzle
# and the hit test lets it keep going after a crawler, still carrying its full
# damage; a crawler it has already passed is never hit twice; anything that
# is not a crawler stops it as before.
SubRx @'
      life:wep.rng/1180,player:!!fromPlayer,owner:sh,tint:wep.tint||'#ffd48a'});
'@ @'
      life:wep.rng/1180,player:!!fromPlayer,owner:sh,tint:wep.tint||'#ffd48a',
      thru:(wep.id==='lance')?1:0});   // v11.84, HIS NOTE: the Lance travels through crawlers
'@
SubRx @'
          for(var e2=0;e2<G.ents.length;e2++){
            var en=G.ents[e2];
            // v6.72, his note: a hired companion takes no friendly fire from you. The
'@ @'
          for(var e2=0;e2<G.ents.length;e2++){
            var en=G.ents[e2];
            if(b._thru&&b._thru.indexOf(en)>=0) continue;   // v11.84: already passed through this one
            // v6.72, his note: a hired companion takes no friendly fire from you. The
'@
SubRx @'
              spark(b.x,b.y,en.kind==='raider'?'#ff5a4a':'#ffc25c',9,220);
              sfx("hit",en.x,en.y); hit=true; break;
            }
          }
'@ @'
              spark(b.x,b.y,en.kind==='raider'?'#ff5a4a':'#ffc25c',9,220);
              sfx("hit",en.x,en.y);
              // v11.84, HIS NOTE: "meridian lance bullets should travel through
              // crawlers". The round keeps going after a crawler with its damage
              // intact and remembers him so he is not hit again next frame;
              // anything else stops it as before.
              if(b.thru&&en.kind==='crawler'){ (b._thru||(b._thru=[])).push(en); continue; }
              hit=true; break;
            }
          }
'@

# ONE SHOT, ONE HIT: a round that passes through two crawlers is still one hit
# against its one shot, or the run report's accuracy climbs past 100 percent
# (the pellet rule in fireWeapon exists for exactly this).
SubRx @'
              G.tel.hits++;
              // Hit feedback at the reticle. The sprite flash and spark happen out
'@ @'
              if(!b._hitTold){ b._hitTold=1; G.tel.hits++; }   // v11.84: one hit per round, however many it passes through
              // Hit feedback at the reticle. The sprite flash and spark happen out
'@

# STAMPS.
SubRx @'
var VER='11.83';
'@ @'
var VER='11.84';
'@
SubRx @'
var WHATSNEW_VER='11.83';
'@ @'
var WHATSNEW_VER='11.84';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE MERIDIAN LANCE TRAVELS THROUGH CRAWLERS, hitting every one on the line with its full damage.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.83:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.83 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.83:[^']*'",{ param($m) "now:'v11.84: HIS NOTE of 2026-09-06, Meridian Lance rounds travel through crawlers. The round is stamped thru at the muzzle when the weapon is the lance; the hit test damages a crawler and lets the round continue, remembering him so he is not hit again next frame; anything else stops it as before. Check 11.84 stands two crawlers on a clear line, fires the real lance through fireWeapon and steps the real bullet update, requires both to have taken one hit each, and fires a rifle the same way requiring only the first hit; fails on v11.83.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

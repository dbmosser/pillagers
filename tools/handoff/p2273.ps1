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

# NO REPEATS OF THE GUN CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      p.ammo+=take; p.reserve-=take; say('Reloaded');
'@ @'
      // v22.73, the raid text rewrite (R28): THE FEED STOPS REPEATING THE GUN CARD AND THE RETICLE. A reload said Reloading when it
      // began and Reloaded when it ended, an empty gun said Out of ammo, a swap said the gun name UP and a belt key said the item and
      // its count, each a feed row for what the gun card (RELOADING, the gun in hand, the rounds), the reticle ([R] RELOAD, NO AMMO)
      // and the belt band already show. The rows are gone; every sound stays.
      p.ammo+=take; p.reserve-=take;
'@

SubRx @'
    p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) blipMine('reload');   // v10.56
    if(!G.sim) say('Reloading.');
'@ @'
    p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) blipMine('reload');   // v10.56; v22.73 (R28): the gun card says RELOADING
'@

SubRx @'
          if(!G.sim){ say('Reloading...'); blipMine('reload'); }   // v10.56
        } else if(p.reserve<=0&&!p.dryTold){ p.dryTold=1; say('Out of ammo.'); if(!G.sim) blipMine('dry'); }   // v10.56: an empty gun clicks
'@ @'
          if(!G.sim) blipMine('reload');   // v10.56; v22.73 (R28): the gun card says RELOADING
        } else if(p.reserve<=0&&!p.dryTold){ p.dryTold=1; if(!G.sim) blipMine('dry'); }   // v10.56: an empty gun clicks; v22.73 (R28): the reticle says NO AMMO
'@

SubRx @'
  say((pp.wep.name+' up').toUpperCase());   // v22.58: the shooter voice, as drawGun says it
'@ @'
  // v22.73 (R28): no line for the swap; the gun card shows the gun in his hands. drawGun still says where the other gun went.
'@

SubRx @'
  if(!_hinted) say(s2.name+(s2.count!==null&&s2.count!==undefined?'  x'+s2.count:''));
  blip('pick');
'@ @'
  // v22.73 (R28): no line naming the cell and its count; the belt band shows the selected key and the count on it.
  blip('pick');
'@

SubRx @'
var VER='22.72';
'@ @'
var VER='22.73';
'@

$pat = "(?m)^  now:'v22\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.73: Reloading, swapping guns and picking a belt key no longer put lines in the feed; the gun card and the crosshair show it. Check 22.73 fails on v22.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

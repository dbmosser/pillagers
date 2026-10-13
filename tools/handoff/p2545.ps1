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

# THE FORGE: ACID ROUNDS EAT ARMOUR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      e.chill=0; e.freezeImm=e.frozenT+4; e.roll=0;
    }
  }
  return true;
}
'@ @'
      e.chill=0; e.freezeImm=e.frozenT+4; e.roll=0;
    }
  } else if(el==='acid'){
    e.corrT=4;
  }
  return true;
}
// v23.xx, THE FORGE (2026-10-12), forge6: ACID. An acid round eats armour plates BEFORE the armour soaks it: 0.6 of the round comes
// off the plate first (elemShred), and for 4 s after (corrT) the plate stops only half of what it would (elemAbsorb), for every
// round that hits him, a teammate round too. A machine takes 1.25 times the damage of an acid round, after any Bulwark shield. No
// damage over time. A Breacher Plate pillager is bare in about seven MK III rifle hits instead of about twenty. No draw on any stream.
function elemShred(e,d){
  var s;
  if(!e||!(d>0)) return 0;
  e.corrT=4;
  if(!(e.armor>0)) return 0;
  s=Math.min(e.armor,0.6*d); e.armor-=s;
  return s;
}
function elemAbsorb(e){ return (armorById(e.rig).absorb||0)*((e.corrT>0)?0.5:1); }
'@

SubRx @'
  if(e.armor>0&&d>0){ sk=armorById(e.rig).absorb||0; ab=Math.min(e.armor,d*sk); e.armor-=ab; d-=ab; }
'@ @'
  if(e.armor>0&&d>0){ sk=elemAbsorb(e); ab=Math.min(e.armor,d*sk); e.armor-=ab; d-=ab; }
'@

SubRx @'
                var esk=armorById(en.rig).absorb||0;
'@ @'
                if(b.el==='acid') elemShred(en,edmg);   // v23.xx (forge6): ACID eats the plate before it soaks the round
                var esk=elemAbsorb(en);   // v23.xx (forge6): a corroded plate stops half
'@

SubRx @'
              if(NET.on&&netEntsPeer()) netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar); else en.hp-=edmg;
'@ @'
              if(b.el==='acid'&&ELEM_MACH[en.kind]) edmg*=1.25;   // v23.xx (forge6): ACID, a quarter more into a machine; player 2's window sends the real number
              if(NET.on&&netEntsPeer()) netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar); else en.hp-=edmg;
'@

SubRx @'
_nsk=armorById(e.rig).absorb||0
'@ @'
_nsk=elemAbsorb(e)
'@

SubRx @'
    if(e.freezeImm>0){ e.freezeImm-=dt; if(e.freezeImm<0) e.freezeImm=0; }
'@ @'
    if(e.freezeImm>0){ e.freezeImm-=dt; if(e.freezeImm<0) e.freezeImm=0; }
    if(e.corrT>0){ e.corrT-=dt; if(e.corrT<0) e.corrT=0; }   // v23.xx (forge6): the acid wears off
'@

SubRx @'
var VER='25.44';
'@ @'
var VER='25.45';
'@

$pat = "(?m)^  now:'v25\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.45: Acid rounds from a MK III gun eat armour plates and hurt machines more. Check 25.45 fails on v25.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

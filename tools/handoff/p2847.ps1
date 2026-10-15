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

# YOUR TEAMMATE SHOWS BARE HANDS WHEN HIS HANDS ARE BUSY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
       hp:Math.round(p.hp||0),mh:Math.round(p.maxhp||100),ar:Math.round(p.armor||0),ac:Math.round(armorCap()||0),dt:p.downed?Math.max(0,Math.ceil(p.downT||0)):0,sa:(!CFG.superhot||G.shAct)?1:0};   // v16.20: pz, this player is paused; v16.23: health and armour, for a teammate's bandage or plate
'@ @'
       hp:Math.round(p.hp||0),mh:Math.round(p.maxhp||100),ar:Math.round(p.armor||0),ac:Math.round(armorCap()||0),dt:p.downed?Math.max(0,Math.ceil(p.downT||0)):0,sa:(!CFG.superhot||G.shAct)?1:0,hd:(G.handsT>0||p.hand)?1:0};   // v16.20: pz, this player is paused; v16.23: health and armour, for a teammate's bandage or plate // v28.47 (cloud-coop-teammate-bare-hands), CLOUD HUNT 2026-10-15: hd, his hands are busy (a grenade or heal out, a search or a seal), so his teammate draws him without his gun as he sees himself
'@

SubRx @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.fk=(m.fk===1||m.fk===2)?m.fk:0; g.el=(g.fk===2&&typeof m.el==='string'&&ELEM[m.el])?m.el:''; g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; g.sa=(m.sa===undefined)?1:(m.sa?1:0); }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour
'@ @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.fk=(m.fk===1||m.fk===2)?m.fk:0; g.el=(g.fk===2&&typeof m.el==='string'&&ELEM[m.el])?m.el:''; g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; g.sa=(m.sa===undefined)?1:(m.sa?1:0); g.hd=m.hd?1:0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour // v28.47 (cloud-coop-teammate-bare-hands), CLOUD HUNT 2026-10-15: hd kept; a word without it (an older window) reads as empty hands
'@

SubRx @'
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; out.pz=g.pz; out.hp=g.hp; out.mh=g.mh; out.ar=g.ar; out.ac=g.ac; out.dt=g.dt; out.sa=g.sa; }   // v15.79: passed on as it came
'@ @'
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; out.pz=g.pz; out.hp=g.hp; out.mh=g.mh; out.ar=g.ar; out.ac=g.ac; out.dt=g.dt; out.sa=g.sa; out.hd=g.hd; }   // v15.79: passed on as it came // v28.47 (cloud-coop-teammate-bare-hands), CLOUD HUNT 2026-10-15: hd passed on too
'@

SubRx @'
    mode=g.dn?'down':((g.roll>0)?'roll':(g.cr?'crouch':(wp?'':'none')));
'@ @'
    mode=g.dn?'down':((g.roll>0)?'roll':(g.cr?'crouch':((wp&&!g.hd&&wp.id!=='fists')?'':'none'))); // v28.47 (cloud-coop-teammate-bare-hands), CLOUD HUNT 2026-10-15: bare hands while his hands are busy or he is on Bare Hands, as his own window draws him
'@

SubRx @'
var VER='28.46';
'@ @'
var VER='28.47';
'@

$pat = "(?m)^  now:'v28\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.47: In co-op, a teammate with a grenade or heal out, searching, cutting a seal or on Bare Hands now shows bare hands in your window, just as he sees himself. Check 28.47 fails on v28.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# PILLAGERS AND YOUR TEAMMATE HOLD BIG GUNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gunHeldOn(st,mode){ return !!(st&&st.hero)&&mode!=='none'&&mode!=='crouchnone'&&mode!=='fist'; }
'@ @'
// v25.xx (bigguns2), HIS ORDER (2026-10-12) "guns in player's characters hands need to be bigger": EVERYONE HOLDS THE BIG GUN. The
// player went first; pillagers, hires, friendly pillagers and your teammate in this window now hold the same baked gun at the same
// size, so a pillager rifle reads as a rifle and his LMG as an LMG across the room, inked so it no longer vanishes into a red sleeve.
// Your teammate Forge gun travels with his gun id (fk and el in his state message) and shows its gold and its element here too.
function gunHeldOn(st,mode){ return mode!=='none'&&mode!=='crouchnone'&&mode!=='fist'; }
'@

SubRx @'
dn:p.downed?1:0,w:(p.wep&&p.wep.id)?String(p.wep.id):'',pz:G.paused?1:0,
'@ @'
dn:p.downed?1:0,w:(p.wep&&p.wep.id)?String(p.wep.id):'',fk:(p.wep&&(p.wep.fk===1||p.wep.fk===2))?p.wep.fk:0,el:(p.wep&&p.wep.fk===2&&p.wep.el)?String(p.wep.el):'',pz:G.paused?1:0,
'@

SubRx @'
g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0;
'@ @'
g.w=netClean(m.w,24); g.fk=(m.fk===1||m.fk===2)?m.fk:0; g.el=(g.fk===2&&typeof m.el==='string'&&ELEM[m.el])?m.el:''; g.sd=(+m.sd)>>>0;
'@

SubRx @'
    g.wep=wp;   // read by drawOp off own
'@ @'
    if(wp&&(g.fk===1||g.fk===2)){   // v25.xx (bigguns2): his Forge gun, made once per change
      if(g._fwk!==g.w+'|'+g.fk+'|'+(g.el||'')){ g._fw=forgeApply(Object.assign({},wp),g.fk,g.el||''); g._fwk=g.w+'|'+g.fk+'|'+(g.el||''); }
      wp=g._fw||wp;
    }    g.wep=wp;   // read by drawOp off own
'@

SubRx @'
var VER='25.59';
'@ @'
var VER='25.60';
'@

$pat = "(?m)^  now:'v25\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.60: Pillagers, hires and your teammate hold the same big guns, and a teammate Forge gun shows its finish in your window. Check 25.60 fails on v25.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

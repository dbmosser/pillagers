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

# ============ HIS NOTE, 2026-09-03 about 21:30: "wheb ny characterr stands
# ============ behind a wall they change color lol". The v9.27 see-through pass
# ============ painted him through a wall as a flat light-blue cutout: coat
# ============ #9fd8ff, no hero racks, half alpha. Behind cover he turned blue.
# ============ The Undercroft pass (v10.51) already draws the real figure. The
# ============ raid pass does now too: his coat, his racks, his stance, his gun,
# ============ at 0.55 alpha, so behind a wall he looks like himself seen
# ============ through it, and nothing else about the pass changes.
SubRx @'
      wc.save();
      // The real sprite, in one flat colour, at low alpha. Reusing drawOp rather
      // than hand drawing a blob means the ghost can never drift away from what
      // the operator actually looks like, and it keeps his facing and stance.
      wc.globalAlpha=0.5;
      if(_stL>0) wc.translate(0,-_stL);
      drawOp(p.x,p.y,p.face,p.bob,'#9fd8ff',0,0,(p.downed?'down':''),0,{own:p});
      wc.restore();
'@ @'
      wc.save();
      // v10.59, his note: "when my character stands behind a wall they change
      // color". This was one flat light-blue colour with no racks. It is the
      // real figure now, the same call the sorted pass makes, faded: his coat,
      // his racks, his stance and his gun, seen through the wall.
      wc.globalAlpha=0.55;
      if(_stL>0) wc.translate(0,-_stL);
      var _gmode=((G.deathBeat>0||p.hp<=0)?'down':(G.punchT>0?'fist':((pmode===''&&(G.handsT>0||(p.wep&&p.wep.id==='fists')))?'none':pmode)));
      drawOp(p.x,p.y,p.face,p.roll>0?(1-p.roll/.38)*12.6:p.bob,'#242832',0,0,_gmode,p.iv,
        {hero:1,own:p,moving:!!p.moving,sprint:!!G.sprinting,ads:!!p.ads,hurt:0,bulk:armorById(p.rig).bulk,
         rl:(p.reloading>0&&p.wep.reload)?clamp(1-p.reloading/p.wep.reload,0,1):0});
      wc.restore();
'@

SubRx @'
var VER='10.58';
'@ @'
var VER='10.59';
'@
SubRx @'
  now:'v10.58: the trailing noise after a big gun is much shorter and a tenth as loud, the big cracks themselves are shorter, and the bolt and pump click inside a third of a second of the shot. Nothing a shot makes lands later than that.',
'@ @'
  now:'v10.59: behind a wall you look like yourself, faded, instead of turning into a light-blue cutout. Your coat, your racks, your stance and your gun, seen through the wall.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

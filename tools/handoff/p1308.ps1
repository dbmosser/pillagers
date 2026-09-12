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

# HIS NOTES, 2026-09-12, live play, two of three:
#   "player shouldn't have gun visible in his hand when he's in the undercroft"
#   "in undercroft it says 'Compact SMG' FIRE use V signal -- all this text is useless"
#
# ONE CAUSE, TWO SYMPTOMS. The floor reuses the raid's own drawing: the same operator
# routine, the same belt strip. Both were handed the raid's arguments down here, so he
# walks around his own home holding a gun, under a line offering him two actions that
# do not exist in the Undercroft. You cannot fire in the Undercroft and there is
# nobody to signal.
#
# THE LINE IS KEPT IN A RAID, WHERE IT IS TRUE. He called the text useless where he
# read it, and where he read it, it is. Up top those are real actions on a real belt,
# and deleting it there would take something he uses. One test, drawn in the raid,
# gone on the floor.
#
# THE GUN GOES OUT OF HIS HANDS, NOT OUT OF HIS ARMOURY. Nothing about what he owns or
# what he goes up with changes; this is what the figure is holding while he walks
# around downstairs, which is nothing.
SubRx @'
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#8a96a1'; ctx.textAlign='center';
    ctx.fillText(sl[sel].name+'   [FIRE] use    [V] signal',W/2,hy-LH(6));
    ctx.textAlign='left';
'@ @'
    // v13.08, HIS NOTE: not in the Undercroft. The belt strip is drawn on the floor
    // as well as in a raid, and this caption offers two actions that do not exist
    // down there: there is nothing to fire at and nobody to signal. It stays in a
    // raid, where both are real and he uses them.
    if(state!=='hub'){
      ctx.font=FS(TYPE.micro); ctx.fillStyle='#8a96a1'; ctx.textAlign='center';
      ctx.fillText(sl[sel].name+'   [FIRE] use    [V] signal',W/2,hy-LH(6));
      ctx.textAlign='left';
    }
'@

SubRx @'
      drawOp(p.x,p.y,p.face,(p.rollT>0)?(1-p.rollT/.38)*12.6:p.bob,'#242832',clamp(P.stash.length/24,0,1),0,
        (p.rollT>0)?'roll':((P.equipped&&P.equipped!=='fists')?'':'none'),0,
        {hero:1,moving:p.moving,sprint:false,ads:false,hurt:0,rl:0,
         own:{wep:WEAPONS[P.equipped]||null}});
'@ @'
      // v13.08, HIS NOTE: "player shouldn't have gun visible in his hand when he's in
      // the undercroft". The floor draws the raid operator, so it was handing him his
      // equipped gun and the stance that goes with it. Empty hands down here, the roll
      // untouched. He still owns the gun and still goes up with it.
      drawOp(p.x,p.y,p.face,(p.rollT>0)?(1-p.rollT/.38)*12.6:p.bob,'#242832',clamp(P.stash.length/24,0,1),0,
        (p.rollT>0)?'roll':'none',0,
        {hero:1,moving:p.moving,sprint:false,ads:false,hurt:0,rl:0,
         own:{wep:null}});
'@

SubRx @'
      drawOp(p.x,p.y,p.face,(p.rollT>0)?(1-p.rollT/.38)*12.6:p.bob,'#9fd8ff',0,0,
        (p.rollT>0)?'roll':((P.equipped&&P.equipped!=='fists')?'':'none'),0,
        {hero:1,moving:p.moving,sprint:false,ads:false,hurt:0,rl:0,own:{wep:WEAPONS[P.equipped]||null}});
'@ @'
      // v13.08: and the same for the ghost of him, which is the same man.
      drawOp(p.x,p.y,p.face,(p.rollT>0)?(1-p.rollT/.38)*12.6:p.bob,'#9fd8ff',0,0,
        (p.rollT>0)?'roll':'none',0,
        {hero:1,moving:p.moving,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}});
'@

# NEW IN.
SubRx @'
  'THE FREEBIE KIT NEVER TOUCHED THE GUN YOU OWN, AND NOW THE CODE SAYS SO.
'@ @'
  'YOU ARE NOT CARRYING A GUN AROUND THE UNDERCROFT. The floor draws the same operator a raid does, so it handed you your equipped gun and the stance that goes with it while you walked around your own home. The belt caption went with it: it offered you FIRE and SIGNAL down there, and there is nothing to fire at and nobody to signal. Both are still there in a raid, where they are true.',
  'THE FREEBIE KIT NEVER TOUCHED THE GUN YOU OWN, AND NOW THE CODE SAYS SO.
'@

# STAMPS.
SubRx @'
var VER='13.06';
'@ @'
var VER='13.08';
'@
SubRx @'
var WHATSNEW_VER='13.06';
'@ @'
var WHATSNEW_VER='13.08';
'@
$cnt=([regex]::Matches($s,"now:'v13\.06:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v13.06 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v13\.06:[^']*'",{ param($m) "now:'v13.08: his notes of 2026-09-12 from live play, two of three. Player should not have a gun visible in his hand when he is in the undercroft; and in the undercroft it says Compact SMG FIRE use V signal, and all that text is useless. One cause, two symptoms: the floor reuses the raid own drawing, the same operator routine and the same belt strip, and both were handed the raid arguments down there, so he walks around his own home holding a gun under a line offering two actions that do not exist in the Undercroft, where you cannot fire and there is nobody to signal. The line is kept in a raid where it is true: he called the text useless where he read it, and where he read it, it is, but up top those are real actions on a real belt and deleting them there would take something he uses. The gun goes out of his hands and not out of his armoury: nothing about what he owns or what he goes up with changes, only what the figure is holding while he walks around downstairs, which is nothing, and the roll pose is untouched. Check 13.08 draws the floor and requires no weapon to reach the operator and the belt caption to be absent, then draws a raid frame and requires both back, so the fix cannot have been made by deleting them everywhere; fails on v13.06 where the floor hands over the equipped gun and prints the caption. NOTE ON VERSION NUMBERS: 13.04, 13.05 and 13.07 carry no game build, they were harness-only checks.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

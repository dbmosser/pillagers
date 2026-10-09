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

# 4K: CENTRE PANELS GROW WITH THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var T=G.trade,PW=LH(340),PH=LH(238),x=Math.round(W/2-PW/2),y=Math.round(H/2-PH/2);
'@ @'
  // v20.75, from the whole-game bug hunt of 2026-10-08 (H42): THE PEDDLER PANEL GROWS WITH THE SCREEN. Its size and its type follow
  // the text dial only, so at 4K it stayed its 1080p size beside a backpack and a world drawn twice as big. It is scaled about the
  // centre of the screen by the screen factor the world prompts use (hudAtIn), which is exactly 1 at 1080p, so 1080p is unchanged.
  var T=G.trade,PW=LH(340),PH=LH(238),x=Math.round(W/2-PW/2),y=Math.round(H/2-PH/2);
  var _tz=hudAtIn(W/2,H/2);
'@

SubRx @'
  ctx.fillText('He is unarmed. Shooting him has a price.',x+14,y+PH-LH(13));
'@ @'
  ctx.fillText('He is unarmed. Shooting him has a price.',x+14,y+PH-LH(13));
  if(_tz){ ctx.restore(); ctx.textAlign='left'; }   // v20.75 (H42)
'@

SubRx @'
      var hIn=(hm.kill?7:5)+(1-hk)*(hm.kill?7:4),hOut=hIn+(hm.kill?7:5);
      ctx.strokeStyle=hm.kill?'rgba(255,192,74,'+(hk*.95)+')':'rgba(240,248,252,'+(hk*.9)+')';
      ctx.lineWidth=hm.kill?2.4:1.8;
'@ @'
      // v20.75, from the whole-game bug hunt of 2026-10-08 (H42): the hit ticks grow with the screen, as the reticle has since v9.53.
      // Its gap is 8 times the screen factor, so at 4K the 1080p ticks sat inside the hole of the cross.
      var hIn=((hm.kill?7:5)+(1-hk)*(hm.kill?7:4))*_rz,hOut=hIn+(hm.kill?7:5)*_rz;
      ctx.strokeStyle=hm.kill?'rgba(255,192,74,'+(hk*.95)+')':'rgba(240,248,252,'+(hk*.9)+')';
      ctx.lineWidth=(hm.kill?2.4:1.8)*_rz;
'@

SubRx @'
      var _ntY=Math.round(H*0.26);
'@ @'
      var _ntY=Math.round(H*0.26);
      // v20.75, from the whole-game bug hunt of 2026-10-08 (H42): the stamp grows with the screen, about its own line, inside the
      // save above; at 4K it was its 1080p size. The screen factor is exactly 1 at 1080p.
      var _ntR=Math.max(1,hudRes()); ctx.translate(W/2,_ntY); ctx.scale(_ntR,_ntR); ctx.translate(-W/2,-_ntY);
'@

SubRx @'
    ctx.fillStyle='#1B1622'; ctx.fillText('YOU DIED',W/2+2,H*0.42+2);
    ctx.fillStyle='#ff5040'; ctx.fillText('YOU DIED',W/2,H*0.42);
'@ @'
    var _ydz=hudAtIn(W/2,H*0.42);   // v20.75, from the whole-game bug hunt of 2026-10-08 (H42): YOU DIED grows with the screen, as DOWN does
    ctx.fillStyle='#1B1622'; ctx.fillText('YOU DIED',W/2+2,H*0.42+2);
    ctx.fillStyle='#ff5040'; ctx.fillText('YOU DIED',W/2,H*0.42);
    if(_ydz) ctx.restore();
'@

SubRx @'
      var _y=p.downed?H/2+64:H/2-124;
'@ @'
      var _y=p.downed?H/2+64:H/2-124;
      // v20.75, from the whole-game bug hunt of 2026-10-08 (H42): THE CENTRE LINE GROWS WITH THE SCREEN. At 4K it stayed its 1080p
      // size and its 1080p distance from the player, who is drawn twice as big. It is scaled about the centre of the screen, as the
      // downed overlay it sits under has been since v9.08, so both keep their places; 1080p is unchanged.
      var _cvz=hudAtIn(W/2,H/2);
'@

SubRx @'
        ctx.fillText(_sub,W/2,_y+LH(20));
      }
      ctx.textAlign='left';
'@ @'
        ctx.fillText(_sub,W/2,_y+LH(20));
      }
      if(_cvz) ctx.restore();
      ctx.textAlign='left';
'@

SubRx @'
var VER='20.74';
'@ @'
var VER='20.75';
'@

$pat = "(?m)^  now:'v20\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.75: At 4K the Peddler panel, YOU DIED, the NOTORIETY stamp, the centre extract line and the hit ticks match the size of the rest of the screen. Check 20.75 fails on v20.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

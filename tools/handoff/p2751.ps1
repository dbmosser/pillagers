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

# THE CENTRE BANNERS ARE ALERTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.notoN=P.notoriety||0;
  G.shake=Math.max(G.shake||0,7);
'@ @'
  G.notoN=P.notoriety||0;
  G.shake=Math.max(G.shake||0,7);
  // v27.51 (feed2), HIS ORDER (2026-10-14): the messages that came in at different heights of the centre come in one place. The notoriety
  // stamp was a banner of its own at 26 percent of the screen (the rating, why, and a sentence on what it costs); it is an alert now, in the
  // top centre lane, as every other big moment is: the rating and its name, and why in the detail. It is also a line in the feed.
  if(!G.arcade){ try{ say('NOTORIETY '+(G.notoN||0)+'  \u00b7  '+notoName(G.notoN).toUpperCase(),'warn',{sub:String(why||''),key:'noto'}); }catch(_nsy){} }
'@

SubRx @'
  // v8.27: THE NOTORIETY STAMP. Three seconds, centred high so it clears the
  // reticle and the belt, and it names the rating so the word he sees here is
  // the word the stats page will show him afterwards.
  if(!G.arcade&&G.notoAt!==undefined&&G.notoAt!==null){   // v23.35 (arcade13): not in the arcade
    var _ntAge=G.t-G.notoAt;
    if(_ntAge>=0&&_ntAge<3){
      var _ntA=Math.min(1,(3-_ntAge)/0.8)*Math.min(1,_ntAge/0.12);
      ctx.save();
      ctx.globalAlpha=_ntA;
      var _ntY=Math.round(H*0.26);
      // v20.75, from the whole-game bug hunt of 2026-10-08 (H42): the stamp grows with the screen, about its own line, inside the
      // save above; at 4K it was its 1080p size. The screen factor is exactly 1 at 1080p.
      var _ntR=Math.max(1,hudRes()); ctx.translate(W/2,_ntY); ctx.scale(_ntR,_ntR); ctx.translate(-W/2,-_ntY);
      ctx.textAlign='center';
      ctx.font=FS(TYPE.head);
      var _ntT='NOTORIETY '+(G.notoN||0)+'   \u00b7   '+notoName(G.notoN).toUpperCase();
      var _ntW=Math.max(ctx.measureText(_ntT).width,ctx.measureText(G.notoWhy||'').width);
      ctx.fillStyle='rgba(24,6,4,.82)';
      ctx.fillRect(W/2-_ntW/2-LH(18),_ntY-LH(22),_ntW+LH(36),LH(50));
      ctx.strokeStyle='rgba(255,107,90,.85)'; ctx.lineWidth=1;
      ctx.strokeRect(W/2-_ntW/2-LH(18)+.5,_ntY-LH(22)+.5,_ntW+LH(36)-1,LH(50)-1);
      ctx.fillStyle='#ff6b5a';
      ctx.fillText(_ntT,W/2,_ntY);
      ctx.font=FS(TYPE.micro);
      ctx.fillStyle='#e8b0a6';
      ctx.fillText(G.notoWhy||'',W/2,_ntY+LH(15));
      ctx.fillStyle='rgba(200,160,150,.85)';
      ctx.fillText(notoBite(G.notoN),W/2,_ntY+LH(28));
      ctx.textAlign='left';
      ctx.restore();
    }
  }

'@ @'
  // v27.51 (feed2): the stamp that was drawn here (the rating, its name, why and what it costs, a banner at 26 percent of the screen) is
  // an alert in the top centre lane now: notoStamp says it. The fields it set (G.notoAt, G.notoWhy, G.notoN) are kept.

'@

SubRx @'
  n=Math.max(1,Math.ceil(t)); s='DROPPING IN '+n;
  y=Math.round(H*(ARCADE.banner?0.66:0.36));
  ctx.save(); ctx.textAlign='center'; ctx.textBaseline='alphabetic';
  ctx.globalAlpha=0.6+0.4*Math.max(0,Math.min(1,t-(n-1)));
  ctx.font=FSz(TYPE.huge,1.2); ctx.fillStyle='#ffc04a'; hudText(s,cx,y);
  ctx.restore();
'@ @'
  n=Math.max(1,Math.ceil(t)); s='DROPPING IN '+n;
  // v27.51 (feed2), HIS ORDER (2026-10-14): not a big banner at 36 percent of the screen but an alert in the top centre lane, the same
  // place as every other big moment. The same key refreshes it each frame, the number changing, and it lingers a second after the
  // count ends. The count goes in the lane only, never into the feed (a line per second would flood it).
  try{ alertSay(s,'ext',{key:'drop',c:'warn',icon:'clock',life:1.2}); }catch(_ads){}
'@

SubRx @'
  if((/^(WEAK SPOT|ACTIVE RELOAD|PICKED UP|CLOSE CALL)$/).test(s)
'@ @'
  if((/^(WEAK SPOT|ACTIVE RELOAD|PICKED UP|CLOSE CALL|NOTORIETY \+\d+)$/).test(s)
'@

SubRx @'
var VER='27.50';
'@ @'
var VER='27.51';
'@

$pat = "(?m)^  now:'v27\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.51: The notoriety stamp and the drop-in count are now alerts in the top centre lane. Check 27.51 fails on v27.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

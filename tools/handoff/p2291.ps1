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

# OFFER LINE AND USE BAR GROW AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.save(); ctx.font=FS(TYPE.label); ctx.textAlign='center';
  w=ctx.measureText(s).width;
  ctx.fillStyle='rgba(6,9,13,.78)'; ctx.fillRect(W/2-w/2-12,y-LH(15),w+24,LH(22));
  ctx.fillStyle='#ffc04a'; ctx.fillText(s,W/2,y);
  ctx.restore();
  HUDGIFTB=y+LH(7);   // v20.55 (H38): the bottom of this plate, for the controller word
'@ @'
  // v22.xx, the raid text rewrite (R40): THE OFFER LINE GROWS AT 4K. HIS ORDER (2026-10-09): the raid text reads like a shooter HUD,
  // and a shooter HUD is the same size on every screen. This line and its plate kept their 1080p size at 4K, so under the message
  // rows and the boss plate (both drawn at the screen scale since v21.11) the offer read as small print. Plate and words are now
  // drawn at the screen scale, grown about the top centre of the plate, so the plate still starts where it did, and HUDGIFTB is the
  // bottom of the grown plate, so the controller word below it moves down with it. At 1080p nothing moves.
  var _gr=Math.max(1,(typeof hudRes==='function')?hudRes():1), _gt=y-LH(15);
  ctx.save();
  if(_gr>1){ ctx.translate(W/2,_gt); ctx.scale(_gr,_gr); ctx.translate(-W/2,-_gt); }
  ctx.font=FS(TYPE.label); ctx.textAlign='center';
  w=ctx.measureText(s).width;
  ctx.fillStyle='rgba(6,9,13,.78)'; ctx.fillRect(W/2-w/2-12,y-LH(15),w+24,LH(22));
  ctx.fillStyle='#ffc04a'; ctx.fillText(s,W/2,y);
  ctx.restore();
  HUDGIFTB=Math.round(_gt+LH(22)*_gr);   // v20.55 (H38): the bottom of this plate, for the controller word (v22.xx, R40: of the grown plate)
'@

SubRx @'
  if(G.emoteBar) y=Math.min(y,emoteStripY()-LH(30)-h);   // v22.14 (K25): above the strip, wherever the strip sits now
  ctx.save();
  ctx.font=FS(TYPE.label); ctx.textAlign='center';
'@ @'
  if(G.emoteBar) y=Math.min(y,emoteStripY()-LH(30)-h);   // v22.14 (K25): above the strip, wherever the strip sits now
  // v22.xx, the raid text rewrite (R40): THE USE BAR CAPTION GROWS AT 4K. The bar itself grew with the screen (v18.75), but its
  // caption (APPLYING BANDAGE  1.2s) and the room around it kept their 1080p size, so at 4K a thick bar carried a small line. The
  // caption is now hudFS(TYPE.label) and the plate paddings and the gap between two bars grow by the same screen factor. The bar
  // moves up by what its plate grew below it, so the plate keeps its distance from the belt caption, the extraction lines and the
  // emote strip. At 1080p nothing moves.
  var _uz=Math.max(1,hr||1), _ux=Math.round(LH(10)*_uz), _ut=Math.round(LH(20)*_uz), _uh=Math.round(LH(28)*_uz), _uc=Math.round(LH(6)*_uz), _ug=Math.round(LH(34)*_uz);
  y-=(_uh-_ut)-(LH(28)-LH(20));
  ctx.save();
  ctx.font=hudFS(TYPE.label); ctx.textAlign='center';
'@

SubRx @'
    if(typeof hudPanel==='function') hudPanel(x-LH(10),y-LH(20),w+LH(20),h+LH(28),0.78);
    else { ctx.fillStyle='rgba(6,9,13,.78)'; ctx.fillRect(x-LH(10),y-LH(20),w+LH(20),h+LH(28)); }
    ctx.fillStyle='#e8f0f6'; ctx.fillText(s,W/2,y-LH(6));
'@ @'
    if(typeof hudPanel==='function') hudPanel(x-_ux,y-_ut,w+_ux*2,h+_uh,0.78);   // v22.xx (R40): the paddings grow with the screen
    else { ctx.fillStyle='rgba(6,9,13,.78)'; ctx.fillRect(x-_ux,y-_ut,w+_ux*2,h+_uh); }
    ctx.fillStyle='#e8f0f6'; ctx.fillText(s,W/2,y-_uc);
'@

SubRx @'
    n++;
    y-=h+LH(34);
'@ @'
    n++;
    y-=h+_ug;   // v22.xx (R40): the gap between two bars grows with the screen
'@

SubRx @'
var VER='22.90';
'@ @'
var VER='22.91';
'@

$pat = "(?m)^  now:'v22\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.91: On a 4K screen the trade offer line and the bandage bar caption are now as big as the rest of the HUD. Check 22.91 fails on v22.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

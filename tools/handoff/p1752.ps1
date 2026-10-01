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

# A TRADE OFFER STAYS ON SCREEN WHILE IT IS OPEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v17.45, his pick 21: the boss bar, top centre, while THE OVERSEER is alive and within 900 of this player.
'@ @'
// v17.52, polish after his pick 4 (trading): AN OFFER STAYS ON SCREEN WHILE IT IS OPEN. The offer line came once in the
// message feed and faded, so a player on a controller who missed it never knew an item was waiting. While an offer to this
// player is open, a line under the boss bar names who offers what, the keys that take it and the seconds left; while this
// player's own offer is open, it says who it waits on. Drawing only.
function drawGiftLine(){
  var gi, go, t, s=null, it, w, y;
  if(typeof G==='undefined'||!G||G.over||!G.player) return null;
  gi=G.giftIn; go=G.giftOut;
  if(gi&&!gi.yes&&(t=GIFT_T-((G.t||0)-gi.t))>0){ it=ITEMS[gi.k]; s=(netSeatName(gi.from)||'Your teammate')+' offers you '+(it?it.name:gi.k)+'.  T or Y to take it.  '+Math.ceil(t)+'s'; }
  else if(go&&(t=GIFT_T-((G.t||0)-go.t))>0){ it=ITEMS[go.k]; s='Offered '+(it?it.name:go.k)+' to '+(netSeatName(go.to)||'your teammate')+'. Waiting for them to take it.  '+Math.ceil(t)+'s'; }
  if(!s) return null;
  y=LH(104);
  ctx.save(); ctx.font=FS(TYPE.label); ctx.textAlign='center';
  w=ctx.measureText(s).width;
  ctx.fillStyle='rgba(6,9,13,.78)'; ctx.fillRect(W/2-w/2-12,y-LH(15),w+24,LH(22));
  ctx.fillStyle='#ffc04a'; ctx.fillText(s,W/2,y);
  ctx.restore();
  return s;
}// v17.45, his pick 21: the boss bar, top centre, while THE OVERSEER is alive and within 900 of this player.
'@

SubRx @'
  try{ drawBossBar(); }catch(_bb){}   // v17.45: his pick 21
'@ @'
  try{ drawBossBar(); }catch(_bb){}   // v17.45: his pick 21
  try{ drawGiftLine(); }catch(_gl){}   // v17.52: an open trade offer stays on screen
'@

SubRx @'
var VER='17.51';
'@ @'
var VER='17.52';
'@

$pat = "(?m)^  now:'v17\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.52: Trading: an open offer now stays on screen with who offers what, T or Y to take it and the seconds left, and the giver sees who it is waiting on. Check 17.52 fails on v17.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

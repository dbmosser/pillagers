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

# THE CO-OP HUD DRAWS WHERE IT SHOULD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ if(NET.on) netTeamHud(by); }catch(_nth){}   // v16.26: your teammates, their health and armour, above your own
  try{ if(NET.on) netFeedDraw(); }catch(_nfd){}   // v16.42: the kill feed
  try{ if(NET.on) netPingDraw(); }catch(_npd){}   // v16.43: the party pings
  try{ if(NET.same) netPadHud(); }catch(_nph){}   // v16.78: the controller paused word, in the window whose pad went quiet
'@ @'
  // v19.07: the co-op HUD (teammate rows, kill feed, pings, the controller paused word) is drawn after the corner scale ends, below
'@

SubRx @'
  ctx.restore();                          // v8.08: end of the corner scale
  ctx.restore();
'@ @'
  ctx.restore();                          // v8.08: end of the corner scale
  ctx.restore();
  // v19.07, FROM THE REVIEW OF 2026-10-07 (found checking the status icons against the teammate HUD): THE CO-OP HUD DRAWS WHERE
  // IT SHOULD. netTeamHud, netFeedDraw, netPingDraw and netPadHud were called inside the vitals corner's zoom (hudZoomIn body, 1.4
  // times hudRes about the bottom left), so every point they drew was pushed up and out: at 1080p the teammate rows sat in the top
  // left corner and ran into the CURRENT PILLAGERS board, and at 1440p and 4K the rows, the kill feed and the pings were drawn off
  // the screen altogether. They are drawn here, in plain screen space. The teammate rows start below the board and grow with the
  // screen; the kill feed starts below CONDITIONS and grows too; the status column starts below the teammate rows.
  try{ NETTEAMBOX.n=0; }catch(_ntb){}   // v19.07: no rows unless drawn this frame, so a party that ended never moves the status column
  try{ if(NET.on) netTeamHud(by); }catch(_nth){}   // v16.26: your teammates, their health and armour
  try{ if(NET.on) netFeedDraw(); }catch(_nfd){}   // v16.42: the kill feed
  try{ if(NET.on) netPingDraw(); }catch(_npd){}   // v16.43: the party pings
  try{ if(NET.same) netPadHud(); }catch(_nph){}   // v16.78: the controller paused word, in the window whose pad went quiet
'@

SubRx @'
function netTeamHud(by){
  var i, g, n=0, x=16, w=150, y, f, t;
'@ @'
var NETTEAMBOX={n:0,x:0,y:0,w:0,h:0};   // v19.07: where the teammate rows were drawn this frame, for the status column (not a click box)
function netTeamHud(by){
  var i, g, n=0, x=16, w=150, y, f, t;
  var _thr=Math.max(1,(typeof hudRes==='function')?hudRes():1), _tt=Math.round(H*0.30), _ty;   // v19.07: rows below the board, grown with the screen
  if(HUDBOX.raiders) _tt=Math.max(_tt,Math.round(HUDBOX.raiders.y+HUDBOX.raiders.h+16*_thr));
  NETTEAMBOX.n=0;
'@

SubRx @'
    y=Math.round(H*0.30)+n*44; n++;   // v16.27, his note: the rows sat on the belt help line; they now run down the left edge, clear of it
'@ @'
    y=Math.round(H*0.30)+n*44; n++;   // v16.27, his note: the rows sat on the belt help line; they now run down the left edge, clear of it
    _ty=_tt+(n-1)*Math.round(44*_thr)+Math.round(15*_thr); ctx.save(); ctx.translate(0,_ty-_thr*y); ctx.scale(_thr,_thr);   // v19.07: this row drawn at its screen place and size
    NETTEAMBOX={n:n,x:Math.round(12*_thr),y:_tt,w:Math.round(158*_thr),h:Math.round(n*44*_thr)};
'@

SubRx @'
    try{ netMateArrow(g); }catch(_ma){}   // v16.41: an arrow at the screen edge to a teammate off screen
'@ @'
    ctx.restore();   // v19.07: the row's own scale ends before the edge arrow, which works in screen space
    try{ netMateArrow(g); }catch(_ma){}   // v16.41: an arrow at the screen edge to a teammate off screen
'@

SubRx @'
function netFeedDraw(){
  var i, f, now=Date.now(), y=Math.round(H*0.40), x=W-LH(16), n=0, a, tw;
  if(!NET.feed||!NET.feed.length) return 0;
'@ @'
function netFeedDraw(){
  var i, f, now=Date.now(), y, x, n=0, a, tw, _fhr=Math.max(1,(typeof hudRes==='function')?hudRes():1);   // v19.07: grown with the screen
  if(!NET.feed||!NET.feed.length) return 0;
  ctx.save(); ctx.scale(_fhr,_fhr); y=Math.round(H*0.46/_fhr); x=(W-LH(16)*_fhr)/_fhr;   // v19.07: below CONDITIONS (was 0.40, which a long contract list reaches)
'@

SubRx @'
    y+=LH(22); n++;
  }
  ctx.globalAlpha=1; ctx.textAlign='left';
  return n;
'@ @'
    y+=LH(22); n++;
  }
  ctx.globalAlpha=1; ctx.textAlign='left';
  ctx.restore();
  return n;
'@

SubRx @'
  if(B&&B.x<ox+wC&&B.x+B.w>ox&&B.y<=oy&&B.y+B.h+g*hr>oy) oy=Math.round(B.y+B.h+g*hr);
'@ @'
  if(B&&B.x<ox+wC&&B.x+B.w>ox&&B.y<=oy&&B.y+B.h+g*hr>oy) oy=Math.round(B.y+B.h+g*hr);
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.y+NETTEAMBOX.h+g*hr>oy) oy=Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr);   // v19.07: and below the teammate rows
'@

SubRx @'
var VER='19.06';
'@ @'
var VER='19.07';
'@

$pat = "(?m)^  now:'v19\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.07: In two player raids your teammate health, the kill feed and pings show on screen at every resolution. Check 19.07 fails on v19.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

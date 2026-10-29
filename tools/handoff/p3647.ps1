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

# STATUSES STACK, MEDALS UNDER THE FEED, RUN GOALS SAY WHAT TO DO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawStatusIcons(){
  var p=G&&G.player, L=STATUSL, E, i, j, n=0, s=0, hr, S, g, r, ox, oy, yBot, rows, B, wC, nf, vf, x, y, cx, cy, tx, tw, lw, rr, u, hx, ph;

'@ @'
// v28.xx (cw-hudstack): the status column as drawn this frame, in screen pixels (n 0 when none): the medal row's fallback spot keeps clear of it, and the checks read it.
var STATBOX={n:0,x:0,y:0,w:0,h:0};
function drawStatusIcons(){
  var p=G&&G.player, L=STATUSL, E, i, j, n=0, s=0, hr, S, g, r, ox, oy, yBot, rows, B, wC, nf, vf, x, y, cx, cy, tx, tw, lw, rr, u, hx, ph, _top;
  STATBOX.n=0;

'@

SubRx @'
  hr=hudRes(); S=LH(26); g=Math.round(8*uiScale()); r=S/2;
  ph=Math.max(48*uiScale(),parseFloat((/([\d.]+)px/).exec(nf)[1])+parseFloat((/([\d.]+)px/).exec(vf)[1])+LH(8));

'@ @'
  // v28.xx (cw-hudstack), HIS NOTE (2026-10-29, his picture of three statuses over two medals): "the statuses are too big and that makes them spill over to the right ...
  // ideally they would all be vertical and not collide and the statuses might be marginally smaller". A row is 40 px tall (was 48), its disc 24 (was 26) and the gap 6
  // (was 8); the shared width is the widest live words (the 220 px floor is gone). The 20 px title and 16 px detail floors stay.
  hr=hudRes(); S=LH(24); g=Math.round(6*uiScale()); r=S/2;
  ph=Math.max(40*uiScale(),parseFloat((/([\d.]+)px/).exec(nf)[1])+parseFloat((/([\d.]+)px/).exec(vf)[1])+LH(4));

'@

SubRx @'
  wC=(Math.ceil(Math.max(220*uiScale(),ph+LH(6)+tw+LH(10)))+g)*hr;   // v28.xx (cw-cx-statuspanels): one measured panel width, at least 220px, with an eight-pixel column gap.

'@ @'
  wC=(Math.ceil(ph+LH(4)+tw+LH(12))+g)*hr;   // v28.xx (cw-hudstack): one shared width, the widest live words and 12 px after them, and the 6 px gap

'@

SubRx @'
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.y+NETTEAMBOX.h+g*hr>oy) oy=Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr);   // v19.07: and below the teammate rows

'@ @'
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.y+NETTEAMBOX.h+g*hr>oy) oy=Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr);   // v19.07: and below the teammate rows
  // v28.xx (cw-hudstack): how high the column may start when its rows do not fit under 40 percent: under every panel above it at the left, the teammate rows and 20 percent of the screen
  _top=Math.round(H*0.20); if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n) _top=Math.max(_top,Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr));

'@

SubRx @'
    if(B.y+B.h+g*hr<=oy||B.y>=yBot) continue;

'@ @'
    if(B.y+B.h+g*hr<=oy||B.y>=yBot){ if(B.y<oy&&B!==FEEDBOX&&B!==MEDALBOX) _top=Math.max(_top,Math.round(B.y+B.h+g*hr)); continue; }   // v28.xx (cw-hudstack): a panel above the column bounds how high it may start

'@

SubRx @'
    if(B.y<=oy+S*hr/2) oy=Math.round(B.y+B.h+g*hr);

'@ @'
    if(B.y<=oy+S*hr/2){ oy=Math.round(B.y+B.h+g*hr); _top=Math.max(_top,oy); }

'@

SubRx @'
  rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((ph+g)*hr)));
  // v28.xx (cw-cx-statuswrap): wrap at full type size; if two columns cannot fit vertically, stack beside the left HUD panels.

'@ @'
  rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((ph+g)*hr)));
  // v28.xx (cw-hudstack): one column first. When the rows do not fit between 40 percent and the feed, the column starts higher, as high as it must and never over
  // a panel above it; only when that is not enough does it wrap (below).
  if((n>rows||yBot-oy<ph*hr)&&oy>_top){ oy=Math.floor(Math.max(_top,yBot-(n*(ph+g)-g)*hr)); rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((ph+g)*hr)+1e-6)); }
  // v28.xx (cw-cx-statuswrap): wrap at full type size; if two columns cannot fit vertically, stack beside the left HUD panels.

'@

SubRx @'
      cx=x+ph/2; cy=y+ph/2; tx=x+ph+LH(6);

'@ @'
      cx=x+ph/2; cy=y+ph/2; tx=x+ph+LH(4);   // v28.xx (cw-hudstack): the words 4 px nearer the disc

'@

SubRx @'
  } finally { ctx.restore(); }
  return s;
}
var CONDWRAP={}, CONDWRAPN=0;
'@ @'
  } finally { ctx.restore(); }
  STATBOX.n=s; STATBOX.x=ox; STATBOX.y=oy; STATBOX.w=Math.ceil(s/rows)*wC-g*hr; STATBOX.h=Math.min(s,rows)*(ph+g)*hr-g*hr;   // v28.xx (cw-hudstack)
  return s;
}
var CONDWRAP={}, CONDWRAPN=0;
'@

SubRx @'
function styMedalSpot(z,n){

'@ @'
function styMedalSpot(z,n){
  // v28.xx (cw-hudstack), HIS NOTE (2026-10-29): "the medals and the statuses collide". The row was slid up and down from the middle of the screen, and the status
  // column (drawn after it) was not one of the panels it kept clear of. It now stands in the medal spot kept for it since v27.40 (his "Halo puts medals in a row at
  // the left"), between the feed and the vitals, where nothing else draws: the emblems as tall as the spot allows (36 px at 1080p, were 50) and the name plate beside
  // the newest, not under it. Without a spot (no feed this raid) the old search below stands, and it keeps clear of the status column too.
  var M=(typeof MEDALBOX==='object'&&MEDALBOX&&MEDALBOX.on&&MEDALBOX.w>0&&MEDALBOX.h>0)?MEDALBOX:null, ms;
  if(M){ ms=Math.max(8,Math.min(Math.round(STYM.size*z),Math.floor(M.h/2)-Math.round(2*z))); return {x:M.x,y:Math.round(M.y+M.h/2),s:ms,g:Math.round(STYM.gap*z),free:1,dn:ms,side:1}; }

'@

SubRx @'
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.w>0) bx.push(NETTEAMBOX);
  function hit(yy){
'@ @'
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.w>0) bx.push(NETTEAMBOX);
  if(typeof STATBOX==='object'&&STATBOX&&STATBOX.n&&STATBOX.w>0) bx.push(STATBOX);   // v28.xx (cw-hudstack)
  function hit(yy){
'@

SubRx @'
      x=sp.x; y=sp.y+s+Math.round(7*z);

'@ @'
      if(sp.side){ x=sp.x+live.length*(2*s+sp.g)-sp.g+Math.round(10*z); y=Math.round(sp.y-hh/2); }   // v28.xx (cw-hudstack): beside the row, in the medal spot
      else { x=sp.x; y=sp.y+s+Math.round(7*z); }

'@

SubRx @'
  kill10:{t:'10 KILLS',n:10,chip:200}, crate6:{t:'6 CRATES',n:6,chip:200}, wave3:{t:'3 WAVES',n:3,chip:250}, air1:{t:'AIR STRIKE',n:1,chip:300},
  vault:{t:'OPEN A VAULT',n:1,chip:400}, pill3:{t:'3 PILLAGERS',n:3,chip:400}, elite:{t:'KILL AN ELITE',n:1,chip:400}, ward:{t:'DOWN A WARDEN',n:1,chip:500}

'@ @'
  // v28.xx (cw-hudstack), HIS NOTE (2026-10-29): "3 pillager 0/3 item -- no idea what that means, not very useful mid raid". Every goal is a thing to do.
  kill10:{t:'GET 10 KILLS',n:10,chip:200}, crate6:{t:'OPEN 6 CRATES',n:6,chip:200}, wave3:{t:'SURVIVE 3 WAVES',n:3,chip:250}, air1:{t:'CALL AN AIR STRIKE',n:1,chip:300},
  vault:{t:'OPEN A VAULT',n:1,chip:400}, pill3:{t:'KILL 3 PILLAGERS',n:3,chip:400}, elite:{t:'KILL AN ELITE',n:1,chip:400}, ward:{t:'DOWN A WARDEN',n:1,chip:500}

'@

SubRx @'
function goalRewardText(gl){
  if(G.arcade) return 'power-up';
  return /^(vault|pill3|elite|ward)$/.test(gl.id)?'item':('$'+((gl.chip|0)*5).toLocaleString());
}

'@ @'
function goalPaysItem(gl){ return /^(vault|pill3|elite|ward)$/.test(gl.id); }
function goalRewardText(gl){
  if(G.arcade) return 'power-up';
  return goalPaysItem(gl)?'bonus loot':('$'+((gl.chip|0)*5).toLocaleString());   // v28.xx (cw-hudstack): the cache roll reads bonus loot, not item
}

'@

SubRx @'
    if(goalRewardText(gl)==='item'){

'@ @'
    if(goalPaysItem(gl)){

'@

SubRx @'
        rows.push({k:'',v:String(_gl.t)+((!_gl.done&&_gl.n>1)?('\u00a0\u00a0'+_gl.v+'/'+_gl.n):'')+'\u00a0\u00a0'+((_gl.done?'done ':'')+goalRewardText(_gl)),vc:_gl.done?UIC.ok:UIC.tx_1});

'@ @'
        // v28.xx (cw-hudstack), HIS NOTE (2026-10-29): "3 pillager 0/3 item -- no idea what that means". The task (kill 3 pillagers), its count, then a dot and what it pays.
        rows.push({k:'',v:String(_gl.t)+((!_gl.done&&_gl.n>1)?('\u00a0\u00a0'+_gl.v+'/'+_gl.n):'')+(_gl.done?'\u00a0\u00a0done':'')+'\u00a0\u00a0\u00b7\u00a0\u00a0'+goalRewardText(_gl).replace(/ /g,'\u00a0'),vc:_gl.done?UIC.ok:UIC.tx_1});

'@

SubRx @'
var VER='36.46';
'@ @'
var VER='36.47';
'@

$pat = "(?m)^  now:'v36\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.47: Status cards are 40 px rows fitted to their words in one column, starting higher when they need room. Style medals stand in the reserved medal row between the feed and the vitals, clear of every status. Run goals read as tasks (kill 3 pillagers 0/3, get 10 kills) with what they pay (bonus loot, $1,000). HUD rendering and goal words only. Check 36.47 fails on v36.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

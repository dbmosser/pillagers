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

# ALLEGIANCE HAS A SHAPE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@ @'
// v28.xx (cw-cx-sideglyphs), his 2.79 a: allegiance has a shape as well as team colour, always on, in both body renderers.
function colourCueGlyph(c,kind,x,y,R,col){
  c.save(); c.translate(x,y); c.scale(R,R); c.lineWidth=1.5; c.lineJoin='round';
  c.fillStyle='#0b0c0d'; c.fillRect(-7,-7,14,14); c.strokeStyle='#efe9dc'; c.fillStyle=col||'#efe9dc';
  c.beginPath();
  if(kind==='foe'||kind==='danger'){
    c.moveTo(0,-5);c.lineTo(5,4);c.lineTo(-5,4);c.closePath();c.fill();c.stroke();
    if(kind==='danger'){c.fillStyle='#0b0c0d';c.fillRect(-.7,-2,1.4,3);c.fillRect(-.7,2,1.4,1);}
  }else if(kind==='ally'||kind==='down'){
    if(kind==='down')c.rotate(Math.PI/4);
    c.fillStyle='#efe9dc';c.fillRect(-5,-1.5,10,3);c.fillRect(-1.5,-5,3,10);
  }else if(kind==='seal'||kind==='place'){
    c.moveTo(0,-5);c.lineTo(5,0);c.lineTo(0,5);c.lineTo(-5,0);c.closePath();c.fill();c.stroke();
  }else if(kind==='loot'){
    c.rect(-4.5,-3,9,7);c.fill();c.stroke();c.moveTo(-2,-3);c.lineTo(-2,-5);c.lineTo(2,-5);c.lineTo(2,-3);c.stroke();
  }else if(kind==='target'||kind==='waypoint'){
    c.arc(0,0,3,0,6.2832);c.moveTo(-6,0);c.lineTo(-2,0);c.moveTo(2,0);c.lineTo(6,0);c.moveTo(0,-6);c.lineTo(0,-2);c.moveTo(0,2);c.lineTo(0,6);c.stroke();
  }else if(kind==='exit'){
    c.arc(0,0,5,0,6.2832);c.stroke();c.beginPath();c.moveTo(0,3);c.lineTo(0,-3);c.moveTo(-2,-1);c.lineTo(0,-3);c.lineTo(2,-1);c.stroke();
  }else if(kind==='partywaypoint'){
    c.arc(0,0,5,0,6.2832);c.stroke();c.beginPath();c.arc(0,0,1.5,0,6.2832);c.stroke();
  }else if(kind==='forge'){
    c.fillStyle='#efe9dc';c.fillRect(-5,-3,10,3);c.fillRect(-2,0,4,3);c.fillRect(-4,3,8,2);
  }
  c.restore();
}
function worldSideCue(x,y,st){
  if(!st||st.hero||seatMarkOf(st)>=0||!(st.team==='ally'||st.team==='foe'))return;
  if(st.own&&(st.own.hp<=0||st.own.dead))return;
  colourCueGlyph(wc,st.team,x-18,y-29,.85,TEAMCOL[st.team]);
}
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
  var result=drawOpBody(x,y,face,ph,coat,pk,muzzle,mode,iv,st);
  worldSideCue(x,y,st);
  return result;
}
function drawOpBody(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@

SubRx @'
var VER='34.03';
'@ @'
var VER='34.04';
'@

$pat = "(?m)^  now:'v34\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.04: Unnumbered allies carry a cream plus and hostile human pillagers a cream edged triangle. Numbered player badges stay clear. Check 34.04 fails on v34.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

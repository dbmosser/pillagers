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

# EACH PLAYER SEES THE OTHER PLAYER LINE OF SIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netUpDraw(DR){
'@ @'
// v18.07, HIS ORDER (2026-10-03): EACH PLAYER SEES THE OTHER PLAYER'S LINE OF SIGHT. What a teammate up top is looking at, you
// see too: his view cone is cut open in your fog of war (a little dimmer than your own), his patch of ground is lit, and an
// enemy standing in his sight is drawn for you as it is for him. Settings has a Shared sight row to turn it off. Only
// teammates shown up top in this raid count, and a downed one sees nothing for you.
function netMates(){ var out=[], i, g; if(!NET.on||!NET.up) return out; for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(netUpShown(g)&&!g.dn) out.push(g); } return out; }
function netMateSees(ev,evc){
  var M=netMates(), i, g, k=(evc===undefined)?1:evc;
  for(i=0;i<M.length;i++){ g=M[i]; if(k>=1?canSee(g.x,g.y,g.f,ev.x,ev.y,G.vseg):canSee(g.x,g.y,g.f,ev.x,ev.y,G.vseg,VF()*k,undefined,AMBR()*k)) return true; }
  return false;
}
function netMateFog(c){
  var M=netMates(), i, g, pol, vg, ag, j;
  for(i=0;i<M.length;i++){
    g=M[i]; pol=buildVisPoly(g.x,g.y,g.f,G.vseg); if(!pol||pol.length<3) continue;
    vg=c.createRadialGradient(g.x,g.y,VF()*.15,g.x,g.y,VF()); vg.addColorStop(0,'rgba(0,0,0,.80)'); vg.addColorStop(1,'rgba(0,0,0,0)');
    c.fillStyle=vg; c.beginPath(); c.moveTo(pol[0].x,pol[0].y); for(j=1;j<pol.length;j++) c.lineTo(pol[j].x,pol[j].y); c.closePath(); c.fill();
    ag=c.createRadialGradient(g.x,g.y,0,g.x,g.y,AMBR()); ag.addColorStop(0,'rgba(0,0,0,.70)'); ag.addColorStop(1,'rgba(0,0,0,0)');
    c.fillStyle=ag; c.beginPath(); c.arc(g.x,g.y,AMBR(),0,6.2832); c.fill();
  }
  return M.length;
}
function netMateLamp(c,r){
  var M=netMates(), i, g, pg;
  for(i=0;i<M.length;i++){ g=M[i]; pg=c.createRadialGradient(g.x,g.y,0,g.x,g.y,r); pg.addColorStop(0,'rgba(0,0,0,.40)'); pg.addColorStop(1,'rgba(0,0,0,0)'); c.fillStyle=pg; c.beginPath(); c.arc(g.x,g.y,r,0,6.2832); c.fill(); }
  return M.length;
}
function netUpDraw(DR){
'@

SubRx @'
    if(ev.seen) VIS.push(ev);
'@ @'
    if(!ev.seen&&CFG.sharedSight!==0&&NET.on&&typeof netMateSees==='function'){ try{ ev.seen=netMateSees(ev,evc); }catch(_ms){} }   // v18.07: his order, shared sight: what a teammate sees, you see
    if(ev.seen) VIS.push(ev);
'@

SubRx @'
  fx2.beginPath(); fx2.arc(psx,psy,AMBR(),0,6.2832); fx2.fill();
'@ @'
  fx2.beginPath(); fx2.arc(psx,psy,AMBR(),0,6.2832); fx2.fill();
  if(CFG.sharedSight!==0&&NET.on){ try{ netMateFog(fx2); }catch(_mf){} }   // v18.07: shared sight, the teammate's cone is open in your fog too
'@

SubRx @'
  lx2.beginPath(); lx2.arc(p.x,p.y,plr,0,6.2832); lx2.fill();
'@ @'
  lx2.beginPath(); lx2.arc(p.x,p.y,plr,0,6.2832); lx2.fill();
  if(CFG.sharedSight!==0&&NET.on){ try{ netMateLamp(lx2,plr); }catch(_ml){} }   // v18.07: shared sight, his ground is lit for you
'@

SubRx @'
  {k:'gfxScale', label:'Render resolution',
'@ @'
  {k:'sharedSight', label:'Shared sight',
   hint:'See what your teammate sees: their view cone is open in your fog of war and the enemies in it are shown. Off, you see only with your own eyes.',
   opts:[
     {n:'On',  cfg:{sharedSight:1}},
     {n:'Off', cfg:{sharedSight:0}}
   ], def:0},
  {k:'gfxScale', label:'Render resolution',
'@

SubRx @'
var VER='18.06';
'@ @'
var VER='18.07';
'@

$pat = "(?m)^  now:'v18\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.07: You now see what your teammate sees: their view cone is open in your fog and the enemies in it are shown (Settings: Shared sight). Check 18.07 fails on v18.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# YOUR TEAMMATES ON THE HUD (queue items 1 and 5, 2026-09-27).

SubRx @'
       hp:Math.round(p.hp||0),mh:Math.round(p.maxhp||100),ar:Math.round(p.armor||0),ac:Math.round(armorCap()||0)};   // v16.20: pz, this player is paused; v16.23: health and armour, for a teammate's bandage or plate
'@ @'
       hp:Math.round(p.hp||0),mh:Math.round(p.maxhp||100),ar:Math.round(p.armor||0),ac:Math.round(armorCap()||0),dt:p.downed?Math.max(0,Math.ceil(p.downT||0)):0};   // v16.20: pz, this player is paused; v16.23: health and armour, for a teammate's bandage or plate
'@

SubRx @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour
'@ @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour
'@

SubRx @'
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; out.pz=g.pz; out.hp=g.hp; out.mh=g.mh; out.ar=g.ar; out.ac=g.ac; }   // v15.79: passed on as it came
'@ @'
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; out.pz=g.pz; out.hp=g.hp; out.mh=g.mh; out.ar=g.ar; out.ac=g.ac; out.dt=g.dt; }   // v15.79: passed on as it came
'@

SubRx @'
  ctx.fillText('HP  '+Math.round(p.hp),24,by+18);
'@ @'
  ctx.fillText('HP  '+Math.round(p.hp),24,by+18);
  try{ if(NET.on) netTeamHud(by); }catch(_nth){}   // v16.26: your teammates, their health and armour, above your own
'@

SubRx @'
function netAllPaused(){
'@ @'
// v16.26, THE QUEUE (his order for the niceties of the genre): YOUR TEAMMATES ON THE HUD. Above your own health, bottom left, one
// row per teammate up top on the party seed: his name, a health bar and an armour bar from his state word (hp, mh, ar, ac), and
// when he is down a red DOWN with the seconds he has left to be picked up (dt). Drawing only.
function netTeamHud(by){
  var i, g, n=0, x=16, w=150, y, f, t;
  if(typeof G==='undefined'||!G||G.over) return 0;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)) continue;
    y=by-96-n*40; n++;
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(x-4,y-15,w+8,36);
    ctx.font=FS(TYPE.label); ctx.textAlign='left';
    ctx.fillStyle=g.dn?'#ff8a80':'#bfe0ff'; ctx.fillText(netSeatName(g.seat)||'PILLAGER',x,y);
    if(g.dn){ t=(g.dt>0)?(' '+g.dt+'s'):''; ctx.fillStyle='#ff5a4a'; ctx.textAlign='right'; ctx.fillText('DOWN'+t,x+w,y); ctx.textAlign='left'; }
    f=(g.mh>0)?clamp((g.hp||0)/g.mh,0,1):0;
    ctx.fillStyle='rgba(255,255,255,.12)'; ctx.fillRect(x,y+5,w,7);
    ctx.fillStyle=g.dn?'#8a2a22':(f<0.35?'#e2564a':'#6fe0a0'); ctx.fillRect(x,y+5,w*f,7);
    if(g.ac>0){ ctx.fillStyle='rgba(255,255,255,.10)'; ctx.fillRect(x,y+14,w,4); ctx.fillStyle='#6fb8ff'; ctx.fillRect(x,y+14,w*clamp((g.ar||0)/g.ac,0,1),4); }
  }
  return n;
}
function netAllPaused(){
'@

SubRx @'
var VER='16.25';
'@ @'
var VER='16.26';
'@

$pat = "(?m)^  now:'v16\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.26: YOUR TEAMMATES ON THE HUD. The queue. Above your own health, each teammate in the raid has a row: his name, a health bar and an armour bar, and when he is down a red DOWN with the seconds he has left to be picked up. Drawing only. No number moved. Check 16.26 fails on v16.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

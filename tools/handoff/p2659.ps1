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

# PILLAGERS HAVE ROLES YOU CAN READ (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feudFoe(a,b){
'@ @'
// v26.xx (ai21), HIS YES (2026-10-14, suggestion 21): PILLAGER ROLES, shown by COLOUR and SILHOUETTE, no words. "He also wants pillagers in
// more distinct colours": every pillager wore his identity coat, a muted shade of a dozen near neighbours, so a crew read as one grey crowd.
// Now a pillager has a ROLE, worked out from what he carries (no random number is drawn: the gun, the rig and a hash of his identity), and
// the role colours his coat (half the identity coat, half the role colour) and gives him one shape that changes his outline:
//   RUSH (red): shoulder spikes. Shotgun, and a third of the SMGs. He closes in to about 45 percent of his gun range and does not back off.
//   FLANK (green): a streaming scarf. Carbine, a third of the SMGs, half the rifles. He swings wide (the old rule).
//   SUPP (amber): a bandolier and an ammo box. The Support MG, and a third of the SMGs.
//   MARK (blue): a pointed hood. The Magnum, the Marksman, Longshot, Whisper and Lance guns, half the rifles. He holds his full range
//   and backs off sooner (50 percent), so he is the one to flank or to smoke.
//   SHIELD (violet): a plate on his arm. Anyone in a heavy rig.
// The medic of the suggestion (a mate who revives mates) is not part of this build. Hired men and friends keep their team look.
var PROLE={
  rush:{c:'#e6492d',apf:.45,rtf:.12,fr:.30},
  flank:{c:'#3dcf74',apf:.85,rtf:.30,fr:.55},
  supp:{c:'#f0b928',apf:.80,rtf:.30,fr:.60},
  mark:{c:'#3aa6ea',apf:1.0,rtf:.50,fr:.80},
  shield:{c:'#a566ea',apf:.60,rtf:.20,fr:.40}
};
function raiderHash(e){
  var s=String((e&&(e.ident||e.name))||''), h=2166136261>>>0, i;
  for(i=0;i<s.length;i++){ h^=s.charCodeAt(i); h=Math.imul(h,16777619)>>>0; }
  return h>>>0;
}
function raiderRole(e){
  var w, h;
  if(!e||e.kind!=='raider'||e.merc||e.friendlyPC||e.ghost) return null;
  if(e.prole&&PROLE[e.prole]) return e.prole;
  w=(e.wep&&e.wep.id)||''; h=raiderHash(e);
  if(e.rig==='heavy') return 'shield';
  if(w==='lmg') return 'supp';
  if(w==='dmr'||w==='sniper'||w==='whisper'||w==='lance'||w==='magnum') return 'mark';
  if(w==='shotgun') return 'rush';
  if(w==='carbine') return 'flank';
  if(w==='rifle') return (h%2)?'mark':'flank';
  return ['rush','flank','supp'][h%3];
}
function raiderApf(e){ var r=raiderRole(e); return r?PROLE[r].apf:.85; }
function raiderRtf(e){ var r=raiderRole(e); return r?PROLE[r].rtf:.30; }
function raiderFr(e){ var r=raiderRole(e); return r?PROLE[r].fr:.55; }
function raiderCoat(e){
  var r=raiderRole(e), c=e.coat, a, b, i, o='#';
  if(!r||typeof c!=='string'||!/^#[0-9a-fA-F]{6}$/.test(c)) return c;
  for(i=0;i<3;i++){
    a=parseInt(c.slice(1+i*2,3+i*2),16); b=parseInt(PROLE[r].c.slice(1+i*2,3+i*2),16);
    a=Math.round(a*0.45+b*0.55); o+=(a<16?'0':'')+a.toString(16);
  }
  return o;
}
function drawRoleMark(e){
  var r=raiderRole(e), c, x, y, fl, k, wv;
  if(!r||e.downed||e.hp<=0||e.state==='down'||e.roll>0) return;
  c=PROLE[r].c; x=e.x; y=e.y; fl=(Math.cos(e.face)<0)?-1:1;
  if(r==='rush'){
    for(k=-1;k<=1;k+=2){
      wc.fillStyle=INK; wc.beginPath(); wc.moveTo(x+k*11.5,y-24); wc.lineTo(x+k*8.5,y-34); wc.lineTo(x+k*4.5,y-24); wc.closePath(); wc.fill();
      wc.fillStyle=c; wc.beginPath(); wc.moveTo(x+k*10,y-25); wc.lineTo(x+k*8.4,y-31.5); wc.lineTo(x+k*6,y-25); wc.closePath(); wc.fill();
    }
  } else if(r==='flank'){
    wv=Math.sin(((typeof G!=='undefined'&&G)?G.t:0)*6+x*0.1)*2;
    wc.fillStyle=INK; wc.beginPath(); wc.moveTo(x-fl*2,y-29); wc.lineTo(x-fl*17,y-25+wv); wc.lineTo(x-fl*16,y-19+wv); wc.lineTo(x-fl*1,y-23); wc.closePath(); wc.fill();
    wc.fillStyle=c; wc.beginPath(); wc.moveTo(x-fl*2.5,y-28); wc.lineTo(x-fl*15,y-24.4+wv); wc.lineTo(x-fl*14.4,y-20.6+wv); wc.lineTo(x-fl*2,y-24.5); wc.closePath(); wc.fill();
  } else if(r==='supp'){
    wc.fillStyle=INK; wc.beginPath(); wc.moveTo(x-7.5,y-26); wc.lineTo(x-3.5,y-27); wc.lineTo(x+7.5,y-13); wc.lineTo(x+3.5,y-12); wc.closePath(); wc.fill();
    wc.fillStyle=c; wc.beginPath(); wc.moveTo(x-6.4,y-25.4); wc.lineTo(x-4,y-26); wc.lineTo(x+6.4,y-13.6); wc.lineTo(x+4,y-13); wc.closePath(); wc.fill();
    wc.fillStyle=INK; rrF(x+fl*7-4.4,y-18.4,8.8,8.8,1.4);
    wc.fillStyle=c; rrF(x+fl*7-3.2,y-17.2,6.4,6.4,1);
  } else if(r==='mark'){
    wc.fillStyle=INK; wc.beginPath(); wc.moveTo(x-7.5,y-29); wc.lineTo(x,y-46); wc.lineTo(x+7.5,y-29); wc.closePath(); wc.fill();
    wc.fillStyle=darkHex(c,.35); wc.beginPath(); wc.moveTo(x-6.2,y-30); wc.lineTo(x,y-43.5); wc.lineTo(x+6.2,y-30); wc.closePath(); wc.fill();
    wc.fillStyle=c; wc.fillRect(x-6.2,y-31.4,12.4,1.8);
  } else if(r==='shield'){
    wc.fillStyle=INK; rrF(x+fl*6-1,y-30.4,10,25,3);
    wc.fillStyle=c; rrF(x+fl*6,y-29.4,8,23,2);
    wc.fillStyle=litHex(c,.35); wc.fillRect(x+fl*6+1,y-28,2,20);
  }
}
function feudFoe(a,b){
'@

SubRx @'
        if((sees||!_cg)&&(d>e.rng*.85||(e.crewArc!==undefined&&sees&&dist(e,{x:fx3,y:fy3})>70))) navSeek(e,fx3,fy3,e.spd,dt);
'@ @'
        if((sees||!_cg)&&(d>e.rng*raiderApf(e)||(e.crewArc!==undefined&&sees&&dist(e,{x:fx3,y:fy3})>70))) navSeek(e,fx3,fy3,e.spd,dt);   // v26.xx (ai21): how close he closes depends on his role
'@

SubRx @'
        var fx3=p.x+Math.cos(fang)*e.rng*.55,fy3=p.y+Math.sin(fang)*e.rng*.55;
'@ @'
        var fx3=p.x+Math.cos(fang)*e.rng*raiderFr(e),fy3=p.y+Math.sin(fang)*e.rng*raiderFr(e);
'@

SubRx @'
        else if(d<e.rng*.30) moveToward(e,e.x-(p.x-e.x),e.y-(p.y-e.y),e.spd*.7,dt);
'@ @'
        else if(d<e.rng*raiderRtf(e)) moveToward(e,e.x-(p.x-e.x),e.y-(p.y-e.y),e.spd*.7,dt);
'@

SubRx @'
      else if(e2.kind==='raider'&&raiderGetUpBar(e2))
        drawOp(e2.x+raiderGetUpShake(e2),e2.y,e2.face,(e2.roll>0)?(1-e2.roll/.38)*12.6:(e2.step||0)*4,e2.coat,
'@ @'
      else if(e2.kind==='raider'&&raiderGetUpBar(e2))
        drawOp(e2.x+raiderGetUpShake(e2),e2.y,e2.face,(e2.roll>0)?(1-e2.roll/.38)*12.6:(e2.step||0)*4,raiderCoat(e2),
'@

SubRx @'
gloves:e2.gloves,pack:e2.pack,patch:e2.patch,tattoo:e2.tattoo,build:e2.build});
'@ @'
gloves:e2.gloves,pack:e2.pack,patch:e2.patch,tattoo:e2.tattoo,build:e2.build}),drawRoleMark(e2);   // v26.xx (ai21): his role mark on top of the body
'@

SubRx @'
var VER='26.58';
'@ @'
var VER='26.59';
'@

$pat = "(?m)^  now:'v26\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.59: Pillagers now read by role: red rushers close in, blue marksmen hold range, green flankers, amber suppressors, violet shield carriers. Check 26.59 fails on v26.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

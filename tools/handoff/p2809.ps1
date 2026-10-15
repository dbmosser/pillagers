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

# TWO PLAYERS NEVER LOOK ALIKE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var id, S, D;
  if(!st||typeof st!=='object') return null;
  if(st.hero){ if(outfitOf(st)||cosWorn('fit')==='jersey') return null; id=cosWorn('scheme'); }
  else { if(st.outfit&&st.outfit!=='outnone') return null; id=st.scheme; }
'@ @'
  var id, S, D, sh;
  if(!st||typeof st!=='object') return null;
  if(st.hero){ if(outfitOf(st)||cosWorn('fit')==='jersey') return null; id=cosWorn('scheme'); sh=seatHere(); if(sh>0) id=seatScheme(sh,id); }   // v28.09 (cosm2): in a party, two bodies never wear one scheme
  else { if(st.outfit&&st.outfit!=='outnone') return null; id=st.scheme; if(st.own&&typeof st.own.seat==='number'&&seatHere()>=0) id=seatScheme(st.own.seat|0,id||'schstd'); }
'@

SubRx @'
function outfitOf(st){
'@ @'
// v28.09 (cosm2), HIS ORDER (2026-10-15): "both players must look great and clearly different" (the party on 10/30, two players in the DEMO).
// THE SEAT. When two or more people are linked in a co-op or DEMO party, every human body carries its seat: a ring on the ground in the seat
// colour (P1 amber, P2 cyan, then lime and pink) with its number on a badge at the front, drawn the same in every window. And a body that
// picked the same scheme as a lower seat (two fresh profiles are both Standard Issue) is drawn in the next free preset, in both windows, the
// same way: seat 0 keeps its own look, seat 1 takes Frost if seat 0 wears the same, and so on. Nobody is asked: the look he picked is kept
// in his own profile and on the other windows when he picked a different scheme. A PvP match has its own red and blue and gets none of this.
var SEATCOL=['#ffb02e','#38d6ff','#a6e83a','#ff5fc8'], SEATPAL=['schfrost','schember','schverdant','schnight','schcrimson','schroyal'];
function seatHere(){
  try{ if(typeof NET==='object'&&NET&&NET.on&&NET.mode!=='pvp'&&NET.seat>=0&&netInCount()>0) return NET.seat|0; }catch(_sh){}
  return -1;
}
// The scheme the body at seat s has picked, as this window has it: its own, or what that seat said in its look.
function seatRaw(s){
  var g, lk;
  if(s===(NET.seat|0)) return cosWorn('scheme');
  g=(NET.up&&NET.up[s])||(NET.floor&&NET.floor[s]); lk=g&&g.lk;
  if(!lk) return '';
  if(lk.scheme) return lk.scheme;
  return (lk.fit&&lk.fit!=='slate'&&SCHEMES['sch'+lk.fit])?('sch'+lk.fit):'schstd';
}
function seatScheme(seat,id){
  var used=[], s, i, p;
  for(s=0;s<seat&&s<4;s++){ p=seatRaw(s); if(p&&used.indexOf(p)>=0){ for(i=0;i<SEATPAL.length;i++) if(used.indexOf(SEATPAL[i])<0&&seatRaw(s)!==SEATPAL[i]){ p=SEATPAL[i]; break; } } if(p) used.push(p); }
  if(!id||used.indexOf(id)<0) return id;
  for(i=0;i<SEATPAL.length;i++) if(used.indexOf(SEATPAL[i])<0) return SEATPAL[i];
  return id;
}
function seatMarkOf(st){
  var sh;
  if(!st||typeof st!=='object') return -1;
  sh=seatHere(); if(sh<0) return -1;
  if(st.hero) return sh;
  return (st.own&&typeof st.own.seat==='number'&&st.own.seat>=0)?(st.own.seat|0):-1;
}
function drawSeatRing(x,y,s){
  var c=SEATCOL[s&3];
  wc.save();
  wc.beginPath(); wc.ellipse(x,y+1,13.6,5.6,0,0,6.2832);
  wc.globalAlpha=0.14; wc.fillStyle=c; wc.fill();
  wc.globalAlpha=0.85; wc.strokeStyle=INK; wc.lineWidth=3.6; wc.stroke();
  wc.globalAlpha=1; wc.strokeStyle=c; wc.lineWidth=1.7; wc.stroke();
  wc.restore();
  // the number, on a badge at the front of the ring (clear of the name plate over the head and of any hat)
  wc.fillStyle=INK; wc.beginPath(); wc.arc(x,y+8.4,4.7,0,6.2832); wc.fill();
  wc.fillStyle=c; wc.beginPath(); wc.arc(x,y+8.4,3.7,0,6.2832); wc.fill();
  wc.fillStyle='#10151b'; wc.font='700 6.6px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif'; wc.textAlign='center';
  wc.fillText(String((s&3)+1),x,y+10.6); wc.textAlign='left';
}
function outfitOf(st){
'@

SubRx @'
  shadowE(x,y+1,10,4,.38);
'@ @'
  shadowE(x,y+1,10,4,.38);
  var _SEAT=seatMarkOf(st);   // v28.09 (cosm2): -1 when no party is on, else this body seat
  if(_SEAT>=0) drawSeatRing(x,y,_SEAT);
'@

SubRx @'
var VER='28.08';
'@ @'
var VER='28.09';
'@

$pat = "(?m)^  now:'v28\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.09: In a two-player game each player now has a coloured ring and a number, and two matching looks are told apart. Check 28.09 fails on v28.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

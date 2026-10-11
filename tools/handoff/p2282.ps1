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

# THE LOCATION TAG (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// about, walking, are the ZONES: "Crossing into the sump."
'@ @'
// about, walking, are the ZONES: their names show as you cross into them (THE SUMP, the location tag since the raid text R34).
'@

SubRx @'
function msgPx(f){ var m=(/([\d.]+)px/).exec(f); return m?parseFloat(m[1]):LH(12); }
'@ @'
function msgPx(f){ var m=(/([\d.]+)px/).exec(f); return m?parseFloat(m[1]):LH(12); }
// v22.xx, the raid text rewrite (R34): THE LOCATION TAG. HIS ORDER (2026-10-09): the raid text reads like Call of Duty, Fortnite or
// ARC Raiders, and in those the place you walk into is its name shown for a moment, never a sentence. Walking into a zone or a
// landmark said Crossing into the receiving apron. or Entering the manifest. as a message row, his authored caps names lowercased,
// one more line in the feed every few steps. Now the authored name shows in caps (RECEIVING APRON, THE MANIFEST) in the alert slot
// when it is free: dim, letter spaced, outlined, no plate, for 2.5 s, at most once per name every 20 s. It is dropped, never
// queued, while an alert holds or a hostile chases within 700, because then the place is the last thing worth reading. G.loc is
// the tag showing {m,T,at}; G.locSeen the time each name last showed. Cosmetic only: nothing here runs while G.sim is set, draws a
// random number or changes game state.
var LOCLIFE=2.5, LOCAGAIN=20;
function locBusy(){
  var p=G&&G.player, i, e;
  if(!p||!G.ents) return false;
  for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(e&&e.state==='chase'&&!(e.hp<=0)&&Math.hypot(e.x-p.x,e.y-p.y)<700) return true; }
  return false;
}
function locSay(n){
  if(!G||G.sim||!n) return false;
  var m=String(n).toUpperCase(), now=G.t||0, seen=(G.locSeen=G.locSeen||{});
  if(alertUp()||locBusy()) return false;   // dropped, never queued
  if(seen.hasOwnProperty(m)&&now-seen[m]<LOCAGAIN) return false;
  seen[m]=now; G.loc={m:m,T:LOCLIFE,at:now};
  return true;
}
function locTick(dt){ var l=G&&G.loc; if(l&&l.T>0){ l.T-=dt; if(!(l.T>0)) G.loc=null; } }
function locUp(){ var l=G&&G.loc; return (l&&l.T>0&&l.m&&!alertUp())?l:null; }
function locH(){ return LH(10)+Math.round(msgPx(FS(TYPE.head))*1.1); }
function locDraw(l){   // inside the message scale, in the alert slot
  var now=G.t||0, al=Math.max(0,Math.min(1,(now-l.at)/0.2,l.T/0.5)), hf=FS(TYPE.head), hp=msgPx(hf), oa=ctx.globalAlpha;
  if(!(al>0)) return;
  ctx.save();
  try{
    ctx.globalAlpha=oa*al; ctx.font=hf; ctx.textAlign='center'; ctx.textBaseline='alphabetic'; ctx.fillStyle=HUDC.dim;
    if('letterSpacing' in ctx) ctx.letterSpacing=Math.round(hp*0.2)+'px';
    hudText(l.m,W/2,LH(96)+LH(5)+Math.round(hp*0.82),2);
  } finally { ctx.restore(); }
}
'@

SubRx @'
  alertTick(dt);   // the alert lane and its queue (R08)
'@ @'
  alertTick(dt);   // the alert lane and its queue (R08)
  locTick(dt);   // v22.xx (R34): the location tag
'@

SubRx @'
  if(al){ ALERTL=al; HUDALERTB=Math.round((LH(96)+al.h)*z); HUDFEEDT=LH(96)+al.h+LH(4); }
'@ @'
  if(al){ ALERTL=al; HUDALERTB=Math.round((LH(96)+al.h)*z); HUDFEEDT=LH(96)+al.h+LH(4); }
  else if(locUp()) HUDFEEDT=LH(96)+locH()+LH(4);   // v22.xx (R34): the location tag holds the slot, so the feed starts under it
'@

SubRx @'
  var _frows=feedRows(), _alL=ALERTL;   // v21.86 (R04): the rows msgLayout laid out; v22.13 (R08): and the alert over them
  if(_frows.length||_alL){
'@ @'
  var _frows=feedRows(), _alL=ALERTL, _loc=_alL?null:locUp();   // v21.86 (R04): the rows msgLayout laid out; v22.13 (R08): and the alert over them; v22.xx (R34): or the location tag
  if(_frows.length||_alL||_loc){
'@

SubRx @'
    if(_alL&&G){ try{ alertDraw(_alL); }catch(_ad){} }   // v22.13 (R08): the alert lane, at the top of the band
'@ @'
    if(_alL&&G){ try{ alertDraw(_alL); }catch(_ad){} }   // v22.13 (R08): the alert lane, at the top of the band
    else if(_loc&&G){ try{ locDraw(_loc); }catch(_ld){} }   // v22.xx (R34): the location tag in the free alert slot
'@

SubRx @'
        if(lmNow) say('Entering the '+placeName(lmNow.name)+'.');
'@ @'
        if(lmNow) locSay(lmNow.name);   // v22.xx (R34): the location tag, not a sentence
'@

SubRx @'
          if(!lmNow&&!G.zoneCd){ say('Crossing into the '+placeName(zNow.name)+'.'); G.zoneCd=6; }
'@ @'
          if(!lmNow&&!G.zoneCd){ if(locSay(zNow.name)) G.zoneCd=6; }   // v22.xx (R34): the location tag, not a sentence
'@

SubRx @'
            say('Crossing into the '+placeName(zn2||DISTRICTS[dzNow].name)+'.'); G.zoneCd=6;
'@ @'
            if(locSay(zn2||DISTRICTS[dzNow].name)) G.zoneCd=6;   // v22.xx (R34): the location tag, not a sentence
'@

SubRx @'
var VER='22.81';
'@ @'
var VER='22.82';
'@

$pat = "(?m)^  now:'v22\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.82: Walking into a new zone shows its name in caps at the top of the screen instead of a Crossing into sentence. Check 22.82 fails on v22.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

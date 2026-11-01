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

# DEAD CODE OUT 3 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// And what it just cost him, in one clause, for the banner.
function notoBite(n){
  n=n||0;
  // v11.68: the stall never shuts (pedOpen, his v8.28 ruling); this said it did.
  if(n>=2) return 'Word has spread. Hires cost more and pillagers trust you less.';
  return 'Hires cost more and pillagers trust you less.';
}

'@ @'
// v28.xx (cw-dead3): dead code out, no caller anywhere (audit 2026-10-28): notoBite, mapFirstFoot, autoCull, needGlow, netSndToggle, netP2Key, legDock, pixSwap.

'@

SubRx @'
function mapFirstFoot(){ var z=(typeof hudRes==='function')?hudRes():1; return Math.max(70,Math.round((LH(43)+18)*z)); }

'@ @'

'@

SubRx @'
// Shed the least useful things until there is room to search again. Returns how
// many went. Refuses rather than gutting a bag of nothing but rares.
function autoCull(cap){
  var shed=0;
  while(bagWeight()>=cap){
    var w=worstBagIndex();
    if(w<0) break;
    var key=dropItem(w);
    if(!key) break;
    // Audit: the shed crate landed inside pickup range, stole the search
    // target, and the loop re-ate its own discard forever. Auto-shed crates
    // are ignored by the chooser for 8 seconds and never fire contracts.
    var shedCt=G.containers[G.containers.length-1];
    if(shedCt&&shedCt.dropped){ shedCt.auto=1; shedCt.dropT=G.t; }
    shed++;
    if(!G.sim) label(G.player.x,G.player.y-26,'Dropped '+ITEMS[key].name,'#9aa8d0',0,false);
    // Loop guard only. The real stop is running out of things worth dropping;
    // this is set beyond any bag a raid can actually produce, because at 12 it
    // was firing first and leaving the pack still over capacity.
    if(shed>80) break;
  }
  return shed;
}

'@ @'

'@

SubRx @'
function needGlow(wc,ct,lift,d2){
  var cx=ct.x, cy=ct.y-lift-d2-3, pu=.55+.45*Math.sin((+G.t||0)*4.2+ct.x*.03);
  wc.save();
  wc.globalCompositeOperation='lighter';
  wc.globalAlpha=.24*pu; wc.fillStyle='#ffd452'; wc.beginPath(); wc.arc(cx,cy,27,0,6.2832); wc.fill();
  wc.globalAlpha=Math.min(1,.8*pu+.2); wc.strokeStyle='#ffd452'; wc.lineWidth=2.4; wc.beginPath(); wc.arc(cx,cy,17,0,6.2832); wc.stroke();
  wc.globalAlpha=.95; wc.fillStyle='#fff0b0';
  wc.beginPath(); wc.moveTo(cx,cy-32); wc.lineTo(cx+5,cy-26); wc.lineTo(cx,cy-20); wc.lineTo(cx-5,cy-26); wc.closePath(); wc.fill();
  wc.restore();
}

'@ @'

'@

SubRx @'
function netSndToggle(){ return netSndSet(!NET.sndOn); }

'@ @'

'@

SubRx @'
function netP2Key(){ return 'salvagerun:profile:p2'; }

'@ @'

'@

SubRx @'
function legDock(s){
  var rs=Math.max(1,hudRes()), u=hudUserZ('legend'), x, z=LEGZ0, w, b, q, k, A, on=0, v=VITBOX, fr, mr;
  if(!s) return null;
  fr=(FEEDBOX.on&&FEEDBOX.w>0)?FEEDBOX.x+FEEDBOX.w+Math.round(LH(10)*rs):0; mr=(MEDALBOX.on&&MEDALBOX.w>0)?MEDALBOX.x+MEDALBOX.w+Math.round(LH(10)*rs):0;
  x=Math.max(s.x,fr,mr);
  if(LEGMW>0) z=Math.max(0.9,Math.min(LEGZ0,((W*0.47-x)/LEGMW)/(rs*u)));
  w=LEGMW*z*rs*u;
  if(LEGMW>0&&x+w>W*0.47) x=Math.max(fr,mr,Math.round(LH(6)*rs),Math.floor(W*0.47-w));   // a short screen: back left toward the old place, so it ends before 47 percent (or as far left as the feed and the medal spot let it: its rows stay 16 px)
  b=Math.min(s.y+s.h,Math.round(s.belt-LH(6)*rs));
  if(BELTCAP&&x<BELTCAP.x+BELTCAP.w&&x+w>BELTCAP.x) b=Math.min(b,Math.round(BELTCAP.y-LH(6)*rs));
  q=useBandBox(); if(q&&x<q.x+q.w&&x+w>q.x-LH(6)*rs) b=Math.min(b,Math.round(q.y-LH(6)*rs));
  A=(G&&G.pwr&&G.pwr.act)?G.pwr.act:null; if(A) for(k in A) if(Object.prototype.hasOwnProperty.call(A,k)&&A[k]>0) on=1;
  q=EDGEBOX.chips; if(on&&q&&q.w>0&&x<q.x+q.w&&x+w>q.x) b=Math.min(b,Math.round(q.y-LH(6)*rs));   // the power up timer chips (only while one runs, so a row left from another raid never counts)
  if(v&&v.w>0&&x<v.x+v.w+LH(2)*rs) b=Math.min(b,Math.round(v.top-LH(6)*rs));   // over the vitals columns: on top of them
  return {x:x,z:z,w:w,b:b};
}

'@ @'

'@

SubRx @'
function pixSwap(src,map){   // palette swap at bake time: map is {'#rrggbb':'#rrggbb'}; every other pixel is kept
  var s=pixCanvas(src.width,src.height), d, p, k, key, to={}, a;
  for(a in map){ if(Object.prototype.hasOwnProperty.call(map,a)){ k=parseInt(a.slice(1),16); to[(k>>16)+','+((k>>8)&255)+','+(k&255)]=parseInt(map[a].slice(1),16); } }
  s.x.drawImage(src,0,0); d=s.x.getImageData(0,0,s.w,s.h); p=d.data;
  for(k=0;k<p.length;k+=4){
    if(!p[k+3]) continue;
    key=p[k]+','+p[k+1]+','+p[k+2];
    if(to[key]!==undefined){ a=to[key]; p[k]=a>>16; p[k+1]=(a>>8)&255; p[k+2]=a&255; }
  }
  s.x.putImageData(d,0,0); return s.c;
}

'@ @'

'@

SubRx @'
var VER='37.05';
'@ @'
var VER='37.06';
'@

$pat = "(?m)^  now:'v37\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.06: Nothing a player can see changes. Check 37.06 fails on v37.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

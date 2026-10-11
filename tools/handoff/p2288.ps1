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

# THE MAP STORY ON A LORE CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function msgTick(dt){
'@ @'
// v22.xx, the raid text rewrite (R39): THE MAP STORY ON A LORE CARD. HIS ORDER (2026-10-09): the raid text reads like Call of Duty,
// Fortnite or ARC Raiders, and in those a found document opens as a card you can read, never as a 250 character message row. The
// map story (THE MANIFEST clipboard, THE GATE PASS printer) was said as one message line of its name and its whole text, which the
// message row cut at two lines with a truncation mark, so most of it was never read, and it was decided in the draw path. Whether
// it has been read is now decided here, in the update (loreTick, from msgTick), and G.storyRead and the run report storyRead are
// still set once. The text shows on a HUD panel card (drawLore): left of centre above the tactical belt, its name as a caps amber
// title and its body wrapped no wider than 30 percent of the screen, for 14 s or until he is 300 away. It is hidden under any alert
// or the use bar, and while the backpack or the map is open. It never goes into the feed. Cosmetic only: no random draw, no state
// beyond the read flags it always set.
var LORELIFE=14, LOREFAR=300;
function loreTick(dt){
  if(!G||G.sim||!G.map||!G.player) return;
  var st=G.map.story, p=G.player, L=G.lore;
  if(st&&!G.storyRead&&Math.hypot(p.x-st.x,p.y-st.y)<60){
    G.storyRead=1; if(G.tel) G.tel.storyRead=1;
    G.lore=L={name:String(st.name||'').toUpperCase(),text:String(st.text||''),x:st.x,y:st.y,T:LORELIFE,at:G.t||0};
  }
  if(L){ L.T-=dt; if(!(L.T>0)||Math.hypot(p.x-L.x,p.y-L.y)>LOREFAR) G.lore=null; }
}
function drawLore(){
  var L=G&&G.lore, p=G&&G.player, rs, w, pad, fT, fB, pB, pT, lh, th, lines=[], words, cur, i, tr, x, y, h, top, al, now;
  if(!L||!p||G.over||G.bagOpen||G.mapOpen||alertUp()||p.prep||p.prepA) return 0;
  now=G.t||0; al=Math.max(0,Math.min(1,(now-L.at)/0.3,L.T/0.6));
  if(!(al>0)) return 0;
  rs=Math.max(1,hudRes());
  pad=Math.round(LH(10)*rs); fT=hudFS(TYPE.head); fB=hudFS(TYPE.label); pT=msgPx(fT); pB=msgPx(fB);
  lh=Math.round(pB*1.35); th=Math.round(pT*1.3);
  w=Math.round(Math.min(W*0.30,LH(420)*rs));
  ctx.save();
  try{
    ctx.font=fB;
    words=TX(L.text).split(' '); cur='';   // his wording of the whole text is what is wrapped, as the CONDITIONS wrap does
    for(i=0;i<words.length;i++){ tr=cur?cur+' '+words[i]:words[i]; if(cur&&txRawW(ctx,tr)>w-pad*2){ lines.push(cur); cur=words[i]; } else cur=tr; }
    if(cur) lines.push(cur);
    h=pad*2+th+lines.length*lh;
    top=H*0.82; if(G.hotCells&&G.hotCells.length){ for(i=0;i<G.hotCells.length;i++) if(G.hotCells[i].y>H*0.4) top=Math.min(top,G.hotCells[i].y); }
    y=Math.max(LH(8),Math.round(top-LH(14)*rs-h)); x=Math.max(LH(8),Math.round(W/2-LH(16)*rs-w));
    ctx.globalAlpha=al;
    hudPanel(x,y,w,h,0.84);
    ctx.textAlign='left'; ctx.textBaseline='alphabetic';
    ctx.font=fT; ctx.fillStyle=HUDC.warn; ctx.fillText(L.name,x+pad,y+pad+Math.round(pT*0.9));
    ctx.font=fB; ctx.fillStyle=HUDC.text;
    for(i=0;i<lines.length;i++) ctx.fillText(lines[i],x+pad,y+pad+th+Math.round(pB*0.95)+i*lh);
  } finally { ctx.restore(); }
  return lines.length;
}
function msgTick(dt){
'@

SubRx @'
  locTick(dt);   // v22.xx (R34): the location tag
'@ @'
  locTick(dt);   // v22.xx (R34): the location tag
  loreTick(dt);   // v22.xx (R39): the map story card
'@

SubRx @'
  try{ drawUseBar(); }catch(_ub){}   // v18.75, his note: the bandage, medkit and plate wind-ups on the HUD
'@ @'
  try{ drawUseBar(); }catch(_ub){}   // v18.75, his note: the bandage, medkit and plate wind-ups on the HUD
  try{ drawLore(); }catch(_lr){}   // v22.xx (R39): the map story card
'@

SubRx @'
    if(!G.sim&&!G.storyRead&&G.player&&dist(G.player,_st2)<60){
      G.storyRead=1; G.tel.storyRead=1;
      say(_st2.name+'. '+_st2.text);
    }
'@ @'
    // v22.xx (R39): whether the story is read is decided in the update (loreTick), and it shows on the lore card (drawLore)
'@

SubRx @'
var VER='22.87';
'@ @'
var VER='22.88';
'@

$pat = "(?m)^  now:'v22\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.88: The story you find on each map now opens as a readable card instead of a cut-off message line. Check 22.88 fails on v22.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

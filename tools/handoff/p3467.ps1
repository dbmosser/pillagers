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

# THE EASY MODE AND INITIALS CARDS ARE SOLID DIALOGS AND PRESS A NAMES THE LOST PAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function easyHud(){
  var n=ARCADE.easyAsk, cx, y, bw, bh, left;
  if(!easyLive()||!ctx) return;
  left=EASY_MS-(Date.now()-(+n.at||0));
  if(left<=0){ easyAnswer(false); return; }
  cx=Math.round(W/2); y=Math.round(H*0.30); bw=LH(440); bh=LH(96);
  ctx.save(); ctx.textAlign='center'; ctx.textBaseline='alphabetic';
  ctx.fillStyle='rgba(6,9,13,.86)'; ctx.fillRect(cx-bw/2,y-LH(40),bw,bh);
  ctx.strokeStyle='rgba(127,227,212,.75)'; ctx.lineWidth=2; ctx.strokeRect(cx-bw/2+1,y-LH(40)+1,bw-2,bh-2);
  ctx.font=FS(TYPE.head); ctx.fillStyle='#7fe3d4'; hudText('Want easy mode?',cx,y-LH(12));
  ctx.font=FS(TYPE.micro); ctx.fillStyle='rgba(242,230,200,.88)';
  hudText((padOn()?padB('A yes  \u00b7  B no'):'Y yes  \u00b7  N no')+'  \u00b7  '+Math.ceil(left/1000),cx,y+LH(18));   // v30.xx (cw-glyphs2), HIS ORDER (2026-10-18): "player should get key prompts if that is the last input they used -- xbox controller prompts should only pop up if player is actively using the controller -- e.g. real time glyph switching". The card named both devices (Y or A, N or B); it names the one in use
  ctx.restore();
}
function arcadeIniHud(){
  var n=ARCADE.ini, cx, y, bw, bh, i, gx, lx, left;
  if(!arcadeIniRaid()||!ctx) return;
  cx=Math.round(W/2); y=Math.round(H*0.56); bw=LH(500); bh=LH(156); gx=LH(56);
  left=Math.max(0,Math.ceil((ARCADE_BOARD.iniMs-(Date.now()-(+n.at||0)))/1000));
  ctx.save(); ctx.textAlign='center'; ctx.textBaseline='alphabetic';
  ctx.fillStyle='rgba(6,9,13,.86)'; ctx.fillRect(cx-bw/2,y-LH(46),bw,bh);
  ctx.strokeStyle='rgba(127,227,212,.75)'; ctx.lineWidth=2; ctx.strokeRect(cx-bw/2+1,y-LH(46)+1,bw-2,bh-2);
  ctx.font=FS(TYPE.head); ctx.fillStyle='#7fe3d4'; hudText("tonight's best \u00b7 enter initials",cx,y-LH(18));   // v28.xx (cw-cx-easymapwords): name the board without choosing a row count
  for(i=0;i<3;i++){
    lx=Math.round(cx+(i-1)*gx);
    ctx.font=FSz(TYPE.huge,1.3); ctx.fillStyle=(i===n.pos)?'#ffc04a':'#f2e6c8'; hudText(n.l[i]||'A',lx,y+LH(36));
    ctx.fillRect(lx-LH(19),y+LH(44),LH(38),(i===n.pos)?3:2);
  }
  ctx.font=FS(TYPE.micro); ctx.fillStyle='rgba(242,230,200,.82)';
  hudText(iniHint()+'  \u00b7  '+left,cx,y+LH(80));   // v30.xx (cw-glyphs2): the hint of the device last used
  ctx.restore();
}

'@ @'
// v34.67 (cw-demorcards), the critic on 96-easy-after-map and 96-initials-in-raid (2 each): "a small, low-contrast teal-outlined box, the box is transparent enough that the map shows through it", "sits on top of the controls legend with no scrim, its hint line collides with the legend text". Both in-raid cards are now the guide's DIALOG: a solid Panel P fill (#16191b, no alpha), a 1px line-hi border, a 2px lime tab, the question as the title, the same words and clocks as before. They sit at 24 percent of the height so neither can reach the controls legend (its top is near 65 percent). Rendering only.
function dlgCard(kind){
  var w=LH(kind==='ini'?520:480), h=LH(kind==='ini'?190:164);
  return {x:Math.round(W/2-w/2), y:Math.round(H*0.24), w:w, h:h, pad:LH(24), fill:'#16191b', line:'#4a5257'};
}
function dlgRight(r,s){ ctx.textAlign='right'; ctx.font=FS(TYPE.head); ctx.fillStyle='#9aa3a8'; hudText(s,r.x+r.w-r.pad,r.y+r.pad+LH(20)); }
function dlgDraw(r,title){
  ctx.fillStyle=r.fill; ctx.fillRect(r.x,r.y,r.w,r.h);
  ctx.strokeStyle=r.line; ctx.lineWidth=1; ctx.strokeRect(r.x+.5,r.y+.5,r.w-1,r.h-1);
  ctx.fillStyle='#e6ff3d'; ctx.fillRect(r.x,r.y,LH(36),2);
  ctx.textBaseline='alphabetic'; ctx.textAlign='left'; ctx.font=FS(TYPE.title); ctx.fillStyle='#f2e6c8';
  hudText(title,r.x+r.pad,r.y+r.pad+LH(20));
}
function easyHud(){
  var n=ARCADE.easyAsk, r, bw, bh, by, gap, bx, left;
  if(!easyLive()||!ctx) return;
  left=EASY_MS-(Date.now()-(+n.at||0));
  if(left<=0){ easyAnswer(false); return; }
  r=dlgCard('easy'); bh=LH(52); gap=LH(16); bw=Math.round((r.w-2*r.pad-gap)/2); by=r.y+r.h-r.pad-bh; bx=r.x+r.pad;
  ctx.save();
  dlgDraw(r,'want easy mode?');
  ctx.textAlign='center'; ctx.textBaseline='middle'; ctx.font=FS(TYPE.head);
  ctx.fillStyle='#e6ff3d'; ctx.fillRect(bx,by,bw,bh);
  ctx.fillStyle='#11150a'; hudText((padOn()?padB('A')+'  yes':'y  yes').toLowerCase(),bx+bw/2,by+bh/2,0.01);   // v30.xx (cw-glyphs2), HIS ORDER (2026-10-18): the prompt names the device last used; the yes is the primary button, the no a ghost
  bx+=bw+gap;
  ctx.strokeStyle='#4a5257'; ctx.lineWidth=1; ctx.strokeRect(bx+.5,by+.5,bw-1,bh-1);
  ctx.fillStyle='#f2e6c8'; hudText((padOn()?padB('B')+'  no':'n  no').toLowerCase(),bx+bw/2,by+bh/2);
  dlgRight(r,String(Math.ceil(left/1000)));
  ctx.restore();
}
function arcadeIniHud(){
  var n=ARCADE.ini, r, i, lx, left, hint;
  if(!arcadeIniRaid()||!ctx) return;
  r=dlgCard('ini');
  left=Math.max(0,Math.ceil((ARCADE_BOARD.iniMs-(Date.now()-(+n.at||0)))/1000));
  ctx.save();
  dlgDraw(r,"tonight's best \u00b7 enter initials");   // v28.xx (cw-cx-easymapwords): name the board without choosing a row count
  ctx.textAlign='center'; ctx.textBaseline='alphabetic';
  for(i=0;i<3;i++){
    lx=Math.round(r.x+r.w/2+(i-1)*LH(64));
    ctx.font=FSz(TYPE.huge,1.3); ctx.fillStyle=(i===n.pos)?'#e6ff3d':'#f2e6c8'; hudText(n.l[i]||'A',lx,r.y+LH(112));
    ctx.fillRect(lx-LH(19),r.y+LH(122),LH(38),(i===n.pos)?3:2);
  }
  hint=iniHint().toLowerCase();   // v30.xx (cw-glyphs2): the hint of the device last used
  ctx.font=FS(TYPE.label); if(ctx.measureText(hint).width>r.w-2*r.pad) ctx.font=FS(TYPE.micro);
  ctx.fillStyle='#9aa3a8'; hudText(hint,r.x+r.w/2,r.y+r.h-LH(18));
  dlgRight(r,String(left));
  ctx.restore();
}

'@

SubRx @'
function padLostUi(on,ready){
'@ @'
// v34.67 (cw-demorcards), the critic on j8-p1-press-a and j8-p2-press-a (2 each): "the screen's real job, press a after a pad was lost, is a small title above a pause menu, so the player can't tell what happened". The title names the lost pad (p1 or p2, in that player's colour) and the same words as before; a career window with no pair keeps the bare words.
function padLostWords(ready,same){
  return ((same==='p1'||same==='p2')?same+' ':'')+(ready?'press a':'pad lost');
}
function padLostTitle(h,ready){
  var same=(typeof NET==='object'&&NET&&NET.same)?(NET.same==='p2'?'p2':'p1'):'', box=document.getElementById('pausebox');
  h.textContent=padLostWords(ready,same);
  if(box){ if(same) box.setAttribute('data-who',same); else box.removeAttribute('data-who'); }
}
function padLostUi(on,ready){
'@

SubRx @'
if(h) h.textContent='pad lost';
'@ @'
if(h) padLostTitle(h,false);
'@

SubRx @'
if(h) h.textContent=ready?'press a':'pad lost';
'@ @'
if(h) padLostTitle(h,ready);
'@

SubRx @'
#root #pausebox.padlost{ background:var(--ui-void) !important; }
'@ @'
#root #pausebox.padlost{ background:var(--ui-void) !important; }
/* v34.67 (cw-demorcards): the lost pad's title is in its player's colour (p1 amber, p2 cyan, as the pad tag), the same two colours the pad tag uses */
#root #pausebox.padlost[data-who="p1"] h3{ color:#f5b73b; }
#root #pausebox.padlost[data-who="p2"] h3{ color:#5fd7e8; }
'@

SubRx @'
var VER='34.66';
'@ @'
var VER='34.67';
'@

$pat = "(?m)^  now:'v34\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.67: The easy mode and initials cards are solid dialog cards that stay clear of the controls list, and the lost pad screen names which pillager lost their pad. Check 34.67 fails on v34.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

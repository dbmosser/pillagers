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

# THE RAID BACKPACK IS A COMPACT PANEL WITH READABLE TEXT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var BZ=hudRes(), bFS=function(s){ var f=FS(s);
'@ @'
  // v28.xx (cw-bagpolish), the critic scored the raid backpack 2 of 5 (2026-10-18, again 2026-10-20: "a wide, mostly empty dark slab with tiny, low contrast text and three lonely item slots ... looks like a debug panel"; the guide floor for read text is 16 px and tx-2 #aaa498). Look and layout only: the grid is 8 tiles wide (54 unit tiles, 8 unit gaps, units follow the text size) so the panel hugs its items instead of spanning 60 percent of the screen, every line of text is the label size (micro now draws as label) in tx-1 or tx-2, the title is the screen title size in tx-1, the selected tile and its ring are lime (the one accent), the lime tab is gone, and the key hints wrap onto a second line instead of running off. What the backpack holds and how items move are untouched.
  var BZ=hudRes(), bFS=function(s){ var f=FS(s===TYPE.micro?TYPE.label:s);
'@

SubRx @'
  var TILE=LH(58)*BZ,GAP=LH(7)*BZ,MARG=LH(30)*BZ;
'@ @'
  var TILE=LH(54)*BZ,GAP=LH(8)*BZ,MARG=LH(24)*BZ;
'@

SubRx @'
(W*0.66-MARG*2+GAP)/(TILE+GAP)),5,12); G.bagCols=COLS;
'@ @'
(W*0.66-MARG*2+GAP)/(TILE+GAP)),6,8); G.bagCols=COLS;
'@

SubRx @'
Math.floor((H-LH(300)*BZ)/(TILE+GAP)));
'@ @'
Math.floor((H-LH(560)*BZ)/(TILE+GAP)));
'@

SubRx @'
  var hh=LH(150)*BZ+rows*(TILE+GAP)+LH(64)*BZ;
'@ @'
  var _dn=stacks.length?Math.min(6,itemRows(stacks[clamp(G.bagSel||0,0,stacks.length-1)].key).length):0;   // v28.xx (cw-bagpolish): the footer is as tall as the selected item's rows
  var hh=LH(262)*BZ+rows*(TILE+GAP)+_dn*LH(18)*BZ;
'@

SubRx @'
G===hubBagG)?1:0.96);
'@ @'
G===hubBagG)?1:0.96,1);
'@

SubRx @'
  var cy=y+LH(19)*BZ;
  ctx.font=bFS(TYPE.head); ctx.fillStyle='#ffc04a';
'@ @'
  var cy=y+LH(30)*BZ;
  ctx.font=bFS(TYPE.title); ctx.fillStyle='#efe9dc';
'@

SubRx @'
ctx.font=bFS(TYPE.micro); ctx.fillStyle='#6b7783'; ctx.textAlign='right';
'@ @'
ctx.font=bFS(TYPE.micro); ctx.fillStyle='#aaa498'; ctx.textAlign='right';
'@

SubRx @'
  cy+=LH(16)*BZ;
  ctx.font=bFS(TYPE.micro); ctx.fillStyle='#6b7783';
  ctx.fillText('EQUIPPED',x+11,cy);
  cy+=LH(15)*BZ;
'@ @'
  cy+=LH(22)*BZ;
  ctx.font=bFS(TYPE.micro); ctx.fillStyle='#aaa498';
  ctx.fillText('EQUIPPED',x+11,cy);
  cy+=LH(24)*BZ;
'@

SubRx @'
  cy+=LH(14)*BZ;
  ctx.font=bFS(TYPE.micro); ctx.fillStyle='#6b7783';
  ctx.fillText('DMG '
'@ @'
  cy+=LH(22)*BZ;
  ctx.font=bFS(TYPE.micro); ctx.fillStyle='#aaa498';
  ctx.fillText('DMG '
'@

SubRx @'
  cy+=LH(16)*BZ;
  // v8.78: this counted
'@ @'
  cy+=LH(20)*BZ;
  // v8.78: this counted
'@

SubRx @'
ctx.fillStyle=(si===sel)?'rgba(52,60,84,.9)':(hov?'rgba(34,42,58,.9)':'rgba(18,24,34,.9)');
'@ @'
ctx.fillStyle=(si===sel)?'#262b30':(hov?'#1e2225':'#16191b');
'@

SubRx @'
ctx.strokeStyle=(si===sel&&!G.bagBelt)?'#ffc04a':(RCOL[it?dispR(stacks[si].key):null]||'rgba(90,102,116,.6)');
'@ @'
ctx.strokeStyle=(si===sel&&!G.bagBelt)?'#e6ff3d':(RCOL[it?dispR(stacks[si].key):null]||'#4a5257');
'@

SubRx @'
ctx.lineWidth=(si===sel)?2:1.2;
'@ @'
ctx.lineWidth=(si===sel)?3:1.2;
'@

SubRx @'
ctx.font=bFS(TYPE.micro); ctx.fillStyle='#9aa8d0'; ctx.textAlign='center';
'@ @'
ctx.font=bFS(TYPE.micro); ctx.fillStyle='#aaa498'; ctx.textAlign='center';
'@

SubRx @'
var hintY=Math.min(gridBot+LH(20)*BZ,y+hh-LH(24)*BZ);
'@ @'
var hintY=Math.min(gridBot+LH(34)*BZ,y+hh-LH(24)*BZ);
'@

SubRx @'
    ctx.font=bFS(TYPE.label);
    ctx.fillStyle=RCOL[sit?dispR(sst.key):null]||'#cdd6dd';
'@ @'
    ctx.font=bFS(TYPE.head);
    ctx.fillStyle='#efe9dc';
'@

SubRx @'
    ctx.textAlign='right'; ctx.fillStyle='#ffc04a';
    // v15.95
'@ @'
    ctx.textAlign='right'; ctx.font=bFS(TYPE.label); ctx.fillStyle='#aaa498';
    // v15.95
'@

SubRx @'
    ctx.font=bFS(TYPE.micro); ctx.fillStyle='#9aa8d0';
    var isGun
'@ @'
    ctx.font=bFS(TYPE.micro); ctx.fillStyle='#aaa498';
    var isGun
'@

SubRx @'
_ry=hintY+LH(13)*BZ;
'@ @'
_ry=hintY+LH(24)*BZ;
'@

SubRx @'
ctx.fillStyle='rgba(154,168,208,.55)';
'@ @'
ctx.fillStyle='#aaa498';
'@

SubRx @'
      ctx.fillStyle='#cdd6dd';
      ctx.fillText(String(_rw[_rr][1]),x+11+LH(74)*BZ,_ry);
      _ry+=LH(11)*BZ;
'@ @'
      ctx.fillStyle='#efe9dc';
      ctx.fillText(String(_rw[_rr][1]),x+11+LH(100)*BZ,_ry);
      _ry+=LH(18)*BZ;
'@

SubRx @'
    ctx.fillStyle='#9aa8d0';
    // v15.59
'@ @'
    ctx.fillStyle='#aaa498';
    // v15.59
'@

SubRx @'
ctx.fillText((state==='hub')?(padOn()?padB('DPAD move
'@ @'
bagHintDraw((state==='hub')?(padOn()?padB('DPAD move
'@

SubRx @'
),x+11,_ry+LH(3)*BZ);
'@ @'
),x+11,_ry+LH(6)*BZ,PW-22);   // v28.xx (cw-bagpolish): the hints wrap to the panel width
'@

SubRx @'
    ctx.font=bFS(TYPE.label); ctx.fillStyle='#6b7783';
    ctx.fillText('Backpack is empty.'
'@ @'
    ctx.font=bFS(TYPE.label); ctx.fillStyle='#aaa498';
    ctx.fillText('Backpack is empty.'
'@

SubRx @'
function drawBag(){
'@ @'
// v28.xx (cw-bagpolish): the backpack key hints flow onto as many lines as the panel width needs (the parts are split where the text has three spaces)
function bagHintDraw(s,x,y,maxW){
  var parts=String(s).split('   '), line='', ln=0, i, t, lh=LH(18)*Math.max(1,hudRes());
  for(i=0;i<parts.length;i++){
    t=line?line+'   '+parts[i]:parts[i];
    if(line&&ctx.measureText(t).width>maxW){ ctx.fillText(line,x,y+ln*lh); ln++; line=parts[i]; } else line=t;
  }
  if(line) ctx.fillText(line,x,y+ln*lh);
  return ln+1;
}
function drawBag(){
'@

SubRx @'
var VER='32.77';
'@ @'
var VER='32.78';
'@

$pat = "(?m)^  now:'v32\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.78: The raid backpack is a compact panel with larger tiles and readable text. Check 32.78 fails on v32.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

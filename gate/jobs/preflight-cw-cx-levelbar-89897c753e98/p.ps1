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

# PILLAGER SURVIVAL LEVEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pilClean(q){
'@ @'
// v28.xx (cw-cx-levelbar), his answers 16, 17, 19, 20, 29 and 52: every earned SP fills the living pillager, even between levels; demo has none.
// v28.xx (cw-cx-levelbar): costs 1000 + 150*(level-1); cumulative 44650 at 20. The 37 extracted run logs have median base kill SP 1525, 3050 after extraction: 14.64 raids, before extra bonuses.
function pilLevelFloor(l){ l=Math.max(1,Math.min(20,l|0))-1; return 1000*l+75*l*(l-1); }
function pilLevelOf(s){ var l=1; while(l<20&&s>=pilLevelFloor(l+1)) l++; return l; }
function pilSPAdd(n,settle){
  if(!G||!G.career||G.arcade||G.sim||(G.over&&!settle)||(typeof ARCADE==='object'&&ARCADE.on)||!P.pil||!Number.isFinite(n)||n<=0) return 0;
  var q=P.pil, before=+q.lsp||0;
  q.lsp=Math.min(pilLevelFloor(20),before+n); q.lvl=pilLevelOf(q.lsp);
  return q.lsp-before;
}
function pilLevelHud(x,y,w){
  if(!G||!G.career||G.arcade||G.sim||(typeof ARCADE==='object'&&ARCADE.on)||!P.pil) return false;
  var q=P.pil, lo=pilLevelFloor(q.lvl), hi=pilLevelFloor(q.lvl+1), f=q.lvl>=20?1:clamp((q.lsp-lo)/(hi-lo),0,1);
  ctx.save(); ctx.font=FS(TYPE.label); ctx.textAlign='left'; ctx.fillStyle=UIC.tx_1;
  hudText('pillager survival level',x,y-8); ctx.textAlign='right'; hudText(String(q.lvl),x+w,y-8);
  bar(x,y,w,6,f,UIC.acc); ctx.restore(); return true;
}
function pilLevelTag(){
  if(!G||!G.career||G.arcade||G.sim||(typeof ARCADE==='object'&&ARCADE.on)||!P.pil) return false;
  var p=G.player, s=pilName(P.pil)+'  '+P.pil.lvl, y=p.y-52-figUpL()-((p.prep||p.prepA)?32:0), tw;
  wc.save(); wc.font=FS(TYPE.micro); wc.textAlign='center'; tw=wc.measureText(s).width;
  wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(p.x-tw/2-4,y-12,tw+8,17);
  wc.fillStyle=(typeof NET!=='undefined'&&NET.seat===1)?'#67d9ed':'#ffc04a'; wc.fillText(s,p.x,y); wc.restore(); return true;
}
function pilClean(q){
'@

SubRx @'
  b=c.b||(c.b={}); b[cat]=(b[cat]|0)+(n|0);
'@ @'
  b=c.b||(c.b={}); b[cat]=(b[cat]|0)+(n|0);
  pilSPAdd(n); // v28.xx (cw-cx-levelbar): all five career SP writers use this tally, including shared kill credit.
'@

SubRx @'
    fin=Math.round(s*2*cm);
'@ @'
    fin=Math.round(s*2*cm);
    pilSPAdd(Math.max(0,fin-s),true); // v28.xx (cw-cx-levelbar): count the extraction and condition bonus once, before the pillager record settles.
'@

SubRx @'
  var HBW=300,HBH=26;   /* v28.xx (cw-barnarrow), the critic (2026-10-19): at 360 the stamina word past the bar ran into belt slot 1; all three vitals bars are 300 wide, the word ends clear of the belt */
'@ @'
  var HBW=300,HBH=26;   /* v28.xx (cw-barnarrow), the critic (2026-10-19): at 360 the stamina word past the bar ran into belt slot 1; all three vitals bars are 300 wide, the word ends clear of the belt */
  pilLevelHud(16,by-73,HBW); // v28.xx (cw-cx-levelbar): six-pixel progression track beside health, inside its existing drag and scale.
'@

SubRx @'
y:by-50-LH(5)-LH(18),w:HBW,h:1
'@ @'
y:(G.career&&!G.arcade?by-110:by-50-LH(5)-LH(18)),w:HBW,h:1
'@

SubRx @'
  drawLongshotGlints();
'@ @'
  pilLevelTag(); // v28.xx (cw-cx-levelbar): the local head shows only name and level, in the world text pass.
  drawLongshotGlints();
'@

SubRx @'
function netPnPut(msg,n){ var nm=netClean(pilHeadName(),24); if(nm&&(nm!==NET.pnSent||n%10===0)){ msg.pn=nm; NET.pnSent=nm; } }   // v37.xx (cw-m2retire)
'@ @'
function netPnPut(msg,n){ if(G&&G.career&&!G.arcade&&!G.sim&&P.pil) msg.pl=P.pil.lvl; var nm=netClean(pilHeadName(),24); if(nm&&(nm!==NET.pnSent||n%10===0)){ msg.pn=nm; NET.pnSent=nm; } }   // v37.xx (cw-m2retire)
'@

SubRx @'
  if(up) netLeadSample(g,x,y,g.tx,g.ty,g.age);   // v36.xx (cw-coopsmooth): his speed from this word and the last; read before the new spot is filed
'@ @'
  if(up) netLeadSample(g,x,y,g.tx,g.ty,g.age);   // v36.xx (cw-coopsmooth): his speed from this word and the last; read before the new spot is filed
  if(up) g.pl=(Number.isInteger(m.pl)&&m.pl>=1&&m.pl<=20)?m.pl:0; // v28.xx (cw-cx-levelbar): never infer a level for an old peer or a demo.
'@

SubRx @'
    if(typeof m.pn==='string'&&NET.pn&&NET.pn[s]) out.pn=NET.pn[s];   // v37.xx (cw-m2retire): passed on as it came
'@ @'
    if(typeof m.pn==='string'&&NET.pn&&NET.pn[s]) out.pn=NET.pn[s];   // v37.xx (cw-m2retire): passed on as it came
    if(up&&g.pl) out.pl=g.pl; // v28.xx (cw-cx-levelbar): forward the displayed survival level.
'@

SubRx @'
function netUpTags(){
  var i, g, nm, tw, n=0, U=figUpL()+3; /* v28.xx (cw-thirdsize): the pixel look keeps its own lift */   // v32.64 (cw-figlook): U lifts the plate over the bigger head and makes room for the bar
  if(!NET.on||typeof G==='undefined'||!G) return 0;
  try{
    wc.font=FS(TYPE.micro);
    for(i=0;i<NET.up.length;i++){
      g=NET.up[i]; if(!netUpShown(g)||netUpHid(g)) continue;   // v35.xx (cw-xsink): no name plate over a teammate an extraction took
      nm=netSeatName(g.seat)||'PILLAGER';
'@ @'
function netUpTags(){
  var i, g, nm, tw, n=0, U=figUpL()+3; /* v28.xx (cw-thirdsize): the pixel look keeps its own lift */   // v32.64 (cw-figlook): U lifts the plate over the bigger head and makes room for the bar
  if(!NET.on||typeof G==='undefined'||!G) return 0;
  try{
    wc.font=FS(TYPE.micro);
    for(i=0;i<NET.up.length;i++){
      g=NET.up[i]; if(!netUpShown(g)||netUpHid(g)) continue;   // v35.xx (cw-xsink): no name plate over a teammate an extraction took
      nm=netSeatName(g.seat)||'PILLAGER';
      if(G.career&&!G.arcade&&g.pl) nm+='  '+g.pl; // v28.xx (cw-cx-levelbar): name and level only; no account rank or trait badges.
'@

SubRx @'
var VER='37.67';
'@ @'
var VER='37.68';
'@

$pat = "(?m)^  now:'v37\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.68: Career health panel has a six-pixel survival level bar. Every career SP award fills it immediately; extraction and condition bonus count once. Names over heads show the survival level. Demo has no progression bar. Existing pillager fields reload without a migration or a new storage key. Check 37.68 fails on v37.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

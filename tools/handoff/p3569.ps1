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

# THE SCORE MULTIPLIER ON SCREEN, FOG OF WAR PAYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var DMUL_ON=1, DMUL_STEP={raiders:0.05,robots:0.05,hits:0.05,ext:0.05,superhot:0.05};
'@ @'
// v35.xx (cw-dmulshow), HIS ADDITION (2026-10-28): "Fog of war should also be one of the multiplier items". Fog of war on is one step (fog). Each window
// draws its own fog, so the raid word carries the host's (fw) and a linked window takes the host's at the build (NET.upFw while NET.upHold), as for every row.
var DMUL_ON=1, DMUL_STEP={raiders:0.05,robots:0.05,hits:0.05,ext:0.05,fog:0.05,superhot:0.05};
'@

SubRx @'
  return {raiders:n>=15?2:(n>=10?1:0), robots:s>=28?2:(s>=20?1:0), hits:d>=1.4?2:(d>=1.2?1:0), ext:v>=1.4?2:(v>=1?1:0), superhot:c.superhot?0:1};
'@ @'
  var fw=(typeof NET==='object'&&NET&&NET.upHold&&(NET.upFw===0||NET.upFw===1))?NET.upFw:((c.fogWar===1)?1:0);   // v35.xx (cw-dmulshow): fog of war, the host's while a linked window builds the raid
  return {raiders:n>=15?2:(n>=10?1:0), robots:s>=28?2:(s>=20?1:0), hits:d>=1.4?2:(d>=1.2?1:0), ext:v>=1.4?2:(v>=1?1:0), fog:fw, superhot:c.superhot?0:1};
'@

SubRx @'
  if(g.arcade) m.arc=1;   // v23.25 (arcade6)
'@ @'
  m.fw=(CFG.fogWar===1)?1:0;   // v35.xx (cw-dmulshow): the host's fog of war, for the party's score multiplier (each window still draws its own fog)
  if(g.arcade) m.arc=1;   // v23.25 (arcade6)
'@

SubRx @'
  NET.upHold=true; NET.upIss=(m.iss===1)?true:((m.iss===0)?false:null);
'@ @'
  NET.upHold=true; NET.upIss=(m.iss===1)?true:((m.iss===0)?false:null);
  NET.upFw=(m.fw===1||m.fw===0)?m.fw:null;   // v35.xx (cw-dmulshow): the host's fog of war row, read by the score multiplier while this raid is built
'@

SubRx @'
    NET.upHold=false; NET.upIss=null; pendSeed=null;
'@ @'
    NET.upHold=false; NET.upIss=null; pendSeed=null; NET.upFw=null;
'@

SubRx @'
// sold, so lean for one raid would cost nothing), fog of war and shared sight (each window's own view, not in the raid word, so two windows would differ).
'@ @'
// sold, so lean for one raid would cost nothing) and shared sight (each window's own view). Fog of war pays a step since his addition of 10-28 (see below).
'@

SubRx @'
function diffSet(t){
'@ @'
// v35.xx (cw-dmulshow), HIS ORDER (2026-10-28): "that should give a score multiplier ... and that should be indicated to the player". The score row under
// difficulty: what the rows as they stand pay (diffMulOf, superhot in), redrawn with every click. No row at x1.00.
function dmulRowHtml(){
  var m=DMUL_ON?Math.round(diffMulOf(CFG)*100)/100:1;
  if(!(m>1)) return '';
  return '<div class="row" id="set_dmulrow"><div style="flex:1"><b>score</b><div class="hint">harder rows pay more sp</div></div><b id="set_dmul" style="padding:6px 12px;min-width:92px;text-align:center;color:var(--amber)">x'+m.toFixed(2)+'</b></div>';
}
function diffSet(t){
'@

SubRx @'
  _SEC['THE RAID']=diffRowHtml()+(_SEC['THE RAID']||'')+expRowHtml();
'@ @'
  _SEC['THE RAID']=diffRowHtml()+dmulRowHtml()+(_SEC['THE RAID']||'')+expRowHtml();   // v35.xx (cw-dmulshow): the score multiplier row under difficulty
'@

SubRx @'
  ctx.font=fs;ctx.fillStyle=UIC.tx_2;hudText(solo?'SCORE':'TEAM SCORE',cx,labelY);
'@ @'
  ctx.font=fs;ctx.fillStyle=UIC.tx_2;hudText(solo?'SCORE':'TEAM SCORE',cx,labelY);
  dmulTag(cx,labelY,ctx.measureText(solo?'SCORE':'TEAM SCORE').width,z);   // v35.xx (cw-dmulshow): the settings multiplier beside the label
'@

SubRx @'
function arcadeScoreHud(y,z){
'@ @'
// v35.xx (cw-dmulshow), his order of 2026-10-28: the settings multiplier this raid pays, small and amber to the right of the score label, in the font the label
// was drawn in. Nothing at x1.00. Returns the tag text or ''.
function dmulTag(cx,y,lw,z){
  var m=diffMul(), t;
  if(!(m>1)) return '';
  t='x'+m.toFixed(2);
  ctx.save(); ctx.textAlign='left'; ctx.fillStyle='#ffc04a'; hudText(t,Math.round(cx+lw/2+8*z),y); ctx.restore();
  return t;
}
function dmulTagW(lw,z){ var m=diffMul(); if(!(m>1)) return 0; return lw/2+8*z+ctx.measureText('x'+m.toFixed(2)).width; }
function arcadeScoreHud(y,z){
'@

SubRx @'
  pw=Math.ceil(Math.max(100*z,w/2+pad+Math.max(side,sw)));
'@ @'
  pw=Math.ceil(Math.max(100*z,w/2+pad+Math.max(side,sw)));
  ctx.font=fs; pw=Math.max(pw,Math.ceil(dmulTagW(ctx.measureText(solo?'SCORE':'TEAM SCORE').width,z)+pad));   // v35.xx (cw-dmulshow): room for the multiplier tag
'@

SubRx @'
  if(ex) sh+=row('','<span class="lgl">EXTRACTION x2</span>'+cnt(s,'+'));
'@ @'
  var _dm=diffMul(); if(_dm>1) sh+=row('dm','<span class="lgl">settings</span><b>x'+_dm.toFixed(2)+'</b>');   // v35.xx (cw-dmulshow): the settings multiplier, once (the rows above already have it in)
  if(ex) sh+=row('','<span class="lgl">EXTRACTION x2</span>'+cnt(s,'+'));
'@

SubRx @'
  ARCADE.over={at:Date.now(),why:String(why||''),team:arcadeTeam(),p1:host?me:mt,p2:host?mt:me};
'@ @'
  ARCADE.over={at:Date.now(),why:String(why||''),team:arcadeTeam(),p1:host?me:mt,p2:host?mt:me};
  try{ ARCADE.over.dm=diffMul(); }catch(_dm){}   // v35.xx (cw-dmulshow): the settings multiplier the run paid, for the card
'@

SubRx @'
  ARCADE.over={at:Date.now(),why:(m&&m.x2)?'extract':((m&&m.ko)?'dead':((m&&m.hf)?'menu':'')),team:arcadeTeam(),p1:mt,p2:me};
'@ @'
  ARCADE.over={at:Date.now(),why:(m&&m.x2)?'extract':((m&&m.ko)?'dead':((m&&m.hf)?'menu':'')),team:arcadeTeam(),p1:mt,p2:me};
  try{ ARCADE.over.dm=diffMul(); }catch(_dm){}   // v35.xx (cw-dmulshow): the settings multiplier, as the host card has it
'@

SubRx @'
    if(oc&&o.why==='extract') ln.splice(1,0,['aoh','EXTRACTED x2']);
'@ @'
    if(oc&&o.dm>1) for(i=0;i<ln.length;i++) if(ln[i][0]==='aos'){ ln.splice(i+1,0,['aor aodm','settings x'+(+o.dm).toFixed(2)]); break; }   // v35.xx (cw-dmulshow): the settings multiplier, once, under the score
    if(oc&&o.why==='extract') ln.splice(1,0,['aoh','EXTRACTED x2']);
'@

SubRx @'
var VER='35.68';
'@ @'
var VER='35.69';
'@

$pat = "(?m)^  now:'v35\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.69: fog of war on pays 5 percent more sp; the settings score multiplier shows in settings, beside the score in a raid and once on the end card Check 35.69 fails on v35.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

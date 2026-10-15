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

# GUN KILL TALLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
thru:(wep.id==='lance')?1:0});
'@ @'
thru:(wep.id==='lance')?1:0,gid:fromPlayer?String(wep.id||''):''});   // v26.xx (career1): the round carries the id of the gun it came from, for the kill tally
'@

SubRx @'
en.pHitT=.3; en.pHitSeat=0; en.blow='g'; en.blowT=G.t;
'@ @'
en.pHitT=.3; en.pHitSeat=0; en.blow='g'; en.blowT=G.t; en.blowG=b.gid||'';
'@

SubRx @'
T.kills[e.kind]++; contractKill(e.kind);
'@ @'
T.kills[e.kind]++; contractKill(e.kind);
        try{ gunKillNote(e); }catch(_gkn){}   // v26.xx (career1): the gun tally
'@

SubRx @'
for(var _kk in _tk) P.kills[_kk]=(P.kills[_kk]||0)+(_tk[_kk]||0);
'@ @'
for(var _kk in _tk) P.kills[_kk]=(P.kills[_kk]||0)+(_tk[_kk]||0);
    try{ gunKillsBank(how); }catch(_gkb){}   // v26.xx (career1): and each gun's kills
'@

SubRx @'
function itemRows(key){
'@ @'
// v26.xx (career1), HIS YES (2026-10-14) to suggestion 29, GUN KILL TALLY: "each gun counts its kills, shown on the gun card". Every round of yours carries the
// id of the gun that fired it (gid); the body it hits keeps that id as blowG next to the blow mark; when that body dies of your round the kill is counted for
// the gun (gunKillNote, into the raid's own tally G.gunK, so the live card reads it at once). The tally is banked into the save (P.gunKills, gun id to count,
// an old save simply has none) when a raid ends in an extraction or a death; an abandoned run counts nothing, like every other score of the run. One count per
// gun id: a rarity twin (the _v gun) is a gun of its own and counts its own. A swing, a blast and a burn are not a gun and count for none. It shows as a KILLS
// row on the gun card (the pickup card, the backpack card, the belt hover card) and on the stash and backpack hover. Display and a count only.
function gunKillsOf(gk){
  var n=0;
  try{ if(P&&P.gunKills&&typeof P.gunKills==='object') n+=(+P.gunKills[gk])|0; }catch(_g){}
  try{ if(typeof G!=='undefined'&&G&&!G.over&&!G.sim&&G.gunK) n+=(+G.gunK[gk])|0; }catch(_r){}
  return n>0?n:0;
}
function gunKillNote(e){
  var id, t;
  if(!G||G.sim||G.arcade||!e||e.blow!=='g'||!e.blowG) return 0;
  id=String(e.blowG); if(id==='fists'||!WEAPONS[id]) return 0;
  t=G.gunK||(G.gunK={}); t[id]=(t[id]|0)+1;
  return t[id];
}
function gunKillsBank(how){
  var k, n=0;
  if(!G||G.sim||G.arcade||how==='abandon'||!G.gunK||!P) return 0;
  if(!P.gunKills||typeof P.gunKills!=='object'||Array.isArray(P.gunKills)) P.gunKills={};
  for(k in G.gunK){ if(Object.prototype.hasOwnProperty.call(G.gunK,k)&&WEAPONS[k]){ P.gunKills[k]=((+P.gunKills[k])|0)+((+G.gunK[k])|0); n+=(+G.gunK[k])|0; } }
  G.gunK={};
  return n;
}
function itemRows(key){
'@

SubRx @'
    R.push(['NOISE',W2.noise>=300?'very loud':(W2.noise>=200?'loud':(W2.noise>0?'quiet':'silent'))]);
'@ @'
    R.push(['NOISE',W2.noise>=300?'very loud':(W2.noise>=200?'loud':(W2.noise>0?'quiet':'silent'))]);
    { var _gkn=gunKillsOf(it.gk); if(_gkn>0) R.push(['KILLS',_gkn.toLocaleString()]); }   // v26.xx (career1): the tally, only once a gun has a kill
'@

SubRx @'
+(tag?rh:0)+(el?rh:0)};
'@ @'
+(tag?rh:0)+(el?rh:0)+((cmp&&cmp.f&&gunKillsOf(cmp.f.id)>0)?rh:0)};   // v26.xx (career1): a row for the kill tally
'@

SubRx @'
if(tag){ yy+=rh; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText(String(tag).toUpperCase(),x+pad,yy,w-pad*2); }
'@ @'
if(gunKillsOf(cmp.f.id)>0){ yy+=rh; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText('KILLS',x+pad,yy); ctx.textAlign='right'; ctx.fillStyle=HUDC.text; ctx.fillText(gunKillsOf(cmp.f.id).toLocaleString(),x+w-pad,yy); }   // v26.xx (career1): the tally
    if(tag){ yy+=rh; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText(String(tag).toUpperCase(),x+pad,yy,w-pad*2); }
'@

SubRx @'
var VER='26.95';
'@ @'
var VER='26.96';
'@

$pat = "(?m)^  now:'v26\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.96: Each gun counts its kills, and the tally shows on the gun card. Check 26.96 fails on v26.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

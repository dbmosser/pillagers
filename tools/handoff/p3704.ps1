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

# DEAD CODE OUT 1 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function forgeName(gk,fk){ var b=WEAPONS[gk]; return (b?b.name:String(gk||''))+forgeMk(fk|0); }

'@ @'
// v28.xx (cw-dead1): dead code out, no caller anywhere (audit 2026-10-28): forgeName, woodsCell, bigSpine, forgeChamfer, msgVictim, msgQDrop, cycleHeal, unkeyedHeals, countHeals, gunDef, placeName, tabOf, netSndLabel, netSndOtherLabel, sectorTitle.

'@

SubRx @'
  function woodsCell(r2,c2){
    for(var wq=0;wq<(map.woods||[]).length;wq++) if(map.woods[wq].r===r2&&map.woods[wq].c===c2) return true;
    return false;
  }

'@ @'

'@

SubRx @'
  function bigSpine(hORv,r2,c2){
    for(var bq=0;bq<(map.bigPairs||[]).length;bq++){
      var B=map.bigPairs[bq];
      if(B.horiz&&hORv==='v'&&B.r===r2&&B.c+1===c2) return true;
      if(!B.horiz&&hORv==='h'&&B.r+1===r2&&B.c===c2) return true;
    }
    return false;
  }

'@ @'

'@

SubRx @'
function forgeChamfer(x,y,w,h,c){ ctx.beginPath(); ctx.moveTo(x+c,y); ctx.lineTo(x+w,y); ctx.lineTo(x+w,y+h-c); ctx.lineTo(x+w-c,y+h); ctx.lineTo(x,y+h); ctx.lineTo(x,y+c); ctx.closePath(); }

'@ @'

'@

SubRx @'
function msgVictim(rows,rk,now,drain){
  var best=null, i, r, rr;
  for(i=0;i<rows.length;i++){
    r=rows[i]; rr=MSGK[msgKind(r.k)].r;
    if(msgProt(r,now)&&(drain||rr>rk)) continue;
    if(!best||rr<best.rr||(rr===best.rr&&(+r.at||-1e9)<(+best.r.at||-1e9))) best={r:r,rr:rr};
  }
  return best?best.r:null;
}

'@ @'

'@

SubRx @'
function msgQDrop(m,key){ var i; while((i=msgQFind(m,key))>=0){ G.msgQ.splice(i,1); G.msgQM.splice(i,1); } }

'@ @'

'@

SubRx @'
// J: the next non-empty medical key, round, as U does for the grenades.
function cycleHeal(){
  var sl=hotbarSlots(), cs=medCells(sl), cur=medSelIx(sl), at=-1, i, nx;
  if(!cs.length){ say((findHeal()>=0)?'NO HEAL ON HOTBAR':'NO MEDICAL SUPPLIES'); return false; }
  for(i=0;i<cs.length;i++) if(cs[i]===cur) at=i;
  nx=cs[(at+1)%cs.length];
  G.msel=sl[nx].itemKey;
  say((ITEMS[G.msel].name+' ready').toUpperCase());
  return true;
}

'@ @'

'@

SubRx @'
function unkeyedHeals(){
  // v14.84: the heals in the backpack whose item is on no belt key.
  var n=0, keyed={};
  for(var s in (G.hotAssign||{})) keyed[G.hotAssign[s]]=1;
  for(var i=0;i<G.bag.length;i++){ var it=ITEMS[G.bag[i]]; if(it&&it.use==='heal'&&!keyed[G.bag[i]]) n++; }
  return n;
}

'@ @'

'@

SubRx @'
function countHeals(){
  var n=0;
  for(var i=0;i<G.bag.length;i++){ var it=ITEMS[G.bag[i]]; if(it&&it.use==='heal') n++; }
  return n;
}

'@ @'

'@

SubRx @'
function gunDef(w){ return GUNDEF[(w&&w.id)||'rifle']||GUNDEF.rifle; }

'@ @'

'@

SubRx @'
// A place already called "THE something" brings its own article.
function placeName(n){
  n=String(n).toLowerCase();
  return n.indexOf('the ')===0?n.slice(4):n;
}

'@ @'

'@

SubRx @'
  function tabOf(k){ return stashTabOf(k); }

'@ @'

'@

SubRx @'
function netSndLabel(on){ return on?'SOUND ON':'SOUND OFF'; }

'@ @'

'@

SubRx @'
function netSndOtherLabel(){ return (NET.sndOther===1)?'sound on':((NET.sndOther===0)?'sound off':'not said yet'); }

'@ @'

'@

SubRx @'
// v13.26: the map name the way he wrote it in the sector line, Cold Storage and The
// Cold Mile, from the upper-case name the heading uses.
function sectorTitle(n){ return String(n||'').toLowerCase().replace(/\b[a-z]/g,function(c){ return c.toUpperCase(); }); }

'@ @'

'@

SubRx @'
var VER='37.03';
'@ @'
var VER='37.04';
'@

$pat = "(?m)^  now:'v37\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.04: Nothing a player can see changes. Check 37.04 fails on v37.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

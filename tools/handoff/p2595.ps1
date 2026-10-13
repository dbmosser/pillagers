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

# TAP H USES THE CHEAPEST HEAL ON THE BELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function quickHeal(){
  var p=G&&G.player;
  if(!G||G.sim||G.over||G.paused||G.trade||!p||p.downed||p.dying||p.specOut) return false;
  try{ useMedical(); }catch(_qh){}
'@ @'
// v25.xx (belt5b), HIS DECISION 2026-10-13: "tap H uses the cheapest heal that helps". From the two medical keys only: the cheapest heal there
// that can still raise him (a Bandage stops at its ceiling, a Medkit goes to full), never a Stim, never a heal that is only in the backpack. With
// a heal in the backpack that would help and none on the belt it says NO HEAL ON BELT and names the key that opens the backpack.
function useBeltHeal(){
  var p=G.player, sl=hotbarSlots(), reach=healReach(p), best=null, anyBelt=false, ci, c, it, bi, a, b;
  if(reach>=p.maxhp){ say((p.healQ>0)?'ALREADY HEALING':'HEALTH FULL'); return false; }
  for(ci=GUNKEYS;ci<HOTBAR_N;ci++){
    if(BELT_CLASS[ci]!=='med') continue;
    c=sl[ci];
    if(!c||c.kind!=='heal'||!(c.count>0)||!ITEMS[c.itemKey]) continue;
    anyBelt=true; it=ITEMS[c.itemKey];
    if(reach>=healCeil(it)) continue;
    if(best){ a=it.amt||0; b=ITEMS[best.itemKey].amt||0; if(a>b||(a===b&&ival(c.itemKey)>=ival(best.itemKey))) continue; }
    best=c;
  }
  if(!best){
    if(anyBelt){ say('BANDAGES STOP AT '+Math.round(healCeil(ITEMS.bandage)),'info',{sub:'You need a Medkit.'}); return false; }
    if(findHeal()>=0){ say('NO HEAL ON BELT','info',{sub:(padOn()?padB('VIEW  BACKPACK'):('['+keyLabel('KeyB','B')+'] BACKPACK'))}); return false; }
    say('NO MEDICAL SUPPLIES');
    return false;
  }
  if(p.prep){ say('ALREADY APPLYING','info',{sub:String(ITEMS[p.prep.key]?ITEMS[p.prep.key].name:'Medical').toUpperCase()}); return false; }
  bi=G.bag.indexOf(best.itemKey);
  if(bi<0) return false;
  G.bag.splice(bi,1); if(!startPrep('heal',best.itemKey)) blip('pick');
  G.tel.heals++;
  spark(p.x,p.y,'#6fe0a0',10,90);
  return true;
}
function quickHeal(){
  var p=G&&G.player;
  if(!G||G.sim||G.over||G.paused||G.trade||!p||p.downed||p.dying||p.specOut) return false;
  try{ useBeltHeal(); }catch(_qh){}   // v25.xx (belt5b): the cheapest heal that helps, from the medical keys
'@

SubRx @'
var VER='25.94';
'@ @'
var VER='25.95';
'@

$pat = "(?m)^  now:'v25\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.95: A tap of H now uses the cheapest heal on the two medical keys, and says NO HEAL ON BELT when only the backpack has one. Check 25.95 fails on v25.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

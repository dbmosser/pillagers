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

# DEAD CODE OUT 2 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gfxLightNow(){ var l=(CFG.gfxLight===0)?0:((CFG.gfxLight===1)?1:2); if(l===2&&!GFXQ.shadow) l=1; return l; }

'@ @'
// v28.xx (cw-dead2): dead code out, no caller anywhere (audit 2026-10-28): gfxLightNow, gfxWet, sizeTag, countArmor, uiKey, goalsHud, arcadeBagFree, arcadeQuickHeal, arcadeAutoSrch.

'@

SubRx @'
function gfxWet(){ return GFX.bypass?0:(+GFX.WET||0); }   // D: how wet the ground is, 0 to 1

'@ @'

'@

SubRx @'
// v7.54, his note: the size difference stated next to the name. Only the
// extremes are tagged, so a third mid-sized map would stay untagged.
function sizeTag(ix){
  var minA=1e15,maxA=0,minI=0,maxI=0;
  for(var q=0;q<FIXED_MAPS.length;q++){
    if(!mapOffered(FIXED_MAPS[q])) continue;   // v23.6x (feat0b): a frozen map is not measured, so the lone card carries no size tag
    var A=FIXED_MAPS[q].w*FIXED_MAPS[q].h;
    if(A<minA){ minA=A; minI=q; }
    if(A>maxA){ maxA=A; maxI=q; }
  }
  if(minI===maxI) return '';
  if(ix===minI) return '(SMALLER MAP)';
  if(ix===maxI) return '(LARGER MAP)';
  return '';
}

'@ @'

'@

SubRx @'
function countArmor(){
  var n=0;
  for(var i=0;i<G.bag.length;i++){ var it=ITEMS[G.bag[i]]; if(it&&it.use==='armor') n++; }
  return n;
}

'@ @'

'@

SubRx @'
// v24.27, UI REDESIGN ui7 (his #50): uiKey(code) is the DOM keycap of a key, named as keyLabel names it (the key as set, or the pad
// button through padB on a controller): a key for the keyboard, a coloured round button for A, B, X and Y, a pill for the bumpers.
function uiKey(code,fallback){
  var L=String(keyLabel(code,fallback)), c='ui-key';
  if(padOn()&&HUDKEY_PAD[L]) c+=' pad pad-'+L.toLowerCase(); else if(padOn()&&(/^(LB|RB|LT|RT|LS|RS|VIEW|MENU|BACK)$/).test(L)) c+=' pill';
  return '<span class="'+c+'">'+L.replace(/&/g,'&amp;').replace(/</g,'&lt;')+'</span>';
}

'@ @'

'@

SubRx @'
function goalsHud(c){
  var S=G.flow, gl, i, z, U, w, lh, pad, h, x, y, hb, yy, n=0;
  if(!S||!S.goals||!S.goals.length||G.bagOpen||G.mapOpen||G.over) return 0;
  z=Math.max(1,hudRes()); U=function(v){ return LH(v)*z; };
  lh=U(15); pad=U(9); h=pad*2+lh*(S.goals.length+1);
  hb=HUDBOX.cond;
  if(hb&&isFinite(hb.y)&&isFinite(hb.x)){ x=hb.x; w=hb.w; y=hb.y+hb.h+Math.round(8*z); }
  else { w=U(176); x=W-Math.round(16*z)-w; y=(MMAP.box?mmBottom():Math.max(topRightBottom(),U(60)))+Math.round(10*z); }
  c.save();
  hudPanel(x,y,w,h,0.84);
  EDGEBOX.goals={x:x,y:y,w:w,h:h};   // v27.17 (gcfix): where the run goals are, so the gun card and the kill feed keep clear of them
  c.textBaseline='alphabetic'; c.textAlign='left'; c.font=hudFS(TYPE.micro);
  c.fillStyle='#ffc04a'; hudText('RUN GOALS',x+pad,y+pad+lh*0.8);
  for(i=0;i<S.goals.length;i++){
    gl=S.goals[i]; yy=y+pad+lh*(i+1)+lh*0.8;
    c.textAlign='left'; c.fillStyle=gl.done?'#7fc4a0':'#cdd6dd';
    hudText(gl.t+((!gl.done&&gl.n>1)?('  '+gl.v+'/'+gl.n):''),x+pad,yy);
    c.textAlign='right'; c.fillStyle=gl.done?'#7fc4a0':'#ffc04a';
    hudText((gl.done?'done ':'')+goalRewardText(gl),x+w-pad,yy);
    n++;
  }
  c.restore();
  return n;
}

'@ @'

'@

SubRx @'
// v23.49, HIS YES (2026-10-11) to the five recommendations, arcade25 (a low finding of the arcade 7-13 review): VALUABLES IGNORE A FULL
// BACKPACK. The search refused any box with BACKPACK FULL once the backpack was at its cap, even a box whose loot never enters the
// backpack: in the arcade a valuable turns into points and pot (arcadeLoot), ammo goes to the reserve and a throwable to the pouch.
// The cap is unlimited on his 2026-08-22 order, so this is latent today, but the arcade rule is that the full test counts only what
// actually goes into the bag. arcadeBagFree(ct) is true when every item left in the box is one of those, and the search then neither
// refuses the box nor sheds the worst of the backpack (autoCull) to make room it does not need. A box with anything else in it is
// refused as before, and a normal raid is unchanged.
function arcadeBagFree(ct){
  var j, it;
  if(!ct||typeof G==='undefined'||!G||!G.arcade||G.sim||ct.mercSrc) return false;
  if(!Array.isArray(ct.loot)||!ct.loot.length) return false;
  for(j=0;j<ct.loot.length;j++){ it=ITEMS[ct.loot[j]]; if(!it||(it.use&&it.use!=='ammo'&&it.use!=='throw')) return false; }
  return true;
}

'@ @'

'@

SubRx @'
// v23.46, HIS YES (2026-10-11) to the five recommendations, arcade23: ONE-BUTTON QUICK HEAL. Belt-then-fire is the heal control a
// walk-up player never finds, so in an arcade raid G on the keyboard (the key as set in CHANGE KEYS) and D-DOWN on the pad heal at
// once through useMedical: the same picker (findHeal), the same wind-up (startPrep), the same refusals and his ruling that a
// Bandage stops at 85 (healCeil) and only a Medkit reaches 100. Only a standing player heals this way; down, G and D-DOWN keep
// their old jobs (the belt words and the self-revive). Outside the arcade G still uses the selected belt item and D-DOWN is unchanged.
function arcadeQuickHeal(){
  var p=G&&G.player;
  if(!G||!G.arcade||G.sim||G.over||G.paused||!p||p.downed||p.dying||p.specOut) return false;
  try{ useMedical(); }catch(_qh){}
  return true;
}

'@ @'

'@

SubRx @'
function arcadeAutoSrch(ct){
  var me;
  if(!ct||typeof G==='undefined'||!G||!G.arcade||G.sim||G.over||ct.opened||ct.dropped||ct.mercSrc) return false;
  if(!Array.isArray(ct.loot)||!ct.loot.length) return false;
  me=(typeof NET==='object'&&NET&&NET.on&&NET.role==='join')?(NET.seat|0):0;
  if(typeof ct.netBy==='number'&&ct.netBy>=0&&ct.netBy!==me) return false;
  return true;
}

'@ @'

'@

SubRx @'
var VER='37.04';
'@ @'
var VER='37.05';
'@

$pat = "(?m)^  now:'v37\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.05: Nothing a player can see changes. Check 37.05 fails on v37.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

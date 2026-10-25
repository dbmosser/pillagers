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

# MACHINES SHOW THEIR DAMAGE: SMOKE AT HALF HEALTH, SPARKS AND A STUTTERING EYE NEAR DEATH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gfxBodyFx(dt){ return gfxHook('body'); }   // C, E: damage smoke and fire, explosions, atmosphere
'@ @'
// v34.73 (cw-machdmg), item 4 of his 10-12 graphics list ("add ALL of this stuff"): MACHINES SHOW THEIR DAMAGE. A live machine under half health trails
// dark smoke; under a fifth it also spits sparks and its eye stutters, so you can see which one to finish. Clock-driven puffs like wreckSmoke (never
// G.smokes, those block sight), sparks from the fx stream (spark uses fxn), no simulation reads. Player 2 gets the health in 20 steps, so both windows draw it.
// Shed first on the quality ladder (GFXQ.particles 0) and scaled by EFFECT INTENSITY (CFG.fxInt: alpha and spark rate; OFF draws nothing).
var GFXDMG_KINDS={sentry:1,crawler:1,snitch:1,listener:1,bulwark:1,howler:1,warden:1,choir:1};
function gfxDmgLevel(e){
  if(!e||!GFXDMG_KINDS[e.kind]||!(e.maxhp>0)||!(e.hp>0)||e.downed||e.finished||e.gone||!isFinite(e.x)||!isFinite(e.y)) return 0;
  var k=(CFG.fxInt===undefined)?1:+CFG.fxInt;
  if(!(k>0)||GFXQ.particles===0) return 0;
  var f=e.hp/e.maxhp;
  return f<=0.2?2:(f<=0.5?1:0);
}
function gfxDamageFx(dt){
  var L=G.ents, i, j, e, lv, ph, t, H, x, y, s, pix=pixOn(), k=(CFG.fxInt===undefined)?1:Math.max(0,Math.min(1,+CFG.fxInt||0)), nS=0, nK=0;
  dt=(isFinite(dt)&&dt>0)?Math.min(dt,0.1):0;
  for(i=0;i<L.length;i++){
    e=L[i];
    if(!GFXDMG_KINDS[e.kind]) continue;
    lv=gfxDmgLevel(e); if(!lv) continue;
    H=elemBodyH(e); ph=grit((e.nid|0)*7+3,11)*6.2832; nS++;
    wc.fillStyle=lv>1?'#1c1917':'#2a2623';
    for(j=0;j<2+lv;j++){
      t=(G.t*.45+j/(2+lv)+ph)%1;
      wc.globalAlpha=(lv>1?.5:.4)*(1-t)*k;
      x=e.x+Math.sin(t*5+ph+j)*3; y=e.y-H-t*18; s=2.5+t*4;
      if(pix) pixFxSquare(wc,x,y,s*2,wc.fillStyle);
      else{ wc.beginPath(); wc.arc(x,y,s,0,6.2832); wc.fill(); }
    }
    if(lv>1){
      nK++;
      if(((G.t*11+ph*3)|0)%3===0){
        wc.globalAlpha=.9*k;
        if(pix) pixFxSquare(wc,e.x,e.y-H*.8,3,'#ffb040');
        else{ wc.fillStyle='#ffb040'; wc.fillRect(e.x-1.5,e.y-H*.8-1.5,3,3); }
      }
      if(fxr()<dt*5*k) spark(e.x+fxn(-(e.r||14)*.4,(e.r||14)*.4),e.y-H*.6+7.8,'#ffb040',1,90);
    }
  }
  wc.globalAlpha=1;
  GFX.dmgN=nS; GFX.dmgS=nK;
}
function gfxBodyFx(dt){ if(!gfxHook('body')) return false; try{ gfxDamageFx(dt); }catch(_gdf){} return true; }   // C, E: damage smoke and sparks (cw-machdmg), explosions, atmosphere
'@

SubRx @'
var VER='34.73';
'@ @'
var VER='34.74';
'@

$pat = "(?m)^  now:'v34\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.74: Machines now trail smoke under half health and spark with a stuttering eye near death. Check 34.74 fails on v34.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

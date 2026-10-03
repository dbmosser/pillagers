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

# KID FIRING TURNS PLAYER 2 TOWARD HIS TARGET (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netAutoFire(p){
'@ @'
// v18.08, HIS ORDER (2026-10-03): KID FIRING TURNS PLAYER 2 AND HIS FIELD OF VISION TOWARD HIS TARGET. The cursor used to move
// only once an enemy was inside gun range, so the body and the view cone kept facing the way he walked while a machine came
// at him from the side. With nothing in gun range, the nearest enemy in sight range with a clear line now gets the cursor, so
// he turns to it before it is close enough to shoot; the trigger stays up until it is.
function afLook(p){
  var i, e, d, best=null, bd, segs;
  if(!p||typeof G==='undefined'||!G||!G.ents) return null;
  bd=VF(); segs=G.vseg||(G.map&&G.map.segs)||[];
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!e||!(e.hp>0)||e.downed||e.finished||e.merc||e.friendlyPC||e.neutral||e.kind==='peddler'||e.kind==='stray') continue;
    if(e.kind==='raider'&&!e.hostile) continue;
    d=dist(p,e); if(d>=bd) continue;
    if(!losClear(p.x,p.y,e.x,e.y,segs)) continue;
    bd=d; best=e;
  }
  return best;
}
function netAutoFire(p){
'@

SubRx @'
  if(!e){ if(PAD.afire){ PAD.afire=0; if(!PAD.firing) mouse.down=false; } return null; }
'@ @'
  if(!e){
    var lk=null;
    if(PAD.afire){ PAD.afire=0; if(!PAD.firing) mouse.down=false; }
    if(p&&!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&!p.downed){ try{ lk=afLook(p); }catch(_al){ lk=null; } }   // v18.08: his order, turn toward the nearest enemy in sight
    if(lk){ pz=ZOOM(); cx=(G.camX===undefined?p.x-W/(2*pz):G.camX); cy=(G.camY===undefined?p.y-H/pz*0.54:G.camY); mouse.x=(lk.x-cx)*pz; mouse.y=(lk.y-cy)*pz; mouse.init=true; }
    return null;
  }
'@

SubRx @'
var VER='18.07';
'@ @'
var VER='18.08';
'@

$pat = "(?m)^  now:'v18\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.08: Kid firing now turns player 2 and his view toward the nearest enemy in sight, before it is in range. Check 18.08 fails on v18.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# A MAP OF EACH SECTOR ON THE SECTOR PAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function renderSector(){
'@ @'
// v17.79, THE VISUAL PASS (2026-10-02): A MAP OF EACH SECTOR ON THE SECTOR PAGE. WHERE ARE YOU GOING? was two rows of text over an
// empty page. Each row now carries a drawn map of its sector from the fixed layout (no build, no seeded draw): the ground, the
// named zones, the buildings and landmarks, and the extraction points as rings. Drawn once per render into a small canvas.
function sectorPreviewDraw(cv,M){
  var c=cv.getContext('2d'), W0=cv.width, H0=cv.height, sc=Math.min(W0/M.w,H0/M.h), ox=(W0-M.w*sc)/2, oy=(H0-M.h*sc)/2, i, z, b, e, n=0;
  if(!c) return 0;
  c.clearRect(0,0,W0,H0);
  c.fillStyle=(M.ground&&M.ground.day)||'#55647A'; c.fillRect(ox,oy,M.w*sc,M.h*sc);
  if(M.zones) for(i=0;i<M.zones.length;i++){ z=M.zones[i]; if(typeof z.x!=='number') continue;
    c.fillStyle='rgba(255,255,255,'+(0.03+0.03*((i%3)))+')'; c.fillRect(ox+z.x*sc,oy+z.y*sc,z.w*sc,z.h*sc);
    c.strokeStyle='rgba(127,146,216,.35)'; c.lineWidth=1; c.strokeRect(ox+z.x*sc+.5,oy+z.y*sc+.5,z.w*sc-1,z.h*sc-1); n++; }
  if(M.buildings) for(i=0;i<M.buildings.length;i++){ b=M.buildings[i]; if(!b||typeof b.x!=='number'||!b.w) continue; c.fillStyle='rgba(20,24,34,.75)'; c.fillRect(ox+b.x*sc,oy+b.y*sc,b.w*sc,b.h*sc); n++; }
  if(M.landmarks) for(i=0;i<M.landmarks.length;i++){ b=M.landmarks[i]; if(!b||typeof b.x!=='number'||!b.w) continue; c.strokeStyle='rgba(255,192,74,.55)'; c.lineWidth=1; c.strokeRect(ox+b.x*sc+.5,oy+b.y*sc+.5,b.w*sc-1,b.h*sc-1); n++; }
  if(M.zones) for(i=0;i<M.zones.length;i++){ z=M.zones[i]; if(typeof z.x!=='number'||!z.name) continue;
    c.font='bold 9px Rubik, system-ui, sans-serif'; c.fillStyle='rgba(205,214,221,.85)'; c.textAlign='center'; c.fillText(z.name,ox+(z.x+z.w/2)*sc,oy+(z.y+z.h/2)*sc+3); }
  if(M.extracts) for(i=0;i<M.extracts.length;i++){ e=M.extracts[i]; if(!e) continue;
    c.strokeStyle='#4de3d0'; c.lineWidth=2; c.beginPath(); c.arc(ox+e.x*sc,oy+e.y*sc,Math.max(4,78*sc),0,6.2832); c.stroke();
    c.fillStyle='rgba(77,227,208,.25)'; c.fill(); n++; }
  c.textAlign='left';
  return n;
}
function sectorPreviews(host){
  var cvs=host.querySelectorAll('canvas.secprev'), i, ix, n=0;
  for(i=0;i<cvs.length;i++){ ix=parseInt(cvs[i].getAttribute('data-map'),10); if(FIXED_MAPS[ix]){ try{ sectorPreviewDraw(cvs[i],FIXED_MAPS[ix]); n++; }catch(_sp){} } }
  return n;
}
function renderSector(){
'@

SubRx @'
       '<div><b style="color:'+(sel?'var(--amber)':'var(--bone)')+'">'+M.name+'</b>'+
'@ @'
       '<canvas class="secprev" data-map="'+i+'" width="420" height="'+Math.round(420*M.h/M.w)+'" style="float:right;margin:0 0 8px 16px;border:1px solid var(--steel-hi);border-radius:4px;background:#0b1020"></canvas>'+   // v17.79: the sector map
       '<div><b style="color:'+(sel?'var(--amber)':'var(--bone)')+'">'+M.name+'</b>'+
'@

SubRx @'
  host.innerHTML=h;
  var rows=host.querySelectorAll('.sectorpick');
'@ @'
  host.innerHTML=h;
  try{ sectorPreviews(host); }catch(_sv){}   // v17.79: the sector maps
  var rows=host.querySelectorAll('.sectorpick');
'@

SubRx @'
var VER='17.78';
'@ @'
var VER='17.79';
'@

$pat = "(?m)^  now:'v17\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.79: The sector page now shows a map of each sector beside its name: zones, buildings and the extraction points. Check 17.79 fails on v17.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ============ HIS NOTE, 2026-09-03 about 21:32: "if a howler is outside, he
# ============ shouldn't be able to bomb inside a house".
# ============
# ============ The Howler lobs a shell at a point and the shell lands there,
# ============ roof or no roof: howlerImpact damaged the player and every body
# ============ inside its radius with nothing between it and them. Standing
# ============ inside a building did not stop a shell fired from the street.
# ============
# ============ A shell now bursts ON the roof it lands on. Nobody under that roof
# ============ takes anything from it, and it still booms, flashes, shakes the
# ============ screen and pulls attention, because a shell hitting the roof over
# ============ your head should be heard. The rule is his sentence exactly: only
# ============ when the thing that fired it was NOT under the same roof, so a
# ============ Howler that has walked inside with you can still hurt you.
SubRx @'
function howlerImpact(SH){
  var p=G.player,R=(CFG.howlerR===undefined?90:CFG.howlerR);
'@ @'
// v10.63, his note: the building a point stands in, or null for open ground.
// The map keeps its buildings as plain rectangles, which is what a roof is here.
function roofAt(x,y){
  if(!G||!G.map) return null;
  var B=G.map.buildings||[];
  for(var i=0;i<B.length;i++){ var b=B[i];
    if(x>b.x&&x<b.x+b.w&&y>b.y&&y<b.y+b.h) return b; }
  return null;
}
function underSameRoof(b,x,y){ return !!b&&x>b.x&&x<b.x+b.w&&y>b.y&&y<b.y+b.h; }
function howlerImpact(SH){
  var p=G.player,R=(CFG.howlerR===undefined?90:CFG.howlerR);
  // v10.63, his note. A shell that lands on a building bursts on the ROOF, so
  // nothing under it is touched. Only when whatever fired it was outside that
  // building: a Howler in the room with you is still a Howler in the room.
  var _roof=roofAt(SH.tx,SH.ty);
  var _onRoof=!!_roof&&!underSameRoof(_roof,SH.x0,SH.y0);
'@
SubRx @'
  var dp=dist(p,{x:SH.tx,y:SH.ty});
  if(dp<R&&!p.downed) damagePlayer(SH.dmg*(1-dp/R)+6,'howler','HOWLER',SH.tx,SH.ty);
  for(var i=G.ents.length-1;i>=0;i--){
    var e=G.ents[i]; if(e.kind==='howler') continue;
    var de=dist(e,{x:SH.tx,y:SH.ty});
    if(de<R+e.r){
'@ @'
  var dp=dist(p,{x:SH.tx,y:SH.ty});
  if(dp<R&&!p.downed&&!(_onRoof&&underSameRoof(_roof,p.x,p.y)))
    damagePlayer(SH.dmg*(1-dp/R)+6,'howler','HOWLER',SH.tx,SH.ty);
  // v10.63: the roof covers everyone under it, not only him, or a shell on a
  // roof would still clear the room of pillagers sheltering in it.
  for(var i=G.ents.length-1;i>=0;i--){
    var e=G.ents[i]; if(e.kind==='howler') continue;
    if(_onRoof&&underSameRoof(_roof,e.x,e.y)) continue;
    var de=dist(e,{x:SH.tx,y:SH.ty});
    if(de<R+e.r){
'@

SubRx @'
var VER='10.62';
'@ @'
var VER='10.63';
'@
SubRx @'
  now:'v10.62: a gun you find goes into your empty slot instead of turning out the gun in your hand. You carry two; if both are full the one you picked is still the one replaced, because that is the only way to choose.',
'@ @'
  now:'v10.63: a Howler standing outside cannot bomb you inside a house. Its shell bursts on the roof and nobody under that roof is touched, though you will hear it land. A Howler that has come inside with you is still dangerous.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

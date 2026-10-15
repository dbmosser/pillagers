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

# EMPTY GUN KEYS SHOW A GHOST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function beltGroupOf(i){
'@ @'
// v27.xx (gunghost), HIS ORDER (2026-10-14): "the guns that player isn't carrying on the bar at the bottom should be translucent and then they fill in opaque (as-is) once
  // player has that gun". A GUN KEY WITH NO GUN SHOWS A GHOST: the base model of the class that key belongs to (gunKeyList: 1 pistol, 2 SMG, 3 rifle, 4 carbine, 5 LMG,
  // 6 shotgun, 7 marksman, 8 sniper, 9 lance; the Scav Pistol shape on 1, the Marksman Rifle on 7), drawn as one flat light grey silhouette at GHOST_A (about 27 percent), with
  // no rarity colour and no magazine bar, under its key number. Once he carries a gun of that class on the key (or drags one onto it for the raid) the key draws opaque exactly as
  // before; a key a gun was dragged off goes back to its ghost. The silhouette is the gun icon the belt already draws, filled flat (source-in), made once per gun and size.
  var GHOST_A=0.27, GHOST_OF={pistol:'pistol',smg:'smg',rifle:'rifle',carbine:'carbine',lmg:'lmg',shotgun:'shotgun',marksman:'dmr',sniper:'sniper',energy:'lance'}, GHOSTSPR={};
  function gunGhost(id,S){
    var e=null, k=id+'|'+Math.round(S), c=GHOSTSPR[k], t, x;
    try{ e=iconSprite(id,S); }catch(_gi){ e=null; }
    if(!e||!e.c) return null;
    if(c&&c.src===e.c) return c;
    t=document.createElement('canvas'); t.width=e.c.width; t.height=e.c.height; x=t.getContext('2d');
    if(!x) return null;
    x.drawImage(e.c,0,0); x.globalCompositeOperation='source-in'; x.fillStyle='#c9d3dc'; x.fillRect(0,0,t.width,t.height);
    c={c:t,s:e.s,src:e.c}; GHOSTSPR[k]=c;
    return c;
  }
  function gunGhostDraw(q,cx,cy,bw){
    var cl=gunKeyList()[q], id=GHOST_OF[cl], gh=id?gunGhost(id,bw*0.64):null, oa;
    if(!gh) return false;
    oa=ctx.globalAlpha; ctx.globalAlpha=GHOST_A; ctx.drawImage(gh.c,cx-gh.s/2,cy-gh.s/2,gh.s,gh.s); ctx.globalAlpha=oa;
    return true;
  }
  function beltGroupOf(i){
'@

SubRx @'
      else if(S.kind==='gun'){
        ctx.fillRect(cx2-bw*0.28,cy2-bw*0.05,bw*0.46,bw*0.11);
'@ @'
      else if(S.kind==='gun'&&S.vacant&&q<GUNKEYS&&gunGhostDraw(q,cx2,cy2,bw)){ /* v27.xx (gunghost): the ghost of the class this key is for */ }
      else if(S.kind==='gun'){
        ctx.fillRect(cx2-bw*0.28,cy2-bw*0.05,bw*0.46,bw*0.11);
'@

SubRx @'
var VER='27.21';
'@ @'
var VER='27.22';
'@

$pat = "(?m)^  now:'v27\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.22: Gun keys with no gun on them now show a faint ghost of their gun, and fill in once you carry that gun. Check 27.22 fails on v27.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

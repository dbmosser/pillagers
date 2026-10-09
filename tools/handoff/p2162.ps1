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

# A SHOT PILLAGER RETURNS FIRE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
else if(en.kind!=='snitch'){ if(en.kind!=='peddler'&&en.kind!=='stray'){ en.alert=2.6; en.state='chase'; en.tx=p.x; en.ty=p.y; } }
'@ @'
else if(en.kind!=='snitch'){ if(en.kind!=='peddler'&&en.kind!=='stray'){ en.alert=2.6; en.state='chase'; en.tx=p.x; en.ty=p.y; returnFire(en,p.x,p.y); } }
'@

SubRx @'
else if(e.kind!=='snitch'){ if(e.kind!=='peddler'&&e.kind!=='stray'){ e.alert=2.6; e.state='chase'; e.tx=sx; e.ty=sy; } }
'@ @'
else if(e.kind!=='snitch'){ if(e.kind!=='peddler'&&e.kind!=='stray'){ e.alert=2.6; e.state='chase'; e.tx=sx; e.ty=sy; returnFire(e,sx,sy); } }
'@

SubRx @'
e.plantT=(Math.hypot(e.x-_rpx,e.y-_rpy)>0.5)
'@ @'
        if(e.retT>0) e.retT-=dt;   // v21.62: the return fire window runs down
e.plantT=(Math.hypot(e.x-_rpx,e.y-_rpy)>0.5)
'@

SubRx @'
        if(e.cd<=0&&sees&&d<e.rng&&e.acqT>=(CFG.raiderReact===undefined?0.34:CFG.raiderReact)){
'@ @'
        // v21.62, HIS NOTE (2026-10-09): "when a pillager bot takes fire they should return fire". A shot pillager turned to chase but
        // fired only once the shooter was in his view cone and he had held him a third of a second, so a shot from the side or the back
        // went unanswered. For 2.5 s after he is hit he fires back whenever the line to his target is clear and in range, after a
        // 0.2 s flinch, even before he has him in his cone.
        var _rtf=!sees&&e.retT>0&&e.retT<=2.3&&d<e.rng&&losClear(e.x,e.y,p.x,p.y,G.vseg);
        if(e.cd<=0&&(sees||_rtf)&&d<e.rng&&(_rtf||e.acqT>=(CFG.raiderReact===undefined?0.34:CFG.raiderReact))){
'@

SubRx @'
function updateEnts(dt){
'@ @'
// v21.62, his note: a hostile pillager hit by a round turns to the shooter and opens a return fire window (see the chase fire test)
function returnFire(e,sx,sy){
  if(!e||e.kind!=='raider'||e.merc||e.friendlyPC||e.downed||e.hp<=0) return false;
  e.retT=2.5; e.face=Math.atan2(sy-e.y,sx-e.x);
  return true;
}
function updateEnts(dt){
'@

SubRx @'
var VER='21.61';
'@ @'
var VER='21.62';
'@

$pat = "(?m)^  now:'v21\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.62: A pillager you shoot now turns and fires back. Check 21.62 fails on v21.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

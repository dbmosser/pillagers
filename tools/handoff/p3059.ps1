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

# AMMO IS THE HERO NUMBER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var EDGEBOX={}, GUNCARD_LAST=null;   // v24.9x (ringbadge): the gun card, pickup rows and co-op kill feed as last drawn, screen pixels
'@ @'
// v28.xx (cw-hudammo), HIS ANSWER Q57 (2026-10-18): "Ammo needs to be prominent. Ideally redesign the whole raid HUD." AMMO IS THE ONE HERO NUMBER OF THE GUN CARD.
// The rounds in the gun are drawn at the big number size (TYPE.num, 44 rendered), the reserve small beside it (TYPE.title, 26), the way Destiny 2 and
// Halo read: one big figure and a quiet one. The big figure is amber when the magazine is a quarter full or less, red when empty; the reserve goes red at none.
function ammoDraw(p,x,y){
  var rs=rsvShow(p), tail=' / '+rs, w, c=UIC.tx_1;
  if(p.ammo===0) c=UIC.danger; else if(p.ammo<=Math.ceil((p.wep.mag||0)*0.25)) c=UIC.warn;
  ctx.font=FS(TYPE.title); ctx.fillStyle=(rs<=0)?UIC.danger:UIC.tx_2; ctx.fillText(tail,x,y);
  w=ctx.measureText(tail).width;
  ctx.font=FS(TYPE.num); ctx.fillStyle=c; ctx.fillText(String(p.ammo),x-w-4,y);
}
var EDGEBOX={}, GUNCARD_LAST=null;   // v24.9x (ringbadge): the gun card, pickup rows and co-op kill feed as last drawn, screen pixels
'@

SubRx @'
    ctx.fillStyle=p.ammo===0?'#ff5a4a':'#cdd6dd';
    ctx.fillText(p.ammo+' / '+rsvShow(p),W-16,by-LH(14));
'@ @'
    ammoDraw(p,W-16,by-LH(14));   // v28.xx (cw-hudammo), his Q57: the rounds are the hero number
'@

SubRx @'
  ctx.fillText(_cornName,W-16,by-LH(34));
'@ @'
  ctx.fillText(_cornName,W-16,by-LH(46));   // v28.xx (cw-hudammo): the name rides higher (was 34) so the big ammo figure has the room
'@

SubRx @'
var VER='30.58';
'@ @'
var VER='30.59';
'@

$pat = "(?m)^  now:'v30\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.59: The gun card shows the rounds in the gun as a big number with the reserve small beside it. Check 30.59 fails on v30.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

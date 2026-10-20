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

# THE EXTRACT INBOUND COUNTDOWN STANDS ON A PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function extBanFont(t){ return hudFS((t>0)?TYPE.huge:TYPE.head); }

'@ @'
function extBanFont(t){ return hudFS((t>0)?TYPE.huge:TYPE.head); }
// v32.xx (cw-extscrim), the critic on screen 37: the big countdown sat on a busy floor with only a thin outline. It stands on one flat HUD plate measured to the words (same panel as every other HUD box).
function extBanPlate(s,x,y,R){
  var w=hudRawW(s)+LH(32)*R, h=LH(50)*R, px=Math.round(x-w/2), py=Math.round(y-LH(38)*R);
  hudPanel(px,py,w,h,0.9,true);
  return {x:px,y:py,w:w,h:h};
}

'@

SubRx @'
    hudText(holding?extractNowLine(_exL,G.shipHold):('EXTRACT '+_exL+' INBOUND  '+Math.ceil(G.beaconT)+'s'),W/2,_exBan);   // v16.30, his word: inbound

'@ @'
    var _exS=holding?extractNowLine(_exL,G.shipHold):('EXTRACT '+_exL+' INBOUND  '+Math.ceil(G.beaconT)+'s');
    if(!holding) extBanPlate(_exS,W/2,_exBan,_exR);   // v32.xx (cw-extscrim)
    hudText(_exS,W/2,_exBan);   // v16.30, his word: inbound

'@

SubRx @'
var VER='32.35';
'@ @'
var VER='32.36';
'@

$pat = "(?m)^  now:'v32\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.36: While extraction is inbound the big countdown line has a flat dark plate behind it. Check 32.36 fails on v32.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# THE HOSTILES CLOSING IN LINE STANDS ON A PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function extBanFont(t){ return hudFS((t>0)?TYPE.huge:TYPE.head); }

'@ @'
function extBanFont(t){ return hudFS((t>0)?TYPE.huge:TYPE.head); }
// v32.xx (cw-hostplate), the critic on screen 37: the red "hostiles closing in" line under the countdown sat loose on the floor with no plate. It stands on the same flat HUD plate as the countdown, measured to its words.
function extRowPlate(s,x,y,R){
  var w=hudRawW(s)+LH(24)*R, h=LH(26)*R, px=Math.round(x-w/2), py=Math.round(y-LH(19)*R);
  hudPanel(px,py,w,h,0.9,true);
  return {x:px,y:py,w:w,h:h};
}

'@

SubRx @'
        hudText(inbound+(inbound===1?' HOSTILE':' HOSTILES')+' CLOSING IN',W/2,_exRow);   // v22.xx (tr8fixa): a caps callout under EXTRACT A INBOUND (INBOUND stays his word for the craft)

'@ @'
        var _exH=inbound+(inbound===1?' HOSTILE':' HOSTILES')+' CLOSING IN';
        extRowPlate(_exH,W/2,_exRow,_exR);   // v32.xx (cw-hostplate)
        hudText(_exH,W/2,_exRow);   // v22.xx (tr8fixa): a caps callout under EXTRACT A INBOUND (INBOUND stays his word for the craft)

'@

SubRx @'
var VER='32.57';
'@ @'
var VER='32.58';
'@

$pat = "(?m)^  now:'v32\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.58: While extraction is inbound the hostiles closing in line has a flat dark plate behind it. Check 32.58 fails on v32.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

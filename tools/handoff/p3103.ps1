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

# FLAT HUD PANELS, SHORTER DEMO CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ g=ctx.createLinearGradient(0,y,0,y+h); g.addColorStop(0,'rgba(24,27,30,'+a+')'); g.addColorStop(1,'rgba(14,16,18,'+a+')'); ctx.fillStyle=g; }catch(_g){ ctx.fillStyle='rgba(17,19,21,'+a+')'; }
'@ @'
  ctx.fillStyle='rgba(17,19,21,'+a+')';   // v28.xx (cw-panelflat), the critic (2026-10-19) and the style guide (Panel P: 'NO gradient'): one flat fill, was a top-to-bottom wash
'@

SubRx @'
  ctx.strokeStyle='rgba(74,82,87,.9)'; ctx.lineWidth=1; ctx.stroke();
'@ @'
  ctx.strokeStyle='rgba(112,122,130,.95)'; ctx.lineWidth=1; ctx.stroke();   // v28.xx (cw-panelflat): the 1px line is lighter so the edge reads (the critic: 'no 1px border')
'@

SubRx @'
var _gtop=trDemo()?LH(76):LH(90), _gh=trDemo()?LH(72):LH(100);
'@ @'
var _gtop=trDemo()?LH(62):LH(90), _gh=trDemo()?LH(58):LH(100);   /* v28.xx (cw-panelflat), the critic (2026-10-19): the demo card had dead space over the name; it is 58 high, the top moves down 14 */
'@

SubRx @'
var VER='31.02';
'@ @'
var VER='31.03';
'@

$pat = "(?m)^  now:'v31\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.03: HUD panels are flat with a clearer 1px edge and the demo gun card is shorter. Check 31.03 fails on v31.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

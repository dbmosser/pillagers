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

# THE HUD PANEL TOGGLE IS A CHEVRON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillText(HOc.c?'[+]':'[-]',bx+bw-pad,ry);
'@ @'
    hudChev(bx+bw-pad,ry,!HOc.c);   // vNN.xx (ui5q2p): a drawn chevron, not [-]
'@

SubRx @'
  ctx.fillText(HOr.c?'[+]':'[-]',PADX-8+LW-LH(6),y0-LH(2));
'@ @'
  hudChev(PADX-8+LW-LH(6),y0-LH(2),!HOr.c);   // vNN.xx (ui5q2p): a drawn chevron, not [-]
'@

SubRx @'
    ctx.fillText('[-]',mx-8+MW-4,my+LH(4));
'@ @'
    hudChev(mx-8+MW-4,my+LH(4),true);   // vNN.xx (ui5q2p): a drawn chevron, not [-]
'@

SubRx @'
function hudPanel(x,y,w,h,a){
'@ @'
// vNN.xx, UI REDESIGN ui5q2p (his #35 and #50, from the AAA judge of the raid HUD shots): THE PANEL TOGGLE IS A CHEVRON. The
// CONDITIONS, CURRENT PILLAGERS and controls panels ended their title row with [-] or [+] in grey text, which read as developer UI.
// The same spot (and the same click target, HUDBOX tg) draws a small chevron now: up while the panel is open, down while folded.
// xr is the right edge and yb the text baseline, as the old fillText had them.
function hudChev(xr,yb,open){
  var s=Math.max(3,LH(4)), cx=xr-s-1, cy=yb-LH(4);
  ctx.save(); ctx.strokeStyle='#a9b4be'; ctx.lineWidth=Math.max(1.5,LH(1.6)); ctx.lineCap='round'; ctx.lineJoin='round';
  ctx.beginPath();
  if(open){ ctx.moveTo(cx-s,cy+s*0.5); ctx.lineTo(cx,cy-s*0.5); ctx.lineTo(cx+s,cy+s*0.5); }
  else { ctx.moveTo(cx-s,cy-s*0.5); ctx.lineTo(cx,cy+s*0.5); ctx.lineTo(cx+s,cy-s*0.5); }
  ctx.stroke(); ctx.restore();
}
function hudPanel(x,y,w,h,a){
'@

SubRx @'
var VER='25.05';
'@ @'
var VER='25.06';
'@

$pat = "(?m)^  now:'v25\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.06: The raid HUD panels fold with a small chevron instead of [-]. Check 25.06 fails on v25.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

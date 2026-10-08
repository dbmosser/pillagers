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

# THE FULL CONTROLS LIST FITS ITS KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var LEGW=LH(412);
  x=Math.max(14,Math.round((W-LEGW)/2));
  hudPanel(x-8,top-6,LEGW,boxH+10,0.84);   // v18.13: the one HUD panel
var cy=top+LH(6), _cx2=x+LH(206), _cy2=top+LH(6);
  ctx.strokeStyle='rgba(127,146,216,.35)'; ctx.lineWidth=1;
  ctx.beginPath(); ctx.moveTo(_cx2-LH(10),top); ctx.lineTo(_cx2-LH(10),top+boxH-LH(6)); ctx.stroke();
'@ @'
  // v19.41, seen on the 4K controls screenshot (2026-10-08): his v12.79 note took the second column (gear rules, sound key) out of
  // this list, but the panel kept its two-column width and the line between the columns, so half of it was empty with a stray
  // divider down the middle. The panel is as wide as the widest line it holds now, still centred, and the divider is gone.
  var _lgW=LH(120), _lgi, _lgj, _lgk;
  ctx.font=FS(TYPE.micro);
  for(_lgi=0;_lgi<LEG.length;_lgi++){
    _lgW=Math.max(_lgW,ctx.measureText(LEG[_lgi][0]).width);
    for(_lgj=0;_lgj<LEG[_lgi][1].length;_lgj++){ _lgk=LEG[_lgi][1][_lgj]; _lgW=Math.max(_lgW,LH(64)+ctx.measureText(_lgk[1]).width,LH(6)+ctx.measureText(padB(_lgk[0])).width); }
  }
var LEGW=Math.round(_lgW+LH(28));
  x=Math.max(14,Math.round((W-LEGW)/2));
  hudPanel(x-8,top-6,LEGW,boxH+10,0.84);   // v18.13: the one HUD panel
var cy=top+LH(6);
'@

SubRx @'
var VER='19.40';
'@ @'
var VER='19.41';
'@

$pat = "(?m)^  now:'v19\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.41: The H controls list is a tidy panel the width of its keys. Check 19.41 fails on v19.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

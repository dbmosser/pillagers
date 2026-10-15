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

# THE BOSS BAR IS ON THE HUD PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.fillStyle='rgba(6,9,13,.72)'; ctx.fillRect(x-4,y-LH(16),w+8,LH(16)+10);
  ctx.fillStyle='#3a0d0d'; ctx.fillRect(x,y,w,6);
  ctx.fillStyle='#ff4a3a'; ctx.fillRect(x,y,w*f,6);
  ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#ffc04a'; ctx.fillText(e.name,W/2,y-LH(4));
'@ @'
  // v27.49 (boss1), HIS RULE (2026-10-14), "all the new features need to be integrated and polished up to a AAA level": THE BOSS BAR IS ON THE
  // HUD PLATE AND SHOWS ITS PHASES. It was a flat dark box with a hand-picked red, the name in amber. It is the one HUD plate now (rail in
  // the danger colour, the track and the fill in it, the name in bone), and THE OVERSEER's bar carries the two thresholds its phases
  // change at (66 and 33 percent, OV_P2 and OV_P3) as ink ticks across the fill, with the phase it is in (PHASE 2, PHASE 3) at the right
  // of the name. The place, the size, the 4K scale and the bottom edge the controller word and the offer line start under are as they were.
  var _bph=(typeof overseerPhaseOf==='function'&&e.name===BOSS_NAME)?overseerPhaseOf(e):0;
  hudPlate(x-4,y-LH(16),w+8,LH(16)+10,UIC.danger,HUDC.plate);
  ctx.fillStyle='rgba(255,255,255,.12)'; ctx.fillRect(x,y,w,6);
  ctx.fillStyle=UIC.danger; ctx.fillRect(x,y,w*f,6);
  if(_bph){ ctx.fillStyle=HUDC.ink; ctx.fillRect(x+w*OV_P2-1,y-1,2,8); ctx.fillRect(x+w*OV_P3-1,y-1,2,8); }
  ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle=HUDC.text; ctx.fillText(e.name,W/2,y-LH(4));
  if(_bph>1){ ctx.textAlign='right'; ctx.fillStyle=HUDC.dim; ctx.fillText('PHASE '+_bph,x+w-LH(4),y-LH(4)); ctx.textAlign='center'; }
'@

SubRx @'
var VER='27.48';
'@ @'
var VER='27.49';
'@

$pat = "(?m)^  now:'v27\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.49: The boss bar is now on the HUD plate and the Overseer bar shows its phases. Check 27.49 fails on v27.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

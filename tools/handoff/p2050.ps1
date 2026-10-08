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

# THE STATION PROMPT SITS ABOVE THE BELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(HB.near){
    var s=HB.near;
    ctx.textAlign='center';
    ctx.font=FS(TYPE.head); ctx.fillStyle=s.c;
    ctx.fillText('['+keyLabel('KeyE','E')+']  '+s.label,W/2,H-58);
    // v10.93, HIS NOTE: this was #8a96a1, which is the dimmest grey in the file.
    ctx.font=FS(TYPE.label); ctx.fillStyle='#b7c2cd';
    ctx.fillText(typeof s.sub==='function'?s.sub():s.sub,W/2,H-42);
'@ @'
  if(HB.near){
    var s=HB.near;
    // v20.50, from the whole-game bug hunt of 2026-10-08 (H39): THE STATION PROMPT SITS ABOVE THE FLOOR BELT. It was drawn at H-58 and
    // H-42 whatever lay below, and the floor belt (on by default) is drawn after it across the bottom of the screen, so [E] and the
    // station's line showed only as scraps between the belt keys at 1080p, 1440p and 4K. The key footer moved above the belt in
    // v18.62 (hubFootY); the prompt now keeps the place above that footer it always had, so it rides up with it, and it grows with
    // the screen as the footer does (hudRes). With the belt off at 1080p nothing moves.
    var _hpR=Math.max(1,(typeof hudRes==='function')?hudRes():1), _hpF=hubFootY();
    ctx.textAlign='center';
    ctx.font=hudFS(TYPE.head); ctx.fillStyle=s.c;
    ctx.fillText('['+keyLabel('KeyE','E')+']  '+s.label,W/2,_hpF-42*_hpR);
    // v10.93, HIS NOTE: this was #8a96a1, which is the dimmest grey in the file.
    ctx.font=hudFS(TYPE.label); ctx.fillStyle='#b7c2cd';
    ctx.fillText(typeof s.sub==='function'?s.sub():s.sub,W/2,_hpF-26*_hpR);
'@

SubRx @'
  ctx.save(); ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#ffc04a';
  ctx.fillText('['+keyLabel('KeyE','E')+'] TAKE '+(it?it.name.toUpperCase():d.k),W/2,H-LH(40));
'@ @'
  // v20.50, from the whole-game bug hunt of 2026-10-08 (H39): AND [E] TAKE SITS ABOVE THE FLOOR BELT. It was drawn at H-LH(40), inside
  // the belt keys that are drawn over it. It keeps the same place above the key footer it had with no belt, so it rides up with the
  // footer, and it grows with the screen as the footer does. With the belt off at 1080p nothing moves.
  var _dpR=Math.max(1,(typeof hudRes==='function')?hudRes():1);
  ctx.save(); ctx.font=hudFS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#ffc04a';
  ctx.fillText('['+keyLabel('KeyE','E')+'] TAKE '+(it?it.name.toUpperCase():d.k),W/2,hubFootY()-(LH(40)-16)*_dpR);
'@

SubRx @'
var VER='20.49';
'@ @'
var VER='20.50';
'@

$pat = "(?m)^  now:'v20\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.50: In the Undercroft the station prompt and [E] TAKE are no longer hidden behind the belt. Check 20.50 fails on v20.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# AT 4K THE HUD STACK DOES NOT OVERLAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillRect(W-16-cw2-8,by-LH(106)-_gGrow,cw2+16,LH(20));
    ctx.fillStyle=ccol; ctx.fillText(clab,W-24,by-LH(92)-_gGrow);
'@ @'
    // v18.49, FROM THE CODE COMB (2026-10-06): THE HIDDEN CHIP SITS ABOVE THE WEAPON PANEL AT EVERY SIZE. The weapon panel (v18.38) grows
    // with the corner's scale, and at 1440p and 4K it was painted over this chip. The chip's bottom is kept above the panel's real top
    // on screen, and the chip is a HUD panel like the rest.
    var _zg=(HUDZ.gear||1)*hudRes()*hudUserZ('gear'), _og=hudOff('gear'), _ptop=H+((by-LH(90))-H)*_zg+(_og.dy||0), _cyb=Math.min(by-LH(86)-_gGrow,_ptop-LH(6));
    if(typeof hudPanel==='function') hudPanel(W-16-cw2-8,_cyb-LH(20),cw2+16,LH(20),0.78); else { ctx.fillRect(W-16-cw2-8,_cyb-LH(20),cw2+16,LH(20)); }
    ctx.fillStyle=ccol; ctx.fillText(clab,W-24,_cyb-LH(6));
'@

SubRx @'
  w=Math.min(520,W*0.4); x=W/2-w/2; y=LH(64);
'@ @'
  w=Math.min(520,W*0.4); x=W/2-w/2; y=Math.round(LH(108)*hudRes());   // v18.49: below the clock, the compass and the extract arrow, scaled with them (was LH(64), inside the stack)
'@

SubRx @'
  y=LH(104);
'@ @'
  y=Math.round(LH(132)*hudRes());   // v18.49: below the boss bar and above the message plate (was LH(104), on the toast)
'@

SubRx @'
var VER='18.48';
'@ @'
var VER='18.49';
'@

$pat = "(?m)^  now:'v18\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.49: At 1440p and 4K the HIDDEN chip, the boss bar and the clock no longer print over each other. Check 18.49 fails on v18.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

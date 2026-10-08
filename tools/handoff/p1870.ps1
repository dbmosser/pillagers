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

# AN EXTRACTION RING LABEL STAYS WHOLE ON SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var zsy=hudDodge(zs.x,zs.y,zwid/2+6,LH(15),0);
    ctx.fillStyle='rgba(6,9,13,.78)';
    ctx.fillRect(zs.x-zwid/2-6,zsy-LH(11),zwid+12,LH(15));
    ctx.fillStyle=za?'#4de3d0':'rgba(168,180,193,.95)';
    ctx.fillText(zlab,zs.x,zsy);
'@ @'
    // v18.70, seen on the 4K raid screenshot (2026-10-07): a ring near the side of the screen had its label run off the edge
    // (EXTRACTION POINT - SOUND THE ALARM TO BEGIN C). The label slides along to stay whole on screen; the ring stays put.
    var zcx=(zwid+24<W)?clamp(zs.x,zwid/2+12,W-zwid/2-12):zs.x;
    var zsy=hudDodge(zcx,zs.y,zwid/2+6,LH(15),0);
    ctx.fillStyle='rgba(6,9,13,.78)';
    ctx.fillRect(zcx-zwid/2-6,zsy-LH(11),zwid+12,LH(15));
    ctx.fillStyle=za?'#4de3d0':'rgba(168,180,193,.95)';
    ctx.fillText(zlab,zcx,zsy);
'@

SubRx @'
var VER='18.69';
'@ @'
var VER='18.70';
'@

$pat = "(?m)^  now:'v18\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.70: Extraction labels near the edge of the screen are no longer cut off. Check 18.70 fails on v18.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

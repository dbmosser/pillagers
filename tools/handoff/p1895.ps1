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

# THE UNDERCROFT FLOOR TEXT GROWS WITH THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;
  ctx.font=FS(TYPE.head); ctx.fillStyle='#ffc04a';
  ctx.fillText('THE UNDERCROFT',16,28);
  ctx.shadowColor='transparent'; ctx.shadowBlur=0;
'@ @'
  // v18.95, seen on the 4K Undercroft screenshot (2026-10-07): the floor's title, stats line and key footer were drawn at their
  // 1080p size at every resolution, specks in the corner at 4K while the station names and the belt grow with the screen. They
  // scale by hudRes too now (exactly 1 at 1080p, so nothing moves there).
  var _hhr=Math.max(1,(typeof hudRes==='function')?hudRes():1);
  ctx.save(); ctx.scale(_hhr,_hhr);
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;
  ctx.font=FS(TYPE.head); ctx.fillStyle='#ffc04a';
  ctx.fillText('THE UNDERCROFT',16,28);
  ctx.shadowColor='transparent'; ctx.shadowBlur=0;
  ctx.restore();
'@

SubRx @'
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;   // v18.62: the halo, for the stats line too
'@ @'
  ctx.save(); ctx.scale(_hhr,_hhr);   // v18.95: the stats line scales with the title
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;   // v18.62: the halo, for the stats line too
'@

SubRx @'
  ctx.shadowColor='transparent'; ctx.shadowBlur=0;   // v18.62: the halo ends with the stats line
'@ @'
  ctx.shadowColor='transparent'; ctx.shadowBlur=0;   // v18.62: the halo ends with the stats line
  ctx.restore();
'@

SubRx @'
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#aab6c2';
'@ @'
  ctx.font=FS(TYPE.micro).replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*Math.max(1,(typeof hudRes==='function')?hudRes():1)).toFixed(1)+'px'; }); ctx.fillStyle='#aab6c2';   // v18.95: the floor key footer grows with the screen
'@

SubRx @'
var VER='18.94';
'@ @'
var VER='18.95';
'@

$pat = "(?m)^  now:'v18\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.95: At 4K the Undercroft title, stats line and key footer are a readable size. Check 18.95 fails on v18.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

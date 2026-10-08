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

# TWO-LINE MAP NOTES NEVER OVERLAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillText('HOT GROUND',hx,hy-hr-5);
    ctx.fillStyle='rgba(255,150,90,.65)';
    ctx.fillText('richer, and busier',hx,hy-hr+7);
'@ @'
    // v19.29, seen on the 4K map screenshot (2026-10-08): the two lines were 12 pixels apart whatever the text size, so where the text
    // is bigger (a big screen, a bigger text setting) the second line printed over the first. They are a line height apart now.
    var _hgf=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11;
    ctx.fillText('HOT GROUND',hx,hy-hr-5);
    ctx.fillStyle='rgba(255,150,90,.65)';
    ctx.fillText('richer, and busier',hx,hy-hr-5+Math.max(12,_hgf*1.15));
'@

SubRx @'
    ctx.fillText('SURVEYED  '+Math.round(f*100)+'%',ox+4,oy+WORLD_H*sc+16);
    ctx.fillStyle='rgba(214,208,190,.45)';
    ctx.fillText('what you walk stays on the map',ox+4,oy+WORLD_H*sc+30);
'@ @'
    // v19.29, seen on the 4K map screenshot (2026-10-08): these two were 14 pixels apart whatever the text size and printed over each
    // other on a big screen. A line height apart now, and lifted together if the second would fall off the bottom of the screen.
    var _svf=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11, _svl=Math.max(14,_svf*1.15), _sv1=oy+WORLD_H*sc+Math.max(16,_svf*1.1);
    if(_sv1+_svl>H-4) _sv1=Math.max(_svf,H-4-_svl);
    ctx.fillText('SURVEYED  '+Math.round(f*100)+'%',ox+4,_sv1);
    ctx.fillStyle='rgba(214,208,190,.45)';
    ctx.fillText('what you walk stays on the map',ox+4,_sv1+_svl);
'@

SubRx @'
var VER='19.28';
'@ @'
var VER='19.29';
'@

$pat = "(?m)^  now:'v19\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.29: The map notes at the bottom and over hot ground read as two clean lines at 4K. Check 19.29 fails on v19.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

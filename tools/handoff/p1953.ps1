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

# THE SURVEYED NOTE STAYS ON THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(_sv1+_svl>H-4) _sv1=Math.max(_svf,H-4-_svl);
    ctx.fillText('SURVEYED  '+Math.round(f*100)+'%',ox+4,_sv1);
    ctx.fillStyle='rgba(214,208,190,.45)';
    ctx.fillText('what you walk stays on the map',ox+4,_sv1+_svl);
'@ @'
    // v19.53, from the review (2026-10-08): lifting the pair to fit (v19.29) pushed SURVEYED into the map frame and cut the bottoms off
    // the second line at 4K and at bigger text sizes. When both lines do not fit under the frame, they sit side by side on one line.
    var _svT='SURVEYED  '+Math.round(f*100)+'%';
    if(_sv1+_svl+_svf*0.25>H){
      _sv1=Math.min(_sv1,H-_svf*0.25-2);
      ctx.fillText(_svT,ox+4,_sv1);
      var _svW=ctx.measureText((typeof TX==='function')?String(TX(_svT)):_svT).width;
      ctx.fillStyle='rgba(214,208,190,.45)';
      ctx.fillText('what you walk stays on the map',ox+4+_svW+_svf*1.2,_sv1);
    } else {
      ctx.fillText(_svT,ox+4,_sv1);
      ctx.fillStyle='rgba(214,208,190,.45)';
      ctx.fillText('what you walk stays on the map',ox+4,_sv1+_svl);
    }
'@

SubRx @'
var VER='19.52';
'@ @'
var VER='19.53';
'@

$pat = "(?m)^  now:'v19\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.53: The SURVEYED note under the sector map is always whole. Check 19.53 fails on v19.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

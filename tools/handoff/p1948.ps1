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

# THE KILL FEED STARTS UNDER CONDITIONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.save(); ctx.scale(_fhr,_fhr); y=Math.round(H*0.46/_fhr); x=(W-LH(16)*_fhr)/_fhr;   // v19.07: below CONDITIONS (was 0.40, which a long contract list reaches)
'@ @'
  // v19.48, from the review (2026-10-08): 46 percent clears a normal CONDITIONS panel, but one grown with its grip, dragged down or
  // long with contracts reached past it, and the feed printed over its rows. The feed starts under the panel whenever the panel is
  // in its column (never lower than three quarters down).
  var _fy0=H*0.46, _fcb=HUDBOX.cond;
  if(_fcb&&_fcb.x<W-LH(16)*_fhr&&_fcb.x+_fcb.w>W-LH(220)*_fhr) _fy0=Math.min(H*0.75,Math.max(_fy0,_fcb.y+_fcb.h+LH(20)*_fhr));
  ctx.save(); ctx.scale(_fhr,_fhr); y=Math.round(_fy0/_fhr); x=(W-LH(16)*_fhr)/_fhr;   // v19.07: below CONDITIONS
'@

SubRx @'
var VER='19.47';
'@ @'
var VER='19.48';
'@

$pat = "(?m)^  now:'v19\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.48: In co-op the kill feed never prints over the CONDITIONS panel. Check 19.48 fails on v19.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

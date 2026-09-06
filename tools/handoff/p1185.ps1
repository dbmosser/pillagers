$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIS NOTE, 2026-09-06 (his 06:26 export, run 3, @327s): "the map should show
# when the extracts are going to close via countdown on each one". It has,
# since v7.60, in TYPE.micro, the smallest face the game has, which is why he
# never saw it. The name is a callout now and the countdown a label, each on
# its own row above the ring.
SubRx @'
      ctx.font=FS(TYPE.micro); ctx.textAlign='center';
      ctx.fillStyle=Z.open?('rgba(77,227,208,'+(0.9*_fl).toFixed(3)+')'):'rgba(154,168,208,.80)';
      ctx.fillText('EXTRACT '+String.fromCharCode(65+_fz),ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-14);
'@ @'
      // v11.85, HIS NOTE: "the map should show when the extracts are going to
      // close via countdown on each one". It did, since v7.60, in the smallest
      // face the game has, so he never saw it. Name as a callout, countdown as
      // a label, each on its own row.
      ctx.font=FS(TYPE.head); ctx.textAlign='center';
      ctx.fillStyle=Z.open?('rgba(77,227,208,'+(0.9*_fl).toFixed(3)+')'):'rgba(154,168,208,.80)';
      ctx.fillText('EXTRACT '+String.fromCharCode(65+_fz),ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(24));
'@
SubRx @'
      ctx.fillText(_zSub,ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-4);
      ctx.textAlign='left';
'@ @'
      ctx.font=FS(TYPE.label);   // v11.85: the countdown, readable
      ctx.fillText(_zSub,ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(6));
      ctx.textAlign='left';
'@

# STAMPS.
SubRx @'
var VER='11.84';
'@ @'
var VER='11.85';
'@
SubRx @'
var WHATSNEW_VER='11.84';
'@ @'
var WHATSNEW_VER='11.85';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE MAP NAMES EACH EXTRACTION AND COUNTS DOWN TO ITS CLOSE in a size you can read.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.84:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.84 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.84:[^']*'",{ param($m) "now:'v11.85: HIS NOTE of 2026-09-06, the map should count down to each extraction closing. It did since v7.60 in TYPE.micro, the smallest face in the game, so he never saw it; the name is drawn in TYPE.head and the countdown in TYPE.label, each on its own row above the ring. Check 11.85 records every fillText the map overlay makes and requires the EXTRACT names at 18px or more and their countdown lines at 15px or more, with at least one of each drawn; fails on v11.84 at 13px.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

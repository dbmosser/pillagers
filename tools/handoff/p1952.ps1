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

# MAP LABEL BOXES FOLLOW HIS WORDING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var t=String(s), fm=(/([\d.]+)px/).exec(String(ctx.font)), fp=fm?parseFloat(fm[1]):12;
    if(t==='SECTOR MAP') hdrY=y;
    Q.push({s:s,x:x,y:y,font:ctx.font,fs:ctx.fillStyle,ta:ctx.textAlign,tb:ctx.textBaseline,ga:ctx.globalAlpha,m:ctx.getTransform(),fp:fp,w:CanvasRenderingContext2D.prototype.measureText.call(ctx,t).width});
'@ @'
    var t=String(s), fm=(/([\d.]+)px/).exec(String(ctx.font)), fp=fm?parseFloat(fm[1]):12;
    if(t==='SECTOR MAP') hdrY=y;
    // v19.52, from the review (2026-10-08): the box is measured on the words that will be drawn, his edit (TX) included, so a longer
    // wording does not overlap a neighbour the placer thought was clear, and a line he blanked takes no room at all.
    var td=(typeof TX==='function')?String(TX(t)):t;
    if(!td.trim()) return;
    Q.push({s:s,x:x,y:y,font:ctx.font,fs:ctx.fillStyle,ta:ctx.textAlign,tb:ctx.textBaseline,ga:ctx.globalAlpha,m:ctx.getTransform(),fp:fp,w:CanvasRenderingContext2D.prototype.measureText.call(ctx,td).width});
'@

SubRx @'
var VER='19.51';
'@ @'
var VER='19.52';
'@

$pat = "(?m)^  now:'v19\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.52: Map labels make room for your own wording. Check 19.52 fails on v19.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# TEXT PLATES FIT THE WORDS ON THEM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var proto=CanvasRenderingContext2D.prototype, _ft=proto.fillText;
    if(proto.__txWrapped) return;
    proto.__txWrapped=1;
'@ @'
    var proto=CanvasRenderingContext2D.prototype, _ft=proto.fillText, _mt=proto.measureText;
    if(proto.__txWrapped) return;
    proto.__txWrapped=1;
    // v21.81, the raid text rewrite (R02): PLATES FIT THE WORDS THAT ARE DRAWN. Only fillText came through this door, so every
    // plate, badge and box sized with measureText was sized on the ORIGINAL wording while the screen drew his (P.txt or a
    // baked TXSHIP line). A longer rewording ran off its plate, a shorter one sat in an empty box. measureText now measures
    // TX(t), the same string fillText will draw. The recorder below measures through the raw one, as t is already translated.
    proto.measureText=function(t){ return _mt.call(this,(typeof t==='string'&&t.length)?TX(t):t); };
'@

SubRx @'
var w=0; try{ w=this.measureText(t).width; }catch(e2){}
'@ @'
var w=0; try{ w=_mt.call(this,t).width; }catch(e2){}
'@

SubRx @'
var VER='21.80';
'@ @'
var VER='21.81';
'@

$pat = "(?m)^  now:'v21\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.81: Text plates and boxes are sized on the words actually drawn, so reworded lines fit their plates. Check 21.81 fails on v21.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# THE CONTROLS LIST STEPS ABOVE THE ITEM IN HAND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    } else HUDZ.legend=LEGZ0;
    var _legUB=(typeof _legAnchorY==='number'&&_legAnchorY>0)?_legAnchorY:_legTarget;
'@ @'
    } else HUDZ.legend=LEGZ0;
    // v33.xx (cw-handclear), the o-02 alarm (10-20): "the controls card overlaps the top of the bandage-in-hand panel". While an item is in
    // hand and the compact list (where it stood last frame, with his drag) reaches over the panel's columns, its bottom stands on the
    // panel's top edge instead of the vitals, so both stay whole; it drops back onto the vitals when the item is put away.
    if(G.legendOn===1&&_legBase&&typeof handPlateBox==='function'){
      var _hpb=handPlateBox(), _hpo=hudOff('legend'), _hpx=_legBase.x+(_hpo.dx||0);
      if(_hpb&&_hpx<_hpb.x+_hpb.w&&_hpx+_legBase.w>_hpb.x) _legTarget=Math.min(_legTarget,_hpb.y-LH(8)-(_hpo.dy||0));
    }
    var _legUB=(typeof _legAnchorY==='number'&&_legAnchorY>0)?_legAnchorY:_legTarget;
'@

SubRx @'
var VER='33.14';
'@ @'
var VER='33.15';
'@

$pat = "(?m)^  now:'v33\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.15: While an item is in hand the controls list stands just above its panel, so both are whole; it drops back when the item is put away. Check 33.15 fails on v33.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

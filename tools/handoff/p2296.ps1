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

# WORLD TEXT DRAWS OVER THE DARK AND FOG (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(NET.on) netUpTags();   // v15.79: the party names over their heads, beside the pillager nameplates
  // nameplates over anything you can currently see
'@ @'
  // v22.xx, the raid text rewrite (R45): WORLD TEXT DRAWS OVER THE DARK AND THE FOG. HIS ORDER (2026-10-09): the raid text reads like a
  // shooter HUD, where a name or a number over the world is always readable. The party tags, the nameplates, the damage numbers and
  // the floating labels (loot found, targets down, WEAK SPOT) were drawn here in the world pass, under the darkness sheet and the fog
  // of war sheet, so by night every one of them was laid over twice (about 0.30, then up to 0.60 more) and a loot name or a damage
  // number at the edge of the light was a smudge. The two passes are kept here as they were and drawn after both sheets, in the same
  // world transform (_wtA and _wtB, called before the weather). Only the order changes: what is drawn, where, and the canSee gate on
  // the nameplates are the same, and no pass is added.
  var _wtA=function(){
  if(NET.on) netUpTags();   // v15.79: the party names over their heads, beside the pillager nameplates
  // nameplates over anything you can currently see
'@

SubRx @'
      wc.fillStyle=hostile?'#ff5a4a':'#ffc04a'; wc.fillRect(ne.x-tw/2-4,ne.y-lift+5,(tw+8)*fw,3);
    }
  }
  // THE SEAL, in the world. A slab with a progress band cut into it.
'@ @'
      wc.fillStyle=hostile?'#ff5a4a':'#ffc04a'; wc.fillRect(ne.x-tw/2-4,ne.y-lift+5,(tw+8)*fw,3);
    }
  }
  };
  // THE SEAL, in the world. A slab with a progress band cut into it.
'@

SubRx @'
  drawDmgNums();
  // floating labels: loot found, targets down
'@ @'
  var _wtB=function(){   // v22.xx (R45): drawn after the fog of war sheet, with _wtA
  drawDmgNums();
  // floating labels: loot found, targets down
'@

SubRx @'
    wc.fillText(lb.txt,lb.x-lw/2,lb.y-rise);
    wc.globalAlpha=1;
  }
  wc.textAlign='left';
'@ @'
    wc.fillText(lb.txt,lb.x-lw/2,lb.y-rise);
    wc.globalAlpha=1;
  }
  wc.textAlign='left';
  };
'@

SubRx @'
  // Weather sits ON TOP of the fog, because rain falls between you and the world
'@ @'
  // v22.xx (R45): the world text, over the darkness and the fog of war sheets, in the world transform it was drawn in before
  wc.save(); wc.scale(Z,Z); wc.translate(-ox,-oy);
  try{ if(typeof _wtA==='function') _wtA(); if(typeof _wtB==='function') _wtB(); } finally { wc.globalAlpha=1; wc.textAlign='left'; wc.restore(); }
  // Weather sits ON TOP of the fog, because rain falls between you and the world
'@

SubRx @'
var VER='22.95';
'@ @'
var VER='22.96';
'@

$pat = "(?m)^  now:'v22\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.96: Loot names, damage numbers and nameplates now draw over the night darkness and the fog, so they stay readable. Check 22.96 fails on v22.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

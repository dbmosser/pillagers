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

# MACHINE SMOKE READS AT 1080P (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    wc.fillStyle=lv>1?'#1c1917':'#2a2623';
    for(j=0;j<2+lv;j++){
      t=(G.t*.45+j/(2+lv)+ph)%1;
      wc.globalAlpha=(lv>1?.5:.4)*(1-t)*k;
      x=e.x+Math.sin(t*5+ph+j)*3; y=e.y-H-t*18; s=2.5+t*4;
      if(pix) pixFxSquare(wc,x,y,s*2,wc.fillStyle);
      else{ wc.beginPath(); wc.arc(x,y,s,0,6.2832); wc.fill(); }
    }

'@ @'
    // v37.09 (cw-machsmoke), his photo of v34.78 (two bulwarks at 40 and 10 percent, no smoke to be seen): the puffs started at the top of the body and
    // rose 18 units into the name plate, which is drawn later and covers them, and they were small, 0.4 opaque and dark on dark ground. They now start
    // on the upper body, rise 12, grow to 8 units across, sit at 0.7 (0.85 near death) with a light grey rim so they read on dark and light ground.
    for(j=0;j<3+lv;j++){
      t=(G.t*.45+j/(3+lv)+ph)%1;
      x=e.x+Math.sin(t*5+ph+j)*(e.r||14)*.35; y=e.y-H*.7-t*12; s=3.5+t*5;
      wc.globalAlpha=(lv>1?.85:.7)*(1-t*.7)*k*.5;
      if(pix) pixFxSquare(wc,x,y,s*2+3,'#8c8782');
      else{ wc.fillStyle='#8c8782'; wc.beginPath(); wc.arc(x,y,s+1.5,0,6.2832); wc.fill(); }
      wc.globalAlpha=(lv>1?.85:.7)*(1-t*.7)*k;
      wc.fillStyle=lv>1?'#1c1917':'#2a2623';
      if(pix) pixFxSquare(wc,x,y,s*2,wc.fillStyle);
      else{ wc.beginPath(); wc.arc(x,y,s,0,6.2832); wc.fill(); }
    }

'@

SubRx @'
var VER='37.09';
'@ @'
var VER='37.10';
'@

$pat = "(?m)^  now:'v37\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.10: A hurt machine trails clear dark smoke from its body. Check 37.10 fails on v37.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

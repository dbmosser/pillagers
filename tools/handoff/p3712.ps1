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

# MACHINE SMOKE: DARKER AND VENTED TO THE SIDES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
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

'@ @'
    // v37.11 (cw-machsmoke2): the first pass sat on the body as faint squares (his picture of v37.10). Darker and near solid (0.9, 1.0 near death), and the
    // puffs now vent out to both sides as they rise, so most of each puff is over open ground, where the grey rim shows, not over the grey body.
    for(j=0;j<3+lv;j++){
      t=(G.t*.45+j/(3+lv)+ph)%1;
      x=e.x+((j&1)?1:-1)*t*H*.8+Math.sin(t*5+ph+j)*3; y=e.y-H*.75-t*10; s=4+t*5;
      wc.globalAlpha=(lv>1?1:.9)*(1-t*.6)*k*.6;
      if(pix) pixFxSquare(wc,x,y,s*2+4,'#9a948e');
      else{ wc.fillStyle='#9a948e'; wc.beginPath(); wc.arc(x,y,s+2,0,6.2832); wc.fill(); }
      wc.globalAlpha=(lv>1?1:.9)*(1-t*.6)*k;
      wc.fillStyle=lv>1?'#14110f':'#1e1a17';
      if(pix) pixFxSquare(wc,x,y,s*2,wc.fillStyle);
      else{ wc.beginPath(); wc.arc(x,y,s,0,6.2832); wc.fill(); }
    }

'@

SubRx @'
var VER='37.11';
'@ @'
var VER='37.12';
'@

$pat = "(?m)^  now:'v37\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.12: A hurt machine trails dark smoke that shows clearly beside and above its body. Check 37.12 fails on v37.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

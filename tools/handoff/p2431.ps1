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

# ARMOUR IN DARK STEEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var aHi='#a6bacb',aMid='#71879a',aLo='#3f505d';
'@ @'
    // v23.xx (spr18), HIS ORDER (2026-10-12) "make them all look better", answer 20 "a" (gritty and grounded): ARMOUR IN DARK STEEL.
    // The plate was a pale ice blue, the lightest thing on the body, so armour 3 read as a pale barrel with a head on it. It is
    // dark steel now, heavier and darker than the cloth, with olive straps holding it on, and armour 3 wears a steel helmet shell
    // over the crown (a hat still goes on over it). The three tier silhouettes (plate, pauldrons, collar and ridge) are unchanged.
    var aHi='#75818c',aMid='#55606b',aLo='#3a434c';
'@

SubRx @'
    wc.fillStyle=aLo; wc.fillRect(bx2+1,ty-13.2,bw2-2,1.8);
    }
'@ @'
    wc.fillStyle=aLo; wc.fillRect(bx2+1,ty-13.2,bw2-2,1.8);
    }
    // v23.xx (spr18): the olive straps that hold the plate on, over each shoulder
    wc.fillStyle=RIG_OLIVE[1]; wc.fillRect(x+leanX-4.6,ty-20.6,1.6,3.2); wc.fillRect(x+leanX+3.0,ty-20.6,1.6,3.2);
    wc.fillStyle=RIG_OLIVE[2]; wc.fillRect(x+leanX-4.6,ty-20.6,1.6,0.7); wc.fillRect(x+leanX+3.0,ty-20.6,1.6,0.7);
    wc.fillStyle=RIG_BUCKLE; wc.fillRect(x+leanX-4.4,ty-18.4,1.2,0.9); wc.fillRect(x+leanX+3.2,ty-18.4,1.2,0.9);
'@

SubRx @'
  // v10.94, HIS NOTE: THE FACE MARKS GO ON FIRST. They used to be painted after
'@ @'
  // v23.xx (spr18): armour 3 wears a dark steel helmet shell over the crown, with a rim over the brow and olive chin straps. A
  // hat that covers the crown draws instead of it; a suit keeps its own head.
  if((st.bulk||0)>=3&&!OUTF&&(HAT==='none'||HAT==='phones'||HAT==='mask')){
    wc.fillStyle=INK; rrF(hx2-8.7,ty-40.6,17.4,7.6,4);
    wc.fillStyle='#55606b'; rrF(hx2-8.1,ty-40.0,16.2,6.5,3.4);
    wc.fillStyle='#75818c'; rrF(hx2-6.8,ty-39.6,8.6,1.6,0.8);
    wc.fillStyle='#3a434c'; wc.fillRect(hx2-8.1,ty-34.7,16.2,1.2);
    wc.fillStyle=RIG_OLIVE[1]; wc.fillRect(hx2-8.5,ty-33.6,1.3,4.4); wc.fillRect(hx2+7.2,ty-33.6,1.3,4.4);
  }
  // v10.94, HIS NOTE: THE FACE MARKS GO ON FIRST. They used to be painted after
'@

SubRx @'
var VER='24.30';
'@ @'
var VER='24.31';
'@

$pat = "(?m)^  now:'v24\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.31: Body armour is dark steel with olive straps, and the heaviest armour adds a steel helmet. Check 24.31 fails on v24.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

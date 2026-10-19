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

# END CARDS: ARMED ABANDON X INSIDE THE CARD, LOSS IN DANGER COLOUR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox.asking::before{ height:min(calc(var(--sp-1) * 40),calc(100% - var(--sp-4))) !important; }

'@ @'
#root #pausebox.asking::before{ height:min(calc(var(--sp-1) * 40),calc(100% - var(--sp-4))) !important; }
/* v28.xx (cw-endx2), the critic on 59 (3 of 5): "the close x floats about 16px outside the card top-right corner, a stray glyph". The armed card is a fixed 40 units tall (320px) while the x was placed off the normal pause frame height (400px+), so it sat 40px too high. It now sits sp-3 inside the armed card corner. */
#root #pausebox.asking #pausex{ top:calc(50% - var(--sp-1) * 20 + var(--sp-3)); }
'@

SubRx @'
  #root .ocloss b{ display:block; font-family:var(--f-cond); font-size:56px; font-weight:700; line-height:1.05; letter-spacing:0; color:var(--tx-1); }

'@ @'
  #root .ocloss b{ display:block; font-family:var(--f-cond); font-size:56px; font-weight:700; line-height:1.05; letter-spacing:0; color:var(--tx-1); }
  /* v28.xx (cw-endx2), the critic on 60 (2 of 5): "a loss of $1,170 reads as neutral, the eye has no reason to land on it". The money left behind is the danger colour; the amount and the $ are unchanged (Q59). */
  #root .ocloss b{ color:var(--danger); }
  #root #oc_btn{ min-width:240px; }
'@

SubRx @'
var VER='31.79';
'@ @'
var VER='31.80';
'@

$pat = "(?m)^  now:'v31\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.80: The armed abandon X sits inside the card corner. The money left behind is red. The main end card button is 240px wide. Check 31.80 fails on v31.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

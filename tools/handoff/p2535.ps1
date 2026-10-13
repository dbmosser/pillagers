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

# A LOCKED BUTTON SAYS WHY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  b.style.opacity=P.credits<GAMBLE_PRICE?0.45:1;
'@ @'
  // vNN.xx, UI REDESIGN ui5q2f (his #50, from the AAA judge of the Wirt shot): A LOCKED BUTTON SAYS WHY. Out of reach, GAMBLE was
  // a dull grey button and nothing said what it was waiting for. It keeps the solid greyed look (ui5q1m) at full strength, and a
  // red chip on it says how much more it needs (NEED $1,600 MORE). The offer BUY below does the same.
  b.style.opacity=1;
  b.setAttribute('data-need',P.credits<GAMBLE_PRICE?('NEED $'+(GAMBLE_PRICE-P.credits).toLocaleString()+' MORE'):'');
'@

SubRx @'
    lb.disabled=!afford;
'@ @'
    lb.disabled=!afford;
    lb.style.opacity=1; lb.setAttribute('data-need',afford?'':('NEED $'+(WIRT_LOT_PRICE-P.credits).toLocaleString()+' MORE'));   // vNN.xx (ui5q2f): the reason chip
'@

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI REDESIGN ui5q2f (his #50, from the AAA judge of the Wirt shot): A LOCKED BUTTON SAYS WHY. GAMBLE and the offer BUY
     out of reach carry a red chip with what they still need. */
  #root #gamblebtn[data-need]:not([data-need=""])::after, #root #wirtlotbtn[data-need]:not([data-need=""])::after{ content:attr(data-need);
    display:inline-block; margin-left:12px; padding:3px 8px; border:1px solid rgba(255,110,85,.55); border-radius:2px; background:rgba(229,72,47,.12);
    color:#ff8a75; font-family:var(--f-cond); font-size:14px; font-weight:700; letter-spacing:.1em; line-height:1.2; vertical-align:middle; }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
var VER='25.34';
'@ @'
var VER='25.35';
'@

$pat = "(?m)^  now:'v25\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.35: At Wirt a button you cannot afford says how much more it needs. Check 25.35 fails on v25.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

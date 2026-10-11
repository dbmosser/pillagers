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

# THE NEWEST PICKUP ROW ALWAYS SHOWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  fL=hudFS(TYPE.label); fp=msgPx(fL); rh=Math.round(fp*1.75); gap=Math.round(LH(4)*rs); pad=Math.round(LH(8)*rs); isz=Math.round(fp*1.3);
'@ @'
  // v22.xx (tr4fixa): THE NEWEST ROW ALWAYS DRAWS. The ceiling at 62 percent down the screen broke the loop before the first row
  // whenever the gun card left less than one row of room under it: at Settings text size 175 and 200 percent, with the gun card
  // grip at about 1.5x, or with the card dragged up. Nothing was drawn, so BACKPACK FULL (which since v22.59 is only this row), a
  // purchase, the Survivor pay, a gift and every item looted vanished. The ceiling now gives way to at least the newest row, and
  // the stack never starts above the top of the screen. The older rows still stop at the ceiling.
  fL=hudFS(TYPE.label); fp=msgPx(fL); rh=Math.round(fp*1.75); gap=Math.round(LH(4)*rs); pad=Math.round(LH(8)*rs); isz=Math.round(fp*1.3);
  if(base-rh<LH(4)) base=rh+LH(4);   // v22.xx (tr4fixa): never above the top of the screen
  top=Math.min(top,base-rh);   // v22.xx (tr4fixa): the newest row always has room
'@

SubRx @'
var VER='22.59';
'@ @'
var VER='22.60';
'@

$pat = "(?m)^  now:'v22\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.60: The newest pickup row, including BACKPACK FULL, always shows on the right, even at big text sizes or with the gun card enlarged. Check 22.60 fails on v22.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

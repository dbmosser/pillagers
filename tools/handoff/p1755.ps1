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

# IN A PARTY RAID THE BACKPACK SAYS HOW TO OFFER AN ITEM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.fillText((PAD&&PAD.on)?((state==='hub')?'VIEW to close':'A pick up or place   B close'):'B or I to close',x+PW-11,cy); ctx.textAlign='left';   // v16.79, his order: in a raid a pad packs with A and backs out on B; on the floor A does nothing to the backpack and VIEW still closes it
'@ @'
  // v17.55, polish after his pick 4: IN A PARTY RAID THE BACKPACK SAYS HOW TO OFFER AN ITEM. Y on a controller (T on keys) offers
  // the selected item to the nearest teammate, and nothing on screen said so. The line keeps its own keys and gains the offer
  // first; on a narrow panel the offer is said shorter. Solo and in the Undercroft the line is as it was.
  var _bh=(PAD&&PAD.on)?((state==='hub')?'VIEW to close':'A pick up or place   B close'):'B or I to close', _bo;
  if(state!=='hub'&&typeof NET==='object'&&NET&&NET.on){ _bo=((PAD&&PAD.on)?'Y':'T')+' offer to teammate   '; _bh=_bo+_bh; if(ctx.measureText(_bh).width>PW-LH(130)) _bh=((PAD&&PAD.on)?'Y':'T')+' offer   '+_bh.slice(_bo.length); }
  ctx.fillText(_bh,x+PW-11,cy); ctx.textAlign='left';   // v16.79, his order: in a raid a pad packs with A and backs out on B; on the floor A does nothing to the backpack and VIEW still closes it
'@

SubRx @'
var VER='17.54';
'@ @'
var VER='17.55';
'@

$pat = "(?m)^  now:'v17\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.55: In a party raid the backpack header now says Y offer to teammate on a controller (T on keys). Check 17.55 fails on v17.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

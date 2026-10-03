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

# T WITH THE BACKPACK OPEN IS THE TRADE KEY AND NOTHING ELSE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(code==='KeyT'&&G&&!G.over&&!G.paused&&!repeat&&NET.on&&typeof netGiftKey==='function'&&netGiftKey()){}   // v17.44: his pick 4, T offers the selected backpack item or takes an offer
'@ @'
  if(code==='KeyT'&&G&&!G.over&&!G.paused&&!G.trade&&!repeat&&NET.on&&typeof netGiftKey==='function'&&netGiftKey()){}   // v17.44: his pick 4, T offers the selected backpack item or takes an offer; v18.22: not behind the stall
'@

SubRx @'
  else if(code==='KeyT'&&G&&!G.over&&!G.paused&&!repeat&&NET.on&&typeof netAidHold==='function') netAidHold();   // v16.84, his ask: T patches up a teammate in reach with your Bandage or Medkit, the pad Y; T was bound to nothing in a raid (H cycles the legend, X is the ring search)
'@ @'
  else if(code==='KeyT'&&G&&!G.over&&!G.paused&&!G.trade&&!G.bagOpen&&!repeat&&NET.on&&typeof netAidHold==='function') netAidHold();   // v16.84, his ask: T patches up a teammate in reach with your Bandage or Medkit, the pad Y; v18.22: never with the backpack open (that T is the trade key) and never behind the stall
'@

SubRx @'
    if(typeof NET==='object'&&NET&&NET.on) MN.push([(PAD&&PAD.on)?'Y':'T','trade'],[(PAD&&PAD.on)?'LB + RB':'N','ping']);   // v18.17: his note, in a party the trade key is on the short list too
'@ @'
    if(typeof NET==='object'&&NET&&NET.on) MN.push([(PAD&&PAD.on)?'Y':'T','trade / patch up'],[(PAD&&PAD.on)?'LB + RB':'N','ping']);   // v18.17: his note, in a party the trade key is on the short list too; v18.22: and it is the patch-up key with nothing selected
'@

SubRx @'
var VER='18.21';
'@ @'
var VER='18.22';
'@

$pat = "(?m)^  now:'v18\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.22: T (or Y) with the backpack open only trades; it never starts a heal by mistake, and does nothing behind the Peddler stall. Check 18.22 fails on v18.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

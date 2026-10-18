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

# CONTROLLER ASKS HOW MANY ON A STACK MOVE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(z&&typeof z.__grabDrop==='function') z.__grabDrop(held.key,held.from);
  return true;
}
function stashPadGhost(){
'@ @'
  // v28.xx (cw-padqty), quality pass on cw-stashqty (his note: "if I ctrl drag an item to the backpack, i should get a prompt asking me how many I want to transfer"): a pad has no Ctrl, so A on the other side of a stack of two or more never reached that prompt. It opens it now, the same qtyDrag the mouse runs; a single item and every refusal still drop as before.
  if(z&&el!==held.el&&typeof qtyDrag==='function'){ var _pq=false; try{ _pq=qtyDrag(held.key,held.from,z); }catch(_pe2){} if(_pq) return true; }
  if(z&&typeof z.__grabDrop==='function') z.__grabDrop(held.key,held.from);
  return true;
}
function stashPadGhost(){
'@

SubRx @'
var VER='29.26';
'@ @'
var VER='29.27';
'@

$pat = "(?m)^  now:'v29\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.27: On a controller, moving a stack between stash and backpack asks how many. Check 29.27 fails on v29.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

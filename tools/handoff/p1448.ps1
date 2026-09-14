$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  if(G){ G.bagOpen=false; G.drag=null; }
'@ @'
  if(G){ G.bagOpen=false; G.drag=null; }
  // v14.48, floor audit finding 4: AND THE FLOOR BACKPACK'S DRAG. Alt-tabbing mid-drag in the Undercroft backpack left its
  // drag set with the icon stuck to the cursor, and the next click anywhere bound that item to the belt key under it, or
  // deleted the key it came from, and saved it. The drag is dropped with the keys; the backpack stays open.
  if(typeof hubBagG!=='undefined'&&hubBagG) hubBagG.drag=null;
'@
SubRx @'
var VER='14.47';
'@ @'
var VER='14.48';
'@

$pat = "(?m)^  now:'v14\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.48: A FLOOR BACKPACK DRAG DOES NOT SURVIVE ALT-TAB. Leaving the window mid-drag in the Undercroft backpack kept the drag, so the next click anywhere bound or removed a belt key and saved it. Losing focus now drops that drag along with the held keys. Check 14.48 starts a floor backpack drag and releases all keys; it fails on v14.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

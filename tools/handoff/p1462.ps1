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
        if(d.fromHot===HC.i){ dropped=true; break; }
'@ @'
        if(d.fromHot===HC.i){ dropped=true; break; }
        // v14.62, backpack audit finding 7: A DRAG WHOSE ITEM HAS LEFT THE BACKPACK BINDS NOTHING. Press and hold a tile, press Z
        // to drop that stack, then let go over a belt key: the key was bound to an item he no longer carried, and the plan
        // saved with it. A backpack drag binds only while its item is still in the backpack.
        if(d.fromHot===undefined&&G.bag.indexOf(d.key)<0){ dropped=true; break; }
'@
SubRx @'
var VER='14.61';
'@ @'
var VER='14.62';
'@

$pat = "(?m)^  now:'v14\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.62: A DRAG WHOSE ITEM HAS LEFT THE BACKPACK BINDS NOTHING. Holding a backpack tile, dropping its stack with Z and letting go over a belt key bound the key to an item no longer carried and saved the plan. A backpack drag now binds only while its item is still in the backpack. Check 14.62 releases a staged backpack drag over a belt cell with the item carried and after it is gone; it fails on v14.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

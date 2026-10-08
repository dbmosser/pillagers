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

# THE GAMBLER OFFER SHOWS ITS ITEM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  el.innerHTML='<span title="'+escHtml(names.join(', '))+'" style="display:inline-flex">'+iconImgHTML(k,34)+'</span>'+
'@ @'
  // v19.24, seen on the 4K gambler screenshot (2026-10-08): the item on the counter was a 34 pixel picture beside four lines of text, a
  // speck at the edge of the card. It is shown at 72, about the height of those lines, with a soft dark tile behind it.
  el.innerHTML='<span title="'+escHtml(names.join(', '))+'" style="display:inline-flex;align-items:center;justify-content:center;width:84px;height:84px;flex:none;border-radius:8px;background:rgba(0,0,0,.22)">'+iconImgHTML(k,72)+'</span>'+
'@

SubRx @'
var VER='19.23';
'@ @'
var VER='19.24';
'@

$pat = "(?m)^  now:'v19\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.24: The gambler shows the item on offer big enough to see. Check 19.24 fails on v19.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

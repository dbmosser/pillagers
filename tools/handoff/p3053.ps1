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

# DEMO GUN CARD HIDES ITEM VALUE AND BACKPACK HINT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.fillText(G.bag.length+' ITEM'+(G.bag.length===1?'':'S')+'  $'+_cv.toLocaleString(),W-16,by);
'@ @'
  if(!trDemo()) ctx.fillText(G.bag.length+' ITEM'+(G.bag.length===1?'':'S')+'  $'+_cv.toLocaleString(),W-16,by);   // v28.xx (cw-hudDemoCard), his Q56 (2026-10-18): the item-value line is hidden in the demo
'@

SubRx @'
  if(!G.bagOpen){
    ctx.font=FS(TYPE.label); ctx.fillStyle='#aaa498';
'@ @'
  if(!G.bagOpen&&!trDemo()){   // v28.xx (cw-hudDemoCard), his Q56 (2026-10-18): the backpack hint is hidden in the demo
    ctx.font=FS(TYPE.label); ctx.fillStyle='#aaa498';
'@

SubRx @'
var VER='30.52';
'@ @'
var VER='30.53';
'@

$pat = "(?m)^  now:'v30\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.53: The demo gun card no longer shows the item-value line or the backpack hint. Check 30.53 fails on v30.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

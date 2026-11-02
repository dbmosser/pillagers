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

# THE BIRTH CARD: A KIT YOU CANNOT PAY FOR STAYS READABLE, THE PICKED HEIR HAS A BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  '#root #birthmodal .bkit:disabled{opacity:.45}'+
'@ @'
  // v37.xx (cw-m2birth3), critic P1: a kit he cannot pay for stays readable, grey words and a red price, instead of the whole row at opacity .45
  '#root #birthmodal .bkit:disabled{opacity:1!important;color:var(--tx-2)}'+
  '#root #birthmodal .bkit:disabled b:last-child{color:var(--danger)}'+
'@

SubRx @'
  '#root #birthmodal .bhcard.on{border-color:var(--acc);background:var(--ui-raised)}'+
'@ @'
  '#root #birthmodal .bhcard.on{border-color:var(--acc);background:var(--ui-raised);box-shadow:inset 6px 0 0 var(--acc)}'+   // v37.xx (cw-m2birth3), critic P1: the picked heir carries a 6px lime bar
'@

SubRx @'
var VER='37.36';
'@ @'
var VER='37.37';
'@

$pat = "(?m)^  now:'v37\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.37: a kit he cannot pay for keeps its words in grey with the price in red at full opacity, still not selectable; the picked heir card has a 6px lime bar on its left edge Check 37.37 fails on v37.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

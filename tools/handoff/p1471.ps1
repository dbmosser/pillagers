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
    if(k==='outfit') continue;   // v10.54: a random look never puts a suit on over what it rolled
'@ @'
    // v14.71, wardrobe audit finding 3: AND IT TAKES A WORN SUIT OFF. The outfit was skipped but not removed, so with a suit on the
    // new hat, hair, beard, clothes and boots were saved and all hidden under it: the button sounded and the figure barely
    // changed. A random look never puts a suit on, and now it takes one off.
    if(k==='outfit'){ P[COSKEY[k]]=COSDEF[k]; continue; }   // v10.54: a random look never puts a suit on over what it rolled
'@
SubRx @'
var VER='14.70';
'@ @'
var VER='14.71';
'@

$pat = "(?m)^  now:'v14\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.71: SURPRISE ME TAKES A WORN SUIT OFF. A random look skipped the suit without removing it, so with a suit on every piece it rolled was saved and hidden under the suit, and the figure barely changed. It now takes the suit off. Check 14.71 presses SURPRISE ME with no suit and with a suit on; it fails on v14.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

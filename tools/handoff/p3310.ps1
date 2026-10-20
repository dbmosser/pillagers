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

# PAD SELECTOR GROUPING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #keysmodal.padlayouts #padlayoutprev,#root #keysmodal.padlayouts #padlayoutnext{font-size:32px;}
'@ @'
  /* v28.xx (cw-cx-padselectorfinish): critic 74: box both arrow targets, centre their glyphs, and put the count after the next arrow so the stepper is symmetric. */
  #root #keysmodal.padlayouts #padlayoutprev,#root #keysmodal.padlayouts #padlayoutnext{display:inline-flex;align-items:center;justify-content:center;flex:0 0 56px;width:56px;height:48px;box-sizing:border-box;padding:0;border:1px solid var(--ui-line-hi);font-size:40px;line-height:1;}
  #root #keysmodal.padlayouts .padlayoutpick .padlayoutcount{order:1;margin-left:8px;font-size:20px;line-height:1.2;}
  #root #keysmodal.padlayouts .padlayoutrow > b{font-size:18px;}
'@

SubRx @'
var VER='33.09';
'@ @'
var VER='33.10';
'@

$pat = "(?m)^  now:'v33\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.10: Boxed arrows flank the layout name evenly, followed by the larger count. Check 33.10 fails on v33.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

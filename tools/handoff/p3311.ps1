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

# PAD SELECTOR CONSISTENT EDGES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #keysmodal.padlayouts #padlayout.padfocus{color:var(--acc);}
'@ @'
  /* v28.xx (cw-cx-padselectorstyle): critic 74: match the idle name/arrow edges; lime belongs to the single focus outline. */
  #root #keysmodal.padlayouts .padlayoutpick button{border-radius:4px;}
  #root #keysmodal.padlayouts #padlayout,#root #keysmodal.padlayouts #padlayout.padfocus{height:48px;box-sizing:border-box;border:1px solid var(--ui-line-hi);color:var(--tx-1);}
  #root #keysmodal.padlayouts .padlayoutrow .padlayoutpick .padlayoutcount{margin-left:0;color:var(--tx-1);}
'@

SubRx @'
var VER='33.10';
'@ @'
var VER='33.11';
'@

$pat = "(?m)^  now:'v33\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.11: All selector buttons share idle edges and height, with neutral name text and a brighter count. Check 33.11 fails on v33.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

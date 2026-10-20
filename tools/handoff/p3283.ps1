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

# PAD CARD CLEARANCES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #keysmodal.padlayouts .padlayoutcount{min-width:56px;padding-right:16px;font:600 16px var(--f-body);color:var(--tx-2);}
'@ @'
  /* v28.xx (cw-cx-padcardgaps): coordinator 10-20: keep the counter clear of the focused layout name ring. */
  #root #keysmodal.padlayouts .padlayoutcount{min-width:56px;margin-left:16px;padding-right:16px;font:600 16px var(--f-body);color:var(--tx-2);}
'@

SubRx @'
  h+=node(12,418,197)+node(14,388,231)+node(15,448,231)+node(13,418,266);
'@ @'
  // v28.xx (cw-cx-padcardgaps): coordinator 10-20: d-right sits above the right arm, clear of the controller lines.
  h+=node(12,418,197)+node(14,388,231)+node(15,476,184)+node(13,418,266);
'@

SubRx @'
var VER='32.82';
'@ @'
var VER='32.83';
'@

$pat = "(?m)^  now:'v32\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.83: The layout counter and d-right label sit clear of the lines around them. Check 32.83 fails on v32.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

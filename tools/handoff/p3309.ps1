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

# PAD LAYOUT SELECTOR CLEARANCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #keysmodal.padlayouts .padlayoutpick{display:flex;gap:0;align-items:center;border:1px solid var(--ui-line-hi);border-radius:4px;}
'@ @'
  /* v28.xx (cw-cx-padselector): o-17: leave room for the focused button growth and one outline, clear of both arrows. */
  #root #keysmodal.padlayouts .padlayoutpick{display:flex;gap:16px;align-items:center;padding:0 8px;border:1px solid transparent;border-radius:4px;flex:none;}
'@

SubRx @'
  #root #keysmodal.padlayouts .padlayoutpick:has(.padfocus){border:2px solid var(--acc);}
  #root #keysmodal.padlayouts .padlayoutpick .padfocus{outline:0!important;}
'@ @'
  /* v28.xx (cw-cx-padselector): one local outline for keys and pad; the group frame, shadow halo and moving ring must not stack. */
  #root #keysmodal.padlayouts .padlayoutpick button{box-shadow:none!important;}
  #root #keysmodal.padlayouts .padlayoutpick button:is(.padfocus,:focus-visible){outline:3px solid var(--acc)!important;outline-offset:3px!important;box-shadow:none!important;}
  body:has(#keysmodal.padlayouts .padlayoutpick .padfocus) > #uimring{display:none!important;}
'@

SubRx @'
  #root #keysmodal.padlayouts .padlayoutcount{min-width:56px;margin-left:16px;padding-right:16px;font:600 16px var(--f-body);color:var(--tx-2);}
'@ @'
  #root #keysmodal.padlayouts .padlayoutcount{min-width:56px;margin-left:0;padding-right:0;font:600 16px var(--f-body);color:var(--tx-2);}
'@

SubRx @'
var VER='33.08';
'@ @'
var VER='33.09';
'@

$pat = "(?m)^  now:'v33\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.09: Layout arrows, name and count stay in one clear row with one outline on the focused button. Check 33.09 fails on v33.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

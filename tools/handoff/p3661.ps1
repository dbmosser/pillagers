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

# FINAL CAPTURE TITLE AND WAKE PROMPT SPACING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    'body #attract[data-capture-playback="1"] .attname{left:50%;right:auto;top:5%;width:max-content;max-width:90vw;min-width:6em;box-sizing:border-box;transform:translateX(-50%);padding:.28em .7em;background:var(--ui-void);border:1px solid var(--ui-line-hi);border-radius:var(--rad);font-size:clamp(56px,5.185185vh,224px);text-shadow:none;opacity:1}'+
'@ @'
    // v28.xx (cw-cx-capturegaps): 24px title breathing room and a 96px underline at 1080p; both double at 4K.
    'body #attract[data-capture-playback="1"] .attname{left:50%;right:auto;top:5%;width:max-content;max-width:90vw;min-width:6em;box-sizing:border-box;transform:translateX(-50%);padding:clamp(24px,2.222222vh,96px);background:var(--ui-void);border:1px solid var(--ui-line-hi);border-radius:var(--rad);font-size:clamp(56px,5.185185vh,224px);text-shadow:none;opacity:1}'+
    'body #attract[data-capture-playback="1"] .attname::after{width:clamp(96px,8.888889vh,384px);height:clamp(4px,.370370vh,16px)}'+
'@

SubRx @'
    'body #attract[data-capture-playback="1"] .attpress{left:50%;right:auto;bottom:12%;width:max-content;max-width:90vw;box-sizing:border-box;transform:translateX(-50%);padding:.25em .75em;background:var(--ui-void);border:1px solid var(--ui-line-hi);border-radius:var(--rad);font-size:clamp(32px,2.962963vh,128px);text-shadow:none}';
'@ @'
    'body #attract[data-capture-playback="1"] .attpress{left:50%;right:auto;bottom:14%;width:max-content;max-width:90vw;box-sizing:border-box;transform:translateX(-50%);padding:.25em .75em;background:var(--ui-void);border:1px solid var(--ui-line-hi);border-radius:var(--rad);font-size:clamp(32px,2.962963vh,128px);text-shadow:none}';
'@

SubRx @'
var VER='36.60';
'@ @'
var VER='36.61';
'@

$pat = "(?m)^  now:'v36\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.61: Recorded-footage title padding is 24px at 1080p with a 96 by 4px underline, and the wake prompt sits 14 percent above the bottom. LOCAL: no linked review. Check 36.61 fails on v36.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

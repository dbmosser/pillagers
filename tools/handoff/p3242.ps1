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

# Terms: lead with the bonus (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #termsmodal .plist button{ min-width:104px; min-height:48px; font-size:18px; }
'@ @'
#root #termsmodal .plist button{ min-width:104px; min-height:48px; font-size:18px; }
/* v28.xx (cw-uc-termsbig2) b-31 step 7, critic on 06 (no focal point, intro sentence, 14px lines): intro hidden, bonus 32px amber so the reward reads first, names bright, sign nothing 200x48. */
#root #termsmodal .msub{ display:none !important; }
#root #termsmodal .plist .vl{ font-size:32px; font-weight:800; font-family:var(--f-cond,inherit); min-width:110px; text-align:right; }
#root #termsmodal .plist .nm{ color:#e8e2d4 !important; }
#root #termsmodal .plist .nm div{ color:#aaa498 !important; }
#root #termsmodal #termsclear{ min-width:200px; min-height:48px; font-size:18px; }
'@

SubRx @'
var VER='32.41';
'@ @'
var VER='32.42';
'@

$pat = "(?m)^  now:'v32\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.42: The terms page hides its intro line and shows the bonus big in amber. Check 32.42 fails on v32.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

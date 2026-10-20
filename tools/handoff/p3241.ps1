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

# Terms: bigger rows and short intro (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div class="msub">Sign for worse conditions and Meridian pays better. Every one of these is a real handicap, it applies the moment you deploy, and the bonus is paid only if you walk out. Die under your own terms and you have simply made a bad day worse.</div>
'@ @'
<div class="msub">Sign for worse conditions. Walk out to get paid more.</div>
'@

SubRx @'
#root #termsmodal .plist{ font-size:18px; }   /* v16.91: the game font, as every text box (his v11.09 rule) */
'@ @'
#root #termsmodal .plist{ font-size:18px; }   /* v16.91: the game font, as every text box (his v11.09 rule) */
/* v28.xx (cw-uc-termsbig) b-31 step 7, critic on 06 (small dim list in a big empty card): rows 76px, names 20px, lines 16px, sign buttons 104x48, content 1400px wide. */
#root #termsmodal .msub, #root #termsmodal .plist, #root #termsmodal #termstotal, #root #termsmodal.modal > .ui-foot{ max-width:1400px !important; width:100%; }
#root #termsmodal .plist .row{ min-height:76px; padding:0 20px; }
#root #termsmodal .plist .nm b{ font-size:20px; }
#root #termsmodal .plist .nm div{ font-size:16px !important; }
#root #termsmodal .plist .vl{ font-size:20px; }
#root #termsmodal .plist button{ min-width:104px; min-height:48px; font-size:18px; }
'@

SubRx @'
var VER='32.40';
'@ @'
var VER='32.41';
'@

$pat = "(?m)^  now:'v32\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.41: The terms page has a one line intro, bigger rows and bigger sign buttons. Check 32.41 fails on v32.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

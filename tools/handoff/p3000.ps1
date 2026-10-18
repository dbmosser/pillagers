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

# THE WELCOME PACK IS A CENTRED CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #termsmodal .plist{ flex:0 1 auto; }

'@ @'
  #termsmodal .plist{ flex:0 1 auto; }
  /* v28.xx (cw-welcomecard), the critic on the Welcome pack (02 = 2 of 5): "a full-screen slab with seven rows hugging the left and the buttons 1600px apart". The style guide: a modal is a centred card, 960 wide at most, and never exceeds its content. The welcome pack takes the Terms frame (centred, fitted to what it holds), 960 wide, with its text, list and footer 880 wide. Restyle only. */
  #welcomemodal{ align-items:center; justify-content:center; }
  #welcomemodal::before{ inset:50% auto auto 50%; width:min(960px,calc(100% - 28px)); height:min(var(--cfh,840px),calc(100% - 28px)); transform:translate(-50%,-50%); }
  #welcomemodal .msub, #welcomemodal .plist, #root #welcomemodal > .ui-foot{ max-width:880px; width:100%; }
  #welcomemodal .plist{ flex:0 1 auto; }

'@

SubRx @'
var CARDFIT={termsmodal:600,gamblemodal:620,barmodal:640,partymodal:760};

'@ @'
var CARDFIT={termsmodal:600,gamblemodal:620,barmodal:640,partymodal:760,welcomemodal:840};   // v28.xx (cw-welcomecard): the welcome pack is a fitted card too

'@

SubRx @'
var VER='29.99';
'@ @'
var VER='30.00';
'@

$pat = "(?m)^  now:'v29\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.00: The welcome pack is a centred card. Check 30.00 fails on v29.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

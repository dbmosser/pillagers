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

# TERMS, PARTY, GAMBLE AND BAR FRAMES ARE THE 90 PERCENT CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root .modal.ui-win:not(#settingsmodal):not(#welcomemodal)::before{ inset:5vh 5vw; border-radius:4px; clip-path:none; border-color:var(--ui-line-hi); background:var(--ui-bg); }
'@ @'
#root .modal.ui-win:not(#settingsmodal):not(#welcomemodal)::before{ inset:5vh 5vw; width:auto; height:auto; transform:none; border-radius:4px; clip-path:none; border-color:var(--ui-line-hi); background:var(--ui-bg); }
/* v28.xx (cw-cardbox), b-31 pictures of the terms, party, gamble and bar windows (screens 06, 07, 15, 16): the 90 percent card set only the edges (inset), but those four windows still carried their old fitted-card width, height and centring shift, so the frame was a 686 by 273 grey box in the top left corner of the screen and the content floated in the dark. The old size and shift are cancelled; the frame is the same 90 percent card as every other window. */
'@

SubRx @'
var VER='31.61';
'@ @'
var VER='31.62';
'@

$pat = "(?m)^  now:'v31\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.62: The terms, party, gamble and bar windows sit in the same centred 90 percent card as the shop. Check 31.62 fails on v31.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

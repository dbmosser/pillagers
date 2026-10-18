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

# THE WELCOME PACK FITS ITS CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #welcomemodal .plist{ flex:0 1 auto; }

'@ @'
  #welcomemodal .plist{ flex:0 1 auto; }
  /* v28.xx (cw-welcomefit), the critic on v30.00 (02 = 2 of 5): "the intro paragraph spills out of the card and is struck through by the card's top edge, the footer floats outside". The #root .msub cap beat the card cap, so the intro ran 1170 wide, and seven 80px rows made the content taller than the frame. The intro is 880 wide, the rows are 64px (hint under the name, no inset), so the title, list and footer all sit inside the frame. */
  #root #welcomemodal .msub{ max-width:880px; }
  #welcomelist .row{ padding-top:4px; padding-bottom:4px; min-height:0; }
  #welcomelist .row .hint{ padding-left:0; margin-top:0; }
  #root #welcomemodal > .ui-foot{ margin-top:14px !important; }

'@

SubRx @'
var VER='30.01';
'@ @'
var VER='30.02';
'@

$pat = "(?m)^  now:'v30\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.02: The welcome pack title, list and buttons sit inside the card. Check 30.02 fails on v30.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

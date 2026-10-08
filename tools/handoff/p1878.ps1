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

# TEXT IN THE FRAMED WINDOWS STAYS INSIDE THE FRAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .msub{ font-size:15px; line-height:1.5; color:var(--ash); max-width:1180px; }
'@ @'
  #root .msub{ font-size:15px; line-height:1.5; color:var(--ash); max-width:1180px; }
  #root #termsmodal .msub, #root #partymodal .msub, #root #gamblemodal .msub, #root #barmodal .msub{ max-width:1060px; }   /* v18.78, seen on the 4K screenshots (2026-10-07): the general 1180 cap above came later and beat the 1060 these framed windows set, so on a big screen their text lines ran out to the frame's edge (THE LAST POUR, WIRT THE GAMBLER, the Terms, the Party); inside the frame again */
'@

SubRx @'
var VER='18.77';
'@ @'
var VER='18.78';
'@

$pat = "(?m)^  now:'v18\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.78: In the bar, gambler, Terms and Party windows the text no longer touches the frame on a 4K screen. Check 18.78 fails on v18.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

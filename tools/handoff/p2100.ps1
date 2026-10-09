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

# WIRT LINES UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #gamblemodal .plist{ flex:0 1 auto; }
'@ @'
  #gamblemodal .plist{ flex:0 1 auto; }
  /* v21.00, from the 4K visual pass of 2026-10-08 (V-C6): THE TWO BOXES AT WIRT ARE ONE WIDTH. THE GAMBLE box was only as wide as
     its one line and its button, and the LIMITED TIME OFFER box under it about two and a half times wider: two centred boxes with
     no edge in common. Both now take the same width (760, or the window if that is narrower), so they stack as one column. */
  #gamblemodal #wirtsec_gamble, #gamblemodal #wirtsec_offer{ width:100%; max-width:760px; }
'@

SubRx @'
var VER='20.99';
'@ @'
var VER='21.00';
'@

$pat = "(?m)^  now:'v20\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.00: At Wirt the gamble box and the offer box are now the same width. Check 21.00 fails on v20.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

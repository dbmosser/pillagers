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

# TITLE: CENTRE THE LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #title #titletag{ margin:24px 0 16px; font:700 var(--fs-title)/1.1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); }
'@ @'
#root #title #titletag{ margin:24px auto 16px; text-align:center; font:600 var(--fs-body)/1.1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-2); }   /* v28.xx (cw-title-centre), the critic (2 of 5, P0): "left-aligned at x=435 while everything else is centred on 960; the boldest text under the logo, it competes with the title". Centred (auto margins, 24px above and 16px below), 20px in tx-2 so the logo and 1 player lead. */
'@

SubRx @'
var VER='30.47';
'@ @'
var VER='30.48';
'@

$pat = "(?m)^  now:'v30\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.48: The title line is centred and quieter. Check 30.48 fails on v30.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

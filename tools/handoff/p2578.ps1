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

# CROUCH IS THE QUIET WALK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
else if(surf==='metal') stepR*=1.30;
'@ @'
else if(surf==='metal'&&!crouch) stepR*=1.30;   // v25.xx (crouchquiet): a crouched step is the quiet walk on every dry ground
'@

SubRx @'
else if(surf==='leaf') stepR*=1.20;
'@ @'
else if(surf==='leaf'&&!crouch) stepR*=1.20;
'@

SubRx @'
var VER='25.77';
'@ @'
var VER='25.78';
'@

$pat = "(?m)^  now:'v25\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.78: A crouched step now makes the same small noise ring on metal and undergrowth as on stone. Check 25.78 fails on v25.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

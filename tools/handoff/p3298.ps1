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

# HIDE UNAVAILABLE SERVER CO-OP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      <div class="modelater"><button class="deploy ghost moderow" id="modecoopsrv" data-mode="coopsrv" disabled>2 PLAYER CO-OP (SERVER)</button><span>coming later</span></div>
'@ @'
      <div class="modelater" style="display:none"><button class="deploy ghost moderow" id="modecoopsrv" data-mode="coopsrv" disabled>2 PLAYER CO-OP (SERVER)</button><span>coming later</span></div><!-- v28.xx (cw-cx-hidecoopsrv), his 2.R6 b: "Hide it completely until it works". Keep the row wired; hide its tag too, in every window. -->
'@

SubRx @'
var VER='32.97';
'@ @'
var VER='32.98';
'@

$pat = "(?m)^  now:'v32\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.98: The title hides the server co-op row and tag in every window. Keyboard and pad keep skipping it. Check 32.98 fails on v32.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# THE DEMO CLOCK IS BIGGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var _cfin=(_ct<=CLOCK_RED), _cy=Math.round(y+h*(_cfin?0.88:0.62)),
'@ @'
// v27.xx (clockbig), HIS ANSWER 14 (2026-10-13): "the countdown clock needs to be bigger". The clock under the score was the smallest type on the HUD (13 pixels at
                    // 1080p, 19 in the last minute). It is the head size now (19.5) and the title size, the same as the score, in the last minute (26), and sits a little lower to
                    // make room. DEMO and CAREER draw this one block.
                    var _cfin=(_ct<=CLOCK_RED), _cy=Math.round(y+h*(_cfin?1.14:0.92)),
'@

SubRx @'
ctx.font=_cfin?FSz(TYPE.head,z):fs; ctx.fillStyle=_cfin?'#ff5a4a':'#cdd6dd'; hudText(_cm+':'
'@ @'
ctx.font=_cfin?FSz(TYPE.title,z):FSz(TYPE.head,z); ctx.fillStyle=_cfin?'#ff5a4a':'#cdd6dd'; hudText(_cm+':'
'@

SubRx @'
var VER='27.98';
'@ @'
var VER='27.99';
'@

$pat = "(?m)^  now:'v27\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.99: The raid clock under the score is bigger, and bigger again in the last minute. Check 27.99 fails on v27.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

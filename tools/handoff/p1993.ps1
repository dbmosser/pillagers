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

# THE COLLAPSED CONTROLS HINT NAMES NO KEYBOARD KEY ON A PAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillText('H  controls',14,_hy);
'@ @'
    // v19.93, from the code review of 2026-10-08: no pad button sends H, so on a controller this hint (and H  hide below) named a key
    // the pad player cannot press, as H  full list did before v19.68. On a pad they are left out.
    if(!(PAD&&PAD.on)) ctx.fillText('H  controls',14,_hy);
'@

SubRx @'
  ctx.fillText('H  hide',x,top+boxH-LH(2));
'@ @'
  if(!(PAD&&PAD.on)) ctx.fillText('H  hide',x,top+boxH-LH(2));
'@

SubRx @'
var VER='19.92';
'@ @'
var VER='19.93';
'@

$pat = "(?m)^  now:'v19\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.93: On a controller the controls hints no longer name the H key. Check 19.93 fails on v19.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

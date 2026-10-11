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

# THE BACKPACK CUE FOLLOWS KEY CHANGES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillText(padOn()?padB('VIEW  BACKPACK'):'B / I  BACKPACK',W-16,by-LH(70));   // v13.52: pad B is the dodge roll
'@ @'
    // v22.65, the raid text rewrite (R23): THE BACKPACK CUE FOLLOWS KEY CHANGES. On the keyboard it always said B / I even after
    // CHANGE KEYS moved the backpack; both keys now come from keyLabel, so an unmoved keyboard reads B / I as before.
    ctx.fillText(padOn()?padB('VIEW  BACKPACK'):(keyLabel('KeyB','B')+' / '+keyLabel('KeyI','I')+'  BACKPACK'),W-16,by-LH(70));   // v13.52: pad B is the dodge roll
'@

SubRx @'
var VER='22.64';
'@ @'
var VER='22.65';
'@

$pat = "(?m)^  now:'v22\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.65: The backpack cue under the gun card names the keys as set in CHANGE KEYS. Check 22.65 fails on v22.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

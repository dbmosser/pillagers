$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  var kitN=(P.kit||[]).length;
'@ @'
  // v14.65, ascent audit finding 1: THE LOADOUT QUESTION COUNTS THE PACKING MY LOADOUT WILL TAKE. After TAKE THE FREEBIE KIT at
  // the stash the packing is set aside, so this counted the empty list and said nothing was packed, while MY LOADOUT then
  // restored the set-aside items and ascended with them. It counts the set-aside packing then, and otherwise only the packed
  // entries still in the stash, the way the rest of this path counts them.
  var kitN=(P.freeKit&&P.kitSaved)?((P.kitSaved.kit||[]).length):((typeof stageKitLive==='function')?stageKitLive().length:(P.kit||[]).length);
'@
SubRx @'
var VER='14.64';
'@ @'
var VER='14.65';
'@

$pat = "(?m)^  now:'v14\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.65: THE LOADOUT QUESTION COUNTS WHAT MY LOADOUT WILL TAKE UP. After taking the freebie kit at the stash the packing is set aside, so the question counted nothing packed while MY LOADOUT restored and took the set-aside items. It now counts the set-aside packing, and otherwise the packed items still in the stash. Check 14.65 asks the question with the freebie kit taken over three packed items; it fails on v14.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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
      var IKC=G.intelKeys[i];
      if(IKC.opened) continue;
'@ @'
      var IKC=G.intelKeys[i];
      // v15.55, keys audit finding 3: THE INTEL KEY MARK LEAVES A CONTAINER ONCE ITS KEY IS TAKEN OUT. The mark asked only
      // whether the box was opened, and opened turns true only when the whole search bar fills. The staged pulls hand loot out
      // one item at a time, worst first, and a 600 to 750 key ranks below a Titanium Cell, a better gun or a Black Box, so a safe or
      // locker searched part way gave up its key first and kept its gold KEY for the rest of the raid, with the key already in
      // his backpack and no key left in the box, even after the key was spent at the door. With several locked rooms that sent
      // him back across the map for a second key that was not there: the same wrong mark v15.17 took off restocked boxes,
      // reached by an ordinary search broken off early. A box now keeps its mark only while a key_ item is still in its loot,
      // the same test startRaid used to list it, so a box that held two keys keeps it until both are out. Crates never showed
      // this (their key is always their last item). No player text, no number and no seeded draw moved.
      if(IKC.opened||!(IKC.loot||[]).some(function(_k){ return String(_k).indexOf('key_')===0; })) continue;
'@
SubRx @'
var VER='15.54';
'@ @'
var VER='15.55';
'@

$pat = "(?m)^  now:'v15\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.55: THE INTEL KEY MARK LEAVES A CONTAINER ONCE ITS KEY IS TAKEN OUT. With a Data Core burned, a safe or locker searched part way gave up its key first, since loot comes out worst first, and its gold KEY stayed on the sector map for the rest of the raid with the key already in the backpack. The mark now goes as soon as no key is left inside, and a box still holding its key keeps it. Check 15.55 holds X beside a staged box until the key comes out and draws the map; it fails on v15.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

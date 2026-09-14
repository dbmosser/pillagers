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

# v14.78, first-hour audit findings 2 and 3: HIS VOCABULARY. The retired word for the backpack was still in two raid messages
# and two season reward names shown from the first visit. None is one of his edited lines.
SubRx @'
  if(!g||g.id==='fists'||g.mag===0){ say('Nothing there to bag.'); return false; }
'@ @'
  if(!g||g.id==='fists'||g.mag===0){ say('Nothing there to put in your backpack.'); return false; }   // v14.78: his word
'@
SubRx @'
  if(!ITEMS['gun_'+g.id]){ say(g.name+' has no place in a bag.'); return false; }
'@ @'
  if(!ITEMS['gun_'+g.id]){ say(g.name+' has no place in your backpack.'); return false; }
'@
SubRx @'
label:'BAG OF FRAGS'},
'@ @'
label:'CRATE OF FRAGS'},
'@
SubRx @'
label:'BIGGER BAG OF FRAGS'},
'@ @'
label:'BIGGER CRATE OF FRAGS'},
'@
SubRx @'
var VER='14.77';
'@ @'
var VER='14.78';
'@

$pat = "(?m)^  now:'v14\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.78: HIS VOCABULARY IN THE RAID AND THE REWARDS. The retired word for the backpack was still in two raid messages for putting a gun away from its belt key and in two season reward names. The messages now say your backpack and the rewards are the Crate of Frags and the Bigger Crate of Frags. Check 14.78 reads every reward name and both messages; it fails on v14.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

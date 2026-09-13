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

# THE FIRST SENTENCE EVERY FRIEND READS MADE A PROMISE NOTHING KEEPS.
#
# Found by walking a brand-new save, the way every friend on itch starts. The
# title screen tells a player with no raids: "First time out. The Undercroft will
# walk you through it." Nothing walks anyone through anything. There is no
# tutorial, no first-run sequence and no guidance chain anywhere in the file: a
# search for any of it finds only this sentence. What a new player actually gets is
# the welcome pack, offered once, and the station prompts on the floor.
#
# IT IS NOT HIS WORDING. None of his baked edits keys on it or produces it, so it is
# original copy and it is mine to make true.
#
# THE LINE NOW DESCRIBES WHAT HAPPENS. It asks the same question the game asks
# before it offers the pack, welcomeFresh, so a player who will be offered the pack
# is told to take it, and a player who will not (a restored save with no raids, or
# one who already closed the pack) is not told about a pack that never appears.
#
# NO KEY IS NAMED. A controller player presses a different button on the floor, and
# the station prompt he walks up to already names the right one.
SubRx @'
        : 'First time out. The Undercroft will walk you through it.';
'@ @'
        // v13.27: it promised the Undercroft would walk him through it, and nothing
        // does. This says what actually happens, asking the same question the game
        // asks before it offers the pack.
        : ((typeof welcomeFresh==='function'&&welcomeFresh())
            ? 'First time out. Take the welcome pack, then walk to ENTER RAID.'
            : 'First time out. Walk to ENTER RAID when you are ready.');
'@

SubRx @'
var VER='13.26';
'@ @'
var VER='13.27';
'@

$pat = "(?m)^  now:'v13\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.27: THE FIRST SENTENCE EVERY FRIEND READS MADE A PROMISE NOTHING KEEPS. Found by walking a brand-new save, the way every friend on itch starts: the title screen tells a player with no raids that the Undercroft will walk him through it, and nothing walks anyone through anything. There is no tutorial, no first-run sequence and no guidance chain anywhere in the file; a search for any of it finds only this sentence. What a new player actually gets is the welcome pack, offered once, and the station prompts on the floor. It is not his wording, since none of his baked edits keys on it or produces it, so it is original copy and mine to make true. The line now describes what happens, asking the same question the game asks before it offers the pack, welcomeFresh: a player who will be offered the pack is told to take it and then walk to ENTER RAID, and a player who will not, a restored save with no raids or one who already closed the pack, is only told to walk to ENTER RAID, so nobody is told about a pack that never appears. No key is named, because a controller player presses a different button on the floor and the station prompt he walks up to already names the right one. Checks 11.73 and 10.98 read this element only with a raid logged, the other branch, and are unaffected. Check 13.27 draws the line for a new player who will be offered the pack and for one who will not, requires no walkthrough promise in either and the pack only where it is offered, and fails on v13.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

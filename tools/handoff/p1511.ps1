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
    if(!G.sim){ dropDeadKeys(); saveProfile(); }
    G=null; keys={};
'@ @'
    // v15.11, quit audit finding 9: AN INSTANT QUIT FORGETS THE FREEBIE KIT PACKING. Taking the freebie kit sets his own
    // packing aside in P.kitBeforeFree and saves it, and the only clear is further down, after the raid settles, so this
    // branch returned with the list still saved. The next raid to end badly, with no freebie kit taken, counted that old
    // list against the stash and told him on the card that packed items were waiting there. Every other raid end clears
    // the list; this one now does too.
    if(!G.sim){ P.kitBeforeFree=null; P.hotBeforeFree=null; P.gunBeforeFree=null; dropDeadKeys(); saveProfile(); }
    G=null; keys={};
'@
SubRx @'
          delete P.raidSpliced;
          P.weapons=P.weapons.filter(function(k){ return !!WEAPONS[k]; });
'@ @'
          delete P.raidSpliced;
          // v15.11, quit audit finding 9: AND A LOAD FORGETS IT. No raid is running when a save loads, and a raid that ended by
          // the page going away (a closed tab, F5, a crash) never reached the clear in endRaid, so the saved list outlived the
          // raid and the next death card counted it. It also stuck: commitKit keeps a list that is not empty, so a later
          // freebie kit was counted against the stale packing rather than the one he had just packed.
          P.kitBeforeFree=null; P.hotBeforeFree=null; P.gunBeforeFree=null;
          P.weapons=P.weapons.filter(function(k){ return !!WEAPONS[k]; });
'@
SubRx @'
var VER='15.10';
'@ @'
var VER='15.11';
'@

$pat = "(?m)^  now:'v15\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.11: AN INSTANT QUIT OR A RELOAD FORGETS THE FREEBIE KIT PACKING. Taking the freebie kit sets your own packing aside so a death card can say where it went, and only a raid that settled cleared that list, so after an instant quit or a closed tab a later death with no freebie kit taken still said the items you had packed before it were in your stash. An instant quit and every load now clear the list. Check 15.11 loads a save holding the list, instant-quits a freebie raid, then dies on a raid of your own and reads the card; it fails on v15.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

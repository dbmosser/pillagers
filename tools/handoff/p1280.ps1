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

# HIS NOTE, after a live round: "contracts says 2k of 14k completed. No idea what
# this means, just delete it."
#
# It is the cover-ground contract, and the number is raw world units divided by a
# thousand against a hardcoded fourteen thousand. Nothing else on any screen is
# ever quoted in those units: distances he is shown are in metres, through the
# same metres() the compass and the death card use. So the line was the only
# place in the game speaking a unit he has no way to read, on a panel he checks
# mid raid to see whether he is on track.
#
# He asked for it to go, so it goes. The row is not left blank: the push below is
# guarded so a conduct note with nothing to say prints nothing at all, rather than
# an empty line with a bullet on it.
#
# EVERY OTHER CONDUCT NOTE IS UNTOUCHED, and the contract itself is unchanged: it
# still tracks, still completes and still pays exactly as it did. Only the line
# that described it in units he could not read is gone.
SubRx @'
        else if(CC.ck==='far'){ note=Math.round((T.distance||0)/1000)+'k of 14k covered'; }
'@ @'
        // v12.80, HIS NOTE: gone, at his word. This printed raw world units over
        // a thousand against a hardcoded fourteen thousand, and nothing else in
        // the game is ever quoted that way; every distance he is shown goes
        // through metres(). The contract still tracks, completes and pays; only
        // the line nobody could read has been taken out.
        else if(CC.ck==='far'){ note=''; }
'@

SubRx @'
        _clines.push({v:(lost?'LOST   ':'')+note,vc:lost?'#c0503a':'#7fc4a0'});
'@ @'
        // v12.80: a conduct note with nothing to say prints nothing, instead of
        // an empty row with a bullet on it.
        if(note) _clines.push({v:(lost?'LOST   ':'')+note,vc:lost?'#c0503a':'#7fc4a0'});
'@

# NEW IN.
SubRx @'
  'H IS THE KEY LIST AND NOTHING ELSE. It used to open with a second column of gear rules and a sound colour key beside the keys, taller than the keys themselves, so the tips were setting the size of the panel you opened to read the bindings.',
'@ @'
  'H IS THE KEY LIST AND NOTHING ELSE. It used to open with a second column of gear rules and a sound colour key beside the keys, taller than the keys themselves, so the tips were setting the size of the panel you opened to read the bindings.',
  'THE COVER GROUND CONTRACT STOPS QUOTING A NUMBER YOU CANNOT READ. It said 2k of 14k covered, in raw world units, which nothing else in the game uses. The line is gone at your word; the contract itself still tracks, completes and pays exactly as it did.',
'@

# STAMPS.
SubRx @'
var VER='12.79';
'@ @'
var VER='12.80';
'@
SubRx @'
var WHATSNEW_VER='12.79';
'@ @'
var WHATSNEW_VER='12.80';
'@
$cnt=([regex]::Matches($s,"now:'v12\.79:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.79 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.79:[^']*'",{ param($m) "now:'v12.80: HIS NOTE after a live round, that the contracts panel says 2k of 14k completed, he has no idea what it means, and it should just be deleted. It is the cover-ground contract, and the number is raw world units divided by a thousand against a hardcoded fourteen thousand. Nothing else on any screen is ever quoted in those units: every distance he is shown goes through metres(), the same one the compass and the death card use. So this was the only line in the game speaking a unit he had no way to read, on a panel he checks mid raid to see whether he is on track. He asked for it to go, so it goes, and the row is not left blank: the push is guarded now so a conduct note with nothing to say prints nothing at all rather than an empty line with a bullet on it. Every other conduct note is untouched, and the contract itself is unchanged, still tracking, still completing and still paying exactly as it did; only the line describing it in unreadable units has been taken out. Check 12.80 stages that contract with distance on the clock and requires no line of its own on the panel, with two controls: another conduct contract in the same state still prints its note, so the guard has not silenced the panel, and the contract still completes on the same distance it always did; fails on v12.79.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

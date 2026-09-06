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

# FIRST TEN MINUTES AUDIT, 2026-09-06: every time he goes down the toast says
# "DOWN. F to get back up. You get one per raid.", including the second time,
# when the one self-revive is spent and F answers "Self-revive spent". A
# second hit to zero downs him just the same (the down branch reads only
# hp), so a new player on his second down is sent to a key that refuses him.
SubRx @'
    G.tel.downs++; say('DOWN. F to get back up. You get one per raid.');
'@ @'
    G.tel.downs++;
    // v12.14: THE SECOND DOWN TELLS THE TRUTH. Once the one self-revive is spent
    // F answers Self-revive spent, so a toast that sent him to F was a lie the
    // HUD contradicted in the same frame. He can still crawl for an extraction,
    // or hold SPACE to give up where that is switched on.
    say(p.revived?('DOWN. Your one self-revive is spent. Crawl for an extraction'+(CFG.giveUp===0?'.':', or hold '+keyLabel('Space','SPACE')+' to give up.'))
                 :'DOWN. '+keyLabel('KeyF','F')+' to get back up. You get one per raid.');
'@

# STAMPS.
SubRx @'
var VER='12.13';
'@ @'
var VER='12.14';
'@
SubRx @'
var WHATSNEW_VER='12.13';
'@ @'
var WHATSNEW_VER='12.14';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE SECOND TIME YOU GO DOWN THE GAME SAYS SO: your one self-revive is spent, so crawl for an extraction or hold SPACE to give up.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.13:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.13 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.13:[^']*'",{ param($m) "now:'v12.14: from the 2026-09-06 first-ten-minutes audit, the going-down toast sent him to F on the second down too, when the one self-revive is spent and F refuses. The second down now says the revive is spent and names the crawl and the give-up hold. Check 12.14 downs him with the revive spent and requires no F in the toast and the word spent, then downs him fresh and requires F; fails on v12.13.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

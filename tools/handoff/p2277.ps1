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

# LINES NOBODY CAN SEE GO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    say(p.revived?('DOWN. Your one self-revive is spent. Crawl for an extraction'+(CFG.giveUp===0?'.':', or hold '+keyLabel('Space','SPACE')+' to give up.'))
                 :'DOWN. '+keyLabel('KeyF','F')+' to get back up. You get one per raid.');   // v11.94, HIS NOTE: per raid
'@ @'
    // v22.77, the raid text rewrite (R32): LINES NOBODY CAN SEE GO. The going-down sentence was drawn in the feed under the downed
    // screen, which says the same thing larger in the same frame: DOWN, the bleed bar, and his v11.94 words '[F] SELF-REVIVE, one
    // per raid' (or, with the revive spent, the crawl row and HOLD [SPACE] TO SURRENDER). The sentence is gone; T.downs still counts.
'@

SubRx @'
      say('They have you. Pulling you out.');
      endRaid('extract'); return;
'@ @'
      endRaid('extract'); return;   // v22.77 (R32): no line; the outcome card covers the raid in this same frame
'@

SubRx @'
    say(_rc>0?('Walked out on the job. XP -'+_rc+'.'):'Walked out on the job. No XP to lose.');
'@ @'
    // v22.77 (R32): no line here; endRaid covers the raid screen in this same click, and the outcome card says the fee (G.abandonFee).
'@

SubRx @'
  emoteBubble(p.x,p.y,E.glyph,'#FFF6DC',1.6);
  say(E.say);
'@ @'
  emoteBubble(p.x,p.y,E.glyph,'#FFF6DC',1.6);   // v22.77 (R32): the bubble over him is the emote; no narration line, the result follows below
'@

SubRx @'
var VER='22.76';
'@ @'
var VER='22.77';
'@

$pat = "(?m)^  now:'v22\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.77: Going down, being hauled out, abandoning and emotes no longer say lines that the downed screen, the outcome card or the bubble already show. Check 22.77 fails on v22.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

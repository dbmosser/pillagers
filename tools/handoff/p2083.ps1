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

# PLAYER 2 HEARS THE WEATHER TURN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    say('The weather is turning. '+nw.line);
    sfx('charge',G.player.x,G.player.y);
'@ @'
    say('The weather is turning. '+nw.line);
    sfxHere('charge',G.player.x,G.player.y);   // v20.83 (H62): played here only; player 2 now hears the turn in his own window, not a second time from where the host stands
'@

SubRx @'
  G.wxNext=netWxOf(m.wn); G.wxT=(typeof m.wt==='number'&&isFinite(m.wt))?clamp(m.wt,0,1):0;
'@ @'
  // v20.83, from the whole-game bug hunt of 2026-10-08 (H62): PLAYER 2 IS TOLD THE WEATHER IS TURNING. Only the host window turns
  // the sky, and the line that gives you time to act before the turn is done was said there alone, so this window changed the
  // sky without a word. A host word that starts a new turn now says it here too, once, with the charge sound played here only.
  var _wo=G.wxNext;
  G.wxNext=netWxOf(m.wn); G.wxT=(typeof m.wt==='number'&&isFinite(m.wt))?clamp(m.wt,0,1):0;
  if(G.wxNext&&(!_wo||_wo.id!==G.wxNext.id)&&!(G.wx&&G.wx.id===G.wxNext.id)&&G.player){ say('The weather is turning. '+G.wxNext.line); sfxHere('charge',G.player.x,G.player.y); }
'@

SubRx @'
var VER='20.82';
'@ @'
var VER='20.83';
'@

$pat = "(?m)^  now:'v20\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.83: In co-op, player 2 is now told when the weather is turning, as the host is. Check 20.83 fails on v20.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

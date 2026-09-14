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

# RAID HUD AND MAP SCREEN AUDIT OF 2026-09-15, finding 5: THE REVIVE PROMPT COUNTED THE BLEED CLOCK, BUT HITS FINISH A DOWNED PILLAGER EARLIER.
# A downed pillager has two clocks: sixteen seconds of bleed, and fifty health that drains at the same pace and that any stray round,
# splash or charge also takes. He is finished by whichever runs out first. The prompt printed only the sixteen seconds, so a man who had
# taken 25 of his 50 in crossfire read "[E] REVIVE KITE 16s" and was finished about eight seconds later with the prompt still reading
# about eight, and a man shot to zero vanished with seconds still showing. The prompt now shows the time he actually has left.
SubRx @'
      ctx.fillText('['+keyLabel('KeyE','E')+'] REVIVE '+(G.nearDown.name||'PILLAGER')+
        '  '+Math.max(0,G.nearDown.downT||0).toFixed(0)+'s',ds3.x,ds3.y);
'@ @'
      // v14.12, HUD audit: the time he actually has, the bleed clock or his health at the bleed pace, whichever runs out first.
      var _rvRate=raiderDownHp()/RAIDER_DOWN_T;
      var _rvLeft=Math.min(Math.max(0,G.nearDown.downT||0),(_rvRate>0)?Math.max(0,G.nearDown.hp||0)/_rvRate:1e9);
      ctx.fillText('['+keyLabel('KeyE','E')+'] REVIVE '+(G.nearDown.name||'PILLAGER')+
        '  '+_rvLeft.toFixed(0)+'s',ds3.x,ds3.y);
'@
SubRx @'
var VER='14.11';
'@ @'
var VER='14.12';
'@

$pat = "(?m)^  now:'v14\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.12: THE REVIVE PROMPT SHOWS THE TIME HE ACTUALLY HAS. Raid HUD and map screen audit of 2026-09-15, finding 5: a downed pillager is finished by his sixteen-second bleed clock or his fifty health, which drains at the same pace and which stray fire also takes, whichever runs out first, but the REVIVE prompt printed only the bleed clock, so a man at half health read 16s and was finished about eight seconds later. The prompt now prints the smaller of the two. Check 14.12 traces the prompt for a downed pillager at 25 of 50 health with sixteen seconds of bleed and requires about eight seconds, with a pillager at full health reading sixteen as the control; it fails on v14.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

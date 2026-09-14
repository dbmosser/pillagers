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

# MACHINE AND PILLAGER AI AUDIT OF 2026-09-14, finding 3: A CREW PICK-UP KEPT YOUR KILL CREDIT ON THE
# PILLAGER. Your lethal round sets byPlayer on a pillager and he goes down with it set. When his crewmate
# picks him up, the pick-up restores downed, state, health, alert and goal, but not byPlayer. Your own
# revive clears it (v11.64: his next death is not yours unless you cause it). So a later Howler shell,
# which takes health without writing byPlayer, or a bleed-out after it, credited his death to you: a kill
# on the report and the contract, and a permanent grudge on his identity from the next raid on. The crew
# pick-up clears the flag exactly as your revive does.
SubRx @'
          TG.downed=0; TG.state='loot'; TG.hp=Math.round(TG.maxhp*0.4);
          TG.alert=0; TG.goal=null;
'@ @'
          TG.downed=0; TG.state='loot'; TG.hp=Math.round(TG.maxhp*0.4);
          TG.alert=0; TG.goal=null;
          TG.byPlayer=false;   // v13.98, AI audit: as your own revive does, his next death is not yours unless you cause it
'@
SubRx @'
var VER='13.97';
'@ @'
var VER='13.98';
'@

$pat = "(?m)^  now:'v13\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.98: A CREW PICK-UP CLEARS YOUR KILL CREDIT. Machine and pillager AI audit of 2026-09-14, finding 3: your lethal round sets byPlayer and he goes down with it, and the crew pick-up restored downed, state, health, alert and goal but not byPlayer, which your own revive clears, so a later Howler shell or bleed-out credited his death to you with a kill on the report and contract and a permanent grudge. The crew pick-up now clears it too. Check 13.98 has a crewmate pick up a pillager you downed and requires the credit cleared, with the pick-up itself as the precondition; it fails on v13.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

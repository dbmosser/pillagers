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
              en.byPlayer=en.hp<=0;
'@ @'
              // v15.45, bodies audit finding: A ROUND INTO A PILLAGER YOU DOWNED KEEPS YOUR KILL WHEN HE BLEEDS OUT. This line was
              // byPlayer=hp<=0, so every round of yours that did not kill wrote the kill mark back to false. Your round that downs a
              // pillager marks him, and the down carries that mark through the bleed-out so the death path credits you (both revives
              // clear it for exactly that reason, v11.64 and v13.98). One more round into him on the floor that left him breathing
              // wiped it, and when he bled out there was no kill in the run report, no contract tick, no grudge and no grudge line,
              // where holding fire would have kept all four. Frags, fists, enemy rounds and lightning only ever write the mark on a
              // killing blow. Now a killing round marks him yours, a round into a standing man that does not kill him clears it as
              // before, and a round into a downed man that does not finish him leaves the mark with whoever downed him.
              // No number, no player text and no seeded draw moved.
              if(en.hp<=0) en.byPlayer=true; else if(!en.downed) en.byPlayer=false;
'@
SubRx @'
var VER='15.44';
'@ @'
var VER='15.45';
'@

$pat = "(?m)^  now:'v15\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.45: A ROUND INTO A PILLAGER YOU DOWNED KEEPS YOUR KILL WHEN HE BLEEDS OUT. Any round of yours that did not kill cleared the mark that credits you, so one more round into a pillager you had downed, fired while he was still on the floor, lost the kill, the contract tick and the grudge when he bled out. A round into a downed man that does not finish him now leaves the mark with whoever downed him. Check 15.45 downs three staged pillagers and bleeds them out, one shot again on the floor after your down and one after a down that was not yours; it fails on v15.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

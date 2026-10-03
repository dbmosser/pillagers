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

# A CONTROLLER UNPLUGGED IN A RAID PAUSES AND SAYS SO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
window.addEventListener('gamepaddisconnected',function(){ padRelease(); PAD.on=false; PAD.announced=false; PAD.mx=0; PAD.my=0; PAD.aiming=false; });
'@ @'
// v17.73, AAA CHECK (2026-10-02): A CONTROLLER UNPLUGGED IN A RAID PAUSES AND SAYS SO. The pad let go of its keys and went
// quiet, and a player whose cable came out stood still with no word while the machines came. The pause box opens (in a party
// it is the overlay it always is for one player) and the line names it.
window.addEventListener('gamepaddisconnected',function(){ padRelease(); PAD.on=false; PAD.announced=false; PAD.mx=0; PAD.my=0; PAD.aiming=false;
  if(typeof G!=='undefined'&&G&&!G.over&&!G.sim&&typeof state!=='undefined'&&state==='raid'){ try{ if(!pauseOpen) togglePauseBox(true); }catch(_pd){} try{ say('Controller disconnected. Plug it in, then resume.'); }catch(_pd2){} }
});
'@

SubRx @'
var VER='17.72';
'@ @'
var VER='17.73';
'@

$pat = "(?m)^  now:'v17\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.73: A controller unplugged in a raid now pauses the game and says so. Check 17.73 fails on v17.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

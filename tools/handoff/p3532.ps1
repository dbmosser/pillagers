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

# SUPERHOT OFF EACH SITTING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(!Object.prototype.hasOwnProperty.call(P.gameOpts,'flashRed')) P.gameOpts.flashRed=(P.cfg&&P.cfg.flashRed===1)?1:0;
'@ @'
if(!Object.prototype.hasOwnProperty.call(P.gameOpts,'flashRed')) P.gameOpts.flashRed=(P.cfg&&P.cfg.flashRed===1)?1:0;
// v35.xx (cw-shoff), HIS ORDER (2026-10-27): "superhot mode should be off by default". EVERY SITTING STARTS WITH SUPERHOT OFF, whatever the save says. His
// saves since 10-25 carried it on, so the game opened with it on, and at the party it would have opened on for his guests. The Settings row and the key left
// of 1 still turn it on, for that sitting only: this load (a boot, and a restore, which loads through here) puts it back off. The save key is unchanged, and a
// linked window still takes the host word over this (v16.74). Set only where it was on, so a save that never had it keeps the same shape.
if(P.gameOpts.superhot) P.gameOpts.superhot=0;
if(P.cfg&&typeof P.cfg==='object'&&P.cfg.superhot) P.cfg.superhot=0;
if(P.tuned&&typeof P.tuned==='object'&&P.tuned.superhot) delete P.tuned.superhot;
'@

SubRx @'
  if(sb.tuned) delete sb.tuned.flashRed;
'@ @'
  if(sb.tuned) delete sb.tuned.flashRed;
  sb.gameOpts.superhot=0; if(sb.tuned) delete sb.tuned.superhot;   // v35.xx (cw-shoff), his order of 10-27 "superhot mode should be off by default": the demo starts with it off too
'@

SubRx @'
  CFG.flashRed=1; // v28.xx (cw-cx-flashdefault): the demo setting takes effect in either window at entry.
'@ @'
  CFG.flashRed=1; // v28.xx (cw-cx-flashdefault): the demo setting takes effect in either window at entry.
  if(netShHost()===null) CFG.superhot=0;   // v35.xx (cw-shoff): the demo starts with Superhot off; on a linked window the host word still decides (v16.74). Leaving puts the sitting dial back.
'@

SubRx @'
var VER='35.31';
'@ @'
var VER='35.32';
'@

$pat = "(?m)^  now:'v35\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.32: every sitting starts with superhot off: the settings row and the key left of 1 still turn it on for that sitting, the next load is off again, and the 2 player demo starts with it off Check 35.32 fails on v35.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

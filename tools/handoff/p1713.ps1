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

# THE RAID A SPECTATING HOST KEEPS RUNNING MAKES NO SOUND IN HIS UNDERCROFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(typeof NET==='object'&&NET&&NET.specG&&G!==NET.specG){ var _kg=G; G=NET.specG; try{ return netOnMsg0(peer,data); } finally{ G=_kg; } }
'@ @'
  // v17.13, co-op hunt 2026-09-28: and it makes no sound in his window. The mute (NET.specTick) held only inside netSpecTick, so a
  // word handled here played a teammate hits, pings and beacon call in the host Undercroft. It is held for every word while he keeps
  // the raid, on his run card too, and put back as it was found, so a word handled inside netSpecTick leaves that tick muted.
  if(typeof NET==='object'&&NET&&NET.specG){
    var _kt=NET.specTick; NET.specTick=true;
    try{
      if(G!==NET.specG){ var _kg=G; G=NET.specG; try{ return netOnMsg0(peer,data); } finally{ G=_kg; } }
      return netOnMsg0(peer,data);
    } finally{ NET.specTick=_kt; }
  }
'@

SubRx @'
function blip(type,d,pan){
  if(G&&G.sim) return;
'@ @'
function blip(type,d,pan){
  if(G&&G.sim) return;
  if(typeof NET==='object'&&NET&&NET.specTick) return;   // v17.13, co-op hunt 2026-09-28: the kept raid is silent in the spectating host window here too (a pillager going down, the beacon call)
'@

SubRx @'
var VER='17.12';
'@ @'
var VER='17.13';
'@

$pat = "(?m)^  now:'v17\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.13: Spectate sounds (co-op hunt 2026-09-28): the only mute for the raid a spectating host keeps running was in sfx, and it held only inside netSpecTick. Every word from the party is handled in netOnMsg against that raid with the mute off, so a teammate sound word (his hits, wall clanks, frag booms and the inbound pings) played through sfx in the host Undercroft, measured from where the host body lies, and a teammate beacon call played the beacon blip at full volume. Inside netSpecTick a pillager going down, the long range kill clank and the hire pick up call blip directly and skipped the sfx mute. Now netOnMsg holds NET.specTick for every word while NET.specG is set (whether or not the window is swapped to it) and puts back the value it found, and blip returns early while NET.specTick is set, the same gate sfx has. sfx still queues the sound for the party before its gate. The host own card and menu sounds play outside both paths and are unchanged. Check 17.13 fails on v17.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

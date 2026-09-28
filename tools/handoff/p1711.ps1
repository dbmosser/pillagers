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

# A PILLAGER THE HOST DROPPED WHO BLEEDS OUT AFTER THE HOST LEFT THE RAID NO LONGER CHANGES HIS SAVED RUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        // and this charged a permanent point either way.
        if(!G.sim&&e.byPlayer){
'@ @'
        // and this charged a permanent point either way.
        // v17.11, co-op hunt 2026-09-28: and not once his run is over. A host who left the raid while the party is still up top
        // keeps it running, and a survivor his round dropped there charged his save for a raid he was already out of.
        if(!G.sim&&e.byPlayer&&!(G.player&&G.player.specOut)){
'@

SubRx @'
        // gun is a target raiders will take, and the player was paying for it.
        if(!G.sim&&e.byPlayer){
'@ @'
        // gun is a target raiders will take, and the player was paying for it.
        // v17.11, co-op hunt 2026-09-28: and the same once the host is out of the raid the party still runs.
        if(!G.sim&&e.byPlayer&&!(G.player&&G.player.specOut)){
'@

SubRx @'
      if(e.byPlayer){
'@ @'
      // v17.11, co-op hunt 2026-09-28: not once the host is out. A host who dies, extracts or abandons while the party is still up
      // top keeps the raid running for them, and a man he had dropped who bled out there added a kill to the run row he had already
      // saved, stepped his contracts and wrote a grudge into his save, for a raid he was no longer in. Such a death is credited to nobody.
      if(e.byPlayer&&!(G.player&&G.player.specOut)){
'@

SubRx @'
var VER='17.10';
'@ @'
var VER='17.11';
'@

$pat = "(?m)^  now:'v17\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.11: Kill credit, co-op hunt 2026-09-28: a pillager the host drops keeps the host kill mark through his bleed out, and when the host is out of the raid (spectating while the party is still up top) netSpecTick keeps running updateEnts on the kept raid. When the man bled out there the credit branch raised G.tel.kills, which is the same object as the kills field of the run row already committed to the log, stepped the host contracts and wrote a grudge with saveProfile; a survivor or the Peddler dropped by a host round charged notoriety the same way. The raider credit branch and the survivor and Peddler notoriety branches now also require that the host player is not spectating (specOut), so nothing in the kept raid is credited to a host who has left it. Solo play and a host still in the raid are unchanged. No number and no player text moved. Check 17.11 fails on v17.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# A LISTENER ALWAYS SCREAMS BEFORE IT CHARGES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(e.state==='dormant'){
      e.state='hunt'; e.wakeT=0.9;
'@ @'
    // v22.09, from the whole-game bug hunt of 2026-10-08 (K20): A LISTENER THAT IS NOT ALREADY HUNTING WAKES WITH ITS SCREAM AND ITS
    // BEAT. The extraction call, the siege pull and the hot ground moving put far-off sleeping Listeners in 'investigate', and the
    // wake (the 0.9 s beat, the alarm, the ping and the line) went only to a 'dormant' one, so one of those charged at the first
    // sound with no warning at all. Any state but a hunt now wakes the full way.
    if(e.state!=='hunt'&&e.state!=='chase'){
      e.state='hunt'; e.wakeT=0.9;
'@

SubRx @'
      e.legs+=dt*10;
      if(e.wakeT>0){
'@ @'
      e.legs+=dt*10;
      // v22.09 (K20): IT SLEEPS UNLESS IT IS HUNTING. It has no search: a pull or the hot ground that put it in 'investigate' left it
      // standing awake with a '?' over it for the rest of the raid, never asleep again. Only a hunt, or a round (chase, turned into
      // a hunt below), keeps it up.
      if(e.state!=='hunt'&&e.state!=='chase') e.state='dormant';
      if(e.wakeT>0){
'@

SubRx @'
  for(var c=0;c<Math.min(2,cand.length);c++){
    cand[c].tx=H.x+rnd(-160,160); cand[c].ty=H.y+rnd(-160,160);
'@ @'
  for(var c=0;c<Math.min(2,cand.length);c++){
    // v22.09 (K20): THE HOT GROUND NEVER TAKES A LISTENER. It sleeps until it hears something, so sending it to look only woke it
    // silently, and one that was hunting you was switched off. It keeps its place; the two scatter draws are still taken for it,
    // so the seeded stream does not move.
    if(cand[c].kind==='listener'){ rnd(-160,160); rnd(-160,160); continue; }
    cand[c].tx=H.x+rnd(-160,160); cand[c].ty=H.y+rnd(-160,160);
'@

SubRx @'
var VER='22.08';
'@ @'
var VER='22.09';
'@

$pat = "(?m)^  now:'v22\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.09: A Listener always screams and pauses before it charges, even after you call extraction. Check 22.09 fails on v22.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

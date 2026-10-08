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

# A RESTORE CODE WAITS FOR THE UNDERCROFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  P.merc=null; P.contracts=[]; P.seals={}; P.mapSeen={}; P.discover={}; P.terms=[]; P.notExt=0;
'@ @'
  P.merc=null; P.contracts=[]; P.seals={}; P.mapSeen={}; P.discover={}; P.terms=[]; P.notExt=0;
  // v20.54, from the whole-game bug hunt of 2026-10-08 (H35): AND A RAID THE REPLACED CHARACTER LEFT OPEN. The armoury guns he
  // carried up (raidSpliced) and a hire who died up there (mercOut) are settled by the next load, and the next load is the
  // restored character's, so he was handed the guns and billed the death benefit. They go here; the UNDO copy, written before
  // this, keeps them for the character they belong to.
  delete P.raidSpliced; delete P.mercOut;
'@

SubRx @'
  function shut(){ pend=null; var c=el('resconfirm'); if(c) c.style.display='none'; var w=el('resword'); if(w) w.value=''; }
'@ @'
  function shut(){ pend=null; var c=el('resconfirm'); if(c) c.style.display='none'; var w=el('resword'); if(w) w.value=''; }
  // v20.54, from the whole-game bug hunt of 2026-10-08 (H35): A RESTORE CODE WAITS FOR THE UNDERCROFT. Settings opens in a raid
  // (v16.45), and v16.50 greyed out PICK FILE, UNDO and the tuning console there, but READ CODE and REPLACE stayed live: a code
  // pasted in a raid replaced the save and reloaded the window 400 ms later, which threw the raid away, and the raid's own notes
  // then settled onto the restored character. In a raid, and while the host runs the raid for his party (as _rOff reads it),
  // both buttons now say why and do nothing, and a code read before the raid cannot be applied in it.
  function resInRaid(){ return !!((typeof G!=='undefined'&&G&&!G.over&&!G.sim)||(typeof NET==='object'&&NET&&NET.on&&NET.specG)); }
  function resNotNow(){ var s=el('reswhat'); shut(); if(s){ s.style.color='var(--hazard)'; s.textContent='A restore code reloads the game, which would end this raid. It works once you are back in the Undercroft.'; } }
'@

SubRx @'
    var ta=el('rescode'), o=restoreRead(ta?ta.value:'');
    var say=el('reswhat');
    pend=o;
'@ @'
    var ta=el('rescode'), o=restoreRead(ta?ta.value:'');
    var say=el('reswhat');
    if(resInRaid()){ resNotNow(); return; }   // v20.54 (H35): not in a raid
    pend=o;
'@

SubRx @'
    if(word!=='restore'||!pend) return;
    var o=pend;
'@ @'
    if(word!=='restore'||!pend) return;
    if(resInRaid()){ resNotNow(); return; }   // v20.54 (H35): a code read in the Undercroft is not applied once a raid has started
    var o=pend;
'@

SubRx @'
var VER='20.53';
'@ @'
var VER='20.54';
'@

$pat = "(?m)^  now:'v20\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.54: A restore code can no longer end a raid, and a restored character no longer takes on the guns or hire bill of the old one. Check 20.54 fails on v20.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

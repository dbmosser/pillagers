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

# PARTY EMERGENCIES NEVER WAIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
try{ sayWhenFree((netSeatName(s)||'Your teammate')+' is down. Pick them up.','crit'); padRumble(0.55,420); }catch(_md){}
'@ @'
try{ say('TEAMMATE DOWN','crit',{sub:(netSeatName(s)||'Your teammate')+' needs a revive.',key:'tmdown'+s,icon:'party',hold:(function(gg){ return function(){ return !!(gg&&gg.dn); }; })(g)}); padRumble(0.55,420); }catch(_md){}
'@

SubRx @'
  if(up&&m.dn&&!g.dn&&g.n>1&&
'@ @'
  // v22.35, the raid text rewrite (R11): PARTY EMERGENCIES NEVER WAIT. His order of 2026-10-09 is a shooter HUD, and in one a
  // teammate going down, the host leaving and you taking over the raid are callouts that show at once and stay while they are
  // true. They were sentences through sayWhenFree. TEAMMATE DOWN is now a critical alert with the party glyph and his name in the
  // detail (NAME needs a revive.), held while his downed flag is up (to the 8 s cap of the alert lane), on every window but his:
  // his own downed screen owns his. HOST IS OUT and YOU ARE RUNNING THE RAID are critical alerts too. The rumble stays; no sound
  // is added. The raid seed test on the word is unchanged.
  if(up&&m.dn&&!g.dn&&g.n>1&&
'@

SubRx @'
    try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(ln); }catch(_sw){}
'@ @'
    try{ if(typeof G!=='undefined'&&G&&!G.over) say('HOST IS OUT','crit',{sub:(netSeatName(0)||'The host')+' '+((hw==='killed')?'was killed':hw?hw:'is out')+'. Extract to finish.',icon:'party'}); }catch(_sw){}   // v22.35 (R11): an alert, the name and how in the detail
'@

SubRx @'
  try{ sayWhenFree(NET.status); }catch(_hs){}
'@ @'
  try{ say('YOU ARE RUNNING THE RAID','crit',{sub:(why==='out')?'Your host is out.':'The connection to your host was lost.',icon:'party'}); }catch(_hs){}   // v22.35 (R11): an alert at once
'@

SubRx @'
var VER='22.34';
'@ @'
var VER='22.35';
'@

$pat = "(?m)^  now:'v22\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.35: TEAMMATE DOWN shows at once and holds while he is down; HOST IS OUT and YOU ARE RUNNING THE RAID are alerts too. Check 22.35 fails on v22.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

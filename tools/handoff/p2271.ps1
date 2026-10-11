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

# AUTO-JOG AND TEAMMATE DOWN IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!p.autoJog&&mg>0){ if(!G.sim) say('STOP FIRST','info',{sub:'Then tap ['+keyLabel('CapsLock','CAPS')+'] to auto-jog.'}); }
'@ @'
    // v22.71 (tr5fixb), the review of raid text batch 5: HIS ORDER (2026-10-09), a raid line is a caps headline and only a short
    // caps detail. The two auto-jog details were still sentences, an instruction ending in a full stop. They now read [CAPS] AUTO-JOG
    // and [CAPS] OR MOVE TO CANCEL, the key in brackets from keyLabel as before. AUTO-JOG ON is a sys row, and sys rows are caps only.
    if(!p.autoJog&&mg>0){ if(!G.sim) say('STOP FIRST','info',{sub:'['+keyLabel('CapsLock','CAPS')+'] AUTO-JOG'}); }
'@

SubRx @'
    else { p.autoJog=!p.autoJog; if(!G.sim){ if(p.autoJog) say('AUTO-JOG ON','sys',{sub:'Tap ['+keyLabel('CapsLock','CAPS')+'] or move to stop.'}); else say('AUTO-JOG OFF','sys'); } }
'@ @'
    else { p.autoJog=!p.autoJog; if(!G.sim){ if(p.autoJog) say('AUTO-JOG ON','sys',{sub:'['+keyLabel('CapsLock','CAPS')+'] OR MOVE TO CANCEL'}); else say('AUTO-JOG OFF','sys'); } }   // v22.71 (tr5fixb), caps details
'@

SubRx @'
      ? (pedOpen()?(G.nearPed===ne?(G.pedBlocked?'THE PEDDLER  (search the crate first)':(promptPick(G.player)==='deal'?('THE PEDDLER  ['+keyLabel('KeyE','E')+'] DEAL'):'THE PEDDLER')):'THE PEDDLER'):'THE PEDDLER  [CLOSED]')   // v22.67 (R25): DEAL only when E deals
'@ @'
      ? (pedOpen()?(G.nearPed===ne?(G.pedBlocked?'THE PEDDLER  \u00b7  SEARCH CRATE FIRST':(promptPick(G.player)==='deal'?('THE PEDDLER  ['+keyLabel('KeyE','E')+'] DEAL'):'THE PEDDLER')):'THE PEDDLER'):'THE PEDDLER  [CLOSED]')   // v22.67 (R25): DEAL only when E deals
'@

SubRx @'
  if(up&&m.dn&&!g.dn&&g.n>1&&typeof G!=='undefined'&&G&&!G.over&&!G.sim&&(G.seed>>>0)===((+m.sd)>>>0)){ try{ say('TEAMMATE DOWN','crit',{sub:(netSeatName(s)||'Your teammate')+' needs a revive.',key:'tmdown'+s,icon:'party',hold:(function(gg){ return function(){ return !!(gg&&gg.dn); }; })(g)}); padRumble(0.55,420); }catch(_md){} }
'@ @'
  // v22.71 (tr5fixb), the review of raid text batch 5: the TEAMMATE DOWN detail was a sentence (his name, then needs a revive, with a
  // full stop). It now reads REVIVE and his name in caps, the verb his [E] REVIVE prompt uses at his body. The Peddler plate beside a
  // crate not yet searched reads THE PEDDLER, a middle dot, SEARCH CRATE FIRST, in the caps of every other nameplate.
  if(up&&m.dn&&!g.dn&&g.n>1&&typeof G!=='undefined'&&G&&!G.over&&!G.sim&&(G.seed>>>0)===((+m.sd)>>>0)){ try{ say('TEAMMATE DOWN','crit',{sub:'REVIVE '+String(netSeatName(s)||'your teammate').toUpperCase(),key:'tmdown'+s,icon:'party',hold:(function(gg){ return function(){ return !!(gg&&gg.dn); }; })(g)}); padRumble(0.55,420); }catch(_md){} }
'@

SubRx @'
var VER='22.70';
'@ @'
var VER='22.71';
'@

$pat = "(?m)^  now:'v22\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.71: The auto-jog lines, the TEAMMATE DOWN detail and the Peddler plate now read as short caps callouts. Check 22.71 fails on v22.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# BACKPACK FULL SAYS WHAT TO PRESS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function bagDropHint(){ return padOn()?padB('[Y] drops the selected item.'):('['+keyLabel('KeyZ','Z')+'] drops the selected item.'); }
'@ @'
// v22.xx (tr4fixc): THE BACKPACK FULL DETAIL NAMES BOTH STEPS, AS A CAPS TAG. The detail read [Z] drops the selected item., a
// sentence on a row whose other tags are short caps, and it was not true where it was read: Z (and Y on a controller) drops only
// with the backpack open, and the pickup stack shows only with it shut. It now reads [B] BACKPACK, a middle dot, [Z] DROP on the
// keyboard (keyLabel, so a moved key reads as moved) and [VIEW] BACKPACK, a middle dot, [Y] DROP on a controller (VIEW opens the
// backpack in pollPad; padB names both for a PlayStation pad). With autoloot on it reads the same: autoloot never sheds rare or
// elite, and those can still be dropped by hand.
function bagDropHint(){ return padOn()?padB('[VIEW] BACKPACK  \u00b7  [Y] DROP'):('['+keyLabel('KeyB','B')+'] BACKPACK  \u00b7  ['+keyLabel('KeyZ','Z')+'] DROP'); }
'@

SubRx @'
      say('BACKPACK FULL','pick',{key:'bagfull',c:'danger',sub:P.autoloot?'Nothing left worth dropping.':bagDropHint()});
'@ @'
      say('BACKPACK FULL','pick',{key:'bagfull',c:'danger',sub:bagDropHint()});   // v22.xx (tr4fixc): the shooter voice, autoloot too
'@

SubRx @'
  if((P.credits||0)<st.price){ say('NOT ENOUGH BANKED CREDITS','info',{sub:'Costs '+'$'+st.price.toLocaleString()+'.'+((G.pedCarry||0)>0?(' '+'$'+(G.pedCarry||0).toLocaleString()+' carried is not banked.'):'')}); return; }
'@ @'
  if((P.credits||0)<st.price){ say('NOT ENOUGH BANKED CREDITS','info',{sub:'Costs '+'$'+st.price.toLocaleString()+'.'+((G.pedCarry||0)>0?(' Carrying '+'$'+(G.pedCarry||0).toLocaleString()+'.'):'')}); return; }   // v22.xx (tr4fixc): the shooter voice, the headline says banked
'@

SubRx @'
var VER='22.61';
'@ @'
var VER='22.62';
'@

$pat = "(?m)^  now:'v22\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.62: BACKPACK FULL now says which key opens the backpack and which drops an item, and the stall refusal shows the price and the money you carry. Check 22.62 fails on v22.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

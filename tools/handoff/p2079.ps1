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

# PLAYSTATION BUTTON NAMES EVERYWHERE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      :(PAD&&PAD.on)?'DPAD move, past the ends to the tactical belt   A pick up or place   B close'   // v16.79, his order: D-LEFT no longer drops on a pad
'@ @'
      // v20.79, from the whole-game bug hunt of 2026-10-08 (H49): THE PAD WORDS GO THROUGH padB, so a PlayStation pad reads CROSS and
      // CIRCLE here, as the header of this same panel already did.
      :(PAD&&PAD.on)?padB('DPAD move, past the ends to the tactical belt   A pick up or place   B close')   // v16.79, his order: D-LEFT no longer drops on a pad
'@

SubRx @'
  ctx.fillText((padOn()?(((G.pedSel||0)===0)?'[A]':'   '):'[1]')+'  SELL BACKPACK  ('+n+')',x+14,cy);   // v13.49: the pad marker
'@ @'
  // v20.79, from the whole-game bug hunt of 2026-10-08 (H49): the marker on the chosen row goes through padB, so on a PlayStation pad
  // it reads [CROSS], as the header above it says, not [A].
  ctx.fillText((padOn()?(((G.pedSel||0)===0)?padB('[A]'):'   '):'[1]')+'  SELL BACKPACK  ('+n+')',x+14,cy);   // v13.49: the pad marker
'@

SubRx @'
    ctx.fillText((padOn()?(((G.pedSel||0)===i+1)?'[A]  ':'     ')
'@ @'
    ctx.fillText((padOn()?(((G.pedSel||0)===i+1)?padB('[A]')+'  ':'     ')
'@

SubRx @'
  if(padOn()){ ctx.fillText('L STICK WALK  \u00b7  LS JOG  \u00b7  '+
'@ @'
  // v20.79, from the whole-game bug hunt of 2026-10-08 (H49): the stick words go through padB, so a PlayStation pad reads L3 JOG,
  // the name the raid legend gives the same button, not LS.
  if(padOn()){ ctx.fillText(padB('L STICK WALK  \u00b7  LS JOG  \u00b7  ')+
'@

SubRx @'
          say2((PAD&&PAD.on)?'Pick an item up with A first, then A on this key puts it there.':'Hover an item in the stash and press a number key to put it on your tactical belt.');   // v16.80: a pad player is told the pad way
'@ @'
          // v20.79, from the whole-game bug hunt of 2026-10-08 (H49): through padB, so a PlayStation pad is told CROSS, not A.
          say2((PAD&&PAD.on)?padB('Pick an item up with A first, then A on this key puts it there.'):'Hover an item in the stash and press a number key to put it on your tactical belt.');   // v16.80: a pad player is told the pad way
'@

SubRx @'
  (function(){ var _fb=document.getElementById('floordropbtn'); if(_fb&&!_fb.onclick) _fb.onclick=function(){ say2('Drag an item onto DROP HERE, or pick one up with A and press A here.'); }; })();
'@ @'
  // v20.79, from the whole-game bug hunt of 2026-10-08 (H49): the DROP HERE tip goes through padB, so a PlayStation pad is told CROSS.
  (function(){ var _fb=document.getElementById('floordropbtn'); if(_fb&&!_fb.onclick) _fb.onclick=function(){ say2(padB('Drag an item onto DROP HERE, or pick one up with A and press A here.')); }; })();
'@

SubRx @'
var VER='20.78';
'@ @'
var VER='20.79';
'@

$pat = "(?m)^  now:'v20\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.79: On a PlayStation pad the backpack, the Peddler, the Undercroft footer and the stash tips name the PlayStation buttons. Check 20.79 fails on v20.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

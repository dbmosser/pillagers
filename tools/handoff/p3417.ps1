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

# DEMO EASY QUESTION AFTER MAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ARCADE.easy=0; ARCADE.easyAsked=0; ARCADE.easyAsk={at:Date.now()};
'@ @'
  ARCADE.easy=0; ARCADE.easyAsked=0; ARCADE.easyAsk={at:Date.now(),waitMap:mapFirstOn()?1:0};   // v28.xx (cw-cx-easymapwords): his 2.28 c, each demo player chooses before the run; the clock waits for this window opening map
'@

SubRx @'
  g.mapFirst=0; g.mapFirstMe=0; g.mapFirstWhy=String(why||''); g.mapOpen=false; g.mapCur=null;
'@ @'
  g.mapFirst=0; g.mapFirstMe=0; g.mapFirstWhy=String(why||''); g.mapOpen=false; g.mapCur=null;
  // v28.xx (cw-cx-easymapwords): the want easy mode? question now comes after the opening map.
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.easyAsk&&ARCADE.easyAsk.waitMap){ ARCADE.easyAsk.at=Date.now(); ARCADE.easyAsk.waitMap=0; }
'@

SubRx @'
function easyLive(){ return !!(typeof ARCADE==='object'&&ARCADE&&ARCADE.easyAsk&&G&&!G.over&&!G.sim&&((ARCADE.on&&G.arcade)||(G.carAsk&&!G.arcade))); }   // v28.xx (cw-easycareer): the card also lives in a career raid that asked
'@ @'
function easyLive(){ return !!(typeof ARCADE==='object'&&ARCADE&&ARCADE.easyAsk&&!ARCADE.easyAsk.waitMap&&G&&!G.over&&!G.sim&&((ARCADE.on&&G.arcade)||(G.carAsk&&!G.arcade))); }   // v28.xx (cw-easycareer): the card also lives in a career raid that asked   // v28.xx (cw-cx-easymapwords): the hidden start question takes no answers behind the opening map
'@

SubRx @'
  ctx.font=FS(TYPE.head); ctx.fillStyle='#7fe3d4'; hudText('TOP 10 TONIGHT \u00b7 ENTER INITIALS',cx,y-LH(18));
'@ @'
  ctx.font=FS(TYPE.head); ctx.fillStyle='#7fe3d4'; hudText("tonight's best \u00b7 enter initials",cx,y-LH(18));   // v28.xx (cw-cx-easymapwords): name the board without choosing a row count
'@

SubRx @'
  el=document.createElement('div'); el.className='aoi'; el.textContent=ARCADE.solo?'TOP 10 TONIGHT \u00b7 ENTER INITIALS':('Player '+((n.who|0)===2?2:1)+' \u00b7 enter initials'); c.appendChild(el);   // v28.xx (cw-iniplayer), his Q62: the heading says whose turn it is. v31.xx (cw-inihead): the appendChild sat inside this comment from v30.36 on, so the card was drawn with no heading at all
'@ @'
  el=document.createElement('div'); el.className='aoi'; el.textContent=ARCADE.solo?"tonight's best \u00b7 enter initials":('Player '+((n.who|0)===2?2:1)+' \u00b7 enter initials'); c.appendChild(el);   // v28.xx (cw-iniplayer), his Q62: the heading says whose turn it is. v31.xx (cw-inihead): the appendChild sat inside this comment from v30.36 on, so the card was drawn with no heading at all   // v28.xx (cw-cx-easymapwords): solo uses the same board title; his Q62 player headings stay
'@

SubRx @'
var VER='34.16';
'@ @'
var VER='34.17';
'@

$pat = "(?m)^  now:'v34\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.17: The easy question gets 12 seconds after the opening map closes in each window. The initials card uses the board title. Check 34.17 fails on v34.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

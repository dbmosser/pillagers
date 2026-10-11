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

# FAR-OFF CHATTER STAYS OFF YOUR SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function updateEnts(dt){
'@ @'
// v22.xx, the raid text rewrite (R35): FAR-OFF CHATTER STAYS OFF YOUR SCREEN. HIS ORDER (2026-10-09): the raid text reads like
// Call of Duty, Fortnite or ARC Raiders, and in those the screen tells you what is happening to you, not a running commentary on
// the far side of the map. A pillager calling or riding out a ring across the map, the Survivor reaching a ring, the Peddler
// setting up or someone else killing the Survivor or the Peddler all said a line wherever you were. Those lines now show only
// when it happens within 900 of you or where you can see it (chatNear). A pillager riding out says nothing at all: the Current
// Pillagers board marks him EXTRACTED and the run report still counts him (T.raidersExtracted). Flavour lines (weather, the deer and
// birds, The Peddler, a nod, a drink wearing off) are said as kind chat, the lowest rank, so they never push a line that matters.
function chatNear(x,y){
  var p=G&&G.player;
  if(!p||!(isFinite(x)&&isFinite(y))) return false;
  if(Math.hypot(x-p.x,y-p.y)<900) return true;
  try{ return !!canSee(p.x,p.y,p.face,x,y,G.vseg); }catch(_c){ return false; }
}
function updateEnts(dt){
'@

SubRx @'
          say('SOMEONE SHOT THE SURVIVOR','chat',{sub:'Not on you.'});   // v22.81 (tr6fixc): the caps callout, a chat row as the raid text plan has it
'@ @'
          if(chatNear(e.x,e.y)) say('SOMEONE SHOT THE SURVIVOR','chat',{sub:'Not on you.'});   // v22.81 (tr6fixc): the caps callout, a chat row as the raid text plan has it; v22.xx (R35): only near or in sight
'@

SubRx @'
          say('THE PEDDLER IS DEAD','chat',{sub:'Someone else did that.'});   // v22.81 (tr6fixc): the caps callout, a chat row
'@ @'
          if(chatNear(e.x,e.y)) say('THE PEDDLER IS DEAD','chat',{sub:'Someone else did that.'});   // v22.81 (tr6fixc): the caps callout, a chat row; v22.xx (R35): only near or in sight
'@

SubRx @'
          say('The survivor made it to Extraction '+extLetter(_sz)+'.');
'@ @'
          if(chatNear(_sz.x,_sz.y)) say('The survivor made it to Extraction '+extLetter(_sz)+'.');   // v22.xx (R35): only near or in sight
'@

SubRx @'
            if(!G.sim) say('The Peddler has set up shop here.');
'@ @'
            if(!G.sim&&chatNear(e.x,e.y)) say('The Peddler has set up shop here.','chat');   // v22.xx (R35): only near or in sight
'@

SubRx @'
          if(!G.sim) say('The Peddler is back at his pitch.');
'@ @'
          if(!G.sim&&chatNear(e.x,e.y)) say('The Peddler is back at his pitch.','chat');   // v22.xx (R35): only near or in sight
'@

SubRx @'
            if(!G.sim) say(e.name+' called extraction.');
'@ @'
            if(!G.sim&&chatNear(z.x,z.y)) say(e.name+' called extraction.');   // v22.xx (R35): only near or in sight
'@

SubRx @'
          say(e.name+' extracted with the goods.'); T.raidersExtracted++;
'@ @'
          T.raidersExtracted++;   // v22.xx (R35): no line; the Current Pillagers board marks him EXTRACTED
'@

SubRx @'
            say(e.name+(e.standing>0?' nods at you.':' is watching you.'));
'@ @'
            say(e.name+(e.standing>0?' nods at you.':' is watching you.'),'chat');   // v22.xx (R35): chat
'@

SubRx @'
                  say(CW.k==='deer'?'The deer goes down.':'You shot a bird.');
'@ @'
                  say(CW.k==='deer'?'The deer goes down.':'You shot a bird.','chat');   // v22.xx (R35): chat
'@

SubRx @'
function sayAny(m){
  if(typeof state!=='undefined'&&state==='raid'&&G&&!G.sim) say(m);
'@ @'
function sayAny(m,k){
  if(typeof state!=='undefined'&&state==='raid'&&G&&!G.sim) say(m,k);   // v22.xx (R35): with its kind
'@

SubRx @'
      if(!buzzDoses(_tg)) sayAny(_tg==='drunk'?'The liquor wears off.':'The colours drain away.');
'@ @'
      if(!buzzDoses(_tg)) sayAny(_tg==='drunk'?'The liquor wears off.':'The colours drain away.','chat');   // v22.xx (R35): chat
'@

SubRx @'
    say('The weather is turning. '+nw.line);
'@ @'
    say('The weather is turning. '+nw.line,'chat');   // v22.xx (R35): chat
'@

SubRx @'
say('The weather is turning. '+G.wxNext.line); sfxHere
'@ @'
say('The weather is turning. '+G.wxNext.line,'chat'); sfxHere
'@

SubRx @'
if(G.wx.id!=='clear'&&G.wx.line) say(G.wx.line);
'@ @'
if(G.wx.id!=='clear'&&G.wx.line) say(G.wx.line,'chat');   // v22.xx (R35): chat
'@

SubRx @'
var VER='22.82';
'@ @'
var VER='22.83';
'@

$pat = "(?m)^  now:'v22\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.83: Pillager, Survivor and Peddler lines from across the map no longer show unless it happens near you or in sight. Check 22.83 fails on v22.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

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

# PILLAGERS SAY NO WORDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var TAUNT={
  spot:['I see you!','Contact, right there!','Got eyes on!','There! Move!','Hey! HEY!','Found one!'],
  hurt:['You are bleeding!','Stay down!','Nearly had you!','Keep running!'],
  down:['Stay down.','That is that.','Should have stayed below.','Easy.'],
  flee:['Not worth it!','I am out!','Keep it!','Take it, I am gone!']
};
// One line at a time across the whole map, never twice inside four seconds. Six
// men in a firefight would otherwise produce a wall of shouting, which tells you
// nothing about where any of them is.
function taunt(e,kind){
  if(!G||G.sim||G.over||!e) return;
  var now=G.t||0;
  if((G.tauntAt||-99)>now-4) return;
  if(dist(G.player,e)>620) return;
  var pool=TAUNT[kind]; if(!pool||!pool.length) return;
  G.tauntAt=now;
  var line=pool[Math.abs(Math.round(e.x+e.y+now))%pool.length];
  emoteBubble(e.x,e.y-30,line,'#ffd48a',2.1);
  if(G.tel) G.tel.taunts=(G.tel.taunts||0)+1;
  var ear=earsOf(e.x,e.y);
  blip('seen',ear.d,ear.pan);
}
'@ @'
// v24.xx (notaunt), HIS ORDER 2026-10-12, verbatim: "get rid of any spoken words from the pillagers, doesn't sound good and kills the
// vibe". His newest word reverses the pillager taunts of his answer 34 b. The taunt lines (spot, hurt, down and flee) and taunt() are
// gone, and with them the mark each one drew over the man. The one part of a taunt that was not a word stays: the low SEEN swell when
// a pillager spots him, now played at the spot site in updateEnts (G.seenBlipAt keeps the old gate: within 620, once in four seconds).
'@

SubRx @'
  (function(){
    if(G.sim) return;
    var near=null,nd=1e9;
    for(var _ti=0;_ti<G.ents.length;_ti++){
      var _te=G.ents[_ti];
      if(_te.kind!=='raider'||_te.downed||_te.merc) continue;
      var _td=dist(p,_te); if(_td<nd){ nd=_td; near=_te; }
    }
    if(near&&nd<420) taunt(near,'down');
  })();
'@ @'
  // v24.xx (notaunt), his order 2026-10-12 (pillagers say no words): a pillager standing near him when he goes down no longer taunts.
'@

SubRx @'
  if(e.kind==='raider'&&e.state==='extract'){ e.alert=2.4; if(!e._fledSaid){ e._fledSaid=1; taunt(e,'flee'); } if(e.crewArc!==undefined) delete e.crewArc; }
'@ @'
  if(e.kind==='raider'&&e.state==='extract'){ e.alert=2.4; if(e.crewArc!==undefined) delete e.crewArc; }   // v24.xx (notaunt): a man breaking off says nothing (his order 2026-10-12)
'@

SubRx @'
        if(e.state!=='chase'&&e.kind==='raider') taunt(e,'spot');
'@ @'
        // v24.xx (notaunt), HIS ORDER 2026-10-12 (pillagers say no words, "doesn't sound good and kills the vibe"): A PILLAGER WHO SPOTS
        // HIM SAYS NOTHING. The spot taunt drew a mark over his head and played the low SEEN swell where he stands; the mark went with the
        // words, and the swell, which is not a word, stays: the same ear (earsOf, panned and attenuated from the pillager), the same reach
        // of 620 from the player and the same gate of once in four seconds across the map that the taunt had. Sound only: no seeded draw.
        if(e.state!=='chase'&&e.kind==='raider'&&!G.sim&&!G.over&&G.player&&dist(G.player,e)<=620&&!(typeof G.seenBlipAt==='number'&&G.seenBlipAt>(G.t||0)-4)){ G.seenBlipAt=G.t||0; var _sbE=earsOf(e.x,e.y); blip('seen',_sbE.d,_sbE.pan); }
'@

SubRx @'
          // v23.xx, HIS ANSWERS (2026-10-12), answer 34 b: "pillager taunts". A PILLAGER WHO HITS YOU TAUNTS YOU. The hurt lines (YOU ARE
          // BLEEDING, NEARLY HAD YOU) were written in v2 but nothing ever called them: a pillager taunted only when he spotted you, put
          // you down or ran. Now a round of his that lands on you can draw one, through the same taunt gate (one line on the map at a
          // time, never twice inside four seconds, only within 620), so a firefight has a voice without becoming a wall of shouting.
          // Machines never taunt. The line is picked from his position and the time, as every taunt is, so no seeded draw moves.
          if(hit&&b.owner&&b.owner.kind==='raider'&&!b.owner.merc&&!G.sim){ try{ taunt(b.owner,'hurt'); }catch(_tht){} }
'@ @'
          // v24.xx (notaunt), his order 2026-10-12 (pillagers say no words): a pillager round that lands on you no longer draws the hurt taunt of answer 34 b.
'@

SubRx @'
  'TAUNTS AND REDESIGNS. Pillagers taunt when they hit you, menus answer with sound, FEEDBACK sends a screenshot, and the Howler and Pillbox are redrawn.',
'@ @'
  'REDESIGNS. Menus answer with sound, FEEDBACK sends a screenshot, and the Howler and Pillbox are redrawn.',
'@

SubRx @'
var VER='25.15';
'@ @'
var VER='25.16';
'@

$pat = "(?m)^  now:'v25\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.16: Pillagers say no words: no taunts and no taunt marks, only the low seen swell when one spots you. Check 25.16 fails on v25.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

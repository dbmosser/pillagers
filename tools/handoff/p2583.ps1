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

# NO EMOTES, MIDDLE MOUSE PINGS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// ============================================================ PARLEY
// Every human in this world was a target. There are ten named identities with a
// standing ledger, a hostility model that already lets a raider be passive, and
// no way at all to USE any of it: you could shoot someone or you could walk
// away. Emotes are the missing verb.
// The one that matters is HAIL. It is not decoration: a passive raider hailed
// twice with your weapon down becomes friendly for the rest of the raid, waves
// back, hands you something out of his bag, and remembers it. A HOSTILE raider
// can be talked down the same way if he has not shot at you recently and you
// are not closing on him. A raider you have KILLED before never listens, which
// is the whole point of the grudge.
var EMOTES=[
  {k:'hail',  name:'HAIL',       glyph:'wave',  say:'You raise a hand.'},
  {k:'stand', name:'STAND DOWN', glyph:'palm',  say:'You lower your weapon.'},
  {k:'point', name:'POINT',      glyph:'point', say:'You point.'},
  {k:'thanks',name:'THANKS',     glyph:'nod',   say:'You nod.'}
];
// You cannot talk to someone down a barrel. Firing recently, or aiming, means
// the hail does not count as one.
function weaponDown(){
  var p=G.player;
  return !p.ads && (G.t*1000-(p.lastShot||-9999))>2600;
}
function emoteBubble(x,y,glyph,col,life){
  if(!G||G.sim) return;
  G.bubbles=G.bubbles||[];
  G.bubbles.push({x:x,y:y,g:glyph,c:col||'#FFF6DC',t:0,life:life||1.8});
  if(G.bubbles.length>40) G.bubbles.shift();
}
function doEmote(ix){
  if(!G||G.over||G.sim) return;
  var E=EMOTES[ix]; if(!E) return;
  var p=G.player;
  // v15.85, trade audit finding: THE EMOTE BAR CLOSES WHEN HE GOES DOWN AND ITS KEYS SAY WHY WHILE HE IS DOWN. A digit that
  // reached here on the floor or in a roll returned with nothing said, so a working key read as a broken one (his v13.19
  // report on the silent roll). Down, it says the line the belt uses from the floor; in a roll, the same shape. The bar
  // stays up for the press after the roll. The cooldown below stays silent: it is under a second after an emote he just
  // watched. No number and no seeded draw moved.
  // v22.81 (tr6fixc), the review of raid text batch 6: HIS ORDER (2026-10-09), a raid line is a short caps callout of at most 34
  // characters. The emote refusals and results were sentences; they are NOT WHILE DOWN, NOT WHILE ROLLING, LOWER YOUR GUN TO TALK,
  // NOBODY IN EARSHOT, and the pillager by name in caps: NAME WILL NOT TALK, NAME STANDS DOWN, NAME WAVES BACK (the longest tag,
  // 20 letters, keeps each within 34), and NOTHING TO SPARE with his name as the detail.
  if(p.downed){ say('NOT WHILE DOWN'); return; }
  if(p.roll>0){ say('NOT WHILE ROLLING'); return; }
  if((G.emoteCd||0)>0) return;
  G.emoteCd=0.9;
  G.emoteBar=false;
  emoteBubble(p.x,p.y,E.glyph,'#FFF6DC',1.6);   // v22.77 (R32): the bubble over him is the emote; no narration line, the result follows below
  // A hail is a shout. It carries, and it carries to things that are not people.
  ping(p.x,p.y,E.k==='hail'?300:150,false,false,'player','move');
  blip('pick',260);
  if(E.k!=='hail'&&E.k!=='stand') return;
  var down=weaponDown();
  if(!down){
    if(E.k==='hail') say('LOWER YOUR GUN TO TALK');
    return;
  }
  var reached=0;
  for(var i=0;i<G.ents.length;i++){
    var e=G.ents[i];
    if(e.kind!=='raider'||e.merc||e.friendlyPC) continue;
    var d=dist(p,e);
    if(d>460) continue;
    if(!losClear(p.x,p.y,e.x,e.y,G.map.segs)) continue;
    reached++;
    if(e.grudge){
      if(!e.grudgeSaid){ e.grudgeSaid=1; say(String(e.name).toUpperCase()+' WILL NOT TALK','ally'); }
      emoteBubble(e.x,e.y,'no','#ff3b30',1.6);
      continue;
    }
    // A hostile raider will hear you out only if he is not mid fight with you
    // and you are not closing the distance on him.
    if(e.hostile){
      if(e.hitT>0||d<190){ emoteBubble(e.x,e.y,'no','#ff6b5a',1.4); continue; }
      e.parley=(e.parley||0)+1;
      emoteBubble(e.x,e.y,'think','#ffc04a',1.6);
      // Standing you have already earned makes him quicker to believe you; a
      // reputation for shooting traders makes him slower.
      var need=2+clamp(Math.round((P.notoriety||0)),0,3)-clamp(Math.round((e.standing||0)/2),0,1);
      if(e.parley>=need){
        e.hostile=false; e.parley=0;
        e.state='loot'; e.alert=0;
        say(String(e.name).toUpperCase()+' STANDS DOWN','ally');
        emoteBubble(e.x,e.y,'wave','#7fc4a0',2.0);
      }
      continue;
    }
    // Passive. Two hails and he is with you for the rest of the run.
    e.trust=(e.trust||0)+1;
    emoteBubble(e.x,e.y,e.trust>=2?'wave':'think',e.trust>=2?'#7fc4a0':'#cdd6dd',1.8);
    if(e.trust>=2&&!e.friendlyPC){
      e.friendlyPC=1;
      e.hostile=false;
      say(String(e.name).toUpperCase()+' WAVES BACK','ally');
      // He gives you something out of his own bag. It is not much and it is not
      // nothing, and it is the first time in this game that a stranger has been
      // worth more alive.
      if(e.bag.length&&!G.sim){
        // v8.49, audit: PICK FROM WHAT HE CAN ACTUALLY GIVE. This drew one index
        // at random and gave up entirely if it landed on a gun - and a gun sits at
        // index 0 of every raider's bag by construction, so a large share of
        // successful parleys silently paid nothing at all.
        // The draws are on the cosmetic stream because this block is live-only:
        // every parley used to consume seeded numbers the bot never consumes.
        var _gcand=[];
        for(var _gq=0;_gq<e.bag.length;_gq++){
          var _gi2=ITEMS[e.bag[_gq]];
          if(_gi2&&_gi2.use!=='gun') _gcand.push(_gq);
        }
        if(_gcand.length){
          var gi=_gcand[fxi(0,_gcand.length-1)],gk=e.bag[gi];
          e.bag.splice(gi,1);
          var gc=setLoot(mkContainer(e.x+fxn(-16,16),e.y+fxn(10,22),'crate'),[gk]);
          gc.time=0.5; gc.gift=1; G.containers.push(gc);
          label(e.x,e.y-20,'GIFT: '+ITEMS[gk].name,'#7fc4a0',0,true);
        } else {
          // He has nothing but his gun, and he is not handing that over. Say so,
          // rather than leaving the player to wonder whether the system works.
          say('NOTHING TO SPARE','ally',{sub:String(e.name).toUpperCase()});
        }
      }
      if(!G.sim){
        var rr=idRec(e.ident);
        rr.standing=(rr.standing||0)+1; rr.met++;
        G.tel.parleys=(G.tel.parleys||0)+1;
        saveProfile();
      }
    }
  }
  if(E.k==='hail'&&!reached) say('NOBODY IN EARSHOT');
}
'@ @'
// v25.xx (noemotes), HIS ORDER 2026-10-13 ("there is an emote system tied to middle mouse, get rid of all that"): THE EMOTE SYSTEM IS GONE. The
// strip V opened (hail, stand down, point, thanks), the bubbles over heads, and the parley they started (a hailed pillager standing down, waving back
// and handing over an item) were removed whole. Middle mouse is the ping.
'@

SubRx @'
  emoteBubble(e.x,e.y,'nod','#7fc4a0',2.0);

'@ @'

'@

SubRx @'
      // He asks again, quietly, while you are standing over him.
      e.askedT=Math.max(0,(e.askedT||0)-dt);
      if(e.found&&!e.helped&&sdd<80&&e.askedT<=0&&!G.sim){
        e.askedT=6;
        emoteBubble(e.x,e.y,'think','#7fc4a0',1.8);
      }

'@ @'

'@

SubRx @'
  // The emote bar owns the number row while it is up, same rule as the stall.
  if(G&&!G.over&&!G.trade&&G.emoteBar){
    if(code==='KeyV'||code==='Escape'||code==='Tab'){ if(ev) ev.preventDefault(); G.emoteBar=false; return; }
    if(code.indexOf('Digit')===0&&!repeat){
      if(ev) ev.preventDefault();
      var en=parseInt(code.slice(5),10);
      if(en>=1&&en<=EMOTES.length) doEmote(en-1);
      return;
    }
  }

'@ @'

'@

SubRx @'
  // v15.85, trade audit finding: THE EMOTE BAR CLOSES WHEN HE GOES DOWN AND ITS KEYS SAY WHY WHILE HE IS DOWN. This toggle
  // had no downed test, unlike the backpack rule below (v14.57), so V on the floor opened the bar over the downed screen, and
  // 1 to 4 then went to doEmote, which returned on the floor with nothing said. Down or in the death fade V opens nothing;
  // down, it says so, in the words the belt already uses from the floor (useHot). Closing is untouched: the emote bar block
  // above still shuts an open bar on V, ESC or TAB before this line runs. No number and no seeded draw moved.
  if(code==='KeyV'&&G&&!G.over&&!G.paused&&!G.trade&&!repeat&&!(G.player&&(G.player.downed||G.player.dying))){
    if(ev) ev.preventDefault();
    G.emoteBar=!G.emoteBar;
    return;
  }
  if(code==='KeyV'&&G&&!G.over&&!G.paused&&!G.trade&&!repeat&&G.player&&G.player.downed&&!G.player.dying){ if(ev) ev.preventDefault(); say('NOT WHILE DOWN'); return; }   // v22.81 (tr6fixc): the caps callout

'@ @'

'@

SubRx @'
'KeyP','KeyH','KeyV','KeyC','KeyX','KeyU'
'@ @'
'KeyP','KeyH','KeyC','KeyX','KeyU'
'@

SubRx @'
(G.mapOpen||G.bagOpen||G.emoteBar)&&backOut()
'@ @'
(G.mapOpen||G.bagOpen)&&backOut()
'@

SubRx @'
    // v15.85, trade audit finding: THE EMOTE BAR CLOSES WHEN HE GOES DOWN AND ITS KEYS SAY WHY WHILE HE IS DOWN. The line
    // above shuts the map and the backpack so that nothing covers the downed screen, and the emote bar was missed: V opens it
    // (say, to hail a pillager at range), a shot puts him on the floor, and drawHUD draws the bar after the red downed wash
    // with no downed test of its own, so HAIL, STAND DOWN, POINT and THANKS sat over the bleed-out under the caption weapon
    // down, they will listen, while 1 to 4 went to doEmote, which returns on the floor. Shut here with the other panels; the
    // first standing V after a revive opens it again. No number, no player text and no seeded draw moved.
    G.emoteBar=false;

'@ @'

'@

SubRx @'
    if(G.emoteBar){ G.emoteBar=false; return true; }

'@ @'

'@

SubRx @'
  // v25.xx (mmbping), HIS ORDER 2026-10-13 ("middle mouse: yes"): MIDDLE MOUSE IS THE PING AND THE SIGNAL, rebindable. With a party it marks
  // what is under the cursor for them (netPingMake, the N key, and on the open map your marker); alone it does what V does (opens and
  // closes the signal strip, so hail and stand down are one click from the aim). It latches no key.

'@ @'
  // v25.xx (mmbping), HIS ORDER 2026-10-13 ("middle mouse: yes"; then "get rid of" the emotes, v25.xx noemotes): MIDDLE MOUSE IS THE PING, rebindable.
  // With a party it marks what is under the cursor for them (netPingMake, the N key, and on the open map your marker). Alone there is nobody to
  // ping and it does nothing. It latches no key.

'@

SubRx @'
if(NET.on) netPingMake(); else { raidKey('KeyV',false,ev); keys['KeyV']=false; }
'@ @'
if(NET.on) netPingMake();
'@

SubRx @'
['Mouse1','ping / signal (mouse)'],
'@ @'
['Mouse1','ping (mouse)'],
'@

SubRx @'
['KeyZ','drop an item for a teammate'],['KeyV','emotes'],['KeyO','order your hire']
'@ @'
['KeyZ','drop an item for a teammate'],['KeyO','order your hire']
'@

SubRx @'
['PARTY',['KeyT','KeyZ','KeyN','KeyV','Mouse1']]];
'@ @'
['PARTY',['KeyT','KeyZ','KeyN','Mouse1']]];
'@

SubRx @'
function keysInv(){ var m=keysMap(), k, inv={}; for(k in m) if(Object.prototype.hasOwnProperty.call(m,k)&&typeof m[k]==='string'&&m[k]!==k) inv[m[k]]=k;
'@ @'
function keysInv(){ var m=keysMap(), k, inv={}; for(k in m) if(Object.prototype.hasOwnProperty.call(m,k)&&typeof m[k]==='string'&&m[k]!==k&&KEYS_ACTS.some(function(a){ return a[0]===k; })) inv[m[k]]=k;   /* v25.xx (noemotes): an action that is not on the list any more (the old V) takes no key */
'@

SubRx @'
  // Emote bubbles. A parley you cannot see happening is a dice roll, so every
  // hail, refusal and wave back gets a mark over the head that sent it.
  if(G.bubbles) for(i=0;i<G.bubbles.length;i++){
    var BB=G.bubbles[i];
    var ba=clamp(1-BB.t/BB.life,0,1),brise=Math.min(BB.t,BB.life)*14;
    var bx=BB.x,by=BB.y-34-brise,br=11;
    wc.globalAlpha=ba;
    wc.fillStyle='rgba(8,11,16,.82)';
    wc.beginPath(); wc.arc(bx,by,br,0,6.2832); wc.fill();
    wc.beginPath(); wc.moveTo(bx-4,by+br-2); wc.lineTo(bx+2,by+br+6); wc.lineTo(bx+4,by+br-3); wc.fill();
    wc.strokeStyle=BB.c; wc.lineWidth=1.4;
    wc.beginPath(); wc.arc(bx,by,br,0,6.2832); wc.stroke();
    wc.strokeStyle=BB.c; wc.fillStyle=BB.c; wc.lineWidth=1.8;
    if(BB.g==='wave'){
      wc.beginPath(); wc.moveTo(bx-4,by+5); wc.lineTo(bx-1,by-2); wc.lineTo(bx+3,by-5); wc.stroke();
      wc.beginPath(); wc.arc(bx+3,by-5,2.2,0,6.2832); wc.fill();
    } else if(BB.g==='palm'){
      wc.beginPath(); wc.moveTo(bx-5,by+4); wc.lineTo(bx-5,by-3); wc.stroke();
      wc.beginPath(); wc.moveTo(bx-1,by+4); wc.lineTo(bx-1,by-5); wc.stroke();
      wc.beginPath(); wc.moveTo(bx+3,by+4); wc.lineTo(bx+3,by-3); wc.stroke();
    } else if(BB.g==='point'){
      wc.beginPath(); wc.moveTo(bx-5,by+3); wc.lineTo(bx+5,by-3); wc.stroke();
      wc.beginPath(); wc.moveTo(bx+5,by-3); wc.lineTo(bx+1,by-3); wc.lineTo(bx+5,by+1); wc.fill();
    } else if(BB.g==='nod'){
      wc.beginPath(); wc.moveTo(bx-5,by-1); wc.lineTo(bx-1,by+4); wc.lineTo(bx+5,by-5); wc.stroke();
    } else if(BB.g==='no'){
      wc.beginPath(); wc.moveTo(bx-4,by-4); wc.lineTo(bx+4,by+4); wc.stroke();
      wc.beginPath(); wc.moveTo(bx+4,by-4); wc.lineTo(bx-4,by+4); wc.stroke();
    } else {
      wc.beginPath(); wc.arc(bx,by-1,3.4,0,6.2832); wc.stroke();
      wc.beginPath(); wc.arc(bx,by+5,1.3,0,6.2832); wc.fill();
    }
    wc.globalAlpha=1;
  }

'@ @'

'@

SubRx @'
sl[sel].name+'   [FIRE] use'+(padOn()?'':'    ['+keyName(keysOf('KeyV'))+'] signal'), _bcW
'@ @'
sl[sel].name+'   [FIRE] use', _bcW
'@

SubRx @'
// v22.14, from the whole-game bug hunt of 2026-10-08 (K25): THE EMOTE STRIP SITS ABOVE THE BELT. It was placed a fixed height from
// the bottom of the screen (H-LH(112)), while the belt grows with the screen, so at 1440p and 4K the strip was painted over the top of
// the belt keys and their numbers, and at 1080p over the belt caption. Its top is now worked out from the belt as drawn this frame:
// above the caption strip (v19.34) with a small gap, and above the extraction lines while they show, as the wind-up bar already goes
// (v19.10). The wind-up bar keeps the same distance above the strip it had.
function emoteStripY(){
  var c=(G&&G.hotCells&&G.hotCells.length)?G.hotCells[0]:null, hy=c?c.y:H-LH(70), bw=c?c.w:LH(60), p=G&&G.player, y;
  var cap=parseFloat(((/([\d.]+)px/).exec(String(beltCapFS(bw)))||[0,11])[1])||11;
  y=Math.round(hy-LH(6)-cap*0.95-LH(6)-LH(30));
  try{ if(p&&((G.beaconT!==null&&!G.over)||(G.active&&dist(p,G.active)<G.active.r))) y=Math.min(y,Math.round(hy-(LH(48)+LH(34))*Math.max(1,(typeof hudRes==='function')?hudRes():1)-LH(30))); }catch(_ex){}
  return y;
}

'@ @'

'@

SubRx @'
  if(G.emoteBar) y=Math.min(y,emoteStripY()-LH(30)-h);   // v22.14 (K25): above the strip, wherever the strip sits now

'@ @'

'@

SubRx @'
  // The emote bar. Deliberately a strip and not a wheel: a wheel wants a mouse
  // you are already using to aim, and this has to be usable while something is
  // walking toward you.
  if(G.emoteBar&&!G.trade){
    var ebw=LH(112),ebh=LH(30),egap=LH(6);
    var etw=EMOTES.length*ebw+(EMOTES.length-1)*egap;
    var ex0=Math.round(W/2-etw/2),ey0=emoteStripY();   // v22.14 (K25): above the belt and its caption as drawn this frame, not a fixed height
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#8a96a1'; ctx.textAlign='center';
    ctx.fillText(weaponDown()?'weapon down, they will listen':'lower your weapon first',
      W/2,ey0-LH(8));
    ctx.textAlign='left';
    for(var eq=0;eq<EMOTES.length;eq++){
      var EE=EMOTES[eq],ebx=ex0+eq*(ebw+egap);
      ctx.fillStyle='rgba(6,9,13,.90)'; ctx.fillRect(ebx,ey0,ebw,ebh);
      ctx.strokeStyle=(EE.k==='hail'&&weaponDown())?'#7fc4a0':'rgba(140,152,163,.42)';
      ctx.lineWidth=1; ctx.strokeRect(ebx+.5,ey0+.5,ebw-1,ebh-1);
      ctx.font=FS(TYPE.micro); ctx.fillStyle='rgba(160,172,184,.85)';
      ctx.fillText(String(eq+1),ebx+LH(6),ey0+LH(12));
      ctx.font=FS(TYPE.label);
      ctx.fillStyle=(EE.k==='hail')?'#ffc04a':'#cdd6dd';
      ctx.textAlign='center'; ctx.fillText(EE.name,ebx+ebw/2,ey0+LH(20)); ctx.textAlign='left';
    }
  }

'@ @'

'@

SubRx @'
      G.emoteCd=Math.max(0,(G.emoteCd||0)-dt);
      if(G.bubbles) for(var bi2=G.bubbles.length-1;bi2>=0;bi2--){
        G.bubbles[bi2].t+=dt;
        if(G.bubbles[bi2].t>G.bubbles[bi2].life) G.bubbles.splice(bi2,1);
      }

'@ @'

'@

SubRx @'
  ['DONE','Emotes and parley: hail a pillager instead of shooting him'],

'@ @'

'@

SubRx @'
var VER='25.82';
'@ @'
var VER='25.83';
'@

$pat = "(?m)^  now:'v25\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.83: The emote system is gone: V opens nothing, and middle mouse is the ping only. Check 25.83 fails on v25.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"

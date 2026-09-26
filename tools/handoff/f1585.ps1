$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.84',what:
'@ @'
  {v:'15.85',what:'the emote bar closes when he goes down and its keys say why while he is down: on his feet V opens the emote bar; shot to the floor with the bar and the map up, going down shuts the bar as it shuts the map; down, V leaves the bar shut and says Not while you are down, and V still shuts a bar that is open; back on his feet with the bar up, a digit pressed in a roll says Not while you are rolling and leaves the bar up, and the same digit with the roll over does the emote and shuts the bar (trade audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof raidKey!=='function'||typeof damagePlayer!=='function'||typeof doEmote!=='function'||typeof EMOTES==='undefined'||!EMOTES||EMOTES.length<3) return 'SKIP: no key handler, damage or emote bar in this build';
     if(typeof keys==='undefined'||!keys||typeof pauseOpen==='undefined') return 'SKIP: no keys or pause state in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], snap=null, g=null, p=null;
     var DOWN='Not while you are down.', ROLL='Not while you are rolling.';
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     function skip(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); }
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     // One fresh press, the way the keyboard listener hands it over, with the keys clear on both sides.
     function press(c){ clearKeys(); raidKey(c,false,null); clearKeys(); }
     // On his feet at full health, no roll, every panel shut and nothing said.
     function stand(){
       p.downed=false; p.dying=false; p.hp=p.maxhp; p.downT=0; p.pendKiller=null; p.healLock=false; p.iv=0; p.roll=0; p.rollCd=0;
       g.emoteBar=false; g.mapOpen=false; g.bagOpen=false; g.drag=null; g.trade=null; g.emoteCd=0; g.msg=''; g.msgT=0;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(pauseOpen||g.paused) return 'SKIP: the raid landed paused';
       if(g.deathBeat!==undefined&&g.deathBeat!==null) return 'SKIP: the raid landed in the death fade';
       p=g.player;
       stand();
       // CONTROL: on his feet V opens the bar, on either build.
       press('KeyV');
       if(!g.emoteBar) return 'SKIP: V on his feet did not open the emote bar here, so the downed press cannot be judged';
       // ONE: shot to the floor with the bar and the map up.
       g.mapOpen=true;
       damagePlayer(999,'test','TEST');
       // CONTROL: he went down and the going-down branch ran, since it shut the map, on either build.
       if(!p.downed) return skip('a 999 hit did not put him down here');
       if(g.mapOpen) return skip('going down did not shut the map here, so the going-down branch cannot be read');
       if(g.emoteBar) bad.push('shot down with the emote bar up, the bar stayed up over the downed screen');
       // TWO: V while he is down opens nothing and says why.
       g.emoteBar=false; g.msg=''; g.msgT=0;
       press('KeyV');
       if(g.emoteBar) bad.push('V while he is down opened the emote bar over the downed screen');
       if(String(g.msg||'')!==DOWN) bad.push('V while he is down said "'+g.msg+'" rather than why it opens nothing');
       // GUARD: V still shuts a bar that is open while he is down, the same closer as on his feet.
       g.emoteBar=true; press('KeyV');
       if(g.emoteBar) bad.push('V did not shut an open emote bar while he is down');
       // THREE: back on his feet with the bar up, a digit in a roll.
       stand();
       press('KeyV');
       if(!g.emoteBar) return skip('V on his feet did not open the emote bar again here');
       p.roll=0.3; g.msg=''; g.msgT=0;
       press('Digit1');
       if(String(g.msg||'')!==ROLL) bad.push('a digit on the emote bar in a roll said "'+g.msg+'" rather than why nothing happened');
       if(!g.emoteBar) bad.push('a digit on the emote bar in a roll shut the bar with no emote done');
       // CONTROL: the roll over, the same row does the emote and shuts the bar, on either build.
       p.roll=0; g.emoteCd=0; g.msg=''; g.msgT=0;
       press('Digit3');
       if(g.emoteBar||String(g.msg||'')!==String(EMOTES[2].say)) return skip('with the roll over the digit did not do the emote and shut the bar here (bar '+g.emoteBar+', said "'+g.msg+'"), so the digits do not reach the emotes through the bar');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearKeys(); }catch(_k){}
       try{ if(g&&g.player){ g.player.downed=false; g.player.dying=false; g.player.roll=0; g.emoteBar=false; g.mapOpen=false; g.bagOpen=false; g.drag=null; } }catch(_p){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

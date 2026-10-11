$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'22.81',what:")) { throw "check 22.81 is in the fixture already" }

SubRx @'
  {v:'22.80',what:
'@ @'
  {v:'22.81',what:'emote, closed ring and bystander lines are caps callouts: the hail says NOT WHILE DOWN, NOT WHILE ROLLING, LOWER YOUR GUN TO TALK and NOBODY IN EARSHOT, a pillager answers NAME WILL NOT TALK, NAME STANDS DOWN or NAME WAVES BACK, E in a closed ring says EXTRACTION A IS CLOSED with the open one as the detail, and a survivor or the Peddler killed by someone else is SOMEONE SHOT THE SURVIVOR or THE PEDDLER IS DEAD; every one is caps, at most 34 characters, with no end punctuation',
   run:function(){
     if(typeof doEmote!=='function'||typeof EMOTES==='undefined'||typeof tryExtractTick!=='function'||typeof extLetter!=='function') return 'SKIP: no emote bar or extraction here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], sk=[], oSay=say, said=[], g=null, p=null, hx=-1, i, e, z=null, z2=null, kz=null, kz2=null, ents0=null, src, l, OS=['Someone','shot','the','survivor.'].join(' '), OP=['The','Peddler','is','dead.'].join(' ');
     function voice(what,want,all){
       var l=null, j;
       if(all){ for(j=0;j<said.length;j++) if(said[j].m===want) l=said[j]; if(!l&&said.length) l=said[0]; }
       else l=said.length?said[0]:null;
       if(!l){ bad.push(what+' said nothing'); return null; }
       if(l.m!==l.m.toUpperCase()||l.m.length>34||/[.!?,;:]$/.test(l.m)) bad.push(what+' said '+JSON.stringify(l.m)+', not a caps callout');
       else if(want&&l.m!==want) bad.push(what+' said '+JSON.stringify(l.m)+', not '+want);
       return l;
     }
     for(i=0;i<EMOTES.length;i++) if(EMOTES[i].k==='hail') hx=i;
     if(hx<0) return 'SKIP: no hail on the emote bar';
     // the bystander lines, read from the page: the old sentences are gone
     src=[].slice.call(document.scripts).map(function(s){ return s.textContent||''; }).join('\n');
     if(src.indexOf(OS+' Not on you.')>=0) bad.push('a survivor killed by someone else still says the old sentence');
     if(src.indexOf(OP+' Someone else did that.')>=0) bad.push('the Peddler killed by someone else still says the old sentence');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; p.downed=false; p.dying=false; p.roll=0; p.ads=false; p.lastShot=-1e9; ents0=g.ents.slice(); g.ents.length=0;
       say=function(m,kd,o){ said.push({m:String(m),k:kd,o:o||null}); };
       p.downed=true; g.emoteCd=0; said.length=0; doEmote(hx); voice('a hail while down','NOT WHILE DOWN'); p.downed=false;
       p.roll=0.3; g.emoteCd=0; said.length=0; doEmote(hx); voice('a hail in a roll','NOT WHILE ROLLING'); p.roll=0;
       p.ads=true; g.emoteCd=0; said.length=0; doEmote(hx); voice('a hail while aiming','LOWER YOUR GUN TO TALK'); p.ads=false;
       g.emoteCd=0; said.length=0; doEmote(hx); voice('a hail with nobody near','NOBODY IN EARSHOT');
       // a pillager in sight: a grudge, a hostile one who believes you, a passive one who trusts you
       e={kind:'raider',x:p.x+40,y:p.y,name:'ZqxRook',ident:(typeof IDENTITIES!=='undefined'&&IDENTITIES[0])?IDENTITIES[0].id:'zqx',grudge:1,hostile:false,bag:[],hitT:0,trust:0,parley:0,state:'loot',alert:0};
       g.ents.push(e);
       g.emoteCd=0; said.length=0; doEmote(hx);
       if(said.length&&said[0].m.toUpperCase().indexOf('EARSHOT')>=0) sk.push('the pillager 40 units away is not in sight of the hail');
       else {
         voice('a hail to a pillager with a grudge','ZQXROOK WILL NOT TALK');
         e.grudge=0; e.grudgeSaid=0; e.hostile=true; e.x=p.x+250; e.parley=20; g.emoteCd=0; said.length=0; doEmote(hx);
         if(e.hostile) sk.push('the hostile pillager did not stand down');
         else voice('a hail a hostile pillager believes','ZQXROOK STANDS DOWN');
         e.hostile=false; e.trust=1; e.friendlyPC=0; e.x=p.x+40; g.emoteCd=0; said.length=0; doEmote(hx);
         voice('a hail a passive pillager trusts','ZQXROOK WAVES BACK',true);
       }
       g.ents.length=0;
       // E in a closed ring with another open
       for(i=0;i<g.zones.length;i++){ if(!z) z=g.zones[i]; else if(!z2&&dist(g.zones[i],z)>z.r+50) z2=g.zones[i]; }
       if(!z||!z2) sk.push('no two extraction rings');
       else {
         kz={o:z.open,b:z.beaconT,h:z.hold,p:z.pullT}; kz2={o:z2.open};
         z.open=false; z.hold=null; z.pullT=null; z.beaconT=null; z2.open=true; g.closedSaid=null;
         p.x=z.x; p.y=z.y; said.length=0;
         tryExtractTick(0.05,true);
         l=null; for(i=0;i<said.length;i++) if(/CLOSED/i.test(said[i].m)) l=said[i];
         if(!l) sk.push('E in a closed ring said no closed line here');
         else {
           said=[l]; voice('E in a closed ring','EXTRACTION '+extLetter(z)+' IS CLOSED');
           if(!(l.o&&/^Extraction [A-Z] is open, [0-9]+m [a-z]/.test(String(l.o.sub||'')))) bad.push('the closed ring line has no detail naming the open one ('+JSON.stringify(l.o)+')');
         }
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=oSay; keys={};
       try{ if(z&&kz){ z.open=kz.o; z.beaconT=kz.b; z.hold=kz.h; z.pullT=kz.p; } if(z2&&kz2) z2.open=kz2.o; }catch(_z){}
       try{ var g2=__state(); if(g2){ g2.closedSaid=null; if(ents0){ g2.ents.length=0; for(i=0;i<ents0.length;i++) g2.ents.push(ents0[i]); } if(!g2.over){ g2.player.downed=false; g2.player.roll=0; g2.player.ads=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     if(!bad.length&&sk.length>2) return 'SKIP: staging: '+sk.join('; ');
     return bad.length?bad.join('; '):null; }},
  {v:'22.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'37.46',what:")) { throw "check 37.46 is in the fixture already" }

SubRx @'
  {v:'37.45',what:
'@ @'
  {v:'37.46',what:'cw-topstrip, his order of 2026-11-02 (the clock, score, extract, player alerts and the down card all across the top edge, leaving more room for play): one rail across the whole top edge holds the score at the left, the clock in the middle and the way out at the right; the corner column starts under it; an alert draws on the rail against the clock; down draws its timer, words and slider on the rail and a danger on its own line under it; two players show both shares on the rail',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy';
     if(typeof railH!=='function'||typeof RAIL!=='object') return 'no top strip: the clock, score and extract still stack in the top middle';
     var bad=[], g=null, p=null, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, tr=[], rh, z, zm, o, o2, role0=ARCADE.role, solo0=ARCADE.solo, HFB=hudFadeBegin;
     function find(re){ for(var k=0;k<tr.length;k++) if(re.test(tr[k].t)) return tr[k]; return null; }
     function band(n,re,lo,hi){ var q=null, k2, a=(lo===undefined)?0:lo, b=(hi===undefined)?rh:hi; for(k2=0;k2<tr.length;k2++) if(re.test(tr[k2].t)){ if(!q) q=tr[k2]; if(tr[k2].y>a&&tr[k2].y<=b){ q=tr[k2]; break; } } if(!q){ bad.push(n+' was not drawn'); return null; } if(!(q.y>a&&q.y<=b)) bad.push(n+' draws at y '+Math.round(q.y)+', off its line ('+Math.round(a)+' to '+Math.round(b)+')'); return q; }
     function frame(){ tr=__textTrace(function(){ drawHUD(); }); }
     function quiet(){ g.alert=null; g.alertQ=[]; g.alertSeen={}; g.msgLog=[]; g.fd=null; g.msgQ=[]; g.msgQM=[]; g.loc=null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       hudFadeBegin=function(){ return null; };   /* a spawn near the map edge can sit under the rail and the fade would draw it on a layer */
       CAREER_ON=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!g.career||!g.cs) return 'SKIP: staging: not a career raid';
       p=g.player; g.ents=[]; g.mapOpen=false; g.bagOpen=false; g.paused=false; p.hp=100; p.downed=false; g.timeLeft=300; g.cs.s=2730; quiet();
       rh=railH(); z=railZ(); zm=(HUDZ.msg||1)*hudRes()*hudUserZ('msg');
       frame(); frame();
       // ONE: calm, the three ends of the rail, and nothing hanging under it
       if(!(rh<=56*z*uiScale())) bad.push('the rail is '+rh+' px tall, not slim');
       o=band('the clock',/^\d+:\d\d$/); if(o&&Math.abs(o.x-W/2)>2) bad.push('the clock is not in the middle (x '+Math.round(o.x)+')');
       o=band('the score',/^2,730 sp$/i); if(o&&!(o.x<W*0.2)) bad.push('the score is not at the left end (x '+Math.round(o.x)+')');
       o=band('the extract line',/^extract \d+m/i); if(o&&!(o.x>W*0.7)) bad.push('the extract line is not at the right end (x '+Math.round(o.x)+')');
       if(RAIL.b!==rh||HUDTOPB!==rh) bad.push('a calm rail hangs something under it (bottom '+RAIL.b+', top band '+HUDTOPB+', rail '+rh+')');
       if(!(ALERTY*zm<=rh+(LH(6)+1)*zm)) bad.push('the lanes under the rail start at '+Math.round(ALERTY*zm)+', not right under it');
       if(!(HUDBOX.cond&&HUDBOX.cond.y>=rh)) bad.push('the corner column starts inside the rail ('+(HUDBOX.cond?Math.round(HUDBOX.cond.y):'no panel')+')');
       if(typeof MMAP==='object'&&MMAP&&MMAP.box&&MMAP.box.y<rh) bad.push('the minimap starts inside the rail ('+Math.round(MMAP.box.y)+')');
       // TWO: an alert stands on the rail, one line, between the score and the clock
       quiet(); alertSay('TEST STRIP ALERT','warn',{key:'t-strip',sub:'test strip detail'}); if(g.alert) g.alert.at=(g.t||0)-1;
       frame(); frame();
       o=band('the alert headline',/^test strip alert$/i); o2=band('the alert detail',/^test strip detail$/i);
       if(o&&o2){
         if(Math.abs(o.y-o2.y)>2) bad.push('the alert is two lines ('+Math.round(o.y)+', '+Math.round(o2.y)+')');
         if(!(o2.x+o2.w<=RAIL.clL)) bad.push('the alert runs into the clock ('+Math.round(o2.x+o2.w)+' past '+Math.round(RAIL.clL)+')');
         if(!(o.x>=RAIL.scR)) bad.push('the alert runs into the score ('+Math.round(o.x)+' before '+Math.round(RAIL.scR)+')');
       }
       if(RAIL.b!==rh) bad.push('an alert hangs under the rail when it is standing');
       var PRF=CanvasRenderingContext2D.prototype, _fr=PRF.fillRect, red=0; PRF.fillRect=function(x,y,w){ if(this===ctx&&x===0&&y===0&&w>=W&&/^rgba\(66, ?18, ?15/.test(String(this.fillStyle))) red++; return _fr.apply(this,arguments); }; try{ drawHUD(); } finally { PRF.fillRect=_fr; }
       if(!red) bad.push('a danger does not tint the rail red');
       // THREE: down, on the rail, no score beside it; a danger takes its own line under the rail
       quiet(); p.downed=true; p.downT=11.05; p.revived=false;
       frame(); frame();
       band('the word down',/^down$/i); band('the down timer',/^11\.05s$/); band('the self-revive words',/^self-revive/i); band('the clock while down',/^\d+:\d\d$/); band('the extract line while down',/^extract \d+m/i);
       if(find(/^2,730 sp$/i)) bad.push('the score still draws under the down card');
       alertSay('TEST STRIP DANGER','warn',{key:'t-strip2'}); if(g.alert) g.alert.at=(g.t||0)-1;
       frame(); frame();
       band('a danger while down',/^test strip danger$/i,rh,rh+60*z);
       quiet(); p.revived=true;
       frame(); frame();
       band('the bleeding out line',/^bleeding out/i); band('the surrender prompt',/surrender/i,rh,rh+40*z);
       if(!(HUDTOPB>rh)) bad.push('the line under the rail is not counted in the top band');
       p.downed=false; p.revived=false; __endRaid('abandon'); __topClear();
       // FOUR: two players, both shares on the rail; the shares step aside for an alert
       CAREER_ON=c0;
       if(arcadeDeploy({mapIx:0,seed:4242})){
         g=__state(); p=g.player; ARCADE.solo=0; ARCADE.role='host'; ARCADE.mine=105; ARCADE.mate=105; g.ents=[]; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.timeLeft=300; quiet();
         frame(); frame();
         band('the team score',/^210 sp$/i); band('your share',/^you 105 sp$/i); band('the partner share',/^p2 105 sp$/i); band('the team label',/^team score$/i);
         alertSay('TEST STRIP ALERT','warn',{key:'t-strip3'}); if(g.alert) g.alert.at=(g.t||0)-1;
         frame(); frame();
         if(find(/^you 105 sp$/i)) bad.push('the shares do not step aside for an alert');
         band('the team score beside an alert',/^210 sp$/i);
         quiet(); if(typeof easyAnswer==='function') easyAnswer(false); g.timeLeft=90; g.arcRushSaid=0; arcadeRushTick(); if(g.alert) g.alert.at=(g.t||0)-1;
         frame(); frame();
         band('the final rush',/^final rush$/i);
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       hudFadeBegin=HFB; CAREER_ON=c0; keys={};
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){} try{ ARCADE.role=role0; ARCADE.solo=solo0; }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

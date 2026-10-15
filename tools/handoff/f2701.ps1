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

if ($s.Contains("  {v:'27.01',what:")) { throw "check 27.01 is in the fixture already" }

SubRx @'
  {v:'27.00',what:
'@ @'
  {v:'27.01',what:'career4, his yes to the trophy case (33): the golden enemy and the Overseer are earned on the kill (not a plain warden), the other six are read from the profile, a trophy is given once, the arcade earns none, and the case on the stash lists all eight, lit or locked, and closes on CLOSE and ESC',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__ents)) return 'SKIP: this fixture cannot deploy';
     if(typeof trophyGive!=='function'||typeof TROPHIES==='undefined') return 'there is no trophy case in this build';
     if(typeof mkCrawler!=='function'||typeof mkWarden!=='function') return 'SKIP: no raid pieces here';
     var bad=[], snap=null, g=null, p=null, q, e, i, L, tiles, yes, no, t, m, ar0, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, ws, k;
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); delete q.trophies; q.ext=0; q.ach={}; q.gunKills={}; q.forged={}; q.codex={};
       if(TROPHIES.length!==8) bad.push('ONE: '+TROPHIES.length+' trophies, not 8');
       // ONE: given once, and only a real one
       if(!trophyGive('firstout')) bad.push('ONE: FIRST OUT was not given');
       if(trophyGive('firstout')) bad.push('ONE: FIRST OUT was given twice');
       if(trophyGive('nosuchtrophy')) bad.push('ONE: a trophy that does not exist was given');
       delete q.trophies;
       // TWO: the six read from the profile
       if(trophyScan(false)!==0) bad.push('TWO: a bare profile earned a trophy');
       q.ext=3; trophyScan(false); if(!trophyHas('firstout')) bad.push('TWO: an extraction did not earn FIRST OUT');
       q.ach={ghost:1,haul20k:1}; trophyScan(false); if(!trophyHas('ghost')||!trophyHas('motherlode')) bad.push('TWO: the achievements did not earn GHOST and MOTHERLODE');
       q.gunKills={rifle:99}; trophyScan(false); if(trophyHas('centurion')) bad.push('TWO: 99 kills earned CENTURION');
       q.gunKills={rifle:100}; trophyScan(false); if(!trophyHas('centurion')) bad.push('TWO: 100 kills did not earn CENTURION');
       q.forged={rifle:{fk:2,el:'cryo'}}; q.weapons=['pistol']; trophyScan(false); if(trophyHas('forged')) bad.push('TWO: a MK III gun not in the armoury earned FORGED');
       q.weapons=['pistol','rifle']; trophyScan(false); if(!trophyHas('forged')) bad.push('TWO: a kept MK III gun did not earn FORGED');
       L=codexGuns(); q.codex={}; for(i=0;i<L.length-1;i++) q.codex[L[i]]=1;
       trophyScan(false); if(trophyHas('armory')) bad.push('TWO: all but one gun earned FULL ARMORY');
       q.codex[L[L.length-1]]=1; trophyScan(false); if(!trophyHas('armory')) bad.push('TWO: every gun did not earn FULL ARMORY');
       // THREE: the two kills
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false; q=__P();
       e=mkCrawler(p.x+60,p.y); e.hp=0; e.byPlayer=1; g.ents=[e]; __ents(0.016);
       if(trophyHas('golden')) bad.push('THREE: a plain kill earned GOLD HUNTER');
       e=mkWarden(p.x+60,p.y); e.hp=0; e.byPlayer=1; e.boss=0; g.ents=[e]; __ents(0.016);
       if(trophyHas('overseer')) bad.push('THREE: a plain Warden earned OVERSEER DOWN');
       ar0=g.arcade; g.arcade=1; e=mkCrawler(p.x+60,p.y); e.golden=1; trophyKill(e); g.arcade=ar0;
       if(trophyHas('golden')) bad.push('THREE: the arcade earned GOLD HUNTER');
       e=mkCrawler(p.x+60,p.y); e.golden=1; e.hp=0; e.byPlayer=1; g.ents=[e]; __ents(0.016);
       if(!trophyHas('golden')) bad.push('THREE: killing the golden enemy did not earn GOLD HUNTER');
       e=mkWarden(p.x+60,p.y); e.boss=1; e.name=BOSS_NAME; e.hp=0; e.byPlayer=1; g.ents=[e]; __ents(0.016);
       if(!trophyHas('overseer')) bad.push('THREE: killing the Overseer did not earn OVERSEER DOWN');
       __endRaid('abandon'); __topClear();
       // FOUR: the case on the stash
       renderHub();
       t=document.getElementById('trophybtn');
       if(!t||t.textContent.indexOf('TROPHIES')<0) bad.push('FOUR: no TROPHIES button on the stash');
       else {
         t.onclick();
         m=document.getElementById('trophymodal');
         if(!m||!m.classList.contains('on')) bad.push('FOUR: the button did not open the case');
         else {
           tiles=document.querySelectorAll('#trophygrid .trp'); yes=document.querySelectorAll('#trophygrid .trp.yes'); no=document.querySelectorAll('#trophygrid .trp.no');
           if(tiles.length!==8) bad.push('FOUR: '+tiles.length+' plaques, not 8');
           if(yes.length!==trophyCount()) bad.push('FOUR: '+yes.length+' lit plaques for '+trophyCount()+' earned');
           for(i=0;i<no.length;i++) if(no[i].textContent.indexOf('LOCKED')<0){ bad.push('FOUR: a dark plaque does not say LOCKED'); break; }
           if(!document.getElementById('closetrophy')) bad.push('FOUR: the case has no CLOSE');
           if(!backOut()||m.classList.contains('on')) bad.push('FOUR: ESC did not close the case');
           t=document.getElementById('trophybtn');
           if(t){ t.onclick(); document.getElementById('closetrophy').click(); if(m.classList.contains('on')) bad.push('FOUR: CLOSE did not close the case'); }
         }
       }
       // FIVE: an old save with no trophies draws
       q=__P(); delete q.trophies;
       try{ renderHub(); renderTrophies(); }catch(ex){ bad.push('FIVE: an old save with no trophies threw: '+(ex&&ex.message||ex)); }
       // SIX: the raid loop is not asked for a thing it does not have
       ws=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       if(ws.indexOf('trophyKill'+'(e); }catch')<0) bad.push('SIX: the kill path never calls trophyKill');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ CAREER_ON=c0; }catch(_c0){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ keys={}; }catch(_k){}
       try{ var mm=document.getElementById('trophymodal'); if(mm) mm.classList.remove('on'); }catch(_m){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

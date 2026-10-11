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

if ($s.Contains("  {v:'22.76',what:")) { throw "check 22.76 is in the fixture already" }

SubRx @'
  {v:'22.75',what:
'@ @'
  {v:'22.76',what:'notoriety is said once: an unarmed Survivor killed by the player through the entity update and a peaceful pillager he hits each set the notoriety stamp and push the NOTORIETY +1 label, and no line said names Notoriety; helping a Survivor says NOTORIETY DOWN TO and the new total',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents)) return 'SKIP: this fixture cannot deploy or step the entities';
     if(typeof notoAggress!=='function'||typeof strayGive!=='function'||typeof notoStamp!=='function'||!ITEMS.bandage) return 'SKIP: no notoriety, Survivor or stamp in this build';
     var bad=[], g=null, p=null, _say=say, said=[], keepN=P.notoriety, keepX=P.notExt, keepEnts=null, keepBag=null, keepC=P.credits, i, n=0, NO='Noto'+'riety', DN='NOTORIETY DOWN '+'TO', st, rd, hasL;
     function lbl(){ var L=g.labels||[], j; for(j=0;j<L.length;j++) if(String(L[j].txt).indexOf('NOTORIETY +1')===0) return true; return false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the raid is a sim';
       p=g.player; p.iv=99; keepEnts=g.ents; keepBag=g.bag.slice();
       say=function(m){ said.push(String(m)); try{ return _say.apply(this,arguments); }catch(_s){} };
       P.notoriety=1; g.notoAt=undefined; g.labels=[];
       // ONE: an unarmed Survivor the player killed, through the entity update.
       st={kind:'stray',x:p.x+400,y:p.y+400,r:11,hp:0,maxhp:70,face:0,coat:'#7a8a6a',name:'SURVIVOR',neutral:1,bag:[],stock:[],want:'bandage',helped:0,found:0,askedT:0,
           state:'idle',tx:p.x+400,ty:p.y+400,cd:0,alert:0,spd:0,dmg:0,rng:0,cone:0,hitT:0,step:0,goal:null,skips:[],goalT:0,goalD:0,extracting:0,byPlayer:1};
       g.ents=[st];
       __ents(0.016);
       if(g.ents.indexOf(st)>=0) return 'SKIP: staging: the entity update did not take the dead Survivor off the list';
       if(P.notoriety!==2) return 'SKIP: staging: the Survivor killed by the player charged no point here ('+P.notoriety+')';
       if(!(typeof g.notoAt==='number')) bad.push('the unarmed Survivor set no notoriety stamp');
       if(!lbl()) bad.push('the unarmed Survivor pushed no NOTORIETY +1 label');
       // TWO: a peaceful pillager he hits.
       g.notoAt=undefined; g.labels=[];
       rd={kind:'raider',x:p.x+300,y:p.y,hostile:false};
       if(!notoAggress(rd)) bad.push('SKIP: staging: hitting a peaceful pillager charged nothing');
       else { if(!(typeof g.notoAt==='number')) bad.push('the peaceful pillager set no notoriety stamp'); if(!lbl()) bad.push('the peaceful pillager pushed no NOTORIETY +1 label'); }
       for(i=0;i<said.length;i++) if(said[i].indexOf(NO)>=0) n++;
       if(n) bad.push(n+' lines named Notoriety over the stamp and the label: '+said.filter(function(s){ return s.indexOf(NO)>=0; }).join(' | '));
       // THREE: a Survivor helped takes a point off and says the new total once.
       g.ents=[]; said.length=0; P.notoriety=3; g.bag=['bandage'];
       st={kind:'stray',x:p.x+40,y:p.y,r:11,hp:70,maxhp:70,face:0,name:'SURVIVOR',neutral:1,bag:[],stock:[],want:'bandage',helped:0,found:0,askedT:0,state:'idle',tx:p.x+40,ty:p.y,cd:0,alert:0,hitT:0,goal:null,skips:[]};
       g.ents.push(st);
       strayGive(st);
       if(st.helped&&P.notoriety===2){
         var all=said.concat((g.msgQ||[]).map(String)), dn=0, nn=0;
         for(i=0;i<all.length;i++){ if(all[i].indexOf(DN+' 2')===0) dn++; if(all[i].indexOf(NO)>=0) nn++; }
         if(dn!==1) bad.push('helping a Survivor at notoriety 3 said '+dn+' NOTORIETY DOWN TO 2 rows, not one ('+all.join(' | ')+')');
         if(nn) bad.push('helping a Survivor said a Notoriety sentence ('+all.join(' | ')+')');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=_say;
       try{ P.notoriety=keepN; P.notExt=keepX; P.credits=keepC; saveProfile(); }catch(_p){}
       try{ if(g&&keepEnts) g.ents=keepEnts; if(g&&keepBag) g.bag=keepBag; }catch(_n){}
       try{ var g2=__state(); if(g2){ g2.notoAt=undefined; g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

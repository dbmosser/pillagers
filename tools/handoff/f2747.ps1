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

if ($s.Contains("  {v:'27.47',what:")) { throw "check 27.47 is in the fixture already" }

SubRx @'
  {v:'27.46',what:
'@ @'
  {v:'27.47',what:'nocluehunt, his answer (cut the golden clue hunt, keep the golden enemy every raid): there is no clue hunt (no props, no search circle, no clue words or marks, no clue code), the golden enemy is still gilded in every raid, it is said once, it is a gold mark on the maps within 900 of the player and not beyond, and the world word to player 2 names the golden body and no hunt',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof goldTick!=='function'||typeof flowMarks!=='function') return 'SKIP: no arcade or golden enemy here';
     var bad=[], g=null, p=null, i, s, sd, S, e, M, n, mk, txt='', sc=[].slice.call(document.scripts), need, lines=[], rs=say, own=false, got=0, oS=null, rowOut=null;
     try{
       // ONE: the hunt is out of the game: no functions, no constants, no words (assembled needles, so this check does not find itself)
       try{ if(typeof clueLayout==='function') bad.push('ONE: clueLayout is still a function'); }catch(_c0){}
       try{ if(typeof clueTick==='function') bad.push('ONE: clueTick is still a function'); }catch(_a){}
       try{ if(typeof clueMarks==='function') bad.push('ONE: clueMarks is still a function'); }catch(_b){}
       for(i=0;i<sc.length;i++) txt+=(sc[i].textContent||'');
       need=[['function clue'+'Layout(','the layout'],['function clue'+'Tick(','the tick'],['function clue'+'Draw(','the drawing'],['function clue'+'Marks(','the marks'],['function clue'+'NetOut(','the word to player 2'],["'GOLD DUST"+" TRAIL'",'a prop name'],["'DROPPED"+" SCANNER'",'a prop name'],["'CHIRPING"+" BEACON'",'a prop name'],["SEARCH CIRCLE"+" ON THE MAP",'the callout'],["'CLUE '"+"+C.n",'the clue callout']];
       for(i=0;i<need.length;i++) if(txt.indexOf(need[i][0])>=0) bad.push('ONE: the game still has '+need[i][1]+' ('+need[i][0]+')');
       // TWO: the golden enemy stays, every raid (three seeds, two maps), said once
       for(sd=0;sd<3;sd++){
         __topClear(); __runPrep();
         if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
         if(!arcadeDeploy({mapIx:sd%2,seed:4242+sd})) return 'SKIP: arcadeDeploy built no arcade raid';
         g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
         p=g.player; keys={}; lines.length=0; say=function(q,kd,o){ lines.push(String(q)+'|'+((o&&o.sub)||'')); }; own=true;
         g.t=4.5; flowTick(0.1); flowTick(0.1);
         S=g.flow&&g.flow.gold;
         if(!S||!S.ref){ bad.push('TWO: seed '+(4242+sd)+' gilded no machine'); }
         else {
           got++;
           if(!S.ref.golden) bad.push('TWO: the machine is not gilded');
           if(g.flow.clue) bad.push('TWO: the raid still keeps a clue hunt');
           n=0; for(i=0;i<lines.length;i++) if(/^GOLDEN ENEMY\|/.test(lines[i])) n++;
           if(n!==1) bad.push('TWO: the golden enemy was announced '+n+' times, not once ('+lines.join(' / ')+')');
           // THREE: the mark: on the maps within 900, not beyond
           e=S.ref; p.x=e.x+400; p.y=e.y; M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='gold'&&Math.abs(M[i].x-e.x)<1) mk++;
           if(mk!==1) bad.push('THREE: the golden enemy is '+mk+' marks 400 away');
           p.x=e.x+GOLD_NEAR+300; M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='gold') mk++;
           if(mk) bad.push('THREE: the golden enemy is a mark 1,200 away');
         }
         say=rs; own=false;
         try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
         try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       }
       // FOUR: the world word to player 2 names the golden body and no hunt
       if(typeof flowNetOut==='function'){
         __topClear(); __runPrep();
         if(arcadeDeploy({mapIx:0,seed:4242})){
           g=__state(); p=g.player; g.t=4.5; flowTick(0.1); flowTick(0.1); netEntsInit(g);
           rowOut=flowNetOut();
           if(!rowOut||!rowOut.g) bad.push('FOUR: the flow word does not name the golden enemy ('+JSON.stringify(rowOut&&Object.keys(rowOut))+')');
           if(rowOut&&rowOut.c!==undefined) bad.push('FOUR: the flow word still carries a hunt');
         }
       }
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     if(!got&&!bad.length) bad.push('TWO: no raid gilded a machine');
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

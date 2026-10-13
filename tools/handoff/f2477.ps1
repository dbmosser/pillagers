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

if ($s.Contains("  {v:'24.77',what:")) { throw "check 24.77 is in the fixture already" }

SubRx @'
  {v:'24.76',what:
'@ @'
  {v:'24.77',what:'his answer 20: after the RUN OVER score counts up, the card shows the best moments of the run (BEST STREAK, BIGGEST HAUL, LONGEST SHOT), with P1 or P2 from the score word in the 2 player demo',
   run:function(){
     var bad=[], sv=null, src0, tried0, c, b, tx, g, p, i, lk=null, vk=0, bk=null, keys0, ki=null;
     function q(cl){ return ATT.el?ATT.el.querySelector('.'+cl):null; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeOverSync!=='function'||typeof ARCADE!=='object'||typeof arcadeEnter!=='function'||typeof arcadeKill!=='function') return 'SKIP: no RUN OVER card in this build';
       if(typeof arcadeOverCount!=='function') return 'SKIP: the score count-up (v23.xx runcount) is not in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       try{ bk=localStorage.getItem(ARCADE_BOARD_KEY); }catch(_b){}
       sv={bc:NET.bc,same:NET.same,pair:NET.pair};
       NET.bc={postMessage:function(){},close:function(){}}; NET.same='host'; NET.pair='tp';
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true;
       if(!arcadeEnter('host')) return 'SKIP: arcadeEnter(host) failed';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: no demo raid';
       g=__state(); p=g&&g.player; if(!g||!g.arcade||!p) return 'SKIP: no demo raid';
       keys0=Object.keys(ITEMS);
       for(i=0;i<keys0.length;i++){ var v0=ival(keys0[i]); if(v0>vk&&v0<5000&&ITEMS[keys0[i]].use!=='gun') { vk=v0; lk=keys0[i]; } }
       if(!lk) return 'SKIP: no valuable to loot';
       g.t=50;
       arcadeKill('raider',false,false,p.x+U_PER_M*12,p.y);
       arcadeKill('raider',false,false,p.x+U_PER_M*30,p.y);
       arcadeKill('raider',false,false,p.x,p.y+U_PER_M*5);
       var n1=arcadeLoot(lk), n2=arcadeLoot(lk);
       ARCADE.deaths=(ARCADE.deaths|0)+1; var n3=arcadeLoot(lk);
       arcadeScTake({t:'arcsc',pair:'tp',run:ARCADE.run.id,s:100,k:1,x:0,bm:[6,0,80]});
       ki=1; arcadeRunEnd('menu');
       if(!ARCADE.over||!ARCADE.over.bm) return 'the run end keeps no best moments';
       ARCADE.over.at=Date.now()-200; arcadeAttShow(); b=q('aobm');
       if(b&&b.style.display!=='none') bad.push('the best moments show before the score has counted up');
       ARCADE.over.at=Date.now()-3000; arcadeAttShow(); b=q('aobm'); c=q('arcover');
       tx=b?b.textContent:'';
       if(!b||b.style.display==='none') bad.push('no best moments on the RUN OVER card after the count ('+(c?c.textContent:'no card')+')');
       else {
         if(tx.indexOf('BEST '+'STREAK')<0||tx.indexOf('6 KILLS')<0||tx.indexOf('P2')<0) bad.push('BEST STREAK is not the 6 of player 2 ('+tx+')');
         if(tx.indexOf('LONGEST '+'SHOT')<0||tx.indexOf('80 M')<0) bad.push('LONGEST SHOT is not the 80 m of player 2 ('+tx+')');
         if(tx.indexOf('BIGGEST '+'HAUL')<0||tx.indexOf(arcadeCr(n1+n2))<0||tx.indexOf('P1')<0) bad.push('BIGGEST HAUL is not the '+arcadeCr(n1+n2)+' of player 1 in one life ('+tx+')');
       }
       if(!(ARCADE.bm&&ARCADE.bm.st===3&&ARCADE.bm.ls===30)) bad.push('this window kept streak '+(ARCADE.bm&&ARCADE.bm.st)+' and shot '+(ARCADE.bm&&ARCADE.bm.ls)+', not 3 and 30');
       if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('no second demo drop');
       else if(ARCADE.bm.st||ARCADE.bm.hl||ARCADE.bm.ls||ARCADE.mateBm) bad.push('a new run kept the best moments of the last one');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ ARCADE.over=null; ARCADE.ini=null; }catch(_o){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ NET.bc=sv.bc; NET.same=sv.same; NET.pair=sv.pair; } }catch(_n){}
       try{ if(sv){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       try{ if(sv){ if(bk===null) localStorage.removeItem(ARCADE_BOARD_KEY); else localStorage.setItem(ARCADE_BOARD_KEY,bk); } }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'23.42',what:")) { throw "check 23.42 is in the fixture already" }

SubRx @'
  {v:'23.41',what:
'@ @'
  {v:'23.42',what:'arcade19, his order 2026-10-11: the controls card, arcadeCardRows gives 8 rows with a keyboard and a pad label, the HOW TO PLAY page draws them, the card shows MOVE at the left while shielded and is gone after the shield drops plus 5 s of frames, and a normal raid never draws it',
   run:function(){
     var bad=[], g=null, g2=null, rows, i, nm, pg, txt, br=null, ownB=false, tr, mv, sg, t0, f, base, pr, nMove='MO'+'VE', nSw='SWITCH '+'GUN';
     function find(list,s){ var j; for(j=0;j<list.length;j++) if(list[j].t===s) return list[j]; return null; }
     function frame(ts){ return __textTrace(function(){ __loop(ts); }); }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeCardRows!=='function') return 'no arcadeCardRows in this build';
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       rows=arcadeCardRows();
       if(!rows||rows.length!==8) bad.push('arcadeCardRows gives '+(rows?rows.length:'no')+' rows, not 8');
       nm=(rows||[]).map(function(r){ return r&&r[0]; }).join(',');
       if(nm!=='MOVE,AIM,FIRE,ROLL,RELOAD,SWITCH GUN,HEAL,EXTRACT') bad.push('the card rows are '+nm);
       for(i=0;i<(rows||[]).length;i++){ if(!rows[i]||typeof rows[i][1]!=='string'||!rows[i][1]||typeof rows[i][2]!=='string'||!rows[i][2]) bad.push('row '+i+' lacks a keyboard or a pad label'); }
       if(rows&&rows[7]&&rows[7][1].indexOf('HOLD ')!==0) bad.push('the EXTRACT keyboard label is '+rows[7][1]);
       if(typeof PAD==='object'&&PAD){ br=PAD.brand; ownB=true; PAD.brand='ps'; pr=arcadeCardRows(); PAD.brand=br; ownB=false;
         if(!pr[7]||pr[7][2].indexOf(' IN A TEAL RING')<0) bad.push('on a PlayStation pad the EXTRACT pad label reads '+(pr[7]&&pr[7][2])); }
       pg=document.createElement('div'); arcadeAttHow(pg); txt=pg.textContent||'';
       if(pg.querySelectorAll('tr').length!==9) bad.push('the HOW TO PLAY page has '+pg.querySelectorAll('tr').length+' table rows, not 9 (a head and 8)');
       if(txt.indexOf(nSw)<0||txt.indexOf('HEAL')<0) bad.push('the HOW TO PLAY page lacks SWITCH GUN or HEAL');
       if(!arcadeDeploy({mapIx:0,seed:4242})) return bad.length?bad.join('; '):'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
       if(!g||!g.player||!g.player.arcSh) return bad.length?bad.join('; '):'SKIP: the arcade drop is not shielded';
       base=performance.now()+1000;
       tr=frame(base); mv=find(tr,nMove); sg=find(tr,nSw);
       if(!mv||!sg) bad.push('no controls card (MOVE and SWITCH GUN) on a shielded drop');
       else if(!(mv.x<hcv.width*0.45)) bad.push('the controls card MOVE sits at x '+Math.round(mv.x)+', not at the left');
       arcadeShieldOff(); t0=+g.t||0;
       tr=frame(base+100);
       if(!find(tr,nMove)) bad.push('the card is gone at once when the shield drops');
       for(f=2;f<=110&&__state()===g&&!g.over;f++) __loop(base+f*100);
       if(__state()!==g||g.over) bad.push('the arcade raid ended during the frames');
       else if(g.player.arcSh) return bad.length?bad.join('; '):'SKIP: the player was shielded again (a respawn) during the frames';
       else if(!((+g.t||0)-t0>=4.5)) return bad.length?bad.join('; '):'SKIP: the frames advanced game time by only '+((+g.t||0)-t0).toFixed(2)+' s';
       else { tr=frame(base+111*100); if(find(tr,nMove)||find(tr,nSw)) bad.push('the controls card still shows 5 s after the shield dropped'); }
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l1){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e1){}
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g2=__state();
       if(!g2) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       if(g2.arcade) bad.push('a normal raid is flagged arcade');
       g2.player.arcSh=1;
       tr=frame(performance.now()+20000);
       g2.player.arcSh=0;
       if(find(tr,nSw)) bad.push('a normal raid draws the controls card');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownB){ try{ PAD.brand=br; }catch(_pb){} }
       try{ if(g2&&g2.player) delete g2.player.arcSh; }catch(_ds){}
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.holdT=0; ARCADE.waveT=0; } }catch(_m){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

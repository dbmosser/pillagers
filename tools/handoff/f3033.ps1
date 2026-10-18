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

if ($s.Contains("  {v:'30.33',what:")) { throw "check 30.33 is in the fixture already" }

SubRx @'
  {v:'30.32',what:
'@ @'
  {v:'30.33',what:'his Q65: in the 2 player demo one extraction does not end the run; it ends when both players have extracted, in either order',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__loop&&window.__endRaid)) return 'SKIP: this fixture cannot step a raid';
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof arcadeOnMsg!=='function'||typeof arcadeMateLive!=='function'||typeof ARCADE!=='object'||typeof NET!=='object') return 'SKIP: no arcade here';
     var bad=[], g, f, bk=null, hadB=false, BK=(typeof ARCADE_BOARD_KEY==='string')?ARCADE_BOARD_KEY:'', nsp=netSamePost, aml=arcadeMateLive, ns0=NET.same, r;
     function step(){ for(f=0;f<8&&__state()===g;f++) __loop(performance.now()+f*16.7); }
     function fresh(){ if(!arcadeDeploy({mapIx:0,seed:4242})) return false; g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.over=null; ARCADE.ini=null; return !!(g&&g.arcade); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(BK){ try{ bk=localStorage.getItem(BK); hadB=true; localStorage.removeItem(BK); }catch(_b){} }
       netSamePost=function(){ return true; }; arcadeMateLive=function(){ return true; };
       // the host extracts first
       if(!fresh()) return 'SKIP: arcadeDeploy built no arcade raid';
       ARCADE.solo=0; ARCADE.run={id:'tq65a'}; ARCADE.mine=1500; ARCADE.mate=400;
       __endRaid('extract'); step();
       if(__state()!==g||ARCADE.over) bad.push('the host extracting ended a 2 player run while player 2 is still up');
       else {
         if(!g.player.specOut) bad.push('the host who extracted is not stood out');
         NET.same='host';
         r=arcadeOnMsg({t:'arcx',pair:NET.pair,run:'tq65a',s:500,k:2}); step();
         if(__state()===g) bad.push('both players extracted and the run did not end');
         else if(!ARCADE.over||ARCADE.over.team!==4000) bad.push('after both extracted the team score is '+(ARCADE.over&&ARCADE.over.team)+', not (1500+500) x2 = 4000');
       }
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e1){}
       // player 2 extracts first
       if(!fresh()) return bad.concat(['SKIP: no second arcade raid']).join('; ');
       ARCADE.run={id:'tq65b'}; ARCADE.mine=1000; ARCADE.mate=200; NET.same='host';
       r=arcadeOnMsg({t:'arcx',pair:NET.pair,run:'tq65b',s:300,k:2}); step();
       if(__state()!==g||ARCADE.over) bad.push('player 2 extracting ended the run while the host is still playing (word answered '+r+')');
       else {
         __endRaid('extract'); step();
         if(__state()===g) bad.push('both players extracted (player 2 first) and the run did not end');
         else if(!ARCADE.over||ARCADE.over.team!==2600) bad.push('after both extracted (player 2 first) the team score is '+(ARCADE.over&&ARCADE.over.team)+', not (1000+300) x2 = 2600');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       netSamePost=nsp; arcadeMateLive=aml; NET.same=ns0; keys={};
       try{ ARCADE.ini=null; }catch(_i){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.solo=0; ARCADE.mine=0; ARCADE.mate=0; ARCADE.mateK=0; ARCADE.mateX=0; ARCADE.kills=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null; ARCADE.run=null; ARCADE.x2=0; ARCADE.xOut=0; ARCADE.endSend=null; }catch(_m){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_b2){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

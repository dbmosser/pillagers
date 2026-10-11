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

if ($s.Contains("  {v:'23.22',what:")) { throw "check 23.22 is in the fixture already" }

SubRx @'
  {v:'23.21',what:
'@ @'
  {v:'23.22',what:'his order: an arcade death drops him back into the same raid with a fresh kit and a hold, nothing settled, and an abandon stops it with no fee',
   run:function(){
     var bad=[], g, p, runs0, xp0, f, x0, y0, oc, rE0=null, el, t0;
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player; runs0=P.runs;
       killPlayer('t');
       if(!(g.deathBeat>0)) bad.push('killPlayer opened no death beat');
       for(f=0;f<150;f++){ __loop(performance.now()+f*16.7); if(__state()!==g||g.deathBeat==null) break; }
       if(__state()!==g) bad.push('the arcade raid was ended or replaced by the death');
       if(g.over) bad.push('the arcade raid ended ('+g.over+')');
       if(p.hp!==p.maxhp) bad.push('hp is '+p.hp+' of '+p.maxhp+' after the respawn');
       if(g.deathBeat!=null) bad.push('the death beat is still '+g.deathBeat);
       if(p.dying||p.downed) bad.push('the player is still dying or downed');
       if(ARCADE.deaths!==1) bad.push('ARCADE.deaths is '+ARCADE.deaths);
       if(P.runs!==runs0) bad.push('a run was counted ('+runs0+' to '+P.runs+')');
       oc=document.getElementById('outcome');
       if(oc&&oc.classList.contains('on')) bad.push('the outcome card is on');
       if(!(ARCADE.holdT>2)) bad.push('the drop-in hold is '+ARCADE.holdT);
       if(typeof spotFree==='function'&&!spotFree(g.map,p.x,p.y,10)) bad.push('the respawn spot is inside a wall');
       if(!g.over&&__state()===g){
         x0=p.x; y0=p.y; keys.KeyD=true; keys.KeyS=true;
         for(f=0;f<20;f++) __loop(performance.now()+f*16.7);
         keys.KeyD=false; keys.KeyS=false;
         if(Math.abs(p.x-x0)>1||Math.abs(p.y-y0)>1) bad.push('he moved during the drop-in hold');
         if(!(ARCADE.holdT<3)) bad.push('the hold did not count down');
         P.xp=5000; xp0=P.xp;
         rE0=runElapsed; runElapsed=function(){ return 600; };
         el=document.getElementById('confirmabandon');
         el.onclick.call(el);
         runElapsed=rE0; rE0=null;
         if(__state()) bad.push('the abandon left an arcade raid in hand');
         if(!ARCADE.on) bad.push('the abandon left the arcade');
         if(P.xp!==xp0) bad.push('the abandon took '+(xp0-P.xp)+' XP');
         if(P.runs!==runs0) bad.push('the abandon counted a run');
         if(oc&&oc.classList.contains('on')) bad.push('the outcome card is on after the abandon');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(rE0) runElapsed=rE0;
       keys.KeyD=false; keys.KeyS=false;
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

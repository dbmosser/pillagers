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

if ($s.Contains("  {v:'26.04',what:")) { throw "check 26.04 is in the fixture already" }

SubRx @'
  {v:'26.03',what:
'@ @'
  {v:'26.04',what:'his note: crouched and kept still, health creeps back one point every two seconds up to 85; a move, a hit or standing up stops it and the wait starts over',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__sim||!window.__keys||typeof tickRegen!=='function'||typeof damagePlayer!=='function'||typeof drawHUD!=='function') return 'SKIP: no raid here';
     var bad=[], g, p, K, q, hp0, said=[], own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText;
     function run(sec){ var n=Math.round(sec/0.05), i; for(i=0;i<n;i++) __sim(0.05); }
     function stage(hp){
       for(q in K) delete K[q];
       p.hp=hp; p.maxhp=100; p.downed=false; p.dying=false; p.iv=0; p.roll=0; p.ads=false; p.healQ=0; p.stimT=0;
       p.combatT=0; p.regenAcc=0; p.hurtAt=-999; p.crQuiet=99; p.crStill=0; p.crAcc=0; p.crX=undefined; p.crY=undefined;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       K=__keys(); g.ents.length=0; g.t=Math.max(g.t||0,30);
       // A: crouched and still for 12 seconds, the RECOVERING mark up at 7 seconds (inside the 10 the old creep wants)
       stage(50); G.crouchTog=true;
       run(7);
       ctx.fillText=function(t){ said.push(String(t)); return of.apply(this,arguments); };
       drawHUD();
       if(own) ctx.fillText=of; else delete ctx.fillText;
       if(!said.some(function(t){ return t.indexOf('RECOVERING')>=0; })) bad.push('crouched and still, seven seconds in, the HUD does not say RECOVERING');
       run(5);
       if(!(p.hp-50>=3&&p.hp-50<=5)) bad.push('crouched and still for 12 seconds from 50 he went to '+p.hp+' (wanted a rise of about 4)');
       // B: standing still, nine seconds: nothing
       stage(50); G.crouchTog=false; run(9);
       if(p.hp!==50) bad.push('standing still for 9 seconds he went from 50 to '+p.hp+', so standing heals too');
       // C: crouched but walking, nine seconds: nothing
       stage(50); G.crouchTog=true; K.KeyW=true; run(9); delete K.KeyW;
       if(p.hp!==50) bad.push('crouched and walking for 9 seconds he went from 50 to '+p.hp+', so moving does not stop it');
       // D: a hit starts the 6 quiet seconds over
       stage(50); G.crouchTog=true; run(6);
       if(!(p.hp>50)) bad.push('control: crouched and still for 6 seconds he did not rise at all (hp '+p.hp+')');
       var before=p.hp; damagePlayer(10,'test','Test'); hp0=p.hp;
       if(!(hp0<before)) return 'SKIP: the staged hit did not land (hp '+before+' to '+hp0+')';
       run(5.5);
       if(p.hp!==hp0) bad.push('5.5 seconds after a hit he went from '+hp0+' to '+p.hp+', inside the 6 quiet seconds');
       run(3.5);
       if(!(p.hp>hp0&&p.hp<=hp0+2)) bad.push('9 seconds after a hit he went from '+hp0+' to '+p.hp+' (wanted one or two points once the 6 had passed)');
       // E: from 84 it stops at 85; above 85 it does nothing
       stage(84); G.crouchTog=true; run(12);
       if(p.hp!==85) bad.push('from 84 crouched and still for 12 seconds he went to '+p.hp+' (wanted 85, the Bandage ceiling)');
       stage(90); G.crouchTog=true; run(9);
       if(p.hp!==90) bad.push('at 90 crouched and still for 9 seconds he went to '+p.hp+' (wanted no change above 85)');
       // F: a move puts the 3 seconds back to the start
       stage(50); G.crouchTog=true; K.KeyW=true; run(2); delete K.KeyW; run(2.5);
       if(p.hp!==50) bad.push('2.5 seconds after he stopped walking he went from 50 to '+p.hp+', inside the 3 still seconds');
       run(3.5);
       if(!(p.hp>50)) bad.push('6 seconds after he stopped walking crouched he had not started to rise (hp '+p.hp+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(own) ctx.fillText=of; else delete ctx.fillText; }catch(_f){} try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; G.crouchTog=false; var g2=__state(); if(g2&&!g2.over){ g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'26.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'27.94',what:")) { throw "check 27.94 is in the fixture already" }

SubRx @'
  {v:'27.93',what:
'@ @'
  {v:'27.94',what:'his order (add the sounds): the air strike has sounds (a confirm and an inbound craft when it is called, the inbound alone in the other window, six blasts at their own pitch that are not the plain boom), every power-up has its own drop, pickup, last three seconds, end and bubble hit sounds, the medals are one climbing pop per tier (the streak DOUBLE KILL to UNSTOPPABLE medal1 to medal5, the style medals by plate tier), the golden enemy sounds once when gilded, and the haul reveal ticks by rarity',
   run:function(){
     if(!window.__endRaid||typeof arcadeDeploy!=='function'||typeof airCall!=='function'||typeof pwrTake!=='function'||typeof styMedal!=='function'||typeof scoreKill!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade raid here';
     if(typeof SPK_PWR!=='object'||typeof SPK_MEDALS!=='object') return 'the sound pack is not in this build (no SPK_PWR)';
     var bad=[], g=null, p, S, A, rs=say, rb=blip, rx=sfx, rt=styTone, own=false, heard=[], tones=[], i, k, it, st, b, kinds=['clip','dmg','rapid','shield'], ex, ik, rar, nd;
     function nm(kind){ return heard.filter(function(h){ return h[0]===kind; }).map(function(h){ return h[1]; }); }
     function cnt(kind,name){ return nm(kind).filter(function(x){ return x===name; }).length; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; ARCADE.holdT=0; g.t=5;
       say=function(){}; blip=function(t){ heard.push(['b',String(t)]); }; sfx=function(t,x,y,w){ heard.push(['s',String(t),x,y,w]); }; styTone=function(n){ tones.push(n); return true; }; own=true;
       // ONE: the air strike
       heard.length=0; airCall(p.x+300,p.y); A=airS();
       if(cnt('b','airConfirm')!==1) bad.push('ONE: calling the strike played airConfirm '+cnt('b','airConfirm')+' times, not once');
       if(cnt('b','airInbound')!==1) bad.push('ONE: calling the strike played airInbound '+cnt('b','airInbound')+' times, not once');
       heard.length=0; airStrikeFx(p.x-300,p.y,1.2,1);
       if(cnt('b','airInbound')!==1) bad.push('ONE: the other window strike played airInbound '+cnt('b','airInbound')+' times, not once');
       if(cnt('b','airConfirm')) bad.push('ONE: the other window strike played the caller confirm');
       heard.length=0; st=A.sk[0];
       for(i=0;i<6;i++) airBlast(st,i);
       b=heard.filter(function(h){ return h[0]==='s'&&h[1]==='airBoom'; });
       if(b.length!==6) bad.push('ONE: six blasts played '+b.length+' airBoom sounds');
       else for(i=0;i<6;i++) if(b[i][4]!==i) bad.push('ONE: blast '+i+' carries wid '+b[i][4]);
       if(cnt('s','boom')) bad.push('ONE: a strike blast still plays the plain boom');
       // TWO: the power-ups
       S=pwrS(); heard.length=0; tones.length=0; pwrDrop('clip',p.x+60,p.y);
       if(cnt('b','pwrAppear')!==1) bad.push('TWO: a drop played pwrAppear '+cnt('b','pwrAppear')+' times');
       S.items.length=0;
       for(i=0;i<kinds.length;i++){
         k=kinds[i]; it={k:k,x:p.x,y:p.y,t:0,life:16}; heard.length=0; tones.length=0; S.act={};
         pwrTake(S,it,p);
         if(cnt('b',SPK_PWR[k])!==1) bad.push('TWO: taking '+k+' played '+(nm('b').join(',')||'nothing')+', not '+SPK_PWR[k]);
         if(tones.length) bad.push('TWO: taking '+k+' still plays its old note');
       }
       ['clip','dmg','rapid','shield','pulse'].forEach(function(q){ if(!SPK_PWR[q]) bad.push('TWO: the power-up '+q+' has no pickup sound'); });
       S.act={dmg:0.02}; heard.length=0; pwrTick(p,0.05);
       if(cnt('b','pwrEnd')!==1) bad.push('TWO: a power-up running out played pwrEnd '+cnt('b','pwrEnd')+' times');
       S.act={rapid:3.02}; heard.length=0; pwrTick(p,0.05);
       if(cnt('b','pwrLast')!==1) bad.push('TWO: the last three seconds played pwrLast '+cnt('b','pwrLast')+' times');
       S.act={}; S.shSnd=undefined; heard.length=0; pwrShieldHit(p.x+30,p.y);
       if(cnt('b','pwrBubbleHit')!==1) bad.push('TWO: a bubble hit played pwrBubbleHit '+cnt('b','pwrBubbleHit')+' times');
       S.act={}; S.items.length=0;
       // FOUR: the golden enemy sounds once, when it is gilded
       heard.length=0; flowTick(0.1);
       ex=g.flow&&g.flow.gold;
       if(!ex||!ex.ref) bad.push('FOUR: no golden body was gilded to stage the sound');
       else {
         if(cnt('b','goldAppear')!==1) bad.push('FOUR: gilding the golden enemy played goldAppear '+cnt('b','goldAppear')+' times, not once');
         heard.length=0; flowTick(0.1); flowTick(0.1);
         if(cnt('b','goldAppear')) bad.push('FOUR: the golden enemy sound played again');
       }
       // THREE: the style medals by plate tier, the kill streak by level
       g.sty=null;
       heard.length=0; tones.length=0; styMedal('MELEE'+' KILL',10,p.x,p.y); ex=nm('b').filter(function(x){ return /^medal/.test(x); });
       if(ex.join(',')!=='medal1') bad.push('THREE: a copper medal played '+(ex.join(',')||'nothing')+', not medal1');
       heard.length=0; styMedal('LONG'+' SHOT',10,p.x,p.y); ex=nm('b').filter(function(x){ return /^medal/.test(x); });
       if(ex.join(',')!=='medal2') bad.push('THREE: an amber medal played '+(ex.join(',')||'nothing')+', not medal2');
       heard.length=0; styMedal('GRENADE'+' DOUBLE',10,p.x,p.y); ex=nm('b').filter(function(x){ return /^medal/.test(x); });
       if(ex.join(',')!=='medal3') bad.push('THREE: a gold medal played '+(ex.join(',')||'nothing')+', not medal3');
       if(tones.length) bad.push('THREE: a medal still plays its old note or tier voice ('+tones.length+')');
       b=[[1,'medal1'],[2,'medal2'],[3,'medal3'],[4,'medal4'],[7,'medal5']];
       for(i=0;i<b.length;i++){
         heard.length=0; scoreKill({streak:{n:b[i][0],t:g.t}},'crawler',false,false,p.x,p.y); ex=nm('b').filter(function(x){ return /^medal/.test(x); });
         if(ex.join(',')!==b[i][1]) bad.push('THREE: the streak reaching '+(b[i][0]+1)+' played '+(ex.join(',')||'nothing')+', not '+b[i][1]);
       }
       // FIVE: the haul reveal ticks by rarity, and not when it is skipped
       ik=Object.keys(ITEMS)[0]; rar=[['common','haulTick'],['uncommon','haulUncommon'],['rare','haulRare'],['elite','haulElite'],['gold','haulGold']];
       for(i=0;i<rar.length;i++){
         nd=document.createElement('span'); nd.setAttribute('data-r',rar[i][0]); nd.setAttribute('data-k',ik); nd.setAttribute('data-v','5');
         heard.length=0; haulShow(nd,false);
         if(nm('b').join(',')!==rar[i][1]) bad.push('FIVE: a '+rar[i][0]+' item played '+(nm('b').join(',')||'nothing')+', not '+rar[i][1]);
       }
       heard.length=0; haulShow(nd,true); if(nm('b').length) bad.push('FIVE: a skipped haul item still ticked');
       if(String(arcadeKill).indexOf('SPK_ME'+'DALS')<0) bad.push('THREE: the DEMO streak plays no medal pop (arcadeKill)');
       if(String(arcadeKill).indexOf('annC'+'ue(')>=0||String(scoreKill).indexOf('annC'+'ue(')>=0) bad.push('THREE: a streak still plays the old chime ladder');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own){ say=rs; blip=rb; sfx=rx; styTone=rt; }
       keys={};
       try{ if(g) g.sty=null; }catch(_gs){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

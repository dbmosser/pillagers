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

if ($s.Contains("  {v:'22.71',what:")) { throw "check 22.71 is in the fixture already" }

SubRx @'
  {v:'22.70',what:
'@ @'
  {v:'22.71',what:'the auto-jog details, the teammate down detail and the Peddler plate in the shooter voice: CAPS while moving says STOP FIRST with the caps detail naming the key and AUTO-JOG, CAPS standing still says AUTO-JOG ON with a caps detail naming the key, a teammate going down raises TEAMMATE DOWN with REVIVE and his name in caps, and the Peddler plate beside an unsearched crate is caps, never a lower case aside',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)) return 'SKIP: this fixture cannot deploy or step the player';
     if(typeof keyLabel!=='function'||typeof PAD==='undefined'||typeof netOnState!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no key labels, controller or party state here';
     var bad=[], g=null, p, ln, padK={}, pk, NK={}, k, realSay=say, oName=netSeatName, oRum=(typeof padRumble==='function')?padRumble:null, td=null, w, peer={seat:1,state:'in'},
         CK='['+keyLabel('CapsLock','CAPS')+']', TD=['TEAMMATE','DOWN'].join(' '), src='', ss, i;
     function said(pre){ var L=(g&&g.msgLog)||[], j; for(j=L.length-1;j>=0;j--) if(String(L[j].m).indexOf(pre)===0) return L[j]; return null; }
     function caps(s){ s=String(s||''); return s.length>0&&s===s.toUpperCase(); }
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       keys={}; NET.on=false; NET.role=null; NET.peers=[];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       p=g.player; g.ents.length=0; g.waveT=-1e9; p.iv=99; p.downed=false;
       PAD.on=false; CK='['+keyLabel('CapsLock','CAPS')+']';
       // A. CAPS while moving: STOP FIRST, and the detail is a caps tag naming the key.
       g.msgLog=[]; p.autoJog=false; p._cpPrev=false; keys={}; keys['CapsLock']=true; keys['KeyW']=true;
       __sim(0.016); keys={};
       ln=said('STOP FIRST');
       if(!ln) bad.push('CAPS while moving did not say STOP FIRST');
       else if(!caps(ln.sub)||String(ln.sub).indexOf(CK)<0||String(ln.sub).indexOf('AUTO-JOG')<0) bad.push('the STOP FIRST detail reads '+JSON.stringify(String(ln.sub||''))+', not a caps tag naming '+CK+' and AUTO-JOG');
       // B. CAPS standing still: AUTO-JOG ON, and the detail is a caps tag naming the key.
       g.msgLog=[]; p.autoJog=false; p._cpPrev=false; p.vx=0; p.vy=0; keys={}; __sim(0.016); keys['CapsLock']=true;
       __sim(0.016); keys={};
       ln=said('AUTO-JOG ON');
       if(!ln) bad.push('CAPS standing still did not say AUTO-JOG ON');
       else if(!caps(ln.sub)||String(ln.sub).indexOf(CK)<0) bad.push('the AUTO-JOG ON detail reads '+JSON.stringify(String(ln.sub||''))+', not a caps tag naming '+CK);
       p.autoJog=false; p._cpPrev=false;
       // C. a teammate goes down: TEAMMATE DOWN, the detail REVIVE and his name in caps. His name is mixed case, so the caps are the build.
       say=function(m,kd,o){ if(String(m)===TD) td=o||{}; };
       if(oRum) padRumble=function(){ return 'test'; };
       netSeatName=function(s){ return s===1?'Moth':(s===0?'Host':null); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; NET.up=[]; NET.floor=NET.floor||[];
       w={t:'st',k:'r',x:Math.round(p.x)+60,y:Math.round(p.y),f:0,sd:g.seed>>>0,dn:0,hp:100,mh:100};
       netOnState(peer,w); netOnState(peer,w); w.dn=1; netOnState(peer,w);
       say=realSay; netSeatName=oName; if(oRum) padRumble=oRum;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       if(!td) bad.push('a teammate going down did not say '+TD);
       else if(!caps(td.sub)||String(td.sub).indexOf('MOTH')<0||String(td.sub).indexOf('REVIVE')<0) bad.push('the '+TD+' detail reads '+JSON.stringify(String(td.sub||''))+', not REVIVE MOTH in caps');
       // D. the Peddler plate beside an unsearched crate, in the game code (the fixture hooks and comment lines cut away).
       try{ ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(_s){}
       var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
       src=src.split('\n').filter(function(l){ return !(/^\s*\/\//).test(l); }).map(function(l){ var q=l.indexOf('   // '); return q>=0?l.slice(0,q):l; }).join('\n');
       if(src.length>100000){
         if(src.indexOf('(search the '+'crate first)')>=0) bad.push('the Peddler plate beside an unsearched crate still reads as a lower case aside in brackets');
         if(src.indexOf('SEARCH CRATE'+' FIRST')<0) bad.push('the Peddler plate beside an unsearched crate does not say SEARCH CRATE FIRST');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; netSeatName=oName; if(oRum) padRumble=oRum;
       try{ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }catch(_n){}
       try{ for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; }catch(_pk){}
       keys={};
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.autoJog=false; g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       keys={};
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

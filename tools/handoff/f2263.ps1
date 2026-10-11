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

if ($s.Contains("  {v:'22.63',what:")) { throw "check 22.63 is in the fixture already" }

SubRx @'
  {v:'22.62',what:
'@ @'
  {v:'22.63',what:'keys follow the device: knocked down mid-pull with a controller says Hold X to try again in his words, on the keyboard his line reads byte for byte as before, and the auto-jog arming line is STOP FIRST naming the bound key',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)) return 'SKIP: this fixture cannot deploy or step the player';
     if(typeof tryExtractTick!=='function'||typeof PAD==='undefined'||typeof keyLabel!=='function') return 'SKIP: no extraction tick or controller here';
     var bad=[], g=null, p, z=null, kz=null, ln, padK={}, pk, kp=null, WORDS=['Knocked down.','Extraction progress bar reset.','Hold'].join(' '), WANT;
     function said(pre){ var L=(g&&g.msgLog)||[], j; for(j=L.length-1;j>=0;j--) if(String(L[j].m).indexOf(pre)===0) return L[j]; return null; }
     function knock(){
       g.msgLog=[]; p.x=z.x; p.y=z.y; p.downed=true; z.hold=10; z.pullT=1; z.pullFloor=0; z.boardT=0;
       tryExtractTick(0.016);
       var e=said('Knocked down'); return e?String(e.m):null;
     }
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       p=g.player; g.ents.length=0; g.waveT=-1e9; p.iv=99; p.downed=false; kp={x:p.x,y:p.y};
       if(CFG.raidSec>0&&g.timeLeft<600) g.timeLeft=600;
       z=g.zones&&g.zones[0]; if(!z) return 'SKIP: no extraction ring on this seed';
       kz={hold:z.hold,pullT:z.pullT,pullFloor:z.pullFloor,boardT:z.boardT};
       if(CFG.downResetsPull===0) return 'SKIP: a knock-down does not reset the pull in this config';
       PAD.on=false; g.msgLog=[]; p.autoJog=false; p._cpPrev=false; keys={}; keys['CapsLock']=true; keys['KeyW']=true;
       __sim(0.016); keys={};
       ln=said('STOP FIRST')||said('Stop first');
       if(!ln) bad.push('CAPS while moving said nothing about a standstill');
       else if(String(ln.m)!=='STOP FIRST'||String(ln.sub||'').indexOf('['+'CAPS]')<0) bad.push('the auto-jog arming line reads '+JSON.stringify(String(ln.m)+' / '+String(ln.sub||''))+', not STOP FIRST naming [CAPS]');
       p.autoJog=false; p._cpPrev=false;
       PAD.on=true; PAD.brand='xbox';
       ln=knock();
       if(ln===null) return 'SKIP: staging: the knock-down branch did not run';
       WANT=WORDS+' '+keyLabel('KeyE','E')+' to try again.';
       if(keyLabel('KeyE','E')==='E') bad.push('with a controller connected the pull key is still labelled E');
       if(ln!==WANT) bad.push('with a controller the knocked down line reads '+JSON.stringify(ln)+', not '+JSON.stringify(WANT));
       if((' '+ln+' ').indexOf(' E ')>=0) bad.push('with a controller the knocked down line still names E');
       PAD.on=false; p.downed=false;
       ln=knock();
       WANT=WORDS+' '+'E to try again.';
       if(ln!==WANT) bad.push('on the keyboard the knocked down line reads '+JSON.stringify(ln)+', not his words '+JSON.stringify(WANT));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       try{ for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; }catch(_pk){}
       try{ if(z&&kz){ z.hold=kz.hold; z.pullT=kz.pullT; z.pullFloor=kz.pullFloor; z.boardT=kz.boardT; } }catch(_z){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.autoJog=false; g2.player.iv=0; if(kp){ g2.player.x=kp.x; g2.player.y=kp.y; } __endRaid('abandon'); } }catch(_e){}
       keys={};
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

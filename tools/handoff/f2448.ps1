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

if ($s.Contains("  {v:'24.48',what:")) { throw "check 24.48 is in the fixture already" }

SubRx @'
  {v:'24.47',what:
'@ @'
  {v:'24.48',what:'his #39: for 1.5 s after a demo run ends a key, click or pad press on the RUN OVER card is swallowed and drops no new run in; after that the same key drops in',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__endRaid)) return 'SKIP: this fixture cannot run a raid';
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object'||typeof arcadeKeyAtt!=='function'||typeof arcadePadAtt!=='function'||typeof arcadeRunEnd!=='function') return 'SKIP: no arcade here';
     var bad=[], g, rs=say, ownS=false, bk=null, hadB=false, BK=(typeof ARCADE_BOARD_KEY==='string')?ARCADE_BOARD_KEY:'', kIL=arcadeIniLive, kIR=(typeof arcadeIniRaid==='function')?arcadeIniRaid:null, ownI=false, r;
     function ev(code){ return {type:'keydown',code:code,key:code,repeat:false,ctrlKey:false,altKey:false,metaKey:false,shiftKey:false,preventDefault:function(){},stopImmediatePropagation:function(){}}; }
     function up(){ var s=__state(); return !!(s&&s.arcade&&!s.over); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(BK){ try{ bk=localStorage.getItem(BK); hadB=true; }catch(_b){} }
       say=function(){}; ownS=true;
       arcadeIniLive=function(){ return false; }; if(kIR) arcadeIniRaid=function(){ return false; }; ownI=true;
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.over=null;
       if(!g||!g.arcade) return 'SKIP: no arcade raid';
       if(ARCADE.role!=='host') return 'SKIP: this window is not the arcade host';
       arcadeRunEnd('menu');
       if(up()) return 'SKIP: arcadeRunEnd left the raid up';
       if(!ARCADE.over) return 'SKIP: no RUN OVER after arcadeRunEnd';
       r=arcadeKeyAtt(ev('KeyW'));
       if(up()) bad.push('a key pressed right as the run ended dropped a new run in');
       try{ if(up()) arcadeRaidStop('end'); }catch(_s1){}
       arcadePadAtt(true,true);
       if(up()) bad.push('a pad press right as the run ended dropped a new run in');
       try{ if(up()) arcadeRaidStop('end'); }catch(_s2){}
       if(ARCADE.over) ARCADE.over.at-=2000;
       arcadeKeyAtt(ev('KeyW'));
       if(!up()) bad.push('a key 2 s after the run ended did not drop a new run in');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownS) say=rs;
       if(ownI){ arcadeIniLive=kIL; if(kIR) arcadeIniRaid=kIR; }
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.mine=0; ARCADE.mate=0; ARCADE.kills=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null; }catch(_m){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_b2){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

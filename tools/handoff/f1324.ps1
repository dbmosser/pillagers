$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v13.24 CHECK, inserted before the v13.23 entry.
#
# THE PLAY PATH: a real container, searched on the real key, holding the best gun
# the table has, so a tier rise over whatever is in hand is guaranteed rather than
# hoped for. The second slot is emptied because that is the branch under test.
#
# IT LISTENS TO say() INSIDE THE CLOSURE and puts it back, because the fixture
# overrides say and guessing at it has lied before.
#
# IT SKIPS HONESTLY when the branch is not reached: a line that was never spoken
# cannot be wrong, and calling that a pass would be green for the wrong reason.
SubRx @'
  {v:'13.23',what:'the full key list behind H names B, and actually draws the row, so the key he was given because Escape is not working is on the reference he opens to look keys up',
'@ @'
  {v:'13.24',what:'finding a better gun with the second slot free tells you to swap to it on the tactical belt, not to press X, which searches',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid))
       return 'SKIP: this fixture cannot drive a live raid';
     if(typeof ITEMS==='undefined'||typeof WEAPONS==='undefined'||typeof WTIER==='undefined')
       return 'SKIP: this fixture cannot reach the gun tables';
     var bad=[], _say=say, heard=[];
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; var st=__state(); if(!st||st.over) return; __loop(T0); } }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.containers||!g.containers.length) return 'SKIP: this landing has no containers';
       var p=g.player;
       // THE BEST GUN IN THE TABLE, so the tier rise is guaranteed.
       var best=null, bt=-1, k;
       for(k in ITEMS){
         var it=ITEMS[k];
         if(it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]){ var t=WTIER[it.gk]||0; if(t>bt){ bt=t; best=k; } }
       }
       if(!best||!(bt>(WTIER[p.wep.id]||0))) return 'SKIP: nothing in the gun table outranks the gun in hand';
       var box=null;
       for(var i=0;i<g.containers.length;i++) if(!g.containers[i].opened){ box=g.containers[i]; break; }
       if(!box) return 'SKIP: this landing has no unopened container';
       box.loot=[best]; box.opened=false;
       p.sec=null;   // the second slot is free: the branch under test
       p.x=box.x; p.y=box.y; p.downed=false;
       keysOff(); frames(3);
       say=function(m){ heard.push(String(m)); try{ return _say.apply(null,arguments); }catch(_s){} };
       keysOff(); __keysRef()['KeyX']=true;
       for(var w=0;w<60;w++){ frames(10); if(box.opened) break; }
       keysOff(); frames(4);
       if(!box.opened) return 'SKIP: the container never opened, so nothing was picked up';
       var line='';
       for(var h=0;h<heard.length;h++) if(heard[h].indexOf('to your empty slot')>=0){ line=heard[h]; break; }
       if(!line) return 'SKIP: the pickup did not take the free-second-slot branch, so the line under test was never spoken';
       if(/\bX swaps\b/.test(line))
         bad.push('finding a better gun tells him X swaps to it, and X does not swap weapons: it searches what he is standing on, so the instruction sends him to the wrong key at the moment he wants his new gun');
       if(line.indexOf('tactical belt')<0)
         bad.push('the pickup line does not say how to swap to the new gun, so he is left guessing: ['+line+']');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ say=_say; }catch(_r){}
       try{ keysOff(); }catch(_k){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.23',what:'the full key list behind H names B, and actually draws the row, so the key he was given because Escape is not working is on the reference he opens to look keys up',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

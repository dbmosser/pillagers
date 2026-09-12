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

# v12.92 CHECK, inserted before the v12.91 entry.
#
# IT DOES NOT ASSERT THE LABELS. It asks the game which button actually performs each
# station act, by pressing the sixteen buttons one at a time through a faked pad and
# watching which key the floor claims, and then requires the label the floor PRINTS
# for that act to name that button. Neither half is written down here, so a rebinding
# cannot leave this check green over a wrong prompt, and a relabel cannot either.
#
# THE PAD IS FAKED AT THE HARDWARE, because pollPad rebuilds PAD from
# navigator.getGamepads every frame and zeroes it when nothing is connected, so state
# poked into PAD is gone before anything reads it.
#
# pollPad IS CALLED DIRECTLY rather than through a frame, so the buttons are read
# without the floor also acting on them and opening a station.
SubRx @'
  {v:'12.91',what:'a downed player can crawl on the stick
'@ @'
  {v:'12.92',what:'on a controller every Undercroft station prompt names the button that actually performs it, so the lift no longer says the launch button will take him to the sector page, while the raid prompts and the keyboard letters are unchanged (audit finding 15, 2026-09-11)',
   run:function(){
     if(!(window.__showScreen&&window.__hubEnter&&window.__keysRef)) return 'SKIP: this fixture cannot reach the Undercroft floor';
     if(typeof keyLabel!=='function'||typeof pollPad!=='function') return 'SKIP: this build has no pad labels to read';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     // The standard pad layout, which is what mapping:'standard' means. Only used to
     // turn a button NUMBER into the name a player reads on their controller.
     var BTN={0:'A',1:'B',2:'X',3:'Y',4:'LB',5:'RB',6:'LT',7:'RT',8:'BACK',9:'START',
              10:'LS',11:'RS',12:'D-UP',13:'D-DOWN',14:'D-LEFT',15:'D-RIGHT'};
     var ACTS=['KeyE','KeyR','KeyF','KeyT'];
     function padWith(down){
       var bts=[],i;
       for(i=0;i<16;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,
                 axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __showScreen('hub'); __hubEnter();
       var K=__keysRef(), kk, i, a;
       // WHICH BUTTON REALLY DOES WHAT, read off the floor rather than written here.
       var owner={};
       for(i=0;i<16;i++){
         for(kk in K) K[kk]=false;
         padWith(i); pollPad();
         for(a=0;a<ACTS.length;a++) if(K[ACTS[a]]&&owner[ACTS[a]]===undefined) owner[ACTS[a]]=i;
       }
       for(kk in K) K[kk]=false;
       // WHAT THE FLOOR PRINTS for each of those acts, with the pad connected.
       padWith(-1); pollPad();
       var named=0;
       for(a=0;a<ACTS.length;a++){
         var code=ACTS[a], b=owner[code];
         if(b===undefined) continue;      // not bound on the floor at all: nothing to name
         named++;
         var lab=keyLabel(code,'?'), want=BTN[b]||('button '+b);
         if(lab!==want)
           bad.push('a station act the floor performs on '+want+' is printed to him as ['+lab+'], so he presses what the prompt says and gets a different action: at the lift that means the button labelled go up is the one that launches the raid with no sector page and no question about what he is taking up');
       }
       if(!named) return 'SKIP: none of the four station acts is bound to a pad button in this build, so there is nothing here to label';
       // CONTROL: THE RAID PROMPTS ARE A DIFFERENT BINDING AND MUST BE UNTOUCHED. In
       // a raid the same four keys sit one button higher, and those labels were right
       // all along; a fix that relabelled everything would break them.
       if(window.__deploy&&window.__state&&owner['KeyE']!==undefined){
         var floorLab=keyLabel('KeyE','E'), raidLab=null;
         try{
           __deploy({kit:[],safe:null,mapIx:0,seed:4242});
           padWith(-1); pollPad();
           raidLab=keyLabel('KeyE','E');
         }catch(_d){}
         if(raidLab===null||!raidLab||raidLab==='KeyE')
           bad.push('control: in a raid the first act is no longer given a controller label at all, so a pad player reads a key code');
         else if(raidLab===floorLab)
           bad.push('control: the raid now prints ['+raidLab+'] for the first act, the same button the FLOOR uses, so the two binding sets have been handed one label table again in the other direction and the raid prompts that were right all along are now wrong');
         try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e2){}
         __showScreen('hub'); __hubEnter();
       }
       // CONTROL: WITH NO PAD THE KEYBOARD LETTER IS PRINTED. A label table that
       // answered regardless of the pad would leave a keyboard player reading
       // controller buttons.
       navigator.getGamepads=function(){ return []; };
       pollPad();
       for(a=0;a<ACTS.length;a++){
         var fb=ACTS[a].replace('Key','');
         if(keyLabel(ACTS[a],fb)!==fb){
           bad.push('control: with no pad connected the station prompt still names a controller button rather than the ['+fb+'] key');
           break;
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.91',what:'a downed player can crawl on the stick
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

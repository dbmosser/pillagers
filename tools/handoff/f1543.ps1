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

SubRx @'
  {v:'15.42',what:
'@ @'
  {v:'15.43',what:'the raid clock reads 0:10 when ten seconds is said, and 0:00 only when it is out: in a frame that crosses one minute, thirty seconds, ten seconds and then the last second, the warning still says its line and plays its siren or tick, and the drawn clock turns from 1:01 to 1:00, 0:31 to 0:30, 0:11 to 0:10 and 0:02 to 0:01 on that same frame; with 0.02 seconds left it reads 0:01, at 44.5 seconds 0:45 in its plain colour, and with the clock out and run on below zero through the burn 0:00, while whole seconds and the count up with the clock off read as before (hud audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function'||typeof ctx==='undefined'||typeof tickClockWarn!=='function'||typeof raidClockOn!=='function') return 'SKIP: no HUD draw, raid clock or clock warning in this build';
     if(typeof say!=='function'||typeof blip!=='function') return 'SKIP: no say or blip in this build';
     var bad=[], g=null, keep=null, clk=[], lines=[], heard=[], realFT=null, ownFT=false, _say=say, _blip=blip, i;
     var OWN=Object.prototype.hasOwnProperty, RED='#ff5a4a';
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // The raid clock as one drawn HUD paints it with this many seconds left: its figure and colour, null on a throw or no clock.
     // It is the centred text shaped like a clock; the old floor of a negative figure put a minus sign inside it, so one is allowed.
     function clock(left){
       g.timeLeft=left; clk.length=0;
       try{ drawHUD(); }catch(_h){ return null; }
       for(var k=0;k<clk.length;k++) if(clk[k].a==='center'&&(/^-?\d+:[0-9-]+$/).test(clk[k].t)) return clk[k];
       return null;
     }
     // One loop frame carrying the clock from prev to now through the v15.24 clock warning: what it said and what it played.
     function cross(prev,now){ lines.length=0; heard.length=0; tickClockWarn(prev,now); }
     function said(head){ for(var k=0;k<lines.length;k++) if(lines[k].indexOf(head)===0) return true; return false; }
     function show(c){ return c?(c.t+(c.c===RED?' in red':' in its plain colour')):'no clock'; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.sim) return 'SKIP: no live raid';
       // CONTROL: this raid was built with a clock, so it counts down and warns.
       if(!raidClockOn()||!(g.raidLen>0)) return 'SKIP: the raid clock is off here (raid length '+g.raidLen+'), so nothing counts down';
       keep={timeLeft:g.timeLeft,raidLen:g.raidLen,t:g.t,warnPrev:g.warnPrev};
       ownFT=OWN.call(ctx,'fillText'); realFT=ctx.fillText;
       ctx.fillText=function(t){ clk.push({t:String(t),c:String(ctx.fillStyle).toLowerCase(),a:ctx.textAlign}); return realFT.apply(this,arguments); };
       say=function(m){ lines.push(String(m)); };
       blip=function(k){ heard.push(String(k)); };
       // CONTROL: on whole seconds the figure is the same on either build, 0:10, 0:45 in its plain colour and 0:44 in red, so the
       // trace reads the clock and its colour.
       var w10=clock(10), w45=clock(45), w44=clock(44);
       if(!w10||w10.t!=='0:10') return 'SKIP: with exactly 10 seconds left the drawn HUD showed '+show(w10)+', not 0:10, so the clock cannot be read here';
       if(!w45||w45.t!=='0:45'||w45.c===RED) return 'SKIP: with exactly 45 seconds left the drawn HUD showed '+show(w45)+', not 0:45 in its plain colour, so the colour cannot be read here';
       if(!w44||w44.t!=='0:44'||w44.c!==RED) return 'SKIP: with exactly 44 seconds left the drawn HUD showed '+show(w44)+', not 0:44 in red, so the colour cannot be read here';
       // THE FINDING: each warning mark crossed in one frame. The figure must turn to the mark on the frame its warning fires.
       var M=[[60.02,59.98,'1:01','1:00','1 minute left.','clockwarn','one minute'],
              [30.02,29.98,'0:31','0:30','THIRTY SECONDS.','clockwarn','thirty seconds'],
              [10.02,9.98,'0:11','0:10','TEN SECONDS.','clocktick','ten seconds'],
              [1.02,0.98,'0:02','0:01','','clocktick','the last second']];
       for(i=0;i<M.length;i++){
         var m=M[i];
         cross(m[0],m[1]);
         // CONTROL: the v15.24 warning fires on this frame on either build, its line and its siren or tick, so the moment is unchanged.
         if(heard.indexOf(m[5])<0||(m[4]&&!said(m[4]))) return skip('the clock crossing '+m[6]+' from '+m[0]+' to '+m[1]+' did not '+(m[4]?('say '+m[4]+' and '):'')+'play '+m[5]+' here ('+(heard.join(',')||'no sound')+')');
         var b=clock(m[0]), a=clock(m[1]);
         if(!b||!a) return skip('no clock was drawn with '+m[0]+' or '+m[1]+' seconds left here');
         if(b.t!==m[2]||a.t!==m[3]) bad.push('on the frame that crosses '+m[6]+', which '+(m[4]?('says '+m[4]+' and '):'')+'plays '+m[5]+', the drawn clock went from '+b.t+' to '+a.t+' where it should turn from '+m[2]+' to '+m[3]);
       }
       // THE LAST LIVE FRAME: with 0.02 seconds left the clock is not out and the site is not burning, so it must not read 0:00.
       var l02=clock(0.02);
       if(!l02) return skip('no clock was drawn with 0.02 seconds left here');
       if(l02.t!=='0:01') bad.push('with 0.02 seconds left and the site not yet burning, the drawn clock read '+l02.t+' rather than 0:01');
       // THE COLOUR: at 44.5 seconds the figure is 0:45, and red waits for 0:44 as it always has.
       var h45=clock(44.5);
       if(!h45) return skip('no clock was drawn with 44.5 seconds left here');
       if(h45.t!=='0:45'||h45.c===RED) bad.push('with 44.5 seconds left the drawn clock read '+show(h45)+' rather than 0:45 in its plain colour');
       // CONTROL: the clock out, as the frame that starts the burn leaves it, reads 0:00 on either build.
       var z0=clock(0);
       if(!z0||z0.t!=='0:00') return skip('with the clock at exactly 0 the drawn HUD showed '+show(z0)+', not 0:00');
       // THE BURN: the loop runs the clock on below zero while the site burns, and it must still read 0:00.
       var zb=clock(-0.4);
       if(!zb) return skip('no clock was drawn with the clock run on to -0.4 here');
       if(zb.t!=='0:00') bad.push('with the site burning and the clock run on to -0.4, the drawn clock read '+zb.t+' rather than 0:00');
       // THE COUNT UP IS UNCHANGED: a raid with no clock reads 1:05 at 65.7 seconds up, in its plain colour, on either build.
       g.raidLen=0; g.t=65.7;
       if(raidClockOn()) return skip('a raid length of 0 did not switch the clock off here');
       var up=clock(0);
       if(!up) return skip('no clock was drawn with the clock off here');
       if(up.t!=='1:05'||up.c===RED) bad.push('with the clock off and 65.7 seconds up, the drawn clock read '+show(up)+' rather than counting up to 1:05 in its plain colour');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say; blip=_blip;
       try{ if(realFT){ if(ownFT) ctx.fillText=realFT; else delete ctx.fillText; } }catch(_t){}
       try{ if(g&&keep){ g.raidLen=keep.raidLen; g.t=keep.t; g.timeLeft=keep.timeLeft; g.warnPrev=keep.warnPrev; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

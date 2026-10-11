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

if ($s.Contains("  {v:'23.28',what:")) { throw "check 23.28 is in the fixture already" }

SubRx @'
  {v:'23.27',what:
'@ @'
  {v:'23.28',what:'arcade7, his order 2026-10-11: in the arcade controller 1 is player 1 and controller 2 is player 2, held in memory and told to the other window; the kept controller pick is never written, and leaving the arcade puts the kept pick back',
   run:function(){
     var bad=[], out=[], sv=null, kh='', kp='', h0=null, p0=null, gps, i, pk=function(ix){ for(var j=0;j<out.length;j++) if(out[j]&&out[j].t==='padpick'&&out[j].ix===ix) return true; return false; }, gs=function(k){ try{ return localStorage.getItem(k); }catch(_g){ return null; } };
     try{
       __topClear(); __runPrep();
       if(typeof arcadeEnter!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object') return 'no arcade in this build';
       if(typeof netPadFor!=='function'||typeof netPadKey!=='function'||typeof netPadLoad!=='function') return 'no pad picks in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,arcPick:NET.arcPick,busy:NET.sameBusy,padIx:NET.padIx,padOther:NET.padOther,padWas:NET.padWas,start:NET.start};
       kh=netPadKey('host'); kp=netPadKey('p2'); h0=gs(kh); p0=gs(kp);
       NET.bc={postMessage:function(m){ out.push(m); },close:function(){}}; NET.same='host'; NET.pair='tp'; NET.sameBusy=true; NET.start=null;
       // a kept host pick of the third controller, which the arcade could never produce on its own
       localStorage.setItem(kh,'2'); netPadLoad();
       if(NET.padIx!==2) return 'SKIP: the kept host pick did not load ('+NET.padIx+')';
       out.length=0;
       if(!arcadeEnter('host')) bad.push('arcadeEnter(host) failed');
       if(NET.padIx!==0) bad.push('in the arcade the host plays controller '+NET.padIx+', not the first (0)');
       if(!pk(0)) bad.push('the host did not tell player 2 it is on the first controller (no padpick 0)');
       if(gs(kh)!=='2') bad.push('entering the arcade wrote the kept host pick ('+gs(kh)+')');
       gps=[{connected:true,buttons:[],axes:[]},{connected:true,buttons:[],axes:[]}];
       i=netPadFor('host',NET.padIx,1,gps,null); if(i!==0) bad.push('with two controllers the host plays '+i+', not 0');
       i=netPadFor('p2',1,0,gps,null); if(i!==1) bad.push('with two controllers player 2 plays '+i+', not 1');
       out.length=0;
       arcadeLeave();
       if(ARCADE.on) bad.push('arcadeLeave left the arcade on');
       if(NET.padIx!==2) bad.push('after leaving the host is on controller '+NET.padIx+', not his kept pick 2');
       if(NET.padIx!==netPadLoad()) bad.push('after leaving the pick is not the kept one');
       if(!pk(2)) bad.push('leaving did not tell player 2 the kept pick (no padpick 2)');
       if(gs(kh)!=='2') bad.push('leaving changed the kept host pick ('+gs(kh)+')');
       // the player 2 side: a kept pick of the fourth controller
       NET.same='p2'; localStorage.setItem(kp,'3'); netPadLoad(); out.length=0;
       if(!arcadeEnter('p2')) bad.push('arcadeEnter(p2) failed');
       else {
         if(NET.padIx!==1) bad.push('in the arcade player 2 plays controller '+NET.padIx+', not the second (1)');
         if(!pk(1)) bad.push('player 2 did not tell the host it is on the second controller (no padpick 1)');
         if(gs(kp)!=='3') bad.push('entering the arcade wrote the kept player 2 pick ('+gs(kp)+')');
       }
       arcadeLeave();
       if(NET.padIx!==3) bad.push('after leaving player 2 is on controller '+NET.padIx+', not the kept pick 3');
       if(gs(kp)!=='3') bad.push('leaving changed the kept player 2 pick ('+gs(kp)+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(kh){ if(h0===null) localStorage.removeItem(kh); else localStorage.setItem(kh,h0); } if(kp){ if(p0===null) localStorage.removeItem(kp); else localStorage.setItem(kp,p0); } }catch(_s){}
       try{ if(sv){ netSameStop(); NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy; NET.padIx=sv.padIx; NET.padOther=sv.padOther; NET.padWas=sv.padWas; NET.start=sv.start; } }catch(_ns){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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
  {v:'15.66',what:
'@ @'
  {v:'15.67',what:'red noise marks for unseen sounds are drawn above the darkness and fog of war sheets: in one drawn raid frame with a red noise mark and a gunfire ping 300 units behind him, where he cannot see, both rings of the mark are drawn once and after the darkness sheet and the fog of war sheet are laid over the world, as the ping ring at the same spot is on either build, in the world transform that ping uses and at the mark colour, size and fade in plain source-over; and with ringsOnTop dialled to 0 the mark goes back under the darkness with the ping (stealth audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof render2D!=='function'||typeof canSee!=='function'||typeof CFG==='undefined') return 'SKIP: no world draw, sight test or dials in this build';
     if(typeof fogC==='undefined'||!fogC||typeof litC==='undefined'||!litC) return 'SKIP: no darkness or fog of war layer in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], snap=null, g=null, p=null, keep=null, seq=[], real={}, own={}, rot=null, RX=0, PX=0, SY=0, i;
     var OWN=Object.prototype.hasOwnProperty, NF=0.35/1.15, RED='#ff5a4a';
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     function skip(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); }
     function tf(c){ try{ var m=c.getTransform(); return [m.a,m.b,m.c,m.d,m.e,m.f]; }catch(_t){ return null; } }
     function wrap(name,fn){ own[name]=OWN.call(wc,name); real[name]=wc[name]; wc[name]=fn; }
     // One drawn raid frame holding only this mark and this ping, and the order the world canvas was handed the darkness sheet,
     // the fog of war sheet and the rings drawn at the two test places.
     function frame(){
       seq.length=0;
       g.noiseRings=[{x:RX,y:SY,t:0.35,life:1.15,r:60,a0:0.65}];
       g.pings=[{x:PX,y:SY,src:'robot',typ:'fire',s:500,occ:1,t:0.3,life:1.1}];
       render2D(0);
       var r={dark:-1,fog:-1,mark:[],ping:[]};
       for(var k=0;k<seq.length;k++){
         var q=seq[k];
         if(q.k==='dark'){ if(r.dark<0) r.dark=q.i; }
         else if(q.k==='fog'){ if(r.fog<0) r.fog=q.i; }
         else r[q.k].push(q);
       }
       return r;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(!g||!g.player||!g.map||g.over) return 'SKIP: no live raid';
       if(!wc||!(W>0&&H>0)) return 'SKIP: the pane has no size, so no world frame can be drawn here';
       rot=CFG.ringsOnTop;
       if(rot===0) return 'SKIP: ringsOnTop is dialled off after a reset here, so the rings are meant to be under the fog';
       p=g.player;
       keep={face:p.face,rings:g.noiseRings,pings:g.pings};
       p.face=Math.PI/2;
       if(!g.vseg&&typeof refreshVseg==='function') refreshVseg();
       var segs=g.vseg||g.map.segs;
       // A spot 300 units behind him. The mark and the ping are told apart by a fraction of a unit that no map place is given.
       var bx=Math.round(p.x-Math.cos(p.face)*300); SY=Math.round(p.y-Math.sin(p.face)*300);
       RX=bx+0.3125; PX=bx+0.6875;
       // CONTROL: he cannot see either place, so it is ground under the fog of war, the only ground a mark is ever made on.
       if(canSee(p.x,p.y,p.face,RX,SY,segs)||canSee(p.x,p.y,p.face,PX,SY,segs)) return 'SKIP: he can see the spot 300 units behind him here, so no mark would be made there';
       wrap('drawImage',function(img){ if(img===litC) seq.push({k:'dark',i:seq.length}); else if(img===fogC) seq.push({k:'fog',i:seq.length}); return real.drawImage.apply(this,arguments); });
       wrap('arc',function(x,y,r){ if(x===RX||x===PX) seq.push({k:(x===RX?'mark':'ping'),i:seq.length,r:r,op:String(this.globalCompositeOperation),a:this.globalAlpha,s:String(this.strokeStyle).toLowerCase(),m:tf(this)}); return real.arc.apply(this,arguments); });
       var f1=frame();
       // CONTROL: the frame laid the darkness sheet and then the fog of war sheet over the world, on either build.
       if(f1.dark<0||f1.fog<0||f1.fog<f1.dark) return 'SKIP: the drawn frame did not lay the darkness sheet and then the fog of war sheet here';
       // CONTROL: the gunfire ping at the same spot is drawn above both sheets by the v4.05 pass on either build, so a ring drawn
       // above the fog is seen by this recording.
       if(!f1.ping.length||f1.ping[0].i<f1.fog) return 'SKIP: the control gunfire ping 300 units behind him was not drawn above the fog of war sheet here';
       var pm=f1.ping[0].m;
       // THE FINDING: both rings of the mark are drawn after the two sheets, and once.
       if(!f1.mark.length) bad.push('a red noise mark 300 units behind him, where he cannot see, was not drawn at all');
       else {
         var under=0, dark=0;
         for(i=0;i<f1.mark.length;i++){ if(f1.mark[i].i<f1.fog) under++; if(f1.mark[i].i<f1.dark) dark++; }
         if(under) bad.push(under+' of the '+f1.mark.length+' rings of a red noise mark 300 units behind him, where he cannot see, were drawn before '+(dark?'the darkness sheet and ':'')+'the fog of war sheet, so '+(dark?'both sheets were':'the sheet was')+' laid over the mark, while the gunfire ping at the same spot was drawn above them');
         if(f1.mark.length!==2) bad.push('the red noise mark was drawn as '+f1.mark.length+' rings, where a mark this far into its life is its ring and one trailing ring, drawn once');
         // The same mark it always was: its colour, size and fade in plain source-over, on the ground the ping is drawn on.
         var A=[0.65*(1-NF),0.65*(1-NF)*0.55], RR=[6+NF*60,6+(NF-0.22)*60];
         for(i=0;i<f1.mark.length&&i<2;i++){
           var q=f1.mark[i];
           if(q.s!==RED||q.op!=='source-over'||Math.abs(q.a-A[i])>0.01||Math.abs(q.r-RR[i])>0.01) bad.push('ring '+(i+1)+' of the mark was drawn in '+q.s+' at alpha '+(+q.a).toFixed(3)+' and radius '+(+q.r).toFixed(2)+' with '+q.op+', not '+RED+' at '+A[i].toFixed(3)+' and '+RR[i].toFixed(2)+' in source-over');
           if(pm&&q.m){ for(var c=0;c<6;c++) if(Math.abs(q.m[c]-pm[c])>1e-6){ bad.push('ring '+(i+1)+' of the mark was drawn in the transform ['+q.m.join(',')+'], not the ['+pm.join(',')+'] of the ping on the same ground'); break; } }
         }
       }
       // THE DIAL: ringsOnTop 0 is the v4.05 way back to the old order, and the mark goes back under the darkness with the ping.
       CFG.ringsOnTop=0;
       var f0=frame();
       CFG.ringsOnTop=rot;
       if(f0.dark<0||!f0.ping.length||f0.ping[0].i>f0.dark) return skip('with ringsOnTop 0 the control ping was not drawn under the darkness sheet here');
       if(f0.mark.length!==2||f0.mark[0].i>f0.dark||f0.mark[1].i>f0.dark) bad.push('with ringsOnTop dialled to 0 the red noise mark was drawn as '+f0.mark.length+' rings and not both under the darkness sheet with the ping, so the dial no longer puts the old order back');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(var nm in real){ if(own[nm]) wc[nm]=real[nm]; else delete wc[nm]; } }catch(_w){}
       try{ if(rot!==null) CFG.ringsOnTop=rot; }catch(_d){}
       try{ if(g&&keep){ g.noiseRings=keep.rings||[]; g.pings=keep.pings||[]; if(p) p.face=keep.face; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

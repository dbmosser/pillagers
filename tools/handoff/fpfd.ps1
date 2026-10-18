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

if ($s.Contains("  {v:'30.68',what:")) { throw "check 30.68 is in the fixture already" }

SubRx @'
  {v:'30.67',what:
'@ @'
  {v:'30.68',what:'the first controller is player 2 only and the second is player 1 only (his order, 2026-10-18: my controller controls both screens at the same time, that is not the intent): through the arcade entry and navigator.getGamepads, with two controllers the player 1 window reads only the second and the player 2 window only the first, with one controller only the player 2 window has it, a state handed over for the other player is never played, and an old kept pick is cleared once',
   run:function(){
     if(typeof NET==='undefined'||!NET||typeof netPadTick!=='function'||typeof netPadRecv!=='function'||typeof pollPad!=='function'||typeof arcadePadsIn!=='function'||typeof netPadNow!=='function'||typeof netSamePost!=='function'||typeof netPadKey!=='function'||typeof PAD==='undefined'||!PAD||typeof RUMBLE==='undefined') return 'SKIP: this build has no same machine controllers';
     if(NET.same||NET.on) return 'SKIP: a party is on in this copy, and the check stands in for both windows';
     if(!(window.__deploy&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], keep={}, ks=[], k, q, r, a, b, h, posts=[], oPost=netSamePost, oGet=navigator.getGamepads, hadGet=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), list=[], pix=PAD.ix, hadPix=Object.prototype.hasOwnProperty.call(PAD,'ix'), PAIR='zqxp2pads', KH='', KP='', FL='salvagerun:samepad:order', h0=null, p0=null, f0=null, lsOk=false;
     function pd(ix,down){ var bts=[], j; for(j=0;j<17;j++) bts.push({pressed:j===down,value:(j===down)?1:0,touched:j===down}); return {connected:true,id:'probe pad '+ix,index:ix,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts}; }
     function side(same){ NET.same=same; NET.pair=PAIR; NET.mode='coop'; NET.padIx=-1; NET.padOther=-1; NET.padFwd=null; NET.padWas=null; NET.padTs={}; NET.padLiveAt=netPadNow(); posts.length=0; }
     function played(same,gps){   // the real path: the arcade entry, then pollPad reads navigator.getGamepads as a window in a pair does
       list=gps; side(same); arcadePadsIn(same); delete PAD.ix; PAD.on=false; NET.padLiveAt=netPadNow(); pollPad();
       return (PAD.on&&typeof PAD.ix==='number')?PAD.ix:-1; }
     function handed(){ var j, o=null; for(j=0;j<posts.length;j++) if(posts[j]&&posts[j].t==='pad') o=posts[j]; return o; }
     function word(ix,to){ var p=[], v=[], j; for(j=0;j<17;j++){ p.push(j===5?1:0); v.push(j===5?1:0); } return {t:'pad',pair:PAIR,ix:ix,own:-1,at:ix,to:to,p:p,v:v,a:[0,0,0,0],b:''}; }
     function nm(g){ return g?('pad '+g.index):'no controller'; }
     function lsGet(key){ try{ return localStorage.getItem(key); }catch(_g){ return null; } }
     for(k in NET) keep[k]=NET[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSamePost=function(m){ posts.push(JSON.parse(JSON.stringify(m))); return true; };
       navigator.getGamepads=function(){ return list; };
       var I0=pd(0,-1), I1=pd(1,-1), Q0=pd(0,3), Q1=pd(1,5);
       // TWO CONTROLLERS, each window reading what the browser reports with nothing said by the other window
       a=played('host',[I0,I1]); b=played('p2',[I0,I1]);
       if(a!==1) bad.push('with two controllers the player 1 window reads pad '+a+', not the second controller (1)');
       if(b!==0) bad.push('with two controllers the player 2 window reads pad '+b+', not the first controller (0)');
       // ONE CONTROLLER: only the player 2 window has it, so it cannot drive both screens
       a=played('host',[I0]); b=played('p2',[I0]);
       if(a!==-1) bad.push('with one controller the player 1 window reads pad '+a+', so one controller drives both screens');
       if(b!==0) bad.push('with one controller the player 2 window reads pad '+b+', not the first controller (0)');
       a=played('host',[null,I1]); b=played('p2',[null,I1]);
       if(a!==-1) bad.push('with one controller in the second slot the player 1 window reads pad '+a);
       if(b!==1) bad.push('with one controller in the second slot the player 2 window reads pad '+b+', not that controller (1)');
       // WHAT EACH WINDOW HANDS THE OTHER, with different buttons down on the two pads
       side('host'); arcadePadsIn('host'); NET.padLiveAt=netPadNow(); r=netPadTick([Q0,Q1]);
       if(r!==Q1) bad.push('the player 1 window in front plays '+nm(r)+' with two controllers, not the second');
       h=handed();
       if(!h||h.ix!==0||h.to!=='p2') bad.push('the player 1 window did not hand the first controller to the player 2 window addressed to it ('+JSON.stringify(h?{ix:h.ix,to:h.to}:null)+')');
       side('p2'); arcadePadsIn('p2'); NET.padLiveAt=netPadNow(); r=netPadTick([Q0,Q1]);
       if(r!==Q0) bad.push('the player 2 window in front plays '+nm(r)+' with two controllers, not the first');
       h=handed();
       if(!h||h.ix!==1||h.to!=='host') bad.push('the player 2 window did not hand the second controller to the player 1 window addressed to it ('+JSON.stringify(h?{ix:h.ix,to:h.to}:null)+')');
       // A STATE HANDED OVER FOR THE OTHER PLAYER IS NEVER PLAYED
       side('p2'); r=netPadRecv(word(0,'p2'));
       if(r!=='pad'||!NET.padFwd||NET.padFwd.ix!==0) bad.push('control: the player 2 window did not take a state handed over for it ('+r+')');
       side('p2'); r=netPadRecv(word(1,'host'));
       if(r==='pad'||NET.padFwd) bad.push('the player 2 window took a state that was handed over for player 1 ('+r+')');
       side('host'); r=netPadRecv(word(1,'host'));
       if(r!=='pad'||!NET.padFwd||NET.padFwd.ix!==1) bad.push('control: the player 1 window did not take a state handed over for it ('+r+')');
       side('host'); r=netPadRecv(word(0,'p2'));
       if(r==='pad'||NET.padFwd) bad.push('the player 1 window took a state that was handed over for player 2 ('+r+')');
       // THE ARCADE ENTRY PUTS NEITHER WINDOW ON A FIXED CONTROLLER
       side('host'); arcadePadsIn('host');
       if(NET.padIx!==-1) bad.push('entering the arcade as player 1 still picks controller '+(NET.padIx+1));
       side('p2'); arcadePadsIn('p2');
       if(NET.padIx!==-1) bad.push('entering the arcade as player 2 still picks controller '+(NET.padIx+1));
       // A PICK KEPT UNDER THE OLD ORDER IS CLEARED ONCE, AND A LATER PICK IS LEFT ALONE
       if(typeof netPadOrderFix!=='function') bad.push('nothing clears a controller pick kept under the old order (no netPadOrderFix)');
       else {
         KH=netPadKey('host'); KP=netPadKey('p2'); h0=lsGet(KH); p0=lsGet(KP); f0=lsGet(FL);
         try{
           localStorage.removeItem(FL); localStorage.setItem(KH,'0'); localStorage.setItem(KP,'1'); lsOk=true;
           netPadOrderFix();
           if(lsGet(KH)!==null||lsGet(KP)!==null) bad.push('the old kept controller picks were not cleared (host '+lsGet(KH)+', player 2 '+lsGet(KP)+')');
           localStorage.setItem(KH,'2'); netPadOrderFix();
           if(lsGet(KH)!=='2') bad.push('a controller pick made after the clear was wiped again ('+lsGet(KH)+')');
         }catch(_ls){ if(lsOk) bad.push('threw in the kept pick part: '+(_ls&&_ls.message||_ls)); }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSamePost=oPost;
       if(hadGet) navigator.getGamepads=oGet; else { try{ delete navigator.getGamepads; }catch(_d){} }
       try{ for(k in NET) if(!Object.prototype.hasOwnProperty.call(keep,k)) ks.push(k); for(q=0;q<ks.length;q++) delete NET[ks[q]]; for(k in keep) NET[k]=keep[k]; }catch(_n){}
       if(hadPix) PAD.ix=pix; else delete PAD.ix;
       try{ padRelease(); PAD.on=false; PAD.prev=[]; RUMBLE.gp=null; padBodyCls(); }catch(_p){}
       try{ if(KH){ if(h0===null) localStorage.removeItem(KH); else localStorage.setItem(KH,h0); if(p0===null) localStorage.removeItem(KP); else localStorage.setItem(KP,p0); if(f0===null) localStorage.removeItem(FL); else localStorage.setItem(FL,f0); } }catch(_r){}
       try{ __endRaid('abandon'); __topClear(); __cleanProfile(); }catch(_e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'30.79',what:")) { throw "check 30.79 is in the fixture already" }

SubRx @'
  {v:'30.78',what:
'@ @'
  {v:'30.79',what:'party launch mode (his Q28): ?party=1&pair=CODE skips the title, enters the arcade as the host on that pair and opens no window',
   run:function(){
     if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';     var R={chans:[],opens:0,reloads:0,navs:[],joins:[]}, oOpen=window.open, oBC=window.BroadcastChannel, hadBC=('BroadcastChannel' in window), oH=netHost, oJ=netJoin, oStart=NET.start, oRel=partyReload, oNav=partyNav, oParty=PARTY, tl=document.getElementById('title'), tDisp=tl?tl.style.display:'', sv=null, bad=[];
     function BC(n){ this.posted=[]; R.chans.push(this); }
     BC.prototype.postMessage=function(m){ this.posted.push(m); };
     BC.prototype.close=function(){};
     function rigOn(){
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,pick:NET.pick,arcPick:NET.arcPick,busy:NET.sameBusy,role:NET.role,on:NET.on,padIx:NET.padIx,padOther:NET.padOther,padWas:NET.padWas,p2win:NET.p2win};
       window.open=function(){ R.opens++; return null; }; window.BroadcastChannel=BC;
       netHost=function(){ return {then:function(){}}; }; netJoin=function(c){ R.joins.push(String(c)); return {then:function(){}}; };
       NET.start=function(){}; partyReload=function(){ R.reloads++; return true; }; partyNav=function(u){ R.navs.push(String(u)); };
     }
     function rigOff(){
       try{ clearInterval(NET.partyT); }catch(_a){}
       PARTY=false; PARTY_EXIT=0;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_b){}
       PARTY=oParty; window.open=oOpen;
       if(hadBC) window.BroadcastChannel=oBC; else { try{ delete window.BroadcastChannel; }catch(_d){ window.BroadcastChannel=undefined; } }
       netHost=oH; netJoin=oJ; NET.start=oStart; partyReload=oRel; partyNav=oNav;
       try{ netReset(); }catch(_c){}
       try{ if(sv){ NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.pick=sv.pick; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy; NET.padIx=sv.padIx; NET.padOther=sv.padOther; NET.padWas=sv.padWas; NET.p2win=sv.p2win||null; } }catch(_e){}
       if(tl) tl.style.display=tDisp;
       try{ localStorage.removeItem(p2RaidKey()); localStorage.removeItem(p2LiveKey()); }catch(_f){}
       try{ document.documentElement.classList.remove('party'); document.documentElement.classList.remove('partyhide'); }catch(_g){}
     }
     function sent(t){ var c=NET.bc, n=0, i; if(c&&c.posted) for(i=0;i<c.posted.length;i++) if(c.posted[i]&&c.posted[i].t===t) n++; return n; }
     function guard(){
       if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';
       if(ARCADE.on) return 'SKIP: the arcade is on';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       return null;
     }
     function prep(){ __topClear(); __runPrep(); if(__state()&&!__state().over) __endRaid('abandon'); }     var r, gd;
     try{
       prep(); gd=guard(); if(gd) return gd;
       rigOn();
       r=partyHostBoot('?party=1&pair=abcd1234');
       if(r!=='host') bad.push('partyHostBoot said '+r+', not host');
       if(!ARCADE.on||ARCADE.role!=='host') bad.push('the host window is not in the arcade (on '+ARCADE.on+', role '+ARCADE.role+')');
       if(NET.same!=='host') bad.push('NET.same is '+NET.same+', not host');
       if(NET.pair!=='abcd1234') bad.push('NET.pair is '+NET.pair+', not abcd1234');
       if(R.opens) bad.push('window.open was called '+R.opens+' times (the shortcut opens player 2 itself)');
       if(!tl||tl.style.display!=='none') bad.push('the title is not hidden');
       if(sent('arcon')<1) bad.push('the host did not tell player 2 arcon');
       if(sent('hostup')<1) bad.push('the host did not post hostup at boot');
       if(NET.mode!=='coop'||!NET.arcPick) bad.push('the pair is not the co-op arcade (mode '+NET.mode+', arcPick '+NET.arcPick+')');
       if(partyHostBoot('?party=1')!=='nopair'||R.opens) bad.push('with no pair code the host window did not fall back to the plain title row');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ rigOff(); __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.79',what:'party launch mode (his Q28): the ?p2=1&arc=1&party=1 window never shows its title, shows the arcade attract at once and takes the host offer',
   run:function(){
     if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';     var R={chans:[],opens:0,reloads:0,navs:[],joins:[]}, oOpen=window.open, oBC=window.BroadcastChannel, hadBC=('BroadcastChannel' in window), oH=netHost, oJ=netJoin, oStart=NET.start, oRel=partyReload, oNav=partyNav, oParty=PARTY, tl=document.getElementById('title'), tDisp=tl?tl.style.display:'', sv=null, bad=[];
     function BC(n){ this.posted=[]; R.chans.push(this); }
     BC.prototype.postMessage=function(m){ this.posted.push(m); };
     BC.prototype.close=function(){};
     function rigOn(){
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,pick:NET.pick,arcPick:NET.arcPick,busy:NET.sameBusy,role:NET.role,on:NET.on,padIx:NET.padIx,padOther:NET.padOther,padWas:NET.padWas,p2win:NET.p2win};
       window.open=function(){ R.opens++; return null; }; window.BroadcastChannel=BC;
       netHost=function(){ return {then:function(){}}; }; netJoin=function(c){ R.joins.push(String(c)); return {then:function(){}}; };
       NET.start=function(){}; partyReload=function(){ R.reloads++; return true; }; partyNav=function(u){ R.navs.push(String(u)); };
     }
     function rigOff(){
       try{ clearInterval(NET.partyT); }catch(_a){}
       PARTY=false; PARTY_EXIT=0;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_b){}
       PARTY=oParty; window.open=oOpen;
       if(hadBC) window.BroadcastChannel=oBC; else { try{ delete window.BroadcastChannel; }catch(_d){ window.BroadcastChannel=undefined; } }
       netHost=oH; netJoin=oJ; NET.start=oStart; partyReload=oRel; partyNav=oNav;
       try{ netReset(); }catch(_c){}
       try{ if(sv){ NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.pick=sv.pick; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy; NET.padIx=sv.padIx; NET.padOther=sv.padOther; NET.padWas=sv.padWas; NET.p2win=sv.p2win||null; } }catch(_e){}
       if(tl) tl.style.display=tDisp;
       try{ localStorage.removeItem(p2RaidKey()); localStorage.removeItem(p2LiveKey()); }catch(_f){}
       try{ document.documentElement.classList.remove('party'); document.documentElement.classList.remove('partyhide'); }catch(_g){}
     }
     function sent(t){ var c=NET.bc, n=0, i; if(c&&c.posted) for(i=0;i<c.posted.length;i++) if(c.posted[i]&&c.posted[i].t===t) n++; return n; }
     function guard(){
       if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';
       if(ARCADE.on) return 'SKIP: the arcade is on';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       return null;
     }
     function prep(){ __topClear(); __runPrep(); if(__state()&&!__state().over) __endRaid('abandon'); }     var r, gd, p;
     try{
       prep(); gd=guard(); if(gd) return gd;
       rigOn();
       r=netSameBootP2('abcd1234','coop');
       if(r!=='ready') bad.push('the player 2 boot said '+r);
       PARTY=true;
       p=partyP2Boot(r);
       if(p!=='arcade') bad.push('partyP2Boot said '+p+', not arcade');
       if(!ARCADE.on||ARCADE.role!=='p2') bad.push('the player 2 window is not in the arcade attract (on '+ARCADE.on+', role '+ARCADE.role+')');
       if(!tl||tl.style.display!=='none') bad.push('the player 2 title is not hidden');
       if(sent('ready')<1) bad.push('player 2 did not post ready');
       if(netSameOnMsg({t:'offer',pair:'abcd1234',mode:'coop',code:'CODE-X'})!=='join'||R.joins[0]!=='CODE-X') bad.push('the host offer was not taken (joins '+R.joins.join(',')+')');
       if(netSameOnMsg({t:'arcon',pair:'abcd1234'})!=='arcon'||sent('arcin')<1) bad.push('arcon from the host was not answered with arcin');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ rigOff(); __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.79',what:'party launch mode (his Q28): after the HOST reloads, player 2 answers hostup with ready and the pair links again, and the host repeats hostup only while nobody is linked',
   run:function(){
     if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';     var R={chans:[],opens:0,reloads:0,navs:[],joins:[]}, oOpen=window.open, oBC=window.BroadcastChannel, hadBC=('BroadcastChannel' in window), oH=netHost, oJ=netJoin, oStart=NET.start, oRel=partyReload, oNav=partyNav, oParty=PARTY, tl=document.getElementById('title'), tDisp=tl?tl.style.display:'', sv=null, bad=[];
     function BC(n){ this.posted=[]; R.chans.push(this); }
     BC.prototype.postMessage=function(m){ this.posted.push(m); };
     BC.prototype.close=function(){};
     function rigOn(){
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,pick:NET.pick,arcPick:NET.arcPick,busy:NET.sameBusy,role:NET.role,on:NET.on,padIx:NET.padIx,padOther:NET.padOther,padWas:NET.padWas,p2win:NET.p2win};
       window.open=function(){ R.opens++; return null; }; window.BroadcastChannel=BC;
       netHost=function(){ return {then:function(){}}; }; netJoin=function(c){ R.joins.push(String(c)); return {then:function(){}}; };
       NET.start=function(){}; partyReload=function(){ R.reloads++; return true; }; partyNav=function(u){ R.navs.push(String(u)); };
     }
     function rigOff(){
       try{ clearInterval(NET.partyT); }catch(_a){}
       PARTY=false; PARTY_EXIT=0;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_b){}
       PARTY=oParty; window.open=oOpen;
       if(hadBC) window.BroadcastChannel=oBC; else { try{ delete window.BroadcastChannel; }catch(_d){ window.BroadcastChannel=undefined; } }
       netHost=oH; netJoin=oJ; NET.start=oStart; partyReload=oRel; partyNav=oNav;
       try{ netReset(); }catch(_c){}
       try{ if(sv){ NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.pick=sv.pick; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy; NET.padIx=sv.padIx; NET.padOther=sv.padOther; NET.padWas=sv.padWas; NET.p2win=sv.p2win||null; } }catch(_e){}
       if(tl) tl.style.display=tDisp;
       try{ localStorage.removeItem(p2RaidKey()); localStorage.removeItem(p2LiveKey()); }catch(_f){}
       try{ document.documentElement.classList.remove('party'); document.documentElement.classList.remove('partyhide'); }catch(_g){}
     }
     function sent(t){ var c=NET.bc, n=0, i; if(c&&c.posted) for(i=0;i<c.posted.length;i++) if(c.posted[i]&&c.posted[i].t===t) n++; return n; }
     function guard(){
       if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';
       if(ARCADE.on) return 'SKIP: the arcade is on';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       return null;
     }
     function prep(){ __topClear(); __runPrep(); if(__state()&&!__state().over) __endRaid('abandon'); }     var gd, n0, h0;
     try{
       prep(); gd=guard(); if(gd) return gd;
       rigOn();
       // the host side: hostup at boot, again on the beat, never while linked
       partyHostBoot('?party=1&pair=abcd1234');
       h0=sent('hostup');
       partyHostUp();
       if(sent('hostup')!==h0+1) bad.push('the host beat did not post hostup while nobody is linked');
       NET.peers=[{state:'in'}];
       partyHostUp();
       if(sent('hostup')!==h0+1) bad.push('the host posted hostup while a player 2 was linked');
       NET.peers=[];
       // the host answers ready with the offer path (a reloaded player 2 or a reloaded host)
       if(['wait','offer'].indexOf(netSameOnMsg({t:'ready',pair:'abcd1234'}))<0) bad.push('the host did not take ready');
       rigOff(); rigOn();
       // the player 2 side: a new host window says hostup
       netSameBootP2('abcd1234','coop');
       n0=sent('ready');
       if(netSameOnMsg({t:'hostup',pair:'abcd1234'})!=='ready'||sent('ready')!==n0+1) bad.push('player 2 did not answer hostup with ready');
       if(netSameOnMsg({t:'hostup',pair:'zzzz9999'})==='ready') bad.push('player 2 answered a hostup of another pair');
       NET.role='join';
       if(netSameOnMsg({t:'hostup',pair:'abcd1234'})==='ready') bad.push('a linked player 2 answered hostup and would tear its link down');
       NET.role=null;
       if(netSameOnMsg({t:'offer',pair:'abcd1234',mode:'coop',code:'CODE-Y'})!=='join') bad.push('after hostup the new offer was not taken');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ NET.peers=[]; NET.role=null; rigOff(); __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.79',what:'party launch mode (his Q28): leaving the arcade for any reason but EXIT DEMO reloads into the party and the title rows stay hidden; EXIT DEMO goes to the plain address',
   run:function(){
     if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';     var R={chans:[],opens:0,reloads:0,navs:[],joins:[]}, oOpen=window.open, oBC=window.BroadcastChannel, hadBC=('BroadcastChannel' in window), oH=netHost, oJ=netJoin, oStart=NET.start, oRel=partyReload, oNav=partyNav, oParty=PARTY, tl=document.getElementById('title'), tDisp=tl?tl.style.display:'', sv=null, bad=[];
     function BC(n){ this.posted=[]; R.chans.push(this); }
     BC.prototype.postMessage=function(m){ this.posted.push(m); };
     BC.prototype.close=function(){};
     function rigOn(){
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,pick:NET.pick,arcPick:NET.arcPick,busy:NET.sameBusy,role:NET.role,on:NET.on,padIx:NET.padIx,padOther:NET.padOther,padWas:NET.padWas,p2win:NET.p2win};
       window.open=function(){ R.opens++; return null; }; window.BroadcastChannel=BC;
       netHost=function(){ return {then:function(){}}; }; netJoin=function(c){ R.joins.push(String(c)); return {then:function(){}}; };
       NET.start=function(){}; partyReload=function(){ R.reloads++; return true; }; partyNav=function(u){ R.navs.push(String(u)); };
     }
     function rigOff(){
       try{ clearInterval(NET.partyT); }catch(_a){}
       PARTY=false; PARTY_EXIT=0;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_b){}
       PARTY=oParty; window.open=oOpen;
       if(hadBC) window.BroadcastChannel=oBC; else { try{ delete window.BroadcastChannel; }catch(_d){ window.BroadcastChannel=undefined; } }
       netHost=oH; netJoin=oJ; NET.start=oStart; partyReload=oRel; partyNav=oNav;
       try{ netReset(); }catch(_c){}
       try{ if(sv){ NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.pick=sv.pick; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy; NET.padIx=sv.padIx; NET.padOther=sv.padOther; NET.padWas=sv.padWas; NET.p2win=sv.p2win||null; } }catch(_e){}
       if(tl) tl.style.display=tDisp;
       try{ localStorage.removeItem(p2RaidKey()); localStorage.removeItem(p2LiveKey()); }catch(_f){}
       try{ document.documentElement.classList.remove('party'); document.documentElement.classList.remove('partyhide'); }catch(_g){}
     }
     function sent(t){ var c=NET.bc, n=0, i; if(c&&c.posted) for(i=0;i<c.posted.length;i++) if(c.posted[i]&&c.posted[i].t===t) n++; return n; }
     function guard(){
       if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';
       if(ARCADE.on) return 'SKIP: the arcade is on';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       return null;
     }
     function prep(){ __topClear(); __runPrep(); if(__state()&&!__state().over) __endRaid('abandon'); }     var gd, de=document.documentElement, ids=['slotpanel','titlestart','modecoop','modearcade1','titleset'], i, el, pl, wasOn=false;
     function shownNow(id){ var e=document.getElementById(id); return !!e&&getComputedStyle(e).display!=='none'; }
     try{
       prep(); gd=guard(); if(gd) return gd;
       rigOn();
       // the title rows, by the page own CSS (the title is put up for the look)
       wasOn=tl?tl.classList.contains('on'):false; if(tl) tl.classList.add('on');
       de.classList.add('party');
       for(i=0;i<ids.length;i++) if(shownNow(ids[i])) bad.push('in the party launch mode #'+ids[i]+' is shown on the title');
       if(!shownNow('modearcade')) bad.push('the 2 PLAYER ARCADE DEMO row is hidden in a host window with no pair');
       de.classList.add('partyhide');
       if(tl&&getComputedStyle(tl).display!=='none'&&tl.parentNode) bad.push('a party window with a pair code shows its title');
       de.classList.remove('party'); de.classList.remove('partyhide');
       if(tl&&!wasOn) tl.classList.remove('on');
       // a leave that is not EXIT DEMO (a caught error, arcoff, anything that calls arcadeLeave)
       PARTY=true;
       partyHostBoot('?party=1&pair=abcd1234');
       arcadeLeave();
       if(R.reloads!==1) bad.push('arcadeLeave in the party launch mode reloaded '+R.reloads+' times, not once');
       if(R.navs.length) bad.push('arcadeLeave went to an address: '+R.navs.join(','));
       if(ARCADE.on) bad.push('the arcade is still on after the leave');
       // EXIT DEMO
       partyHostBoot('?party=1&pair=abcd1234');
       arcadeOpLeave();
       if(R.reloads!==1) bad.push('EXIT DEMO reloaded into the party ('+R.reloads+' reloads)');
       pl=partyPlainUrl();
       if(R.navs.length!==1||R.navs[0]!==pl||R.navs[0].indexOf('?')>=0||R.navs[0].indexOf('party')>=0) bad.push('EXIT DEMO went to '+R.navs.join(',')+', not the plain address '+pl);
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ rigOff(); __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.79',what:'party launch mode (his Q28): without ?party=1 nothing changes: no boot, no reload on leave, EXIT DEMO leaves in place',
   run:function(){
     if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';     var R={chans:[],opens:0,reloads:0,navs:[],joins:[]}, oOpen=window.open, oBC=window.BroadcastChannel, hadBC=('BroadcastChannel' in window), oH=netHost, oJ=netJoin, oStart=NET.start, oRel=partyReload, oNav=partyNav, oParty=PARTY, tl=document.getElementById('title'), tDisp=tl?tl.style.display:'', sv=null, bad=[];
     function BC(n){ this.posted=[]; R.chans.push(this); }
     BC.prototype.postMessage=function(m){ this.posted.push(m); };
     BC.prototype.close=function(){};
     function rigOn(){
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,pick:NET.pick,arcPick:NET.arcPick,busy:NET.sameBusy,role:NET.role,on:NET.on,padIx:NET.padIx,padOther:NET.padOther,padWas:NET.padWas,p2win:NET.p2win};
       window.open=function(){ R.opens++; return null; }; window.BroadcastChannel=BC;
       netHost=function(){ return {then:function(){}}; }; netJoin=function(c){ R.joins.push(String(c)); return {then:function(){}}; };
       NET.start=function(){}; partyReload=function(){ R.reloads++; return true; }; partyNav=function(u){ R.navs.push(String(u)); };
     }
     function rigOff(){
       try{ clearInterval(NET.partyT); }catch(_a){}
       PARTY=false; PARTY_EXIT=0;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_b){}
       PARTY=oParty; window.open=oOpen;
       if(hadBC) window.BroadcastChannel=oBC; else { try{ delete window.BroadcastChannel; }catch(_d){ window.BroadcastChannel=undefined; } }
       netHost=oH; netJoin=oJ; NET.start=oStart; partyReload=oRel; partyNav=oNav;
       try{ netReset(); }catch(_c){}
       try{ if(sv){ NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.pick=sv.pick; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy; NET.padIx=sv.padIx; NET.padOther=sv.padOther; NET.padWas=sv.padWas; NET.p2win=sv.p2win||null; } }catch(_e){}
       if(tl) tl.style.display=tDisp;
       try{ localStorage.removeItem(p2RaidKey()); localStorage.removeItem(p2LiveKey()); }catch(_f){}
       try{ document.documentElement.classList.remove('party'); document.documentElement.classList.remove('partyhide'); }catch(_g){}
     }
     function sent(t){ var c=NET.bc, n=0, i; if(c&&c.posted) for(i=0;i<c.posted.length;i++) if(c.posted[i]&&c.posted[i].t===t) n++; return n; }
     function guard(){
       if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';
       if(ARCADE.on) return 'SKIP: the arcade is on';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       return null;
     }
     function prep(){ __topClear(); __runPrep(); if(__state()&&!__state().over) __endRaid('abandon'); }     var gd, h, p;
     try{
       prep(); gd=guard(); if(gd) return gd;
       rigOn();
       if(PARTY) bad.push('PARTY is on in a page opened without ?party=1');
       if(partyOf('?p2=1&mode=coop&pair=abcd1234&arc=1')) bad.push('partyOf read a party address from one without party=1');
       if(partyHostBoot('?pair=abcd1234')!=='off'||ARCADE.on||R.opens||NET.same==='host') bad.push('partyHostBoot did something without party=1');
       NET.same='host'; arcadePadsIn('host'); h=NET.padIx; NET.same='p2'; arcadePadsIn('p2'); p=NET.padIx;
       if(h!==-1||p!==-1) bad.push('the arcade pad picks changed: host '+h+', player 2 '+p);
       NET.same='host'; NET.pair='abcd1234'; NET.padIx=-1;
       if(!arcadeEnter('host')) bad.push('arcadeEnter failed');
       arcadeOpLeave();
       if(R.reloads||R.navs.length) bad.push('leaving the arcade without party=1 reloaded or navigated');
       if(ARCADE.on) bad.push('EXIT DEMO did not leave the arcade');
       NET.same='host'; NET.pair='abcd1234';
       if(netSameOnMsg({t:'hostup',pair:'abcd1234'})==='ready') bad.push('a host window answered hostup');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ rigOff(); __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.79',what:'party launch mode (his Q28): stale player 2 marks (p2raid and p2live set 10 s ago by a killed window) do not stop a party boot from entering the arcade, and the marks are cleared',
   run:function(){
     if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';     var R={chans:[],opens:0,reloads:0,navs:[],joins:[]}, oOpen=window.open, oBC=window.BroadcastChannel, hadBC=('BroadcastChannel' in window), oH=netHost, oJ=netJoin, oStart=NET.start, oRel=partyReload, oNav=partyNav, oParty=PARTY, tl=document.getElementById('title'), tDisp=tl?tl.style.display:'', sv=null, bad=[];
     function BC(n){ this.posted=[]; R.chans.push(this); }
     BC.prototype.postMessage=function(m){ this.posted.push(m); };
     BC.prototype.close=function(){};
     function rigOn(){
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,pick:NET.pick,arcPick:NET.arcPick,busy:NET.sameBusy,role:NET.role,on:NET.on,padIx:NET.padIx,padOther:NET.padOther,padWas:NET.padWas,p2win:NET.p2win};
       window.open=function(){ R.opens++; return null; }; window.BroadcastChannel=BC;
       netHost=function(){ return {then:function(){}}; }; netJoin=function(c){ R.joins.push(String(c)); return {then:function(){}}; };
       NET.start=function(){}; partyReload=function(){ R.reloads++; return true; }; partyNav=function(u){ R.navs.push(String(u)); };
     }
     function rigOff(){
       try{ clearInterval(NET.partyT); }catch(_a){}
       PARTY=false; PARTY_EXIT=0;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_b){}
       PARTY=oParty; window.open=oOpen;
       if(hadBC) window.BroadcastChannel=oBC; else { try{ delete window.BroadcastChannel; }catch(_d){ window.BroadcastChannel=undefined; } }
       netHost=oH; netJoin=oJ; NET.start=oStart; partyReload=oRel; partyNav=oNav;
       try{ netReset(); }catch(_c){}
       try{ if(sv){ NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.pick=sv.pick; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy; NET.padIx=sv.padIx; NET.padOther=sv.padOther; NET.padWas=sv.padWas; NET.p2win=sv.p2win||null; } }catch(_e){}
       if(tl) tl.style.display=tDisp;
       try{ localStorage.removeItem(p2RaidKey()); localStorage.removeItem(p2LiveKey()); }catch(_f){}
       try{ document.documentElement.classList.remove('party'); document.documentElement.classList.remove('partyhide'); }catch(_g){}
     }
     function sent(t){ var c=NET.bc, n=0, i; if(c&&c.posted) for(i=0;i<c.posted.length;i++) if(c.posted[i]&&c.posted[i].t===t) n++; return n; }
     function guard(){
       if(typeof partyHostBoot!=='function'||typeof partyP2Boot!=='function'||typeof PARTY==='undefined') return 'this build has no party launch mode (?party=1)';
       if(ARCADE.on) return 'SKIP: the arcade is on';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       return null;
     }
     function prep(){ __topClear(); __runPrep(); if(__state()&&!__state().over) __endRaid('abandon'); }     var gd, t10=String(Date.now()-10000);
     try{
       prep(); gd=guard(); if(gd) return gd;
       rigOn();
       localStorage.setItem(p2RaidKey(),t10); localStorage.setItem(p2LiveKey(),t10);
       if(!p2RaidNow()) return 'SKIP: the stale mark did not read as a raid in the other window';
       if(partyHostBoot('?party=1&pair=abcd1234')!=='host'||!ARCADE.on) bad.push('a party boot with stale player 2 marks did not enter the arcade');
       if(p2RaidNow()) bad.push('the stale player 2 raid mark is still there');
       if(localStorage.getItem(p2LiveKey())) bad.push('the stale player 2 live mark is still there');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ rigOff(); __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'30.84',what:")) { throw "check 30.84 is in the fixture already" }

SubRx @'
  {v:'30.83',what:
'@ @'
  {v:'30.84',what:'the two windows of a pair see each other in the Undercroft over the pair channel (his order of 2026-10-18: players 1 and 2 should be able to see each other in the undercroft): a mate word with the pair code makes the floor draw him once with the operator body where he stands, in his own look, with his name over him, and a nameless one reads player 2 in the host window and player 1 in the other; a word with another pair code is ignored; with no pair on a word draws nothing and a floor update posts nothing; with the pair on a floor update posts where this player stands with the pair code and his look, a few times a second; a word that he left removes him, so does a long silence; a linked party that already shows him draws him once; leaving the floor for a raid posts that this window left; and the seeded stream never moves',
   run:function(){
     if(typeof NET==='undefined'||!NET||typeof netSameOnMsg!=='function'||typeof netSamePost!=='function'||typeof drawHubWorld!=='function'||typeof updateHubWorld!=='function'||typeof netReset!=='function')
       return 'this build has no pair channel or no Undercroft floor to draw the other window on';
     if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running, and the pair meets on the Undercroft floor';
     if(!(window.__hubEnter&&window.__topClear&&window.__deploy&&window.__frame&&window.__endRaid&&window.__runPrep)) return 'SKIP: this fixture cannot drive the floor and a raid';
     if(NET.same||NET.on||NET.pair) return 'SKIP: a pair or a party is on in this copy, and the check stands in for the other window';
     var PAIR='zqxmate1', MX=333, MY=277, bad=[], ops=[], texts=[], posted=[], r, i, rng0=null, rng1=null, spied=false, fillOwn=false, oFill=null, raided=false, w, ws, m1, px, py;
     var oOp=drawOp, oPost=netSamePost, oCrowd=(typeof tickHubCrowd==='function')?tickHubCrowd:null, _s2=(typeof say2==='function')?say2:null;
     var SAYT=(typeof HUBSAY_T==='number')?HUBSAY_T:null, keepNet={same:NET.same,pair:NET.pair,mode:NET.mode,on:NET.on,seat:NET.seat};
     function frame(){ ops=[]; texts=[]; try{ drawHubWorld(0); }catch(e){ bad.push('a floor frame threw: '+(e&&e.message||e)); } }
     function at(x,y){ var out=[], j, o; for(j=0;j<ops.length;j++){ o=ops[j]; if(!o.hero&&Math.abs(o.x-x)<=1.5&&Math.abs(o.y-y)<=1.5) out.push(o); } return out; }
     function painted(t){ return texts.join('|').toLowerCase().indexOf(String(t).toLowerCase())>=0; }
     function words(t){ var out=[], j; for(j=0;j<posted.length;j++) if(posted[j]&&posted[j].t===t) out.push(posted[j]); return out; }
     function mate(pair,x,y,nm){ var o={t:'hubmate',pair:pair,x:x,y:y,f:0.5,m:0,r:0,lk:{fit:'moss',hair:'red'}}; if(nm) o.nm=nm; return o; }
     function unspy(){
       try{ if(spied){ drawOp=oOp; netSamePost=oPost; if(oCrowd) tickHubCrowd=oCrowd; } }catch(_r){}
       try{ if(spied&&oFill){ if(fillOwn) wc.fillText=oFill; else delete wc.fillText; } }catch(_f){}
       spied=false;
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });   // a fresh profile opens the welcome window
       try{ var pbx=document.getElementById('pausebox'); if(pbx&&pbx.classList.contains('on')){ try{ togglePauseBox(false); }catch(_tp){} if(pbx.classList.contains('on')){ pbx.classList.remove('on'); pauseOpen=false; } } }catch(_pb){}
       if(typeof state==='undefined'||state!=='hub'||!HB||!HB.player||!wc) return 'SKIP: the Undercroft floor is not up here';
       netReset();
       for(var k in keys) keys[k]=false;
       if(_s2) say2=function(){};
       rng0=RNGS;
       fillOwn=Object.prototype.hasOwnProperty.call(wc,'fillText'); oFill=wc.fillText;
       spied=true;
       drawOp=function(x,y,face,ph,coat,pk,mz,mode,iv,st){
         ops.push({x:x,y:y,f:face,mode:String(mode),hero:!!(st&&st.hero),hair:st?st.hair:undefined,own:(st&&st.own)||null});
         return oOp.apply(null,arguments);
       };
       if(oCrowd) tickHubCrowd=function(){};
       wc.fillText=function(t){ texts.push(String(t)); return oFill.apply(wc,arguments); };
       netSamePost=function(m){ try{ posted.push(JSON.parse(JSON.stringify(m))); }catch(_j){} return true; };

       // ZERO: the spot is empty.
       frame(); frame();
       if(at(MX,MY).length) return 'SKIP: something already stands where the other window is staged';

       // ONE: SOLO. No pair on: a word draws nothing, a floor update posts nothing.
       netSameOnMsg(mate(PAIR,MX,MY,'ZQX MATE'));
       frame();
       if(at(MX,MY).length||painted('ZQX MATE')) bad.push('with no pair on a mate word still drew a body or his name');
       posted.length=0; updateHubWorld(0.3); updateHubWorld(0.3);
       if(posted.length) bad.push('with no pair on a floor update still posted '+posted.length+' words on the pair channel');

       // TWO: THE HOST WINDOW. The pair is on; he is player 2.
       NET.same='host'; NET.pair=PAIR; NET.mode='coop';
       r=netSameOnMsg(mate('zqxother9',111,222,'ZQX OTHER'));
       frame();
       if(at(111,222).length||painted('ZQX OTHER')) bad.push('a mate word with another pair code was drawn');
       r=netSameOnMsg(mate(PAIR,MX,MY,'ZQX MATE'));
       frame();
       m1=at(MX,MY);
       if(m1.length!==1) bad.push('a mate word with the pair code did not draw him once where he stands: '+m1.length+' bodies at '+MX+','+MY+' (the handler said '+r+')');
       else if(m1[0].hair!=='red') bad.push('he is not dressed from his look: hair '+m1[0].hair+' for red');
       if(!painted('ZQX MATE')) bad.push('his name is not painted over him');
       netSameOnMsg(mate(PAIR,MX,MY));
       frame();
       if(!painted('player 2')) bad.push('a nameless mate in the host window is not called player 2');

       // THREE: THE OTHER WINDOW. The pair is on; he is player 1.
       r=netSameOnMsg({t:'hubgone',pair:PAIR});
       NET.same='p2';
       netSameOnMsg(mate(PAIR,MX,MY));
       frame();
       if(at(MX,MY).length!==1) bad.push('in the player 2 window a mate word did not draw him once');
       if(!painted('player 1')) bad.push('a nameless mate in the player 2 window is not called player 1');
       netSameOnMsg({t:'hubgone',pair:PAIR});
       NET.same='host';

       // FOUR: THIS WINDOW SENDS where this player stands, a few times a second, with the pair code and his look.
       posted.length=0;
       px=HB.player.x; py=HB.player.y;
       for(i=0;i<20;i++) updateHubWorld(0.05);
       ws=words('hubmate');
       if(ws.length<3||ws.length>15) bad.push('a second on the floor posted '+ws.length+' mate words, not a few');
       else {
         w=ws[0];
         if(w.pair!==PAIR) bad.push('the mate word does not carry the pair code');
         if(Math.abs(w.x-px)>3||Math.abs(w.y-py)>3) bad.push('the mate word says '+w.x+','+w.y+' and this player stands at '+px.toFixed(1)+','+py.toFixed(1));
         if(!w.lk||typeof w.lk!=='object') bad.push('the first mate word carries no look, so he would arrive undressed');
       }

       // FIVE: HE LEAVES. A word that he left removes him; so does a long silence.
       netSameOnMsg(mate(PAIR,MX,MY,'ZQX MATE'));
       frame();
       if(at(MX,MY).length!==1) bad.push('control: the mate was not drawn before the word that he left');
       r=netSameOnMsg({t:'hubgone',pair:PAIR});
       frame();
       if(at(MX,MY).length||painted('ZQX MATE')) bad.push('after the word that he left he is still drawn (the handler said '+r+')');
       netSameOnMsg(mate(PAIR,MX,MY,'ZQX MATE'));
       updateHubWorld(1.0); updateHubWorld(1.0); updateHubWorld(1.0);
       frame();
       if(at(MX,MY).length) bad.push('a mate not heard from for 3 s is still drawn');

       // SIX: A LINKED PARTY that already shows him draws him once, where the party says.
       netSameOnMsg(mate(PAIR,MX,MY,'ZQX MATE'));
       NET.on=true; NET.seat=0; NET.roster=[{seat:0,name:'ZQX A'},{seat:1,name:'ZQX WEB'}];
       NET.floor=[null,{seat:1,x:150,y:150,f:0,tx:150,ty:150,tf:0,mv:0,roll:0,bob:0,age:0,n:1,lk:null,cr:0,sp:0,dn:0,w:'',sd:0,wep:null}];
       frame();
       if(at(150,150).length!==1||at(MX,MY).length) bad.push('with a linked party showing him he is drawn '+at(150,150).length+' times in the party place and '+at(MX,MY).length+' times in the pair place');
       NET.on=false; NET.floor=[]; NET.roster=[]; NET.seat=keepNet.seat;
       netSameOnMsg({t:'hubgone',pair:PAIR});
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the floor code');

       // SEVEN: LEAVING THE FLOOR says so. This window stands on the floor, posts, then goes up into a raid.
       unspy();
       netSamePost=function(m){ try{ posted.push(JSON.parse(JSON.stringify(m))); }catch(_j){} return true; };
       spied=true; fillOwn=false; oFill=null;
       NET.same='host'; NET.pair=PAIR;
       posted.length=0;
       updateHubWorld(0.3);
       if(!words('hubmate').length) bad.push('control: the floor update posted no mate word before the raid');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); raided=true;
       for(i=0;i<6;i++) __loop(performance.now()+i*16.7);
       if(!words('hubgone').length) bad.push('this window went up into a raid and never posted that it left the floor, so the other window keeps drawing a body that is not there');
       else if(words('hubgone')[0].pair!==PAIR) bad.push('the word that this window left does not carry the pair code');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ NET.same=''; NET.pair=''; NET.mode=keepNet.mode; NET.on=false; NET.seat=keepNet.seat; }catch(_n){}
       try{ netReset(); }catch(_nr){}
       unspy();
       try{ if(typeof netSamePost==='function'&&netSamePost!==oPost) netSamePost=oPost; }catch(_sp){}
       try{ if(raided) __endRaid('abandon'); }catch(_e){}
       try{ for(var kz in keys) keys[kz]=false; }catch(_kz){}
       try{ if(SAYT!==null) HUBSAY_T=SAYT; }catch(_st){}
       try{ if(_s2) say2=_s2; }catch(_s2e){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

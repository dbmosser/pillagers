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

if ($s.Contains("  {v:'22.68',what:")) { throw "check 22.68 is in the fixture already" }

SubRx @'
  {v:'22.67',what:
'@ @'
  {v:'22.68',what:'a downed teammate shows DOWN with his seconds over his head, and within reach [E] REVIVE NAME with the seconds; out of reach only DOWN shows and no revive prompt',
   run:function(){
     if(typeof netMateDown!=='function'||typeof netOnState!=='function'||typeof netUpTags!=='function'||typeof netUpShown!=='function'||typeof drawHUD!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no teammates up top';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,up:NET.up,upOut:NET.upOut,peers:NET.peers,roster:NET.roster,status:NET.status,srch:NET.srch,holds:NET.holds},
         oSend=netSend, oRef=netRefresh, oSay=say, oBlip=blip, k0=keys, bad=[], k, peer, p, w, g1, seen=[], oFT=ctx.fillText, oWT=(typeof wc!=='undefined'&&wc)?wc.fillText:null, NM='ZQX'+' MATE', txt;
     function spy(){ seen=[]; ctx.fillText=function(t){ seen.push(String(t)); return oFT.apply(this,arguments); }; if(oWT&&wc!==ctx) wc.fillText=function(t){ seen.push(String(t)); return oWT.apply(this,arguments); }; }
     function unspy(){ try{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }catch(_a){} try{ if(oWT&&wc!==ctx){ delete wc.fillText; if(wc.fillText!==oWT) wc.fillText=oWT; } }catch(_b){} }
     function look(){ spy(); try{ netUpTags(); }catch(_t){ seen.push('THREW '+_t.message); } try{ drawHUD(); }catch(_h){ seen.push('THREW '+_h.message); } finally{ unspy(); } return seen; }
     function has(f){ for(var j=0;j<seen.length;j++) if(f(seen[j])) return seen[j]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player||G.over) return 'SKIP: staging: no raid';
       p=G.player; keys={}; G.sim=0; p.downed=false; p.roll=0; p.iv=99; G.ents.length=0; G.bagOpen=false; G.mapOpen=false;
       G.nearContainer=null; G.nearDoor=null; G.nearDown=null; G.nearSeal=null; G.nearStray=null; G.nearPed=null; G.nearPad=false;
       netSend=function(){ return true; }; netRefresh=function(){}; say=function(){}; blip=function(){};
       peer={state:'in',seat:1};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:NM}]; NET.up=[]; NET.upOut=undefined; NET.specG=null; NET.holds={}; NET.srch=null;
       w={t:'st',k:'r',sd:G.seed>>>0,x:p.x+40,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:1,w:'',pz:0,hp:0,mh:100,ar:0,ac:0,dt:12,sa:1};
       netOnState(peer,w);
       g1=NET.up[1];
       if(!g1||!g1.dn||!netUpShown(g1)) return 'SKIP: staging: the downed teammate word was not filed up top';
       g1.x=p.x+40; g1.y=p.y; g1.dt=12;
       if(netMateDown(p)!==1) return 'SKIP: staging: the teammate 40 units away is not in revive reach';
       look();
       txt=has(function(s){ return s.indexOf('REVIVE')>=0&&s.indexOf(NM)>=0; });
       if(!txt) bad.push('a downed teammate 40 units away has no REVIVE prompt naming him ('+JSON.stringify(seen.filter(function(s){ return s.indexOf(NM)>=0||s.indexOf('DOWN')>=0; }))+')');
       else if(txt.indexOf('12s')<0||txt.indexOf('[')!==0) bad.push('the revive prompt over him reads '+JSON.stringify(txt)+', not [key] REVIVE with his seconds');
       if(!has(function(s){ return s.indexOf('DOWN')===0&&s.indexOf('12s')>0; })) bad.push('a downed teammate 40 units away shows no DOWN with his seconds');
       g1.x=p.x+400; g1.y=p.y;
       if(netMateDown(p)>=0) return 'SKIP: staging: the teammate 400 units away is still in revive reach';
       look();
       if(has(function(s){ return s.indexOf('REVIVE')>=0&&s.indexOf(NM)>=0; })) bad.push('a downed teammate 400 units away, out of reach, still shows a revive prompt');
       if(!has(function(s){ return s.indexOf('DOWN')===0; })) bad.push('a downed teammate 400 units away does not show DOWN over his head');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally {
       unspy();
       netSend=oSend; netRefresh=oRef; say=oSay; blip=oBlip; keys=k0;
       for(k in keep) NET[k]=keep[k];
       try{ if(G){ G.netRevEat=0; G.netRevWait=-1; G.netRevDone=-1; G.netRevT=0; G.netRevS=-1; if(G.player){ G.player.downed=false; G.player.iv=0; } } }catch(e){}
       try{ __endRaid('abandon'); __topClear(); __cleanProfile(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

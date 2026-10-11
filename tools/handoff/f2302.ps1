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

if ($s.Contains("  {v:'23.02',what:")) { throw "check 23.02 is in the fixture already" }

SubRx @'
  {v:'23.01',what:
'@ @'
  {v:'23.02',what:'never-words out of raid text: a machine wreck prompts SEARCH WRECK, a dead Sentry and a dead Crier are labelled DESTROYED, a ping on a Crier, a Pillbox, a Survivor and the Peddler names them so with no colon label, and the Current Pillagers board counts the dead as dead; no drawn or said text holds SNITCH, CHOIR, STRAY, BOTWRECK or PEDLAR, or a machine name followed by DOWN',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace)||typeof mkContainer!=='function'||typeof mkSentry!=='function'||typeof netEntDeathFx!=='function'||typeof netPingName!=='function'||typeof netPingDraw!=='function'||typeof drawRaiderBoard!=='function'||typeof canSee!=='function') return 'SKIP: no prompts, kill labels, pings or board here';
     var bad=[], g=null, p=null, i, j, tr, ct, e, a, ok, all=[], said=[], realSay=say, keepN={on:NET.on,seat:NET.seat,roster:NET.roster,pings:NET.pings,wps:NET.wps},
         NEVER=['SNI'+'TCH','CHO'+'IR','STR'+'AY','BOT'+'WRECK','PED'+'LAR'], MACH=['SENTRY','CRIER','PILLBOX','WARDEN','BULWARK','HOWLER','CRAWLER','LISTENER'], rr=null, row=null;
     function scan(list,where){ for(var q=0;q<list.length;q++){ var s=String(list[q]); for(var k=0;k<NEVER.length;k++) if(s.toUpperCase().indexOf(NEVER[k])>=0) bad.push(where+' reads '+JSON.stringify(s)); for(var k2=0;k2<MACH.length;k2++) if(s.indexOf(MACH[k2])===0&&(/ DOWN$/).test(s)) bad.push(where+' reads '+JSON.stringify(s)+', a machine DOWN'); } }
     function texts(fn){ return __textTrace(fn).map(function(o){ return o.t; }); }
     function lbls(){ return g.labels.map(function(l){ return String(l.txt); }); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; g.bagOpen=false; g.mapOpen=false; p.downed=false;
       say=function(m,k,o){ said.push(String(m)+((o&&o.sub)?(' '+o.sub):'')); return realSay.apply(this,arguments); };
       // ONE: the search prompt on a machine wreck
       ct=mkContainer(p.x+30,p.y,'botwreck'); g.containers.push(ct);
       g.nearContainer=ct; g.searching=null;
       tr=texts(function(){ drawHUD(); });
       scan(tr,'the search prompt on a machine wreck');
       if(!tr.some(function(s){ return s.indexOf('SEARCH WRECK')>=0; })) bad.push('a machine wreck does not prompt SEARCH WRECK (drawn: '+JSON.stringify(tr.filter(function(s){ return s.indexOf('SEARCH')>=0; }))+')');
       g.nearContainer=null; g.containers.splice(g.containers.indexOf(ct),1);
       // TWO: a dead Sentry in view (the host path) and a dead Crier in a linked window
       for(a=0;a<16&&!rr;a++){ var ang=a*Math.PI/8, tx=p.x+Math.cos(ang)*110, ty=p.y+Math.sin(ang)*110; p.face=ang; if(canSee(p.x,p.y,p.face,tx,ty,g.vseg)) rr={x:tx,y:ty}; }
       if(!rr) return 'SKIP: staging: no clear line of sight from the spawn';
       g.labels.length=0;
       e=mkSentry(rr.x,rr.y); e.hp=0; e.state='patrol'; g.ents.length=0; g.ents.push(e);
       __ents(0.016);
       all=lbls(); scan(all,'the kill label of a Sentry');
       if(!all.some(function(s){ return (/DESTROYED$/).test(s); })) bad.push('a dead Sentry in view is not labelled DESTROYED (labels: '+JSON.stringify(all)+')');
       g.labels.length=0;
       netEntDeathFx({kind:'snitch',name:'',x:rr.x,y:rr.y,hp:0});
       all=lbls(); scan(all,'the kill label of a Crier in a linked window');
       if(all.indexOf('CRIER DESTROYED')<0) bad.push('a dead Crier in a linked window is not labelled CRIER DESTROYED (labels: '+JSON.stringify(all)+')');
       g.labels.length=0;
       // THREE: pings
       ok={snitch:'CRIER',choir:'PILLBOX',stray:'SURVIVOR',peddler:'THE PEDDLER'};
       for(var kk in ok){ var w=netPingName({kind:kk,name:''}); if(w!==ok[kk]) bad.push('a ping on a '+ok[kk]+' says '+JSON.stringify(w)); }
       NET.on=false; NET.seat=0; NET.roster=[{seat:0,name:'Host'},{seat:1,name:'Zqxkid'}]; NET.wps={};
       NET.pings=[{x:p.x+80,y:p.y+20,at:Date.now(),s:1,w:netPingName({kind:'snitch',name:''})},{x:p.x-80,y:p.y-20,at:Date.now(),s:1,dg:1}];
       tr=texts(function(){ ctx.save(); try{ netPingDraw(); } finally { ctx.restore(); } });
       scan(tr,'a ping label');
       for(i=0;i<tr.length;i++) if(tr[i].indexOf(': ')>=0) bad.push('a ping label is a colon label: '+JSON.stringify(tr[i]));
       if(!tr.some(function(s){ return s.indexOf('CRIER')>=0&&(/\d+m$/).test(s); })) bad.push('a ping on a Crier is not drawn naming the CRIER with its distance (drawn: '+JSON.stringify(tr)+')');
       NET.pings=[];
       // FOUR: the board counts the dead as dead
       if(g.roster&&g.roster.length){
         for(i=0;i<g.roster.length&&!row;i++){ var r=g.roster[i]; if(r&&!r.merc&&r.ref&&g.ents.indexOf(r.ref)<0&&!r.out) row=r; }
         if(row){
           tr=texts(function(){ ctx.save(); try{ drawRaiderBoard(); } finally { ctx.restore(); } });
           scan(tr,'the Current Pillagers board');
           if(tr.some(function(s){ return (/\d+ down$/).test(s); })) bad.push('the board counts the dead as down: '+JSON.stringify(tr.filter(function(s){ return (/ down$/).test(s); })));
           if(!tr.some(function(s){ return (/\d+ dead$/).test(s); })) bad.push('the board does not count the dead as N dead');
         }
       }
       scan(said,'a said line');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; NET.on=keepN.on; NET.seat=keepN.seat; NET.roster=keepN.roster; NET.pings=keepN.pings; NET.wps=keepN.wps; keys={};
       try{ var g2=__state(); if(g2){ g2.labels.length=0; g2.nearContainer=null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

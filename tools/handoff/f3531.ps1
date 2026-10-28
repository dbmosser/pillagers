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

if ($s.Contains("  {v:'35.31',what:")) { throw "check 35.31 is in the fixture already" }

SubRx @'
  {v:'35.30',what:
'@ @'
  {v:'35.31',what:'cw-quietpause, his order 2026-10-27 (build the quiet hud, all 5 changes): a line said under the solo pause box shows on the answer line over the box only and is not also written into the left feed behind it; with the box shut a system line is a feed line; and a finished contract whose words run to five or more names them on its feed line, now the one place it shows',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function'||typeof syncPause!=='function'||typeof netPauseLive!=='function') return 'SKIP: no pause box in this build';
     var bad=[], g=null, el=document.getElementById('hubtoast'), NP='ZQ '+'PAUSE NOTE', NS='ZQ '+'SHUT NOTE', con0;
     if(!el) return 'SKIP: no answer line in this page';
     function inFeed(s){ var L=(g&&g.fd&&g.fd.lines)||[], j; for(j=0;j<L.length;j++) if(String(L[j].txt).toUpperCase().indexOf(s)>=0) return true; return false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       g.fd={t:0,seq:0,lines:[]}; g.alert=null; g.alertQ=[]; g.mapPop=null; g.mapOpen=false; g.bagOpen=false;
       el.textContent=''; el.classList.remove('on');
       togglePauseBox(true); syncPause();
       if(!g.paused) return 'SKIP: staging: the pause box did not pause the raid';
       if(netPauseLive()) return 'SKIP: staging: this raid is shared, so its pause is the overlay';
       say(NP,'sys');
       if(String(el.textContent).toUpperCase().indexOf(NP)<0||!el.classList.contains('on')) bad.push('control: a system line said under the solo pause box is not on the answer line (it reads '+JSON.stringify(el.textContent)+')');
       if(inFeed(NP)) bad.push('a system line said under the solo pause box is also written into the left feed behind the box, so it shows again once the box shuts');
       togglePauseBox(false); syncPause(); g.paused=false;
       el.textContent=''; el.classList.remove('on');
       say(NS,'sys');
       if(!inFeed(NS)) bad.push('control: with the box shut a system line is not a line of the left feed');
       if(String(el.textContent).indexOf(NS)>=0) bad.push('control: with the box shut a system line went to the answer line');
       // TWO: a finished contract whose words run to five or more names them on its feed line; an unkeyed long detail still stays out
       if(typeof contractOpen==='function'&&typeof contractDesc==='function'&&window.__P){
         var P2=__P(), i, ct=null, c1, H1, L, ln=null, lg=null; con0=P2.contracts;
         for(i=0;i<g.containers.length;i++){ var k0=g.containers[i]; if(k0&&!k0.dropped&&!k0.opened&&k0.type){ ct=k0; break; } }
         c1=ct?{type:'open',ct:ct.type,n:2,prog:1,desc:'Open 2 zqx9k long named boxes',reward:100}:null;
         if(c1){ P2.contracts=[c1]; H1=contractDesc(c1); }
         if(c1&&String(H1).split(/\s+/).length>=5){
           g.fd={t:0,seq:0,lines:[]}; contractOpen(ct);
           L=g.fd.lines; for(i=0;i<L.length;i++) if(String(L[i].txt).indexOf('CONTRACT DONE')===0) ln=L[i];
           if(c1.prog<c1.n||!ln) bad.push('TWO control: the crate did not finish the contract into a line of the left feed (progress '+c1.prog+' of '+c1.n+')');
           else if(String(ln.txt).indexOf(H1)<0) bad.push('TWO: the finished contract line reads '+JSON.stringify(ln.txt)+', without its words '+JSON.stringify(H1));
           say('ZQX9K PLAIN HEAD','info',{sub:'this is a long explaining detail line'});
           L=g.fd.lines; for(i=0;i<L.length;i++) if(String(L[i].txt).indexOf('ZQX9K PLAIN HEAD')===0) lg=L[i];
           if(!lg) bad.push('TWO control: an info line said is not a line of the left feed');
           else if(String(lg.txt).indexOf('explaining')>=0) bad.push('TWO: an unkeyed line now shows its long explaining detail in the feed');
         }
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ if(con0!==undefined) __P().contracts=con0; }catch(_k){}
       try{ togglePauseBox(false); syncPause(); }catch(_c){} try{ pauseOpen=false; }catch(_c2){}
       try{ el.textContent=''; el.classList.remove('on'); if(typeof HUBTOAST_T!=='undefined'&&HUBTOAST_T){ clearTimeout(HUBTOAST_T); HUBTOAST_T=null; } }catch(_t){}
       try{ var g2=__state(); if(g2){ g2.paused=false; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

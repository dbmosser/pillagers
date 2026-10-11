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

if ($s.Contains("  {v:'22.60',what:")) { throw "check 22.60 is in the fixture already" }

SubRx @'
  {v:'22.59',what:
'@ @'
  {v:'22.60',what:'the pickup stack always draws its newest row: at Settings text size 175 and 200 percent, and with the gun card grip at 1.5x, a BACKPACK FULL row pushed into the stack is drawn at the right edge of the screen',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     if(typeof drawPickups!=='function'||typeof pickSay!=='function') return 'SKIP: no pickup stack here';
     var bad=[], g=null, oFT=ctx.fillText, ev=[], OP=Object.prototype.hasOwnProperty, hadUS=OP.call(P,'uiScale'), keepUS=P.uiScale,
         hadHud=OP.call(P,'hud'), keepHud=(P.hud!==undefined)?JSON.stringify(P.hud):null, BF=['BACKPACK','FULL'].join(' '),
         cases=[[1.75,1],[2.0,1],[1.2,1.5]], i, j, n, hit;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       for(i=0;i<cases.length;i++){
         P.uiScale=cases[i][0];
         if(!P.hud||typeof P.hud!=='object') P.hud={};
         P.hud.gear=JSON.parse(JSON.stringify(P.hud.gear||{})); P.hud.gear.z=cases[i][1];
         g.pick=[]; pickSay(BF,{key:'bagfull',c:'danger',sub:'[Z] DROP'});
         for(j=0;j<g.pick.length;j++) g.pick[j].at=(g.t||0)-1;
         ev=[]; n=-1;
         ctx.fillText=function(t,x){ ev.push([String(t),+x]); return oFT.apply(this,arguments); };
         ctx.save(); try{ n=drawPickups(); } finally { ctx.restore(); unspy(); }
         hit=false; for(j=0;j<ev.length;j++) if(ev[j][0].indexOf(BF)>=0&&ev[j][1]>W*0.6&&ev[j][1]<=W) hit=true;
         if(!hit) bad.push('at text size '+Math.round(cases[i][0]*100)+' percent with the gun card at '+cases[i][1]+'x the BACKPACK FULL row is not drawn (drawPickups drew '+n+' rows)');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy();
       if(hadUS) P.uiScale=keepUS; else delete P.uiScale;
       if(hadHud) P.hud=(keepHud===null)?undefined:JSON.parse(keepHud); else delete P.hud;
       try{ var g2=__state(); if(g2){ g2.pick=[]; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

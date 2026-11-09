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

if ($s.Contains("  {v:'37.68',what:")) { throw "check 37.68 is in the fixture already" }

SubRx @'
  {v:'37.67',what:
'@ @'
  {v:'37.68',what:'five local message sounds, per-kind cooldown, critical-only rumble and profile message controls; pickups untouched',
   run:function(){
     if(typeof msgSound!=='function'||typeof msgScaleK!=='function') return 'missing message controls';
     var oldTone=styTone, oldRumble=padRumble, oldNow=statusNow, oldPlate=hudPlate, oldGO=P.gameOpts, oldTuned=P.tuned,
       role=NET.role, on=NET.on, seat=NET.seat, spec=NET.specTick, bad=[], sounds=[], buzz=[], t=100, g, i, j, ln, r, a;
     function ok(v,m){ if(!v) bad.push(m); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'no raid for message checks';
       g.mapOpen=false; g.bagOpen=false; g.paused=false; g.hubFloor=false; g.sim=false;
       styTone=function(n){ sounds.push(JSON.stringify(n)); return true; };
       padRumble=function(s,ms){ buzz.push([s,ms]); return 'own'; };
       statusNow=function(){ return t; }; NET.specTick=0;
       P.gameOpts={}; P.tuned={}; applyGameOpts();
       var opts=[['msgTime',5,10],['msgScale',4,2],['msgOpacity',5,1]];
       for(i=0;i<opts.length;i++){ P.gameOpts[opts[i][0]]=opts[i][1]; applyGameOpts(); ok(CFG[opts[i][0]]===opts[i][2],opts[i][0]+' profile choice'); }
       ok(msgFont('600 20px sans-serif')==='600 40.0px sans-serif','200 percent text');
       var fill=''; hudPlate=function(x,y,w,h,c,f){ fill=f; }; msgPlate(0,0,100,30,null,HUDC.plate);
       ok(fill==='rgba(17,19,21,1)','opaque message plate'); CFG.msgOpacity=0; msgPlate(0,0,100,30,null,HUDC.plate);
       ok(fill==='rgba(17,19,21,0)','transparent message plate'); hudPlate=oldPlate; CFG.msgOpacity=1;
       for(j=0;j<2;j++){
         NET.on=true; NET.role=j?'join':'host'; NET.seat=j; sounds=[]; buzz=[]; g.msgSoundAt={};
         for(i=0;i<5;i++){ var c='abcde'[i]; msgSound(c,i===0?'crit':'','EXTRACTION CALLED',null); msgSound(c,i===0?'crit':'','EXTRACTION CALLED',null); }
         ok(sounds.length===5,'one sound per family in role '+j); ok(buzz.length===1,'only critical danger rumbles');
         ok(new Set(sounds).size===5,'families have distinct sounds');
         t+=2; msgSound('a','warn','DANGER',null); ok(buzz.length===1,'warning has no rumble');
         t+=2; g.msgSoundAt={}; sounds=[];
         g.alert=null; g.alertSeen={}; g.alertQ=[];
         alertSay('DANGER','crit',{key:'settings-test'}); alertSay('DANGER','crit',{key:'settings-test'});
         ok(sounds.length===1,'alert refresh has no second sound');
         a=g.alert; r=a.T; alertTick(1); ok(Math.abs(a.T-(r-0.1))<0.001,'10x alert time');
         g.fd=null; g.player.combatT=99; sounds=[]; g.msgSoundAt={};
         ln=feedSay('GOAL DONE','obj',{reach:'d'},'d');
         ok(ln&&ln.mc==='d'&&sounds.length===1,'goal sounds on display');
         if(ln){ g.fd.t=ln.at+10; ok(feedAlpha(ln)===1,'10x goal time'); }
         t+=2; g.ans=null; g.ansSeen={}; ansSay('NO AMMO'); t+=3; ok(!!ansUp(),'10x answer time');
         for(i=0;i<5;i++) P.gameOpts['msgOn'+'abcde'[i]]=1;
         applyGameOpts();
         for(i=0;i<5;i++){ var c2='abcde'[i]; ok(CFG['msgOn'+c2]===0,'saved kind off '+c2); g.msgSoundAt={}; sounds=[]; msgSound(c2,'crit','EXTRACTION CALLED',null); ok(!sounds.length,'disabled '+c2+' silent'); }
         g.alert=null; alertSay('DANGER','crit'); ok(!g.alert,'danger off');
         ok(!feedSay('GOAL DONE','obj',{reach:'d'},'d'),'goal off');
         ok(!feedSay('TEAMMATE OUT','ally',{reach:'c'},'c'),'teammate off');
         alertSay('EXTRACTION CALLED','ext'); ok(!g.alert,'extraction off');
         ok(!ansUp(),'answer off');
         g.fd=null; ln=feedAdd('+$10','money'); ok(ln&&!ln.mc,'money bypasses message controls');
         if(ln){ g.fd.t=ln.at+10; ok(feedAlpha(ln)===0,'money time unchanged'); }
         ok(msgFamily('+$10','pick',null)==='','pickup excluded');
         for(i=0;i<5;i++) P.gameOpts['msgOn'+'abcde'[i]]=0;
         applyGameOpts();
       }
       return bad.length?bad.join('; '):null;
     } finally {
       styTone=oldTone; padRumble=oldRumble; statusNow=oldNow; hudPlate=oldPlate; NET.role=role; NET.on=on; NET.seat=seat; NET.specTick=spec;
       try{ __endRaid('abandon'); }catch(e){} __topClear(); __resetCfg(); __cleanProfile(); P.gameOpts=oldGO; P.tuned=oldTuned; applyGameOpts();
     }
   }},
  {v:'37.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'35.61',what:")) { throw "check 35.61 is in the fixture already" }

SubRx @'
  {v:'35.60',what:
'@ @'
  {v:'35.61',what:'OS reduced motion supplies light shake and half intensity only for unset choices in both player windows, and really reduces shake and hit pause',
   run:function(){
     if(typeof gameOptIx!=='function'||typeof hitStopOn!=='function'||typeof gfxTrauma!=='function') return 'missing motion controls';
     var bad=[], g=null, om=window.matchMedia, go=P.gameOpts, tk=P.tuned, ns=NET.same, nr=NET.role, no=NET.on;
     var reduced=false, mode='ok', i, j, full, light, k;
     function mm(q){
       if(q==='(prefers-reduced-motion: reduce)'){
         if(mode==='throw') throw new Error('media unavailable');
         return {matches:reduced,media:q};
       }
       return om?om.call(window,q):{matches:false,media:q};
     }
     function want(tag,sh,fi){
       applyGameOpts();
       if(CFG.shake!==sh||CFG.fxInt!==fi) bad.push(tag+': shake/intensity '+CFG.shake+'/'+CFG.fxInt+' wanted '+sh+'/'+fi);
     }
     function pause(tag,seconds){
       var e={hp:100,boss:false,downed:false,finished:false,stopT:0,stopImm:0};
       var hit=hitStopOn(e,64);
       if(hit!==(seconds>0)||Math.abs(e.stopT-seconds)>1e-8) bad.push(tag+': hit pause '+e.stopT+' wanted '+seconds);
       if(seconds>0&&(e.stopImm!==HITSTOP_IMM||hitStopOn(e,64)!==false)) bad.push(tag+': hit immunity changed');
     }
     function shake(){ GFX.shG=null; g.shake=0; gfxTrauma(0); g.shake=7; return gfxTrauma(0.016); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       window.matchMedia=mm; itchDefs(0); P.gameOpts={}; P.tuned={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.sim) return 'could not stage a live raid';
       for(i=0;i<2;i++){
         NET.same=i?'p2':'host'; NET.role=i?'join':'host'; NET.on=false;
         k=i?'player 2':'player 1';
         reduced=false; P.gameOpts={}; P.tuned={}; want(k+' usual',1,1); pause(k+' usual',HITSTOP_T); full=shake();
         reduced=true; want(k+' reduced',0.5,0.5); pause(k+' reduced',HITSTOP_T*0.5); light=shake();
         if(!(full>0)||Math.abs(light-full*0.25)>1e-8) bad.push(k+': actual camera shake did not fall to one quarter');
         if(gameOptIx('shake')!==1||gameOptIx('fxInt')!==1) bad.push(k+': rows do not show light/half');
         if(Object.prototype.hasOwnProperty.call(P.gameOpts,'shake')||Object.prototype.hasOwnProperty.call(P.gameOpts,'fxInt')) bad.push(k+': defaults were saved as player picks');
         for(j=0;j<4;j++){
           P.gameOpts={shake:j}; want(k+' saved shake '+j,[0,0.5,1,1.5][j],0.5);
         }
         for(j=0;j<3;j++){
           P.gameOpts={fxInt:j}; want(k+' saved intensity '+j,0.5,[1,0.5,0][j]); pause(k+' saved intensity '+j,HITSTOP_T*[1,0.5,0][j]);
         }
         P.gameOpts={shake:2,fxInt:0}; want(k+' saved full',1,1);
         reduced=false; want(k+' saved full without OS request',1,1);
         reduced=true; P.gameOpts={}; P.tuned={shake:1,fxInt:1}; CFG.shake=1.3; CFG.fxInt=0.7; want(k+' tuned',1.3,0.7);
         P.tuned={}; P.gameOpts={}; mode='throw'; want(k+' unavailable query',1,1);
         mode='ok'; window.matchMedia=undefined; want(k+' no media API',1,1); window.matchMedia=mm;
         reduced=false; want(k+' unset after OS request ends',1,1);
         reduced=true; itchDefs(1); want(k+' itch reduced',0.5,0.5); itchDefs(0);
       }
       return bad.length?bad.join('; '):null;
     } finally {
       window.matchMedia=om; NET.same=ns; NET.role=nr; NET.on=no;
       P.gameOpts=go; P.tuned=tk; itchDefs(ON_ITCH?1:0);
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg();
       GFX.shG=null; GFX.tr=0; GFX.shL=0; GFX.shA=0; GFX.sx=0; GFX.sy=0;
     }
   }},
  {v:'35.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

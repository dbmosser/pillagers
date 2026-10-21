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

if ($s.Contains("  {v:'33.36',what:")) { throw "check 33.36 is in the fixture already" }

SubRx @'
  {v:'33.35',what:
'@ @'
  {v:'33.36',what:'cw-mmoff, his order (2026-10-20): the minimap is off by default in a career raid and in the demo (nothing drawn, MMAP.box empty), the Settings row turns it back on at its old size, a save that held a minimap size comes in as off once and then keeps his pick, and the run info panel sits higher with it off',
   run:function(){
     if(typeof mmShown!=='function'||typeof drawMinimap!=='function'||typeof MMAP==='undefined'||!window.__opts) return 'SKIP: no minimap here';
     var bad=[], g, kGO=P.gameOpts, kF=P.mmOff1, kS=CFG.mmSz, kM=CFG.minimap, R, w0, bb, tb0, row, i;
     function draw(){ __frame(0); __frame(0); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false;
       R=hudRes();
       // ONE: a fresh profile in a career raid draws no minimap
       P.gameOpts={}; delete P.mmOff1; CFG.minimap=1; __opts.apply(); draw();
       if(CFG.mmSz!==0) bad.push('ONE: a fresh profile has mmSz '+CFG.mmSz+', not 0 (off)');
       if(MMAP.box) bad.push('ONE: a fresh career raid drew a minimap');
       tb0=HUDBOX.cond?HUDBOX.cond.y:-1;   // the run info panel
       // TWO: the row has OFF first and steps S, N, L; Standard is the old plate and pushes the panels under it down
       row=null; (__opts.rows()||[]).forEach(function(r){ if(r.k==='mmSize') row=r; });
       if(!row||!row.opts||row.opts[0].n!=='OFF'||row.def!==0) bad.push('TWO: the MINIMAP row does not start at OFF');
       if(row&&row.opts.length!==4) bad.push('TWO: the MINIMAP row has '+row.opts.length+' choices, not 4');
       __opts.cycle('mmSize'); __opts.cycle('mmSize'); draw();
       if(CFG.mmSz!==1) bad.push('TWO: two clicks gave mmSz '+CFG.mmSz+', not 1 (standard)');
       if(!MMAP.box) bad.push('TWO: standard drew no minimap');
       else {
         w0=MMAP.box.w; bb=MMAP.box.y+MMAP.box.h;
         if(w0<Math.round(216*R)) bad.push('TWO: the standard plate is '+w0+' wide, under the old '+Math.round(216*R));
         if(!(tb0>=0&&HUDBOX.cond&&tb0<HUDBOX.cond.y)) bad.push('TWO: the run info panel did not move down for the minimap (off '+tb0+', on '+(HUDBOX.cond&&HUDBOX.cond.y)+')');
       }
       __opts.cycle('mmSize'); draw();
       if(CFG.mmSz!==1.35||!MMAP.box||Math.abs(MMAP.box.w-w0*1.35)>2) bad.push('TWO: large is not 1.35 times the standard plate');
       __opts.cycle('mmSize'); draw();
       if(CFG.mmSz!==0||MMAP.box) bad.push('TWO: the fourth click did not go round to off');
       // THREE: a save that held a size comes in as off once, then his pick stays
       P.gameOpts={mmSize:2,volMaster:3}; delete P.mmOff1; __opts.apply();
       if(CFG.mmSz!==0||P.gameOpts.mmSize!==0) bad.push('THREE: an old save with a minimap size did not come in as off ('+CFG.mmSz+')');
       if(P.mmOff1!==1) bad.push('THREE: the one-time flag was not set');
       if(P.gameOpts.volMaster!==3) bad.push('THREE: the move touched another row');
       __opts.cycle('mmSize'); __opts.apply();
       if(P.gameOpts.mmSize!==1||CFG.mmSz!==0.75) bad.push('THREE: his pick after the move was reset ('+P.gameOpts.mmSize+')');
       // FOUR: the demo follows the same row, off by default
       __endRaid('abandon'); __topClear();
       P.gameOpts={}; delete P.mmOff1; __opts.apply();
       if(typeof arcadeDeploy==='function'&&typeof ARCADE==='object'&&ARCADE){
         if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('FOUR: arcadeDeploy built no arcade raid');
         else {
           g=__state(); if(g&&!g.over&&g.player){
             draw(); if(MMAP.box) bad.push('FOUR: the demo drew a minimap by default');
             __opts.cycle('mmSize'); __opts.cycle('mmSize'); draw();
             if(!MMAP.box) bad.push('FOUR: the demo did not draw the minimap with the row on');
           }
         }
       }
       return bad.length?bad.join('; '):null;
     } finally { P.gameOpts=kGO; if(kF===undefined) delete P.mmOff1; else P.mmOff1=kF; CFG.mmSz=kS; CFG.minimap=kM; try{ __endRaid('abandon'); }catch(_e){} __topClear(); } }},
  {v:'33.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

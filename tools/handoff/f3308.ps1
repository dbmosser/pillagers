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

if ($s.Contains("  {v:'33.08',what:")) { throw "check 33.08 is in the fixture already" }

SubRx @'
  {v:'33.07',what:
'@ @'
  {v:'33.08',what:'golden sentry and pillager bot death callouts draw once in both windows and keep search the hoard (critic duplicate finding)',
   run:function(){
     var g=null, oPeer=flowPeer, own=Object.prototype.hasOwnProperty.call(XF,'xfGold'), gold0=XF.xfGold,
         kinds=['sentry','raider'], names=['golden sentry down','golden pillager bot down'], i, side, trace, hits, want;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'staging: no raid';
       flowPeer=function(){ return false; }; XF.xfGold=1;
       g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.legendOn=0;
       for(i=0;i<kinds.length;i++) for(side=0;side<2;side++){
         g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.alert=null; g.msgLog=[]; g.fd=null;
         g.mapPop={q:[],wait:0,replay:0,open:false,at:0}; g.flow=g.flow||{};
         if(side===0){
           g.flow.gold={ref:{kind:kinds[i],hp:0,x:g.player.x+100,y:g.player.y},dead:0}; goldTick(0.01);
         }else{
           g.flow.gold={ref:null,dead:0}; goldNetTake([0,1,g.player.x+100,g.player.y,kinds[i]]);
         }
         feedTick(0.3); trace=__textTrace(function(){ __frame(0.016); }); want=names[i];
         hits=trace.filter(function(r){ return r.t.toLowerCase().indexOf(want)>=0; });
         if(hits.length!==1) return (side?'linked ':'host ')+want+' drawn '+hits.length+' times';
         if(hits[0].t.toLowerCase().indexOf('search the hoard')<0) return 'missing search the hoard';
       }
       return null;
     } finally {
       flowPeer=oPeer; if(own) XF.xfGold=gold0; else delete XF.xfGold;
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     } }},
  {v:'33.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

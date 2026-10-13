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

if ($s.Contains("  {v:'24.60',what:")) { throw "check 24.60 is in the fixture already" }

SubRx @'
  {v:'24.59',what:
'@ @'
  {v:'24.60',what:'his answer 35: the low health heartbeat is a lub-dub with a knock a laptop speaker can play, louder as it gets worse',
   run:function(){
     if(typeof __audio!=='object'||!__audio.record||!__audio.blipRaw) return 'SKIP: no audio recorder in this fixture';
     var bad=[], lg, hi=0, lo=0, starts=[], i, keepSim=(G?G.sim:null), seen=null, rb=blip;
     try{
       if(G) G.sim=false;
       lg=__audio.record(function(){ __audio.blipRaw('heart',0,undefined,1); });
       var os=(lg&&lg.osc)||[];
       for(i=0;i<os.length;i++){ if(os[i].t0!==null&&starts.indexOf(+(+os[i].t0).toFixed(3))<0) starts.push(+(+os[i].t0).toFixed(3)); }
       if(starts.length<2) bad.push('the heartbeat is one beat (starts at '+starts.join(',')+'), not a lub-dub');
       if(os.length<4) bad.push('the heartbeat has no knock a small speaker plays ('+os.length+' oscillators, not two thumps and two knocks)');
       if(window.__deploy&&window.__endRaid){
         __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         var g=__state(); if(g&&!g.over&&!g.sim){
           blip=function(k){ if(k==='heart') seen=[].slice.call(arguments); };
           g.player.hp=12; HEART=0;
           for(var f=0;f<6&&!seen;f++) __loop(performance.now()+f*16.7);
           blip=rb;
           if(!seen) bad.push('no heartbeat at 12 health');
           else if(!(typeof seen[3]==='number'&&seen[3]>0.5)) bad.push('the heartbeat at 12 health is not told how bad it is ('+seen[3]+')');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ blip=rb; try{ if(G&&keepSim!==null) G.sim=keepSim; }catch(_s){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.hp=100; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

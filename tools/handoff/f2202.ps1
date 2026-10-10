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

if ($s.Contains("  {v:'22.02',what:")) { throw "check 22.02 is in the fixture already" }

SubRx @'
  {v:'22.01',what:
'@ @'
  {v:'22.02',what:'a teammate who joined late is timed from when he came up: the swift contract, the abandon fee, the instant quit test and the time on his run card all count his own time, not the host raid',
   run:function(){
     if(typeof runElapsed!=='function'||typeof conductMet!=='function'||typeof raidClockOn!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: no late join clock here';
     var bad=[], oSay=say, said=[], xp0=P.xp, runs0, Ln, cb, g, h, T, nd;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!raidClockOn()) return 'SKIP: this raid has no clock';
       Ln=(g.raidLen===undefined?CFG.raidSec:g.raidLen); if(!(Ln>480)) return 'SKIP: the raid is too short to stage';
       say=function(s){ said.push(String(s)); };
       g.timeLeft=Ln-437; g.lateEl=414;   // the raid is 7 min 17 s old and he came up 23 s ago
       if(Math.abs(runElapsed()-23)>0.01) return 'SKIP: staging: his own time reads '+runElapsed();
       if(!conductMet('swift')) bad.push('23 seconds after he came up, the extract within three minutes contract already reads as broken');
       cb=document.getElementById('confirmabandon');
       if(!cb||typeof cb.onclick!=='function') return 'SKIP: no abandon button';
       P.xp=7777;
       g.player.downed=false; g.player.hp=Math.max(1,g.player.hp||100); g.deathBeat=0;
       cb.onclick.call(cb);
       if(!g.over) bad.push('the abandon confirm did not end the raid');
       if(said.some(function(s){ return s.indexOf('Walked out')===0; })||(g.abandonFee||0)>0) bad.push('an abandon 23 seconds after he came up cost him '+(g.abandonFee||0)+' XP');
       h=(document.getElementById('oc_manifest')||{}).innerHTML||'';
       nd='23 second'+'s on the surface';
       if(h.indexOf(nd)<0) bad.push('his run card does not say he was up top for 23 seconds'+(h.indexOf('7 min'+'s')>=0?' (it counts the host raid, 7 mins)':''));
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(!g||g.over||!g.player||!g.tel){ bad.push('staging: no second raid'); }
       else {
         Ln=(g.raidLen===undefined?CFG.raidSec:g.raidLen);
         g.timeLeft=Ln-437; g.lateEl=436.6;   // he came up 0.4 s ago and has done nothing
         T=g.tel; T.distance=0; T.containers=0; T.shots=0;
         runs0=P.runs;
         __endRaid('abandon');
         if(P.runs!==runs0) bad.push('a quit 0.4 seconds after he came up, having done nothing, was logged as a run and not as an instant quit');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=oSay;
       try{ var g2=__state(); if(g2){ g2.lateEl=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       P.xp=xp0;
       try{ saveProfile(); }catch(_sp){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

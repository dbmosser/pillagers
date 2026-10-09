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

if ($s.Contains("  {v:'20.85',what:")) { throw "check 20.85 is in the fixture already" }

SubRx @'
  {v:'20.84',what:
'@ @'
  {v:'20.85',what:'a hire on FOLLOW never takes the enemy footsteps: with the hire walking 150 away and a crawler walking 400 away the step heard is the crawler, and with only the hire walking no step plays',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof window.__enemyAudioReal!=='function'||typeof STEP_T==='undefined'||typeof ac!=='function') return 'SKIP: the real enemy step tick was not kept aside by this fixture';
     var EA=window.__enemyAudioReal, bad=[], calls=[], oBlip=blip, oAc=ac, g0=null, g, p, hire, cr;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||!p||g.over||g.sim) return 'SKIP: no live raid';
       g0=g; g.ents.length=0; p.iv=99;
       hire={kind:'raider',merc:1,friendly:1,hostile:false,grudge:false,name:'ZQXHIRE',x:p.x+150,y:p.y,state:'follow',moving:true,hp:90,maxhp:90,alert:0};
       cr={kind:'crawler',name:'ZQXCRAWL',x:p.x-400,y:p.y,state:'patrol',moving:true,hp:30,maxhp:30,alert:0};
       g.ents.push(hire); g.ents.push(cr);
       ac=function(){ return {currentTime:1,state:'running'}; };
       blip=function(t,d){ calls.push({t:String(t),d:+d}); };
       STEP_T=0; calls.length=0; EA(0.016);
       if(calls.length!==1) bad.push('one step tick played '+calls.length+' steps, not 1');
       else if(!(Math.abs(calls[0].d-400*1.35)<1)) bad.push('the step heard came from '+Math.round(calls[0].d/1.35)+' away, the hire walking behind you, not the crawler 400 away');
       cr.moving=false; STEP_T=0; calls.length=0; EA(0.016);
       if(calls.length) bad.push('with only the hire walking a footstep still played, from '+Math.round(calls[0].d/1.35)+' away');
       // CONTROL: the same man, walking in the same spot but not on your side, is heard.
       hire.merc=0; hire.friendly=0; hire.hostile=true; STEP_T=0; calls.length=0; EA(0.016);
       if(!(calls.length===1&&Math.abs(calls[0].d-150*1.35)<1)) bad.push('control: a hostile pillager walking 150 away made no step ('+JSON.stringify(calls)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       blip=oBlip; ac=oAc; STEP_T=0;
       try{ if(g0){ g0.ents.length=0; if(g0.player){ g0.player.iv=0; g0.player.downed=false; } if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

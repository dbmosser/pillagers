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

if ($s.Contains("  {v:'27.37',what:")) { throw "check 27.37 is in the fixture already" }

SubRx @'
  {v:'27.36',what:
'@ @'
  {v:'27.37',what:'nolockdown, his order (get rid of the sealed lockdown thing): the lockdown alarm event is gone: it is not an event, no raid over many seeds plans one, it cannot be launched, its cache tag, its fence code and its words are not in the game, and the other five events are still there',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof evPlan!=='function'||typeof evLaunch!=='function'||typeof EVENTS!=='object') return 'SKIP: no arcade or raid events here';
     var bad=[], g=null, seed0, s, i, n, plan, ids={}, hasId=0, need=[], txt='', sc=[].slice.call(document.scripts), kinds=['debris','convoy','bounty','cool','rampage'], ev, E;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       // ONE: it is not in the pool, and not a row of events
       if(EVENTS['lo'+'ck']) bad.push('ONE: the lockdown event is still a row of EVENTS');
       if(typeof EV_IDS==='object'&&EV_IDS.indexOf('lo'+'ck')>=0) bad.push('ONE: the lockdown is still in the event pool');
       for(i=0;i<kinds.length;i++) if(!EVENTS[kinds[i]]) bad.push('ONE: the event '+kinds[i]+' is gone too');
       // TWO: over many seeds no raid plans one (the plan is drawn on the event side stream of each seed)
       seed0=g.seed; n=0; E={};
       for(s=1;s<=240;s++){
         g.seed=s; plan=evPlan({});
         for(i=0;i<plan.length;i++){ n++; ids[plan[i].id]=(ids[plan[i].id]|0)+1; if(plan[i].id==='lo'+'ck') hasId++; }
       }
       g.seed=seed0;
       if(hasId) bad.push('TWO: '+hasId+' of '+n+' planned events over 240 seeds were the lockdown');
       for(i=0;i<kinds.length;i++) if(kinds[i]!=='rampage'&&!ids[kinds[i]]) bad.push('TWO: no '+kinds[i]+' was planned in 240 seeds');
       // THREE: it cannot be launched
       try{ ev=evLaunch('lo'+'ck'); }catch(_el){ ev=null; }
       if(ev) bad.push('THREE: evLaunch made a lockdown');
       // FOUR: the code and the words are out of the game (assembled needles, so this check does not find itself)
       for(i=0;i<sc.length;i++) txt+=(sc[i].textContent||'');
       need=[['EVENTS.'+'lock=','the event row'],["name:'LOCKDOWN"+" ALARM'",'its name'],["'LOCKDOWN"+" CACHE'",'its cache tag'],['function lock'+'Keep(','its fence code'],['function lock'+'Sealed(','its seal test'],["'SEALED"+" IN'",'its callout'],["'DISTRICT"+" SEALED'",'its other callout'],["'DOORS"+" OPEN'",'its doors line'],["'LOCKDOWN"+" OVER'",'its end line']];
       for(i=0;i<need.length;i++) if(txt.indexOf(need[i][0])>=0) bad.push('FOUR: the game still has '+need[i][1]+' ('+need[i][0]+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g&&seed0!==undefined) g.seed=seed0; }catch(_s){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

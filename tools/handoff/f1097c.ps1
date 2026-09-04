$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ---- THE REPAIR ARM WAS TESTING NOTHING AND NOT SAYING SO. repairCost returns
# ---- null while the wear system has one band, so both calls came back empty, no
# ---- part was added to the wanted set, and the check reported a clean pass over
# ---- a branch it had never reached. It says which world it is in now, and it
# ---- fails only on the contradiction: a live wear system that still refuses to
# ---- name a repair part.
SubRx @'
     if(typeof repairCost==='function'&&typeof WEAPONS!=='undefined'){
       var prof=__P(), keepW=prof.wear;
       prof.wear={};
       var gid=null;
       for(k in WEAPONS){ if(WEAPONS[k]&&WEAPONS[k].mag!==0){ gid=k; break; } }
       if(gid){
         prof.wear[gid]=600;  var rl=repairCost(gid);
         prof.wear[gid]=1800; var rh=repairCost(gid);
         if(rl&&rl.part){ wanted[rl.part]=1; why[rl.part]='repairing a worn gun'; }
         if(rh&&rh.part){ wanted[rh.part]=1; why[rh.part]='repairing a badly worn gun'; }
         if(rl&&rh&&rl.part===rh.part)
           bad.push('control: light and heavy wear both ask for '+rl.part+', so only one repair part is being tested');
       } else bad.push('control: no gun was found to wear, so the repair parts are untested');
       prof.wear=keepW;
     }
'@ @'
     var wearOn=(typeof wearLive==='function')?!!wearLive():false;
     if(typeof repairCost==='function'&&typeof WEAPONS!=='undefined'){
       var prof=__P(), keepW=prof.wear;
       prof.wear={};
       var gid=null;
       for(k in WEAPONS){ if(WEAPONS[k]&&WEAPONS[k].mag!==0){ gid=k; break; } }
       if(gid){
         prof.wear[gid]=600;  var rl=repairCost(gid);
         prof.wear[gid]=1800; var rh=repairCost(gid);
         if(rl&&rl.part){ wanted[rl.part]=1; why[rl.part]='repairing a worn gun'; }
         if(rh&&rh.part){ wanted[rh.part]=1; why[rh.part]='repairing a badly worn gun'; }
         if(rl&&rh&&rl.part===rh.part)
           bad.push('control: light and heavy wear both ask for '+rl.part+', so only one repair part is being tested');
         // THE HONEST PART. While WEARSTEPS carries one band the repair economy
         // is switched off and repairCost refuses every gun, so this arm tests
         // nothing and must not pretend otherwise. It only fails on the
         // contradiction: wear alive and still no part named.
         if(wearOn&&!(rl&&rl.part)&&!(rh&&rh.part))
           bad.push('the wear system is running and yet a gun at 1,800 rounds cannot name a repair part');
       } else bad.push('control: no gun was found to wear, so the repair parts are untested');
       prof.wear=keepW;
     }
     // AND THE GAME MUST NOT PROMISE A USE IT WILL NOT HONOUR. With the repair
     // economy dormant, nothing may be labelled a repair part.
     if(typeof itemWanted==='function'&&typeof REPAIR_PARTS!=='undefined'&&!wearOn){
       var _rw=itemWanted(REPAIR_PARTS.heavy);
       if(_rw&&String(_rw).indexOf('repair')>=0)
         bad.push('the stash says '+REPAIR_PARTS.heavy+' is for gun repairs while the wear system is switched off, which is a use the game will not honour');
     }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

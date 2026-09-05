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

# v11.42 HOOK: drive the REAL load body synchronously. applyLoadedProfile is the
# post-storeGet body factored out this build; on an older build it does not exist,
# so the hook is undefined there and the check skips rather than throwing (typeof
# on an undeclared name is safe). SKEY is file scope.
SubRx @'
window.__loadProfile=function(){ return loadProfile(); };
'@ @'
window.__loadProfile=function(){ return loadProfile(); };
window.__applyLoaded=(typeof applyLoadedProfile==='function')?function(prof){ applyLoadedProfile({key:SKEY,value:JSON.stringify(prof)}); return true; }:undefined;
'@

# v11.44 CHECK, inserted before the current top (v11.43) entry.
SubRx @'
  {v:'11.43',what:'the baked text edits are his latest set (71), including the title-screen and tutorial lines he rewrote after the v11.42 snapshot',
'@ @'
  {v:'11.44',what:'loading a pre-mig945 save keeps the player saved dials: the rig-buyback migration persists through storeSet without saving the defaults over the config before the cfgv block reads it, and the buyback still runs',
   run:function(){
     if(!(window.__applyLoaded&&window.__P&&window.__cfg)) return 'SKIP: this fixture cannot drive the loader synchronously (older build has no applyLoadedProfile seam)';
     var KEY='salvagerun:profile', saved;
     try{ saved=localStorage.getItem(KEY); }catch(e){ return 'SKIP: localStorage is not reachable here'; }
     var bad=[];
     try{
       // A pre-mig945 save with a DISTINCTIVE dial that neither a default nor a
       // migration produces: ambient 250 (default 190; the cfgv-12 migration only
       // moves 150 to 190, so 250 must be left alone). A rig in the stash so the
       // buyback has work. cfgv 12 so migrations WOULD run if reached.
       var prof={credits:5000, xp:100, cfg:{ambient:250, raidSec:480}, cfgv:12, stash:['rig_medium'], pname:'TESTER'};
       window.__applyLoaded(prof);
       var P=window.__P(), CFG=window.__cfg();
       // THE FIX: the saved dial survives the load, both in the profile and live.
       if(!(P.cfg&&P.cfg.ambient===250)) bad.push('the saved ambient 250 loaded back as '+(P.cfg?P.cfg.ambient:'(cfg null)')+', so the rig-buyback migration saved defaults over the player config');
       if(CFG.ambient!==250) bad.push('the live CFG.ambient loaded as '+CFG.ambient+' rather than the saved 250, so the config did not reach the game');
       if(P.cfgv===17) bad.push('cfgv was stamped to 17 during the load, which is saveProfile running before the cfgv block');
       // CONTROL: the buyback still ran, or the fix broke the migration.
       if(!(P.credits>5000)) bad.push('control: the rig buyback did not pay (credits '+P.credits+'), so the migration no longer runs');
       if(P.stash&&P.stash.indexOf('rig_medium')>=0) bad.push('control: the bought-back rig is still in the stash, so the buyback did not run');
     } finally {
       try{ if(saved===null) localStorage.removeItem(KEY); else localStorage.setItem(KEY, saved); }catch(e){}
       try{ if(window.__cleanProfile) __cleanProfile(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.43',what:'the baked text edits are his latest set (71), including the title-screen and tutorial lines he rewrote after the v11.42 snapshot',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

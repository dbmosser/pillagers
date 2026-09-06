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

# v11.47 HOOKS: raise a crash through the real catcher, and read or set the
# loaded gate. On a build without the gate __ploaded answers null and the check
# runs the old path, which is the control.
SubRx @'
window.__loadProfile=function(){ return loadProfile(); };
'@ @'
window.__loadProfile=function(){ return loadProfile(); };
window.__noteCrash=function(k,m,w){ return noteCrash(k,m,w); };
window.__ploaded=function(v){ if(typeof PLOADED==='undefined') return null; if(v!==undefined) PLOADED=!!v; return PLOADED; };
'@

# v11.47 CHECK, inserted before the v11.46 entry.
SubRx @'
  {v:'11.46',what:'a hostile pillager standing in the extraction ring who can see you returns fire after ONE beat, instead of having his cooldown floored every frame so he never shoots; and with the acquisition gate pinned shut (raiderReact 99) he fires none, so the rounds pass through the gate',
'@ @'
  {v:'11.47',what:'a crash caught before the profile is read never saves over the real save: it goes to its own key, and a crash after the read still lands in P.crashes',
   run:function(){
     if(!(window.__noteCrash&&window.__P)) return 'SKIP: this fixture cannot raise a crash through the catcher';
     var KEY='salvagerun:profile', PRE='salvagerun:precrash', saved=null, bad=[];
     try{ saved=localStorage.getItem(KEY); }catch(e){ return 'SKIP: localStorage is not reachable here'; }
     // A DISTINCTIVE stored save that no default could produce.
     var real='{"credits":424242,"xp":7,"pname":"ZQXREAL","stash":[],"weapons":["pistol"]}';
     try{
       localStorage.setItem(KEY, real); try{ localStorage.removeItem(PRE); }catch(e0){}
       // BEFORE THE READ. On this build __ploaded closes the gate; on an older
       // build there is no gate and the catcher saves the live P over the save.
       var had=(window.__ploaded?window.__ploaded():null);
       if(window.__ploaded) window.__ploaded(false);
       window.__noteCrash('error','zqx boot probe','probe:1');
       var after=null; try{ after=localStorage.getItem(KEY); }catch(e1){}
       if(after!==real) bad.push('a crash before the profile was read overwrote the real save (the stored profile changed to '+String(after).slice(0,50)+')');
       var pre=null; try{ pre=JSON.parse(localStorage.getItem(PRE)||'null'); }catch(e2){}
       if(!(pre&&pre.length&&/zqx boot probe/.test(String(pre[pre.length-1].msg||'')))) bad.push('the boot crash was not written to its own key');
       // AFTER THE READ (control): the gate is open and a crash is recorded in P.
       if(window.__ploaded) window.__ploaded(true);
       var P=window.__P(); var n0=(P.crashes||[]).length;
       window.__noteCrash('error','zqx after probe','probe:2');
       if(!((P.crashes||[]).length>n0)) bad.push('control: after the read a crash was not recorded in P.crashes, so the catcher is off');
       if(window.__ploaded&&had!==null) window.__ploaded(had);
     } finally {
       try{ if(saved===null) localStorage.removeItem(KEY); else localStorage.setItem(KEY, saved); }catch(e3){}
       try{ localStorage.removeItem(PRE); }catch(e4){}
       try{ if(window.__cleanProfile) __cleanProfile(); }catch(e5){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.46',what:'a hostile pillager standing in the extraction ring who can see you returns fire after ONE beat, instead of having his cooldown floored every frame so he never shoots; and with the acquisition gate pinned shut (raiderReact 99) he fires none, so the rounds pass through the gate',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

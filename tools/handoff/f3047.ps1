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

if ($s.Contains("  {v:'30.47',what:")) { throw "check 30.47 is in the fixture already" }

SubRx @'
  {v:'30.46',what:
'@ @'
  {v:'30.47',what:'his Q67: the demo kit is the same all night (every drop and respawn) and changes only after NEW PARTY',
   run:function(){
     if(window.storage&&window.storage.set) return 'SKIP: this host saves through window.storage, not localStorage';
     if(typeof arcadeDeploy!=='function'||typeof arcadeKitApply!=='function'||typeof arcadeNewParty!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade kit here';
     var bad=[], PK=ARCADE_PARTY_KEY, pk=null, hadP=false, g, p, seen={}, i, first, n=0, differs=false;
     function kitName(){ return String(p.wep&&p.wep.name)+'+'+String(p.sec&&p.sec.name); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       try{ pk=localStorage.getItem(PK); hadP=true; localStorage.removeItem(PK); }catch(_p){}
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player;
       first=kitName();
       for(i=0;i<9;i++){ arcadeKitApply(p,g,'dead'); seen[kitName()]=1; }
       for(var k in seen) n++;
       if(n!==1||!seen[first]) bad.push('nine respawns gave '+n+' different kits ('+Object.keys(seen).join(' | ')+'), not the one of the night');
       // NEW PARTY changes it (a draw can repeat, so it is asked up to 40 times)
       for(i=0;i<40&&!differs;i++){ arcadeNewParty(); arcadeKitApply(p,g,'dead'); if(kitName()!==first) differs=true; }
       if(!differs) bad.push('NEW PARTY never changed the kit in 40 draws');
       else {
         first=kitName(); seen={}; n=0;
         for(i=0;i<6;i++){ arcadeKitApply(p,g,'dead'); seen[kitName()]=1; }
         for(var k2 in seen) n++;
         if(n!==1||!seen[first]) bad.push('after NEW PARTY six respawns gave '+n+' different kits');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(hadP){ if(pk===null) localStorage.removeItem(PK); else localStorage.setItem(PK,pk); } }catch(_p2){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

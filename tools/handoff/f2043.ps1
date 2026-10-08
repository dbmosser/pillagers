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

if ($s.Contains("  {v:'20.43',what:")) { throw "check 20.43 is in the fixture already" }

SubRx @'
  {v:'20.42',what:
'@ @'
  {v:'20.43',what:'a debt survives a reload: a save owing money loads owing the same, a hire who died before the page went away is still owed after a second load, and the other counters still cannot load below zero',
   run:function(){
     if(typeof applyLoadedProfile!=='function'||typeof storeSet!=='function'||typeof saveProfile!=='function'||typeof MERC_DEATH!=='number') return 'SKIP: no profile loader here';
     var bad=[], snap=null, oSet=storeSet, sv, DEBT=-2417, c1;
     try{
       __topClear(); __cleanProfile();
       if(typeof G!=='undefined'&&G&&!G.over&&!G.sim) return 'SKIP: a raid is running, and a load happens in the Undercroft';
       snap=JSON.parse(JSON.stringify(P));
       storeSet=function(){};
       // ONE: a save holding a debt, as the end of a raid leaves it after a hire who died.
       sv=JSON.parse(JSON.stringify(snap)); delete sv.raidSpliced; delete sv.mercOut;
       sv.credits=DEBT; sv.runs=-7;
       applyLoadedProfile({value:JSON.stringify(sv)});
       if(P.credits!==DEBT) bad.push('a save owing '+(-DEBT)+' loaded with '+P.credits+' credits, so a reload wipes the debt');
       if(P.runs!==0) bad.push('control: a run count of -7 loaded as '+P.runs+', not 0');
       // TWO: the page went away after the hire died up there. The load bills him, and the next load keeps what is left.
       sv=JSON.parse(JSON.stringify(snap)); delete sv.raidSpliced;
       sv.credits=1013; sv.mercOut={dead:1};
       applyLoadedProfile({value:JSON.stringify(sv)});
       c1=P.credits;
       if(c1!==1013-MERC_DEATH) bad.push('control: the death benefit billed on the load left '+c1+', not '+(1013-MERC_DEATH));
       applyLoadedProfile({value:JSON.stringify(P)});
       if(P.credits!==c1) bad.push('a second load turned the '+c1+' left after the death benefit into '+P.credits);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       storeSet=oSet;
       try{ if(snap) applyLoadedProfile({value:JSON.stringify(snap)}); }catch(_r){}
       try{ saveProfile(); }catch(_s){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

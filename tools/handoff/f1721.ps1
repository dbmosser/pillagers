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

if ($s.Contains("  {v:'17.21',what:")) { throw "check 17.21 is in the fixture already" }

SubRx @'
  {v:'17.20',what:
'@ @'
  {v:'17.21',what:'a hire is spent at the lift: a raid that ends by the page going away (F5, a closed tab, a crash) leaves no hire in the save to drop in again for free, and a hire who died up there first is billed his death benefit when the save loads',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__identityIds&&window.__cleanProfile&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults)||typeof updateEnts!=='function'||typeof storeSet!=='function'||typeof MERC_DEATH!=='number') return 'SKIP: this fixture cannot hire, deploy and load a save';
     var ids=__identityIds(); if(!ids.length) return 'SKIP: no identity to hire';
     var snap=null, oSet=storeSet, last=null, bad=[], M, c0, sv;
     function hired(){ if(!G||!G.ents) return null; for(var j=0;j<G.ents.length;j++) if(G.ents[j].merc) return G.ents[j]; return null; }
     function up(){ P.merc=ids[0]; P.credits=77777; __deploy({kit:[],safe:null,mapIx:0,seed:4242}); return hired(); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       storeSet=function(v){ last=v; };
       // ARM 1: he lives, and the page goes away mid-raid. What the store last held is what the reload reads.
       M=up(); if(!M) return 'SKIP: staging: the hire did not drop in';
       if(!last) return 'SKIP: staging: nothing was saved on the way up';
       sv=JSON.parse(last); c0=sv.credits;
       __applyLoaded(sv);
       if(P.merc) bad.push('after the page went away mid-raid the save still holds the hire ('+P.merc+'), so he is still HIRED at the bench with his fee already paid');
       if(P.credits!==c0) bad.push('control: a hire who lived was billed on the reload ('+c0+' to '+P.credits+')');
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(hired()) bad.push('the next ascent after the reload dropped the same hire in again with no new fee');
       try{ if(G&&!G.over) __endRaid('abandon'); __topClear(); }catch(e0){}
       // ARM 2: he dies up there, then the page goes away.
       __resetCfg(); __pinDefaults(0); last=null;
       M=up(); if(!M) return 'SKIP: staging: the hire did not drop in on the second raid';
       M.hp=0; M.byPlayer=false; M.downed=0;
       updateEnts(0.05);
       if(!G.mercDead) return bad.length?bad.join('; '):'SKIP: staging: stepping the hire at no health did not kill him';
       sv=JSON.parse(last); c0=sv.credits;
       __applyLoaded(sv);
       if(P.credits!==c0-MERC_DEATH) bad.push('a hire who died before the page went away was never billed his death benefit: credits '+c0+' became '+P.credits+' on the reload, not '+(c0-MERC_DEATH));
     } finally {
       storeSet=oSet;
       try{ if(G&&!G.over) __endRaid('abandon'); }catch(e1){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __resetCfg(); __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'37.00',what:")) { throw "check 37.00 is in the fixture already" }

SubRx @'
  {v:'36.99',what:
'@ @'
  {v:'37.00',what:'only machines are golden: over 200 seeds (5 real raids, 40 seeds each, with hostile pillagers added far from the player) the pick is never a pillager, and goldOk refuses a far hostile pillager while it accepts a machine there (his 10-31 words: no golden pillager bots)',
   run:function(){
     if(typeof goldOk!=='function'||typeof goldPickIx!=='function') return 'SKIP: no golden pick here';
     var bad=[], g, p, r, s, ix, k, n=0, nm=0, nSeeds=0, e, j, sd0, added, kinds={};
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(r=0;r<5;r++){
         try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_a){}
         try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_b){}
         __topClear(); __runPrep();
         if(r<3){ __deploy({kit:[],safe:null,mapIx:r,seed:4242+r}); }
         else if(typeof arcadeDeploy==='function'){ if(!arcadeDeploy({mapIx:r-3,seed:4300+r})) continue; }
         else break;
         g=__state(); if(!g||g.over||!g.player) continue;
         n++; p=g.player; sd0=g.seed; added=[];
         if(r===0){
           e={hp:50,kind:'raider',hostile:1,x:p.x+2000,y:p.y,r:12};
           if(goldOk(e,p)) bad.push('goldOk accepts a hostile pillager 2000 away');
           e={hp:50,kind:'crawler',x:p.x+2000,y:p.y,r:12};
           if(!goldOk(e,p)) bad.push('goldOk refuses a crawler 2000 away');
         }
         // four hostile pillagers far from the player, so every seed has pillagers on the list in the old build
         for(j=0;j<4;j++){ e={hp:50,maxhp:50,kind:'raider',hostile:1,x:p.x+1500+j*90,y:p.y+(j%2?400:-400),r:12}; g.ents.push(e); added.push(e); }
         for(s=0;s<40;s++){
           g.seed=(sd0+s*7919+1)>>>0; nSeeds++;
           ix=goldPickIx();
           if(ix>=0){ nm++; k=g.ents[ix]&&g.ents[ix].kind; kinds[k]=1; if(k==='raider') bad.push('raid '+r+' seed '+g.seed+' gilds a pillager'); }
         }
         g.seed=sd0;
         for(j=0;j<added.length;j++){ ix=g.ents.indexOf(added[j]); if(ix>=0) g.ents.splice(ix,1); }
         if(bad.length>5) break;
       }
       if(!bad.length&&nSeeds<120) bad.push('only '+nSeeds+' seeds tried in '+n+' raids (want 120 or more)');
       if(!bad.length&&nm<20) bad.push('only '+nm+' of '+nSeeds+' seeds had a machine to gild (want 20 or more)');
       return bad.length?bad.slice(0,6).join('; '):null;
     } finally {
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_c){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'36.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

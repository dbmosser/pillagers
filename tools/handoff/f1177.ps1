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

# THE PIN TABLE FOLLOWS THE DEFAULT. __pinDefaults pins every dial for every
# check; a pin left at 150 would have the whole corpus measuring a blast the
# game no longer throws.
SubRx @'
smokeR:165,fragR:150,healSolo:1
'@ @'
smokeR:165,fragR:190,healSolo:1
'@

# v11.77 CHECK, inserted before the v11.76 entry. A real blast against a real
# pillager at a fixed distance, the loss compared with both formulas; and the
# real loader driven with an old save, so the migration is measured too.
# __applyLoaded takes a plain profile object (it wraps and stringifies it);
# my first draft handed it {value:...} and the loader rejected the profile,
# which read as the migration failing.
SubRx @'
  {v:'11.76',what:'the Scav Pistol costs 1800 in the shop, down from 3600, and is still the cheapest gun on the shelf (his order of 2026-09-06)',
'@ @'
  {v:'11.77',what:'a frag blast reaches further and hits harder: the radius is 190 and the damage at a fixed distance matches the new formula and exceeds the old one (his order of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy or drive the loader';
     if(typeof explodeFrag!=='function'||typeof DEF==='undefined') return 'SKIP: no frag blast in this build';
     var bad=[], k;
     if(DEF.fragR!==190) bad.push('the default blast radius is '+DEF.fragR+' and not 190');
     function withCfg(fr){ var c={}; for(k in DEF) c[k]=DEF[k]; c.fragR=fr; return {credits:900,cfgv:17,cfg:c}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.fragR=DEF.fragR;   // the game reads CFG; the blast is measured at the shipped default
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, R=(CFG.fragR===undefined?190:CFG.fragR);
       if(R!==190) bad.push('control: the blast is being measured at radius '+R+', not 190');
       // A PILLAGER WITH A CLEAR LINE TO A POINT 40 UNITS AWAY.
       var e=null, fx=0, fy=0;
       for(var i=0;i<g.ents.length&&!e;i++){
         var c=g.ents[i]; if(c.kind!=='raider'||c.downed||c.finished||c.merc) continue;
         var tries=[[c.x+40,c.y],[c.x-40,c.y],[c.x,c.y+40],[c.x,c.y-40]];
         for(var t=0;t<tries.length;t++){ if(losClear(tries[t][0],tries[t][1],c.x,c.y,g.map.segs)){ e=c; fx=tries[t][0]; fy=tries[t][1]; break; } }
       }
       if(!e) return 'SKIP: no pillager with a clear line to a blast point';
       e.hp=1000; p.x=e.x+1500; p.y=e.y;   // he is well outside any radius
       var de=Math.hypot(e.x-fx,e.y-fy), eff=Math.max(0,de-e.r);
       var expectNew=115*(1-eff/190)+25, expectOld=85*(1-eff/150)+15;
       explodeFrag({x:fx,y:fy});
       var loss=1000-e.hp;
       if(Math.abs(loss-expectNew)>1.5) bad.push('a blast '+Math.round(de)+' units from a pillager took '+loss.toFixed(1)+' and not the '+expectNew.toFixed(1)+' the new formula gives');
       // CONTROL: it hits harder than it did, or the numbers moved nowhere.
       if(loss<expectOld+5) bad.push('control: the blast took '+loss.toFixed(1)+', no more than the old formula ('+expectOld.toFixed(1)+')');
       // THE MIGRATION: an old save still on 150 comes up at 190; a hand-set 140 survives.
       __applyLoaded(withCfg(150));
       if(CFG.fragR!==190) bad.push('a cfgv 17 save carrying the old 150 loaded with fragR '+CFG.fragR+' instead of 190');
       __applyLoaded(withCfg(140));
       if(CFG.fragR!==140) bad.push('control: a hand-set 140 was overwritten to '+CFG.fragR+' by the migration');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ __topClear(); __cleanProfile(); __resetCfg(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.76',what:'the Scav Pistol costs 1800 in the shop, down from 3600, and is still the cheapest gun on the shelf (his order of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

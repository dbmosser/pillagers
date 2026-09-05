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

SubRx @'
  {v:'11.28',what:'the backpack arrows keep a number: with every carried item claimed by a belt key an arrow leaves the selection at 0, and with two free stacks the arrows still walk the grid',
'@ @'
  {v:'11.29',what:'the sector screen says whose figures it shows and shows the ones in the code, and a death card on a fresh profile gives the XP total without measuring it against the last reward of the season',
   run:function(){
     if(!(window.__hubEnter&&window.__endRaid&&window.__P&&window.__deploy)) return 'SKIP: this fixture cannot walk the ascent';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], prof=__P(), keep={}, k;
     for(k in prof) keep[k]=prof[k];
     try{
       __runPrep(); __resetCfg(); __pinDefaults(0);
       // THE FRESH FRIEND, as v11.11 builds him, in memory only.
       prof.runs=0; prof.ext=0; prof.died=0; prof.best=0; prof.credits=600; prof.xp=0; prof.xpLevel=1;
       prof.stash=[]; prof.kit=[]; prof.log=[]; prof.contracts=[]; prof.racks=0; prof.arrays=0; prof.notoriety=0;
       prof.cstand=0; prof.spClaimed=[]; prof.kills={}; prof.cosBought={}; prof.junk={}; prof.weapons=['pistol'];
       prof.equipped='pistol'; prof.pack=0; prof.cosAll=0; prof.stashTab='all';
       __hubEnter();
       // ONE: the sector screen. Opened the way he opens it, read as text.
       var mb=document.getElementById('mapbtn'); if(!mb) return 'SKIP: no map button on the floor';
       mb.click();
       var sm=document.getElementById('sectormodal'), st=(sm.textContent||'').replace(/\s+/g,' ');
       if(!/modal on/.test(sm.className)) bad.push('the sector screen did not open from the map button');
       var robotWord=['test ','robot'].join('');
       if(st.indexOf(robotWord)<0) bad.push('the sector screen shows figures without saying they are the '+robotWord+'s');
       var oldPhrase=['measured ','extraction'].join('');
       if(st.indexOf(oldPhrase)>=0) bad.push('the sector screen still says "'+oldPhrase+'" with no owner');
       // The numbers on the screen are the numbers in the code, both maps.
       var SM=(window.__sectorMeas?__sectorMeas():null);
       if(SM&&SM.length>=2){
         for(var mi=0;mi<2;mi++){
           if(st.indexOf('extracts '+SM[mi].ext+'%')<0) bad.push('map '+mi+' shows a different extract figure from the code, which says '+SM[mi].ext);
           if(st.indexOf('first contact ~'+SM[mi].fc+'s')<0) bad.push('map '+mi+' shows a different first contact from the code, which says '+SM[mi].fc);
         }
         // CONTROL: the figures are not the v8.01 ones any more.
         if(SM[0].ext===18||SM[1].ext===23.5) bad.push('control: the code still carries the v8.01 figures, so nothing was refreshed');
       } else bad.push('the fixture cannot read SECTOR_MEAS, so the screen cannot be checked against the code');
       var cl=document.getElementById('closesector'); if(cl) cl.click();
       // TWO: the death card on the fresh friend. Deployed by the fixture, ended dead.
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __endRaid('dead');
       var man=(document.getElementById('oc_manifest').textContent||'').replace(/\s+/g,' ');
       var ofCap=[' of ','1,200,000'].join('');
       if(man.indexOf(ofCap)>=0) bad.push('the death card still measures the XP against the last reward: "'+man.slice(0,120)+'"');
       if(!/XP in all/.test(man)) bad.push('the death card does not give the XP total: "'+man.slice(0,120)+'"');
       if(!/penalty for failure to extract/.test(man)) bad.push('control: the death card lost its penalty note, so this is not the line the finding is about');
       // CONTROL: the extraction card keeps its "of" and its Next sentence.
       __topClear();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __endRaid('extract');
       var man2=(document.getElementById('oc_manifest').textContent||'').replace(/\s+/g,' ');
       if(man2.indexOf(ofCap)<0) bad.push('control: the extraction card lost its "of 1,200,000", which was to stay: "'+man2.slice(0,120)+'"');
       if(!/Next: /.test(man2)) bad.push('control: the extraction card lost its Next sentence: "'+man2.slice(0,160)+'"');
       __topClear();
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ for(k in keep) prof[k]=keep[k]; for(k in prof) if(!(k in keep)) delete prof[k]; }
     return bad.length?bad.join('; '):null; }},
  {v:'11.28',what:'the backpack arrows keep a number: with every carried item claimed by a belt key an arrow leaves the selection at 0, and with two free stacks the arrows still walk the grid',
'@

# THE HOOK the check reads the code's figures through.
SubRx @'
window.__world=function(){ return {w:WORLD_W,h:WORLD_H}; };
'@ @'
window.__world=function(){ return {w:WORLD_W,h:WORLD_H}; };
window.__sectorMeas=function(){ return SECTOR_MEAS; };
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

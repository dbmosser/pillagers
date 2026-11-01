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

if ($s.Contains("  {v:'37.16',what:")) { throw "check 37.16 is in the fixture already" }

SubRx @'
  {v:'37.15',what:
'@ @'
  {v:'37.16',what:'cw-p0gear, his progression plan of 11-01 (m0 foundation): worn gear is a saved piece of its own (kind, rarity, power, traits, pips) in nine slots, rolled on its own dice so the raid stream never moves (the same seed gives the same piece, more power gives stronger traits, scrap has 1 trait and the others 2, from the slot pool); every load checks the pieces (unknown kinds and traits dropped, numbers clamped, a piece in the wrong slot to the stash, one id once); wearing swaps, taking off returns to the stash; the sum of everything worn is 0 with nothing on, two rings with one trait count the stronger, every stat stops at its cap; an old save loads with two empty lists and nothing lost, and gear survives a reload',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function') return 'SKIP: no loader here';
     if(typeof wornMake!=='function'||typeof wornClean!=='function'||typeof wornWear!=='function'||typeof wornOff!=='function'||typeof wornMods!=='function'||typeof wornAdd!=='function'||typeof WORN_SLOTS==='undefined'||typeof WORN_STATS==='undefined') return 'no worn gear pieces in this build (wornMake, wornClean, wornWear, wornOff, wornMods, wornAdd)';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, bad=[], a, b, c, r0, f0, i, j, s, m, q, snap, base, pc;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function same(x,y){ return JSON.stringify(x)===JSON.stringify(y); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       base=JSON.parse(JSON.stringify(P)); base.cfg=JSON.parse(JSON.stringify(CFG)); base.cfgv=18;
       need(same(WORN_SLOTS,['head','amulet','armor','pants','ring1','ring2','boots','gloves','pack']),'ONE: the slots are '+JSON.stringify(WORN_SLOTS)+', not his nine');
       // TWO: its own dice
       r0=RNGS; f0=(typeof FXS!=='undefined')?FXS:null;
       a=wornMake('gloves',2,50,12345); b=wornMake('gloves',2,50,12345); c=wornMake('gloves',2,50,777001);
       for(i=0;i<200;i++) wornMake('ring',i%4,1+i%100,9000+i);
       need(RNGS===r0&&(f0===null||FXS===f0),'TWO: making pieces moved the raid or cosmetic stream');
       need(a&&same(a,b),'TWO: one seed made two different pieces: '+JSON.stringify(a)+' / '+JSON.stringify(b));
       need(c&&!same(a.tr,c.tr),'TWO: two seeds made the same traits '+JSON.stringify(a&&a.tr));
       need(a&&a.k==='gloves'&&a.r===2&&a.pw===50&&a.pip===0&&a.tr.length===2&&a.tr[0].s!==a.tr[1].s,'TWO: a rare pair of gloves reads '+JSON.stringify(a));
       for(i=0;i<4;i++){ q=wornMake('boots',i,50,4242+i); need(q&&q.tr.length===(i===0?1:2),'TWO: rarity '+i+' rolled '+(q&&q.tr.length)+' traits');
         for(j=0;q&&j<q.tr.length;j++) need(['quiet','hide','spd'].indexOf(q.tr[j].s)>=0,'TWO: boots rolled '+q.tr[j].s); }
       for(i=0;i<60;i++){ q=wornMake('pants',i%4,1+i,500+i); for(j=0;j<q.tr.length;j++){ s=WORN_STATS[q.tr[j].s];
         if(!(q.tr[j].v>0&&q.tr[j].v<=s.base*1.5*1.4*1.25+0.001)) bad.push('TWO: pants trait out of range '+JSON.stringify(q.tr[j])); } }
       a=wornMake('armor',1,100,31337); b=wornMake('armor',1,1,31337);
       need(a&&b&&a.tr[0].s===b.tr[0].s&&a.tr[0].v>b.tr[0].v&&a.tr[1].v>b.tr[1].v,'TWO: power 100 is not stronger than power 1: '+JSON.stringify(a&&a.tr)+' / '+JSON.stringify(b&&b.tr));
       need(wornMake('cloak',1,50,1)===null,'TWO: a cloak was made (his answer 54: no cloak)');
       // THREE: a damaged save is cleaned
       q={gearN:0,gear:[null,{k:'cloak',r:1,pw:5,tr:[]},{id:'x1',k:'boots',r:9,pw:-5,tr:[{s:'quiet',v:0.04},{s:'fly',v:1},{s:'hide',v:9}],pip:7},{id:'x1',k:'pants',r:0,pw:20,tr:[]},'junk'],
          worn:{ring1:{id:'x2',k:'boots',r:0,pw:10,tr:[{s:'spd',v:0.02}]},head:{k:'head',r:1,pw:30,tr:[{s:'hide',v:0.03}]},cloak:{k:'ring',r:0,pw:3,tr:[]}}};
       wornClean(q);
       pc=null; for(i=0;i<q.gear.length;i++) if(q.gear[i].id==='x1') pc=q.gear[i];
       need(pc&&pc.k==='boots'&&pc.r===3&&pc.pw===1&&pc.pip===3&&pc.tr.length===2&&pc.tr[0].s==='quiet'&&pc.tr[1].s==='hide'&&pc.tr[1].v===WORN_STATS.hide.cap,'THREE: the damaged boots read '+JSON.stringify(pc));
       need(q.gear.filter(function(x){ return x.id==='x1'; }).length===1,'THREE: one id twice survived');
       need(q.gear.some(function(x){ return x.id==='x2'; })&&!q.worn.ring1,'THREE: boots in a ring slot stayed worn');
       need(q.worn.head&&q.worn.head.id&&!q.worn.cloak&&q.gear.every(function(x){ return x.k!=='cloak'; }),'THREE: the head piece or the cloak is wrong: '+JSON.stringify(q.worn));
       need(q.gear.length===2,'THREE: '+q.gear.length+' stash pieces, not the boots x1 and the boots x2');
       // FOUR: wear, swap, take off
       q={};
       a=wornAdd(q,{k:'ring',r:1,pw:40,tr:[{s:'quiet',v:0.05}]}); b=wornAdd(q,{k:'ring',r:1,pw:40,tr:[{s:'quiet',v:0.04}]}); c=wornAdd(q,{k:'ring',r:0,pw:40,tr:[{s:'spd',v:0.02}]});
       need(a&&b&&c&&a.id&&a.id!==b.id&&b.id!==c.id&&q.gear.length===3,'FOUR: three rings did not get three ids');
       need(wornWear(q,a.id)&&q.worn.ring1===a&&wornWear(q,b.id)&&q.worn.ring2===b,'FOUR: two rings did not take both ring slots');
       need(wornWear(q,c.id)&&q.worn.ring1===c&&q.gear.indexOf(a)>=0&&q.gear.length===1,'FOUR: a third ring did not swap the first back to the stash');
       need(!wornWear(q,a.id,'boots'),'FOUR: a ring went on the boots slot');
       need(wornOff(q,'ring2')&&!q.worn.ring2&&q.gear.indexOf(b)>=0,'FOUR: taking a ring off did not return it to the stash');
       // FIVE: the one sum
       m=wornMods({}); for(s in WORN_STATS) need(m[s]===0,'FIVE: nothing worn gives '+s+' '+m[s]);
       m=wornMods({ring1:{k:'ring',r:1,pw:40,pip:0,tr:[{s:'quiet',v:0.05}]},ring2:{k:'ring',r:1,pw:40,pip:0,tr:[{s:'quiet',v:0.04},{s:'reload',v:0.02}]},
                   boots:{k:'boots',r:1,pw:40,pip:3,tr:[{s:'quiet',v:0.03}]},armor:{k:'armor',r:3,pw:100,pip:3,tr:[{s:'tough',v:0.15}]}});
       need(Math.abs(m.quiet-0.11)<1e-9,'FIVE: quiet is '+m.quiet+', not 0.05 (the stronger ring) + 0.06 (boots at 3 pips)');
       need(Math.abs(m.reload-0.02)<1e-9&&m.tough===WORN_STATS.tough.cap&&m.spd===0,'FIVE: reload '+m.reload+', tough '+m.tough+' (cap '+WORN_STATS.tough.cap+'), speed '+m.spd);
       // SIX: an old save loads with two empty lists and nothing lost; gear survives a reload
       snap=JSON.parse(JSON.stringify(base)); delete snap.gear; delete snap.worn; delete snap.gearN;
       snap.credits=4321; snap.stash=['scrap','core']; snap.weapons=['pistol','smg']; snap.equipped='smg';
       applyLoadedProfile({value:JSON.stringify(snap)});
       need(Array.isArray(P.gear)&&P.gear.length===0&&P.worn&&typeof P.worn==='object'&&Object.keys(P.worn).length===0,'SIX: an old save has gear '+JSON.stringify(P.gear)+' worn '+JSON.stringify(P.worn));
       need(P.credits===4321&&same(P.stash,['scrap','core'])&&P.weapons.indexOf('smg')>=0&&P.equipped==='smg','SIX: the old save lost something (credits '+P.credits+', stash '+JSON.stringify(P.stash)+')');
       a=wornAdd(P,wornMake('gloves',3,77,2024)); b=wornAdd(P,wornMake('pack',1,20,2025)); wornWear(P,a.id);
       snap=JSON.parse(JSON.stringify(P)); applyLoadedProfile({value:JSON.stringify(snap)});
       need(P.worn.gloves&&P.worn.gloves.id===a.id&&same(P.worn.gloves.tr,a.tr)&&P.gear.length===1&&P.gear[0].id===b.id&&P.gearN===snap.gearN,'SIX: gear did not survive a reload: worn '+JSON.stringify(P.worn)+' stash '+JSON.stringify(P.gear));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

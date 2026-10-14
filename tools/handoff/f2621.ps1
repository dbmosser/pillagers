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

if ($s.Contains("  {v:'26.21',what:")) { throw "check 26.21 is in the fixture already" }

SubRx @'
  {v:'26.20',what:
'@ @'
  {v:'26.21',what:'his question (2026-10-14, where is the Forge): E at the station opens the panel, picking MK II turns the gun in hand into its MK II and takes the cost from the raid score; too little score says NEED; no gun says so',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof raidKey!=='function') return 'SKIP: no raid here';
     var bad=[], g, p, f, i, said=[], blips=[], realSay=say, realBlip=blip, w0, sc0, a0, car, cs0, hadCs, saveArc, saveMine, ex;
     function setScore(v){ if(g.arcade) ARCADE.mine=v; else { g.cs=g.cs||{s:0,k:0,streak:null,waveT:0,waveN:0}; g.cs.s=v; } }
     function getScore(){ return g.arcade?(ARCADE.mine|0):(g.cs?(g.cs.s|0):0); }
     function press(code){ raidKey(code,false,null); keys[code]=false; }
     function tick(nf){ for(var j=0;j<nf;j++) __sim(0.05); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; f=g.forge; if(!f) return 'the raid has no Forge';
       ex=g.ents; g.ents=[]; hadCs=g.cs; cs0=g.cs?g.cs.s:0;
       say=function(m,k,o){ said.push(String(m)); }; blip=function(t){ blips.push(String(t)); };
       for(var kk in keys) keys[kk]=false;
       p.hp=100000; p.iv=99; p.downed=false; p.x=f.x; p.y=f.y; p.vx=0; p.vy=0;
       car=Object.assign({},WEAPONS.rifle); p.wep=car; p.ammo=10; p.wepIssued=true; p.reloading=0; p.jam=0;
       // 1. too little score: a clear line, nothing opens, nothing changes
       setScore(1000); keys.KeyE=true; tick(6); keys.KeyE=false; tick(2);
       if(g.forgeUI) bad.push('the panel opened with 1000 score');
       if(said.indexOf('NEED $2,500')<0) bad.push('too little score said '+JSON.stringify(said.slice(0,4))+' not NEED $2,500');
       if(p.wep.fk||getScore()!==1000) bad.push('too little score still changed the gun or the score');
       // 2. no gun: says so
       said.length=0; p.wep=WEAPONS.fists; setScore(9000); keys.KeyE=true; tick(6); keys.KeyE=false; tick(2);
       if(g.forgeUI||said.indexOf('NO GUN IN HAND')<0) bad.push('fists did not say NO GUN IN HAND ('+JSON.stringify(said.slice(0,3))+')');
       // 3. enough score: E opens the panel, 1 buys MK II
       said.length=0; blips.length=0; car=Object.assign({},WEAPONS.rifle); p.wep=car; p.ammo=10; p.wepIssued=true; setScore(3000);
       keys.KeyE=true; tick(6); keys.KeyE=false; tick(2);
       if(!g.forgeUI){ bad.push('E at the Forge with 3000 score opened no panel'); }
       else {
         press('Digit1'); tick(2);
         if(g.forgeUI) bad.push('the panel stayed open after the purchase');
         if(!p.wep||p.wep.fk!==1) bad.push('the gun in hand is not MK II (fk '+(p.wep&&p.wep.fk)+')');
         else {
           if(p.wep.dmg!==29.9) bad.push('the MK II rifle does '+p.wep.dmg+' not 29.9');
           if(p.wep.name!=='Auto Rifle MK II') bad.push('the MK II rifle is called '+p.wep.name);
           if(p.wepIssued) bad.push('a forged loaner is still marked issued');
         }
         if(getScore()!==500) bad.push('the score is '+getScore()+' after a 2500 upgrade of 3000');
         if(said.indexOf('GUN UPGRADED')<0) bad.push('no GUN UPGRADED line ('+JSON.stringify(said.slice(0,5))+')');
         if(blips.indexOf('forge')<0) bad.push('the Forge made no sound');
         if(!g.gunCard||!g.gunCard.w||g.gunCard.w.fk!==1) bad.push('no gun card for the new gun');
         if(WEAPONS.rifle.dmg!==23||WEAPONS.rifle.fk) bad.push('the weapon table was touched');
       }
       // 4. a MK II gun is at the top of what the bench offers in this build or asks for an element: either way no second MK II charge
       // 5. ESC closes with no charge
       p.wep=Object.assign({},WEAPONS.smg); p.ammo=10; setScore(5000); keys.KeyE=true; tick(6); keys.KeyE=false; tick(2);
       if(!g.forgeUI) bad.push('the panel did not open for the SMG');
       else { press('Escape'); tick(1); if(g.forgeUI) bad.push('ESC left the panel open'); if(getScore()!==5000||p.wep.fk) bad.push('ESC charged or changed the gun'); }
       // 6. the same in the DEMO wallet
       saveArc=g.arcade; saveMine=ARCADE.mine;
       try{ g.arcade=true; ARCADE.mine=3000; if(forgeScore()!==3000) bad.push('the DEMO wallet reads '+forgeScore()); if(!forgeSpend(2500)||ARCADE.mine!==500) bad.push('the DEMO wallet did not pay'); if(forgeSpend(1000)) bad.push('the DEMO wallet paid with too little'); }
       finally { g.arcade=saveArc; ARCADE.mine=saveMine; }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=realSay; blip=realBlip;
       for(var k2 in keys) keys[k2]=false;
       try{ if(g){ if(ex) g.ents=ex; g.forgeUI=null; g.cs=hadCs; } var g2=__state(); if(g2&&!g2.over){ g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

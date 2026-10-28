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

if ($s.Contains("  {v:'35.85',what:")) { throw "check 35.85 is in the fixture already" }

SubRx @'
  {v:'35.84',what:
'@ @'
  {v:'35.85',what:'elite Longshots warn for half a second, ordinary rifles fire immediately, and both windows receive the clear-line muzzle star',
   run:function(){
     var g,e,p,active0,oFW=fireWeapon,oS=sfx,oL=losClear,oD=null,calls=0,charges=0,copy,row,bodySeen;
     function shots(){ return g.bullets.filter(function(b){return b.owner===e;}).length; }
     function put(elite,wep){
       e=mkRaider(p.x+400,p.y,IDENTITIES[0],true); e.elite=elite; e.wep=wep; e.rng=900; e.spd=0;
       e.hp=e.maxhp; e.hostile=true; e.merc=0; e.friendlyPC=0; e.downed=0; e.finished=0; e.state='chase';
       e.face=Math.PI; e.cone=Math.PI; e.alert=20; e.acqT=1; e.cd=0; e.bag=[]; e.goal=null; e.roll=0; e.pinT=0;
       e.kitT=99; e.helped=0; e.affix=null; e.blind=0; e.overheat=0; e.stunT=0; e.frozenT=0; g.ents=[e]; g.bullets=[]; return e;
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; active0=g.active; p.iv=999; p.downed=false; p.x=1800; p.y=1600;
       g.map.walls=[]; g.map.segs=[]; g.vseg=[]; g.smokes=[]; g.shells=[]; g.pConceal=1;
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false;
       sfx=function(k,x,y){if(k==='charge'&&e&&x===e.x&&y===e.y)charges++;};
       fireWeapon=function(sh){ if(sh===e) calls++; return oFW.apply(this,arguments); };
       put(1,WEAPONS.sniper); __ents(1/60);
       if(calls||shots()||!(e.glint>.48&&e.glint<=.5)) return 'elite fired without half-second warning: calls '+calls+' bullets '+shots()+' glint '+e.glint;
       if(charges!==1) return 'charge did not sound once at the shooter';
       for(var i=0;i<29;i++) __ents(1/60);
       if(calls||shots()) return 'elite fired before half a second';
       __ents(1/60);
       if(calls!==1||shots()!==1||e.glint>0) return 'tell expiry did not fire exactly one real round';
       if(e.cd<2.72-.5-.02||e.cd>4.64-.5) return 'Longshot cooldown did not repay the warning time: '+e.cd;
       calls=0; put(0,WEAPONS.rifle); __ents(1/60);
       if(calls!==1||shots()!==1||e.glint>0) return 'ordinary rifle no longer fires immediately';
       // v28.xx (cw-cx-longshotglint): stage an already-acquired target at the ring; otherwise the existing first-contact beat floors cd to 0.5 before this shot is ready.
       calls=0; put(1,WEAPONS.sniper); e.state='extract'; e.extracting=.1; e.beat=1; CFG.raiderBeacon=0;
       g.active={x:e.x,y:e.y,r:100,open:true,hold:50,beaconT:null}; __ents(1/60);
       if(calls||shots()) return 'ring shot bypassed the warning: calls '+calls+' bullets '+shots();
       if(!(e.glint>.48&&e.glint<=.5)) return 'ready ring pillager did not start a tell: state '+e.state+' cd '+e.cd+' acqT '+e.acqT+' glint '+e.glint;
       for(i=0;i<30;i++) __ents(1/60); g.active=active0;
       if(calls!==1||shots()!==1||e.glint>0) return 'ring warning never released one real round';
       calls=0; put(1,WEAPONS.sniper); __ents(1/60); e.x=p.x+1200;
       for(i=0;i<30;i++) __ents(1/60);
       if(calls||shots()||e.glint>0) return 'out-of-range tell was not dropped';
       calls=0; put(1,WEAPONS.sniper); __ents(1/60);
       losClear=function(){return false;}; for(i=0;i<30;i++) __ents(1/60); losClear=oL;
       if(calls||shots()||e.glint>0) return 'blocked tell fired through cover';
       put(1,WEAPONS.sniper); e.glint=.25; e.burnT=.2; e.downed=1; e.getUp=.1;
       row=netEntRow(e); if((row[8]&7)!==7) return 'ninth-field glint clobbered burn or get-up';
       copy=netEntMake(777,'raider',e.x,e.y); copy.wep=WEAPONS.sniper; copy.elite=1;
       netEntFlagsApply(copy,row[7],row[8]); if(!(copy.glint>0)||!copy.burnT||!copy.getUp) return 'linked window missed glint or old status bits';
       copy.glint=.2; netEntFlagsApply(copy,row[7],row[8]); if(copy.glint!==.2) return 'repeat snapshot restarted the tell';
       netEntFlagsApply(copy,row[7],row[8]&~4); if(copy.glint>0||!copy.burnT||!copy.getUp) return 'clearing glint damaged other status bits';
       e.downed=0; e.getUp=0; e.seen=false; e.glint=.04;
       if(typeof drawLongshotGlints!=='function') return 'no muzzle star drawing';
       if(drawLongshotGlints()!==1) return 'clear-line hidden body did not draw a glint';
       losClear=function(){return false;}; if(drawLongshotGlints()!==0) return 'star revealed a shooter through a wall'; losClear=oL;
       oD=drawLongshotGlints; drawLongshotGlints=function(){if(/_wtA/.test(new Error().stack))bodySeen=true;return oD();};
       __frame(0); if(!bodySeen) return 'glint did not draw in the above-fog world pass';
       return null;
     } finally {
       fireWeapon=oFW; sfx=oS; losClear=oL; if(oD) drawLongshotGlints=oD;
       if(g&&active0) g.active=active0;
       try{__endRaid('abandon');}catch(_e){} __topClear();
     }
   }},
  {v:'35.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

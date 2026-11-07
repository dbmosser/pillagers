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

if ($s.Contains("  {v:'37.52',what:")) { throw "check 37.52 is in the fixture already" }

SubRx @'
  {v:'37.51',what:
'@ @'
  {v:'37.52',what:'overseer targets the highest standing damage dealer and shares that seat with the joining window',
   run:function(){
     var nk={},k,g,p,e,body,row,copy,oBoss=bossTick,bad=[];
     function expect(ok,msg){if(!ok)bad.push(msg);}
     for(k in NET) nk[k]=NET[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.sim=false; g.paused=false;
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.specG=null; NET.upOut={}; NET.upHow={};
       NET.roster=[{seat:0,name:'a'},{seat:1,name:'b'}]; NET.peers=[{seat:1,state:'in'}];
       p.x=2000; p.y=1600; p.downed=0; p.specOut=0;
       NET.up=[{seat:1,n:5,age:0,sd:g.seed>>>0,tx:2600,ty:1600,tf:0,dn:0,mv:0}];
       e=mkWarden(1700,1600); e.boss=1; e.name=BOSS_NAME; e.ovDmg={0:50,1:400}; e.spd=0; e.cd=100;
       body=netUpBody(NET.up[0]);
       expect(netTargetFor(e)===body,'farther top damage dealer did not get the overseer');
       NET.up[0].dn=1; expect(netTargetFor(e)===p,'downed damage leader kept the overseer'); NET.up[0].dn=0;
       NET.up[0].xo=1; expect(netTargetFor(e)===p,'extracted leader kept the overseer'); NET.up[0].xo=0;
       NET.up[0].age=NET_HUB_STALE+1; expect(netTargetFor(e)===p,'stale leader kept the overseer'); NET.up[0].age=0;
       e.ovDmg[0]=400; expect(netTargetFor(e)===p,'tie did not use nearest');
       e.ovDmg={}; expect(netTargetFor(e)===p,'no damage did not use nearest');
       e.ovDmg={0:500,1:400}; p.specOut=1; expect(netTargetFor(e)===body,'spectating host kept the overseer'); p.specOut=0;
       e.boss=0; expect(netTargetFor(e)===p,'ordinary warden used the ledger'); e.boss=1;
       NET.on=false; expect(netTargetFor(e)===p,'solo target changed'); NET.on=true;
       // Exercise the real host tick, including one-time deltas, expired tags and healing.
       bossTick=function(){}; g.ents=[e]; e.ovDmg={}; delete e.ovHp0; e.pHitT=0;
       updateEnts(0); var hp=e.hp; e.hp-=40; e.pHitT=.3; e.pHitSeat=1; updateEnts(0);
       expect(e.ovDmg[1]===40&&e.ovHp0===hp-40,'host tick did not credit seat 1 health loss');
       updateEnts(0); expect(e.ovDmg[1]===40,'same health loss counted twice');
       e.hp-=10; e.pHitT=.3; e.pHitSeat=0; updateEnts(0); expect(e.ovDmg[0]===10,'host damage was not credited');
       e.hp+=5; updateEnts(0); expect(e.ovDmg[0]===10,'healing reduced the ledger');
       e.hp-=5; e.pHitT=0; updateEnts(0); expect(e.ovDmg[0]===10,'untagged loss was credited');
       // Both seat encodings and all old status bits survive the row round trip.
       e.ovDmg={0:50,1:400}; e.glint=.2; e.openT=1; e.bigW=1; e.windup=.5; e.burnT=1; e.downed=1; e.getUp=1;
       row=netEntRow(e); expect((row[8]&31)===31&&((row[8]>>>5)&7)===2,'seat 1 row or old bits wrong');
       copy=netEntMake(999,'warden',e.x,e.y); copy.boss=1; netEntFlagsApply(copy,row[7],row[8]);
       expect(copy.ovTargetSeat===1&&copy.burnT>0&&copy.getUp>0&&copy.openT>0&&copy.bigW&&copy.glint>0,'row apply lost target or status');
       NET.role='join'; NET.seat=1; NET.up=[{seat:0,n:5,age:0,sd:g.seed>>>0,tx:1701,ty:1600,tf:0,dn:0,mv:0}];
       expect(netTargetFor(copy)===p,'joining window did not follow its own target seat');
       netEntFlagsApply(copy,0,(row[8]&31)|32); expect(netTargetFor(copy)===netUpBody(NET.up[0]),'joining window did not follow host target seat');
       netEntFlagsApply(copy,0,0); expect(copy.ovTargetSeat===-1,'cleared row kept a stale target');
       NET.role='host'; NET.seat=0; NET.up=[{seat:1,n:5,age:0,sd:g.seed>>>0,tx:2600,ty:1600,tf:0,dn:0,mv:0}];
       e.ovDmg={0:500,1:400}; expect(((netEntRow(e)[8]>>>5)&7)===1,'host target seat was not encoded');
     }catch(ex){bad.push('threw: '+(ex.message||ex));}
     finally{
       bossTick=oBoss;
       for(k in NET) if(!(k in nk)) delete NET[k]; for(k in nk) NET[k]=nk[k];
       try{__endRaid('abandon');}catch(_end){} __topClear();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'37.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

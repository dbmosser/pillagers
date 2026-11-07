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

if ($s.Contains("  {v:'37.50',what:")) { throw "check 37.50 is in the fixture already" }

SubRx @'
  {v:'37.49',what:
'@ @'
  {v:'37.50',what:'hurt hostile pillagers split into fixed charges and escapes, and pillagers flee live frags including party copies',
   run:function(){
     var g,p,bad=[],oBoss=bossTick,oWater=inWater,nk=Object.assign({},NET),oldKit=CFG.raiderKit,i,e;
     function ok(v,s){if(!v) bad.push(s);}
     function bot(n,h){
       var q=mkRaider(2000,1600,undefined,true);
       Object.assign(q,{nid:n,hostile:true,merc:0,friendlyPC:0,golden:0,downed:0,hp:h,maxhp:100,state:'chase',alert:10,face:0,cd:99,tx:2500,ty:1600,cornered:0,smkT:0,elite:0,affix:null,crew:1,bag:[],looted:0});
       return q;
     }
     function fragProbe(fx,hire,sim){
       g.sim=sim; e=bot(31,100); e.state='loot'; e.hostile=false; e.merc=hire; e.cd=99;
       e.goal={x:e.x,y:e.y,opened:false,loot:[],type:'crate'}; e.goalT=0; e.goalD=0;
       g.ents=[e]; g.frags=[{x:1940,y:1600,mine:1,fx:fx,t:0,fuse:1.1,nsent:1}];
       for(var j=0;j<111;j++){ updateEnts(0.01); updateThrowables(0.01); }
       ok(g.frags.length===0,'frag did not burst');
       ok(Math.hypot(e.x-1940,e.y-1600)>190,'looting pillager did not escape frag (fx '+fx+', hire '+hire+', sim '+sim+')');
       ok(e.hp===100,'frag hurt escaping pillager');
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state(); p=g.player;
       NET.on=false; CFG.raiderKit=1; bossTick=function(){}; inWater=function(){return false;};
       g.sim=true; g.map.walls=[]; g.map.segs=[]; g.grid=null; g.vseg=[]; g.vgrid=null; g.brl=[]; g.containers=[]; g.shells=[]; g.frags=[]; g.ents=[];
       p.x=2500; p.y=1600; p.hp=100; p.downed=0; g.pCrouch=false;
       for(i=1;i<=20;i++) g.ents.push(bot(i,25));
       var ns=g.smokes.length; updateEnts(0.01); var charge=0,run=0;
       for(i=0;i<20;i++){
         e=g.ents[i];
         if(e.state==='chase'&&e.cornered){ charge++; ok(!e.fled&&!e.smkT&&e.rushT===4,'charger smoked or announced flight'); }
         else if(e.state==='extract') run++; else bad.push('hurt pillager neither charged nor fled');
       }
       ok(charge>=6&&charge<=10&&run===20-charge,'charge/flee split '+charge+'/'+run);
       ok(g.smokes.length-ns===run,'smoke count does not match escapes');
       e=g.ents.filter(function(q){return q.rushT>0;})[0];
       if(e){
         g.ents=[e]; var x=e.x,y=e.y; updateEnts(0.1);
         ok(Math.abs(Math.hypot(e.x-x,e.y-y)-e.spd*1.25*0.1)<0.1,'rush speed is not 1.25x');
         ok(Math.abs(e.rushT-3.9)<0.001,'rush clock did not tick');
         e.rushT=0.01; updateEnts(0.02); ok(e.rushT===0&&e.cornered&&e.state!=='extract','rush expiration restarted escape');
       }
       fragProbe(0,0,true); fragProbe(1,0,true); fragProbe(1,1,true); fragProbe(0,0,false);
       g.sim=true; e=bot(32,100); e.state='loot'; e.hostile=false;
       e.goal={x:e.x,y:e.y,opened:false,loot:[],type:'crate'}; e.goalT=0; e.goalD=0; g.ents=[e];
       var fr={x:1940,y:1600,t:0.1,fuse:1.1}; g.frags=[fr]; var x0=e.x;
       updateEnts(0.01); ok(e.x===x0,'frag reaction was earlier than 0.15s');
       fr.t=0.2; fr.by=e; updateEnts(0.01); ok(e.x===x0,'pillager fled own frag');
       fr.by=null; fr.t=fr.fuse; updateEnts(0.01); ok(e.x===x0,'pillager fled expired frag');
       return bad.length?bad.join('; '):null;
     }finally{
       bossTick=oBoss; inWater=oWater; CFG.raiderKit=oldKit; NET.on=false;
       try{__endRaid('abandon');}catch(_e){} __topClear(); Object.assign(NET,nk);
     }
   }},
  {v:'37.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

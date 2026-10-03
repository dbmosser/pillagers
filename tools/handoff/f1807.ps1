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

if ($s.Contains("  {v:'18.07',what:")) { throw "check 18.07 is in the fixture already" }

SubRx @'
  {v:'18.06',what:
'@ @'
  {v:'18.07',what:'shared sight: an enemy the player cannot see but a teammate up top is facing is drawn as seen, the fog of war sheet is thinner in front of the teammate than with the row Off, Settings has the Shared sight row, and with it Off the enemy is not seen through the teammate',
   run:function(){
     if(typeof netMateSees!=='function'||typeof netMateFog!=='function') return 'there is no shared sight';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], keep={on:NET.on,role:NET.role,up:NET.up,upSeed:NET.upSeed,roster:NET.roster,seat:NET.seat}, s0=CFG.sharedSight, g, p, e=null, i, j, mate, ks=(GAMEOPTS||[]).map(function(o){ return o.k; }), offs=[0,90,-90,180,-180,270,-270], ok=false, sf, pz, sx, sy, aOn=-1, aOff=-1;
     if(ks.indexOf('sharedSight')<0) bad.push('Settings has no Shared sight row');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={}; g.mapOpen=false; p.face=0;
       for(i=0;i<g.ents.length;i++){ if((g.ents[i].kind==='sentry'||g.ents[i].kind==='crawler')&&g.ents[i].hp>0){ e=g.ents[i]; break; } }
       if(!e) return 'SKIP: no machine to look at';
       mate={seat:1,x:0,y:0,f:0,tx:0,ty:0,tf:0,mv:0,roll:0,bob:0,age:0,n:3,lk:null,cr:0,sp:0,dn:0,w:'',sd:(g.seed>>>0),wep:null,pz:0,sa:1,hp:100,mh:100};
       for(j=0;j<offs.length&&!ok;j++){ e.x=p.x-520; e.y=p.y+offs[j]; mate.x=e.x-140; mate.y=e.y; mate.tx=mate.x; mate.ty=mate.y; if(mate.x>60&&mate.y>60&&losClear(mate.x,mate.y,e.x,e.y,g.vseg)&&!losClear(p.x,p.y,e.x,e.y,g.vseg)===false) ok=true; }
       if(!ok) return 'SKIP: no clear line for the teammate here';
       NET.on=true; NET.role='host'; NET.seat=0; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}]; NET.upSeed=(g.seed>>>0); NET.up=[]; NET.up[1]=mate;
       sf=(typeof SOFTR==='number')?SOFTR:1; pz=ZOOM();
       CFG.sharedSight=1; e.seen=false; __frame(0.016);
       if(!e.seen) bad.push('the enemy the teammate faces is not seen');
       sx=(mate.x+70-g.camX)*pz*sf; sy=(mate.y-g.camY)*pz*sf;
       aOn=fx2.getImageData(Math.round(sx),Math.round(sy),1,1).data[3];
       CFG.sharedSight=0; e.seen=false; __frame(0.016);
       if(e.seen) bad.push('with Shared sight Off the enemy is still seen through the teammate');
       aOff=fx2.getImageData(Math.round(sx),Math.round(sy),1,1).data[3];
       if(!(aOn<aOff*0.7)) bad.push('the fog in front of the teammate is not opened (alpha '+aOn+' on, '+aOff+' off)');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       NET.on=keep.on; NET.role=keep.role; NET.up=keep.up; NET.upSeed=keep.upSeed; NET.roster=keep.roster; NET.seat=keep.seat; CFG.sharedSight=s0; keys={};
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'18.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

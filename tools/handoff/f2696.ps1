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

if ($s.Contains("  {v:'26.96',what:")) { throw "check 26.96 is in the fixture already" }

SubRx @'
  {v:'26.95',what:
'@ @'
  {v:'26.96',what:'career1, his yes to the gun kill tally (29): a round carries its gun, a kill by that round counts for the gun, a blast does not, the tally is banked on an extraction and not on an abandon, and it shows as a KILLS row on the hover and the gun card',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__ents&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof gunKillsOf!=='function') return 'there is no gun kill tally in this build';
     if(typeof mkCrawler!=='function'||typeof updateBullets!=='function'||typeof fireWeapon!=='function'||typeof rayHitG!=='function'||typeof spotFree!=='function') return 'SKIP: no raid pieces here';
     var bad=[], snap=null, g=null, p=null, i, j, aa, x, y, dx, dy, e, b, c0, c1, h0, h1;
     function lane(ax,ay,bx,by){ var d=Math.hypot(bx-ax,by-ay)||1; return rayHitG(ax,ay,(bx-ax)/d,(by-ay)/d,d)>=d-0.5; }
     function ground(){
       var k;
       for(k=0;k<32;k++){ aa=k/32*6.2832; dx=Math.cos(aa); dy=Math.sin(aa); x=p.x+dx*150; y=p.y+dy*150;
         if(x>80&&y>80&&x<WORLD_W-80&&y<WORLD_H-80&&spotFree(g.map,x,y,40)&&lane(x-dx*60,y-dy*60,x,y)) return {x:x,y:y,dx:dx,dy:dy}; }
       return null;
     }
     function bulletKill(gid){
       var t=ground(), en, n;
       if(!t) return -1;
       en=mkCrawler(t.x,t.y); en.hp=5; en.maxhp=5; g.ents=[en];
       g.bullets.length=0;
       g.bullets.push({x:t.x-t.dx*24,y:t.y-t.dy*24,vx:t.dx*1180,vy:t.dy*1180,dmg:500,life:0.4,player:true,owner:p,tint:'#ffffff',el:'',thru:0,gid:gid});
       for(n=0;n<6&&en.hp>0;n++) updateBullets(1/60);
       if(!(en.hp<=0)) return -2;
       __ents(0.016);
       return 1;
     }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __P().gunKills={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false;
       // ONE: a fired round carries its gun
       fireWeapon(p,WEAPONS.rifle,p.x+300,p.y,true);
       b=g.bullets[g.bullets.length-1];
       if(!b||b.gid!=='rifle') bad.push('ONE: a round of the Auto Rifle carries gid '+(b&&b.gid));
       g.bullets.length=0;
       // TWO: a kill by that round counts for the gun, in the raid at once
       if(!ground()) return 'SKIP: no open ground for the shot';
       c0=gunKillsOf('rifle');
       h0=bulletKill('rifle');
       if(h0!==1) bad.push('TWO: the staged round did not kill ('+h0+')');
       else if(gunKillsOf('rifle')!==c0+1) bad.push('TWO: a rifle kill moved the live tally from '+c0+' to '+gunKillsOf('rifle'));
       if(gunKillsOf('smg')!==0) bad.push('TWO: an SMG count appeared from a rifle kill');
       // THREE: a blast is not a gun
       e=mkCrawler(p.x+50,p.y); e.hp=0; e.byPlayer=1; e.blow='x'; e.blowG='rifle'; g.ents=[e]; __ents(0.016);
       if(gunKillsOf('rifle')!==c0+1) bad.push('THREE: a blast kill counted for the rifle ('+gunKillsOf('rifle')+')');
       // FOUR: the row on the hover and the card
       h1=itemRows('gun_rifle'); c1=null; for(i=0;i<h1.length;i++) if(h1[i][0]==='KILLS') c1=String(h1[i][1]);
       if(c1!==String(gunKillsOf('rifle'))) bad.push('FOUR: the rifle hover KILLS row reads '+c1);
       h1=itemRows('gun_smg'); for(i=0;i<h1.length;i++) if(h1[i][0]==='KILLS') bad.push('FOUR: the SMG hover has a KILLS row with no kills');
       if(typeof gunCardSize==='function'&&typeof gunCompare==='function'){
         j=gunCompare(WEAPONS.rifle,WEAPONS.smg); h0=gunCardSize(j,'').h; h1=gunCardSize(gunCompare(WEAPONS.smg,WEAPONS.rifle),'').h;
         if(!(h0>h1)) bad.push('FOUR: the card of a gun with kills is not taller than one with none ('+h0+' against '+h1+')');
       }
       // FIVE: an abandon banks nothing, an extraction banks the raid
       __endRaid('abandon'); __topClear();
       if(((+__P().gunKills.rifle)|0)!==0) bad.push('FIVE: an abandoned raid banked '+__P().gunKills.rifle+' kills');
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no second raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false;
       if(bulletKill('rifle')!==1||bulletKill('rifle')!==1) bad.push('FIVE: the second raid kills did not land');
       if(gunKillsOf('rifle')!==2) bad.push('FIVE: the live tally in the second raid reads '+gunKillsOf('rifle')+', not 2');
       __endRaid('extract'); __topClear();
       if(((+__P().gunKills.rifle)|0)!==2) bad.push('FIVE: an extraction banked '+__P().gunKills.rifle+' rifle kills, not 2');
       if(gunKillsOf('rifle')!==2) bad.push('FIVE: the tally reads '+gunKillsOf('rifle')+' after the raid, not 2');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ keys={}; }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

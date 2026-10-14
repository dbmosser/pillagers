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

if ($s.Contains("  {v:'26.79',what:")) { throw "check 26.79 is in the fixture already" }

SubRx @'
  {v:'26.78',what:
'@ @'
  {v:'26.79',what:'his words (suggestion 28): a plain Warden has an armoured front like the Bulwark (a round inside its front arc does 40 percent, from the side full, from behind half again), the Bulwark is unchanged, and the Overseer stays unarmoured',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof mkWarden!=='function'||typeof mkBulwark!=='function'||typeof updateBullets!=='function'||typeof spotFree!=='function'||typeof rayHitG!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, sp=null, k, aa, x, y, W, Bw, Ov, lossF, lossS, lossB, lossBw, lossOv;
     function inW(x,y){ return x>60&&y>60&&x<WORLD_W-60&&y<WORLD_H-60; }
     function lane(ax,ay,bx,by){ var d=Math.hypot(bx-ax,by-ay)||1; return rayHitG(ax,ay,(bx-ax)/d,(by-ay)/d,d)>=d-0.5; }
     function hit(e,sx,sy,vx,vy){
       var h0=e.hp, j;
       g.bullets.length=0;
       g.bullets.push({x:sx,y:sy,vx:vx*1180,vy:vy*1180,dmg:100,life:0.4,player:true,owner:p,tint:'#ffffff',el:'',thru:0});
       for(j=0;j<10;j++) updateBullets(1/60);
       e.hp=h0-(h0-e.hp);
       return h0-e.hp;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false; all=g.ents.slice();
       for(k=0;k<24&&!sp;k++){
         aa=k/24*6.2832; x=p.x+Math.cos(aa)*200; y=p.y+Math.sin(aa)*200;
         if(inW(x-130,y)&&inW(x+130,y)&&inW(x,y+130)&&inW(x,y-130)&&spotFree(g.map,x,y,60)&&lane(x+130,y+14,x,y+14)&&lane(x,y+130,x,y)&&lane(x-130,y+14,x,y+14)) sp={x:x,y:y};
       }
       if(!sp) return 'SKIP: no open ground for the shots';
       W=mkWarden(sp.x,sp.y); W.face=0; W.hp=W.maxhp=100000; W.state='patrol'; W.boss=0; W.windup=null;
       g.ents=[W];
       lossF=hit(W,sp.x+130,sp.y+14,-1,0);
       lossS=hit(W,sp.x,sp.y+130,0,-1);
       lossB=hit(W,sp.x-130,sp.y+14,1,0);
       if(!(lossF>=35&&lossF<=45)) bad.push('a round of 100 into the front of a Warden did '+Math.round(lossF)+', not about 40');
       if(!(lossS>=95&&lossS<=105)) bad.push('a round of 100 into the side of a Warden did '+Math.round(lossS)+', not 100');
       if(!(lossB>=145&&lossB<=155)) bad.push('a round of 100 into the back of a Warden did '+Math.round(lossB)+', not 150');
       Ov=mkWarden(sp.x,sp.y); Ov.boss=1; Ov.face=0; Ov.r=44; Ov.hp=Ov.maxhp=100000; Ov.state='patrol'; Ov.windup=null; g.ents=[Ov];
       lossOv=hit(Ov,sp.x+130,sp.y+14,-1,0);
       if(!(lossOv>=95&&lossOv<=105)) bad.push('a round of 100 into the front of the Overseer did '+Math.round(lossOv)+': it should stay unarmoured');
       Bw=mkBulwark(sp.x,sp.y); Bw.elite=0; Bw.face=0; Bw.hp=Bw.maxhp=100000; Bw.state='patrol'; Bw.windup=null; g.ents=[Bw];
       lossBw=hit(Bw,sp.x+130,sp.y+14,-1,0);
       if(!(lossBw>=10&&lossBw<=14)) bad.push('a round of 100 into the front of a Bulwark did '+Math.round(lossBw)+', not 12 (the Bulwark is unchanged)');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ if(g&&all){ g.ents=all; g.bullets.length=0; } var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

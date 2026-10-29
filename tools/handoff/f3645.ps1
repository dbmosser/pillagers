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

if ($s.Contains("  {v:'36.45',what:")) { throw "check 36.45 is in the fixture already" }

SubRx @'
  {v:'36.44',what:
'@ @'
  {v:'36.45',what:'combat status panels share a measured width of at least 220px, 48px rows and full 20px/16px type in crowded solo and both demo roles at 1080p and 4K',
   run:function(){
     var g,p,ft=ctx.fillText,sp=statusPill,kk=keys,md=mouse.down,us=P.uiScale,ownUS=Object.prototype.hasOwnProperty.call(P,'uiScale'),buzz=P.buzz,
         boxes=[HUDBOX,FEEDBOX,MEDALBOX,NETTEAMBOX],nk={on:NET.on,role:NET.role,seat:NET.seat},ar=ARCADE.role,
         ow=W,oh=H,bad=[],sizes=[[1920,1080],[3840,2160]],si,role,layout,seen={},panels=[],tag;
     function need(ok,msg){if(!ok)bad.push(tag+': '+msg);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();P.uiScale=1;
       __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       g.mapOpen=false;g.bagOpen=false;g.paused=false;g.sim=false;keys={};mouse.down=false;
       ctx.fillText=function(t,x,y){var m=ctx.getTransform(),d=(typeof DPRH==='number'&&DPRH>0)?DPRH:1,px=parseFloat((/([\d.]+)px/.exec(ctx.font)||[])[1]);seen[String(t).toLowerCase()]={px:px*Math.sqrt(m.a*m.a+m.b*m.b)/d/hudRes()};return ft.apply(this,arguments);};
       statusPill=function(x,cy,x1,h){var m=ctx.getTransform(),d=(typeof DPRH==='number'&&DPRH>0)?DPRH:1;panels.push({x:(m.a*x+m.c*(cy-h/2)+m.e)/d,y:(m.b*x+m.d*(cy-h/2)+m.f)/d,w:(x1-x)*m.a/d,h:h*m.d/d});return sp.apply(this,arguments);};
       for(si=0;si<sizes.length;si++)for(role=0;role<3;role++)for(layout=0;layout<3;layout++){
         __forceSize(sizes[si][0],sizes[si][1]);NET.on=role>0;NET.role=role===2?'join':'host';NET.seat=role===2?1:0;ARCADE.role=role===2?'p2':'host';g.arcade=role>0;
         HUDBOX=layout?{body:{x:0,y:H*(layout===1?0.60:0.50),w:W*0.18,h:H*0.50}}:{};FEEDBOX={on:0};MEDALBOX={on:0};NETTEAMBOX={n:0};
         p.hp=100;p.healQ=0;p.stamLock=0;p.stamRelease=0;p.downed=false;p.arStk=3;p.arBonus=1;p.arMul=1.15;p.arGun=p.wep;p.ammo=3;p.reloading=0;p.stimT=5;p.shStk=15;p.bmStk=15;p.bmUntil=g.t+4;
         P.buzz=[{tag:'drunk',t:30,dur:180}];seen={};panels=[];tag=sizes[si].join('x')+' role '+role+' layout '+layout;
         ctx.save();try{var hd=(typeof DPRH==='number'&&DPRH>0)?DPRH:1;ctx.setTransform(hd,0,0,hd,0,0);drawStatusIcons();}finally{ctx.restore();}
         ['stim','active reload x3','steady hand +15%','beast mode +15%','liquor'].forEach(function(t){need(seen[t]&&isFinite(seen[t].px)&&seen[t].px>=19.99,t+' title below 20px or missing');});
         ['5s','+15% damage','damage','4s','30s'].forEach(function(t){need(seen[t]&&isFinite(seen[t].px)&&seen[t].px>=15.99,t+' detail below 16px or missing');});
         need(panels.length>=5,'a live status panel was omitted');
         panels.forEach(function(a,i){need(a.w/hudRes()>=219.9&&a.h/hudRes()>=47.9,'panel '+i+' below shared dimensions');need(Math.abs(a.w-panels[0].w)<0.1,'panel '+i+' width differs');need(a.x>=0&&a.y>=0&&a.x+a.w<=W+0.1&&a.y+a.h<=H+0.1,'panel '+i+' outside viewport');panels.forEach(function(b,j){if(j>i)need(!(a.x<b.x+b.w&&a.x+a.w>b.x&&a.y<b.y+b.h&&a.y+a.h>b.y),'panels '+i+' and '+j+' overlap');});});
       }
       return bad.length?bad.join('; '):null;
     }finally{
       ctx.fillText=ft;statusPill=sp;keys=kk;mouse.down=md;NET.on=false;
       try{if(p){p.arStk=0;p.arBonus=0;p.stimT=0;p.shStk=0;p.bmStk=0;}__endRaid('abandon');}catch(_e){}__topClear();
       HUDBOX=boxes[0];FEEDBOX=boxes[1];MEDALBOX=boxes[2];NETTEAMBOX=boxes[3];NET.on=nk.on;NET.role=nk.role;NET.seat=nk.seat;ARCADE.role=ar;
       if(ownUS)P.uiScale=us;else delete P.uiScale;P.buzz=buzz;__forceSize(ow,oh);
     }
   }},
  {v:'36.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

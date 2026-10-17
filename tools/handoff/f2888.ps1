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

if ($s.Contains("  {v:'28.88',what:")) { throw "check 28.88 is in the fixture already" }

SubRx @'
  {v:'28.87',what:
'@ @'
  {v:'28.88',what:'cloud-coop-p2-blast-past-shield: a blast, a mine, fists or an air strike from player 2 go straight past a shielded elite on the host as the host own do, and only his gun rounds (marked sk) are soaked by the shield',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof netOnMsg!=='function'||typeof netShotSend!=='function'||typeof mkCrawler!=='function'||typeof netEntMake!=='function'||typeof affixSoak!=='function'||typeof updateBullets!=='function'||typeof explodeFrag!=='function'||typeof airBlast!=='function') return 'SKIP: the co-op shot path is not here';
     var bad=[], g=null, p=null, NK={}, k, oS=netSend, oSF=netSendFast, oB=netBroadcast, posted=[], h={seat:0,state:'in'}, hp={seat:1,state:'in'}, staged=false, e=null, m=null, n, a, aa, x=0, y=0, dx=1, dy=0, found=false, w, ws, i, L;
     function take(word){ e.hp=400; e.maxhp=400; e.shieldHp=200; e.finished=0; e.downed=0; netOnMsg(hp,JSON.stringify(word)); return {lost:Math.round((400-e.hp)*100)/100,sh:e.shieldHp}; }
     function shots(){ return posted.filter(function(q){ return q&&q.t==='shot'&&q.id===901; }); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100;
       for(a=0;a<32;a++){ aa=a/32*6.2832; dx=Math.cos(aa); dy=Math.sin(aa); x=p.x+dx*150; y=p.y+dy*150; if(spotFree(g.map,x,y,40)&&rayHitG(x-dx*60,y-dy*60,dx,dy,60)>=59.5){ found=true; break; } }
       if(!found) return 'SKIP: no clear lane next to the player';
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0;
       netSendFast=function(q,mm){ return true; };
       netSend=function(q,mm){ posted.push(JSON.parse(JSON.stringify(mm))); return true; };
       netBroadcast=function(mm){ return 1; };
       e=mkCrawler(x,y); e.elite=1; e.affix='shield'; e.hp=e.maxhp=400; e.shieldHp=200;
       // ONE: the host takes player 2 words: blasts, fists and the air strike go past the shield, a round marked sk is soaked
       NET.role='host'; NET.seat=0; NET.peers=[hp]; NET.entMap={901:e}; g.ents=[e];
       L=[['frag',{t:'shot',id:901,dmg:80,x:p.x,y:p.y,a:0}],['air strike',{t:'shot',id:901,dmg:50,x:p.x,y:p.y,a:0}],['fist',{t:'shot',id:901,dmg:30,x:p.x,y:p.y,a:0}]];
       for(i=0;i<L.length;i++){ w=take(L[i][1]); if(w.lost!==L[i][1].dmg||w.sh!==200) bad.push('ONE: player 2 '+L[i][0]+' word of '+L[i][1].dmg+' lost '+w.lost+' with the shield at '+w.sh+' (the host own '+L[i][0]+' takes the full '+L[i][1].dmg+' and leaves the shield at 200)'); }
       w=take({t:'shot',id:901,dmg:100,x:p.x,y:p.y,a:0,sk:1});
       if(w.lost!==0||w.sh!==100) bad.push('ONE: player 2 round word (sk) of 100 lost '+w.lost+' with the shield at '+w.sh+' (the shield must soak it: 0 lost, shield 100)');
       // TWO: player 2 window marks his gun round sk and not his frag or his air strike
       NET.role='join'; NET.seat=1; NET.peers=[h]; NET.entMap={};
       m=netEntMake(901,'crawler',x,y); m.hp=m.maxhp=400; m.nIn=1; NET.entMap[901]=m; g.ents=[m];
       posted.length=0; g.bullets.length=0; g.bullets.push({x:x-dx*30,y:y-dy*30,vx:dx*1180,vy:dy*1180,dmg:23,life:0.4,player:true,owner:p,tint:'#fff',el:'',thru:0,gid:'rifle'});
       for(n=0;n<6&&!shots().length;n++) updateBullets(1/60);
       ws=shots(); if(!ws.length) bad.push('TWO: player 2 rifle round sent no shot word'); else if(ws[0].sk!==1) bad.push('TWO: player 2 rifle round word has no sk mark ('+JSON.stringify(ws[0])+')');
       m.hp=400; posted.length=0; p.hp=100; explodeFrag({x:x,y:y}); p.hp=100;
       ws=shots(); if(!ws.length) bad.push('TWO: player 2 frag sent no shot word'); else if('sk' in ws[0]) bad.push('TWO: player 2 frag word is marked sk ('+JSON.stringify(ws[0])+')');
       m.hp=400; posted.length=0; airBlast({pts:[{x:x,y:y}]},0);
       ws=shots(); if(!ws.length) bad.push('TWO: player 2 air strike blast sent no shot word'); else if('sk' in ws[0]) bad.push('TWO: player 2 air strike word is marked sk ('+JSON.stringify(ws[0])+')');
     }catch(x2){ bad.push('threw: '+String(x2&&x2.message||x2)); }
     finally{
       netSend=oS; netSendFast=oSF; netBroadcast=oB;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join(' | '):null;
   }},
  {v:'28.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

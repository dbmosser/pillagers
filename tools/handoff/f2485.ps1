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

if ($s.Contains("  {v:'24.85',what:")) { throw "check 24.85 is in the fixture already" }

SubRx @'
  {v:'24.84',what:
'@ @'
  {v:'24.85',what:'his note: THE OVERSEER seeing you says SPOTTED BY THE OVERSEER, a plain warden says SPOTTED BY A WARDEN, and a teammate window says the same line',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents)||typeof canSee!=='function'||typeof bossTick!=='function'||typeof netMarkTake!=='function'||typeof NET!=='object'||!NET) return 'SKIP: this fixture cannot deploy and step';
     var bad=[], g, p, all=null, w=null, b=null, i, lines=[], oSay=say, NK={}, k, cb=CFG.boss, peer={seat:0,state:'in'}, HG='SOMETHING '+'HUGE', OV='SPOTTED BY THE '+'OVERSEER', WD='SPOTTED BY A '+'WARDEN';
     var sight=function(e){
       var a, j, t, ox, oy;
       for(j=0;j<16;j++){
         a=j*Math.PI/8; ox=Math.cos(a)*(j<8?140:220); oy=Math.sin(a)*(j<8?140:220);
         e.x=p.x+ox; e.y=p.y+oy; e.face=Math.atan2(p.y-e.y,p.x-e.x); e.announced=false; e.seenYou=false; e.state='patrol'; e.alert=0;
         if(!canSee(e.x,e.y,e.face,p.x,p.y,g.vseg)) continue;
         lines=[]; g.ents=[e];
         for(t=0;t<6&&!e.announced;t++){ e.face=Math.atan2(p.y-e.y,p.x-e.x); __ents(0.05); }
         if(e.announced) return lines.slice();
       }
       return null;
     };
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; all=g.ents.slice(); p.iv=99; p.hp=100; p.downed=false; G.pCrouch=false;
       for(i=0;i<all.length;i++) if(all[i].kind==='warden'&&!all[i].boss){ w=all[i]; break; }
       if(!w) return 'SKIP: no plain warden on this map';
       say=function(s){ lines.push(String(s)); };
       var lw=sight(w);
       if(!lw) return 'SKIP: staging: the warden never saw the player';
       if(!lw.some(function(s){ return s.indexOf(WD)===0; })) bad.push('a plain warden seeing you says '+JSON.stringify(lw)+', not SPOTTED BY A WARDEN');
       if(lw.some(function(s){ return s.indexOf('OVERSEER')>=0||s.indexOf(HG)>=0; })) bad.push('a plain warden seeing you says '+JSON.stringify(lw));
       CFG.boss=1; g.bossDone=0; g.t=Math.max(g.t||0,3); g.ents=all.slice();
       b=bossTick(true);
       if(!b||!b.boss) return 'SKIP: staging: THE OVERSEER did not come';
       var lb=sight(b);
       if(!lb) return 'SKIP: staging: THE OVERSEER never saw the player';
       if(!lb.some(function(s){ return s.indexOf(OV)===0; })) bad.push('THE OVERSEER seeing you says '+JSON.stringify(lb)+', not SPOTTED BY THE OVERSEER');
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[peer]; NET.upSeed=g.seed>>>0; NET.entMap=NET.entMap||{};
       lines=[]; netMarkTake(peer,{t:'mark',k:'big',nid:0,seat:1,boss:1});
       if(!lines.some(function(s){ return s.indexOf(OV)===0; })) bad.push('player 2 window seen by THE OVERSEER says '+JSON.stringify(lines));
       lines=[]; netMarkTake(peer,{t:'mark',k:'big',nid:0,seat:1,boss:0});
       if(!lines.some(function(s){ return s.indexOf(WD)===0; })) bad.push('player 2 window seen by a plain warden says '+JSON.stringify(lines));
       lines=[]; netMarkTake(peer,{t:'mark',k:'big',nid:0,seat:0,boss:1});
       if(lines.length) bad.push('the line for player 1 was said on player 2 window: '+JSON.stringify(lines));
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       say=oSay; CFG.boss=cb;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(all&&g){ g.ents=all; if(b&&all.indexOf(b)<0) g.ents.push(b); } var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

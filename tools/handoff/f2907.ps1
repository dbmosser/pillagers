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

if ($s.Contains("  {v:'29.07',what:")) { throw "check 29.07 is in the fixture already" }

SubRx @'
  {v:'29.06',what:
'@ @'
  {v:'29.07',what:'cw-blowround: the host takes player 2 crowbar as a blow (no roll out of the line), player 2 gun round rolls him as before',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, rd=null, pa, r, w, k, a, ux, uy, NK={}, oS=netSend, oSF=netSendFast, E0=null, sent=[], mx=mouse.x, my=mouse.y, okp=false;
     for(k in NET) NK[k]=NET[k];
     function fresh(){ rd.hp=rd.maxhp=500; rd.hostile=true; rd.rig='none'; rd.armor=0; rd.roll=0; rd.rollCd=0; rd.downed=0; rd.finished=0; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; p.iv=99;
       rd=g.ents.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hp>0&&!x.downed&&!x.boss; })[0];
       if(!rd) return 'SKIP: staging: no pillager in the fixture raid';
       E0=g.ents; g.ents=[rd]; fresh();
       for(a=0;a<8;a++){ ux=Math.cos(a*0.785); uy=Math.sin(a*0.785); if(losClear(p.x,p.y,p.x+ux*120,p.y+uy*120,g.map.segs)){ rd.x=p.x+ux*35; rd.y=p.y+uy*35; okp=true; break; } }
       if(!okp) return 'SKIP: staging: no clear line beside the player';
       rd.face=Math.atan2(p.y-rd.y,p.x-rd.x); var s=w2s(rd.x,0,rd.y); mouse.x=s.x; mouse.y=s.y; p.face=Math.atan2(rd.y-p.y,rd.x-p.x);
       NET.on=true; NET.upSeed=g.seed>>>0; pa={state:'in',seat:1}; NET.up=[]; NET.roster=[{seat:0,name:'A'},{seat:1,name:'B'}];
       netSend=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; }; netSendFast=netSend;
       NET.role='host'; NET.seat=0; NET.peers=[pa]; netEntsInit(g);
       NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}]; sent.length=0;
       meleeStrike();
       w=sent.filter(function(m){ return m.t==='shot'; })[0];
       NET.role='host'; NET.seat=0; NET.peers=[pa];
       if(!w) return 'SKIP: staging: player 2 crowbar sent no word';
       fresh(); w.dmg=100; r=netShotTake(pa,w);
       if(r!=='shot') return 'SKIP: staging: the host did not take player 2 crowbar ('+r+')';
       if(rd.roll>0) bad.push('player 2 crowbar rolled the pillager out of the line');
       if(Math.round(500-rd.hp)!==100) bad.push('player 2 crowbar dealt '+(500-rd.hp)+' not 100');
       fresh(); r=netShotTake(pa,{t:'shot',id:rd.nid,dmg:30,a:0,x:rd.x-35,y:rd.y,sk:1});
       if(r!=='shot') return 'SKIP: staging: the host did not take player 2 round ('+r+')';
       if(!(rd.roll>0)) bad.push('player 2 gun round no longer rolls him');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ netSend=oS; netSendFast=oSF; for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; mouse.x=mx; mouse.y=my; if(g&&E0) g.ents=E0; if(g) g.bullets.length=0; }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'29.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'25.15',what:")) { throw "check 25.15 is in the fixture already" }

SubRx @'
  {v:'25.14',what:
'@ @'
  {v:'25.15',what:'forge4: a shock hit arcs half its damage to the nearest body, stuns the machine it hit for half a second with no re-stun inside the immunity, never arcs to a pillager at peace or a hire, and arcs at most once in 0.2 s',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof elemHit!=='function'||typeof forgeApply!=='function') return 'SKIP: no raid or elemental rounds here';
     var bad=[], g, p, all=null, oPX, oPY, cs, A, B, rd, X0, Y0, dx=1, dy=0, k, ok=false, h, ax0, ay0, s1, oMerc=null, oHost;
     try{
       __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       all=g.ents.slice(); oPX=p.x; oPY=p.y; X0=p.x; Y0=p.y;
       for(k=0;k<8;k++){ var ux=Math.cos(k*0.7854), uy=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ux*180,Y0+uy*180,g.map.segs)){ dx=ux; dy=uy; ok=true; break; } }
       if(!ok) return 'SKIP: staging: no open line from the drop point';
       cs=all.filter(function(x){ return x.kind==='crawler'&&x.hp>0&&!x.downed; });
       if(cs.length<2) return 'SKIP: fewer than two crawlers on this map';
       A=cs[0]; B=cs[1];
       p.x=X0-dx*200; p.y=Y0-dy*200;
       function stage(){ g.ents=[A,B]; A.x=X0; A.y=Y0; B.x=X0+dx*100; B.y=Y0+dy*100; A.hp=A.maxhp=B.hp=B.maxhp=2000; A.armor=B.armor=0;
         A.stunT=A.stunImm=B.stunT=B.stunImm=0; A.state=B.state='patrol'; A.tx=B.tx=X0+dx*400; A.ty=B.ty=Y0+dy*400; g.arcCd=null; }
       stage();
       elemHit(A,'shock',40,0,p.x,p.y);
       if(Math.abs(B.hp-1980)>0.01) bad.push('the second crawler took '+(2000-B.hp)+' from a 40 shock hit, want 20');
       if(!(A.stunT>0)) bad.push('the crawler hit by shock is not stunned');
       if(!(A.stunImm>0)) bad.push('the stunned crawler has no immunity');
       if(A.hp!==2000) bad.push('elemHit took health off the body it was handed ('+A.hp+')');
       ax0=A.x; ay0=A.y;
       for(k=0;k<3;k++) __ents(0.1);
       if(Math.hypot(A.x-ax0,A.y-ay0)>0.01) bad.push('the stunned crawler moved '+Math.hypot(A.x-ax0,A.y-ay0).toFixed(1));
       s1=A.stunT;
       g.arcCd=null; elemHit(A,'shock',40,0,p.x,p.y);
       if(A.stunT>s1+1e-9) bad.push('a second shock hit inside the immunity stunned it again');
       A.stunT=0; A.x=X0; A.y=Y0; ax0=A.x;
       stage(); h=B.hp;
       elemHit(A,'shock',40,0,p.x,p.y); elemHit(A,'shock',40,0,p.x,p.y);
       if(Math.abs((h-B.hp)-20)>0.01) bad.push('two shock hits inside 0.2 s arced '+(h-B.hp)+', want one arc of 20');
       elemTick(0.25); elemHit(A,'shock',40,0,p.x,p.y);
       if(Math.abs((h-B.hp)-40)>0.01) bad.push('the arc did not come back after 0.2 s ('+(h-B.hp)+')');
       rd=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hp>0&&!x.downed; })[0];
       if(rd){
         oHost=rd.hostile; oMerc=rd.merc;
         g.ents=[A,rd]; rd.x=X0+dx*100; rd.y=Y0+dy*100; rd.hp=rd.maxhp=2000; rd.armor=0; g.arcCd=null;
         rd.hostile=false; elemHit(A,'shock',40,0,p.x,p.y);
         if(rd.hp!==2000) bad.push('a shock arc hit a pillager at peace');
         if(rd.hostile!==false) bad.push('a shock arc turned a pillager at peace');
         rd.hostile=true; rd.merc=1; g.arcCd=null; elemHit(A,'shock',40,0,p.x,p.y);
         if(rd.hp!==2000) bad.push('a shock arc hit a hire');
         rd.merc=oMerc; g.arcCd=null; elemHit(A,'shock',40,0,p.x,p.y);
         if(!(rd.hp<2000)) bad.push('a shock arc missed a hostile pillager in reach');
         rd.hostile=oHost;
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ if(rd&&oMerc!==null) rd.merc=oMerc; }catch(_m){}
       try{ var g2=__state(); if(g2){ if(all) g2.ents=all; g2.arcCd=null; if(g2.player){ g2.player.x=oPX; g2.player.y=oPY; } if(!g2.over){ g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

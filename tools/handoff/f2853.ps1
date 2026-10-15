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

if ($s.Contains("  {v:'28.53',what:")) { throw "check 28.53 is in the fixture already" }

SubRx @'
  {v:'28.52',what:
'@ @'
  {v:'28.53',what:'cloud-feel-finish-dying: FINISH is drawn over a downed pillager in reach while the player stands, and not in the death beat after killPlayer',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, rd, E0=null, oK=keys, oCr=CFG.raiderCrawl, X0, Y0, dx=0, dy=0, k, ux, uy, n, i, proto=CanvasRenderingContext2D.prototype, oF=proto.fillText;
     function frame(){ var cap=[]; proto.fillText=function(t){ if(String(t).indexOf('FINISH')>=0) cap.push(String(t)); return oF.apply(this,arguments); }; try{ render2D(0); drawHUD(); } finally{ proto.fillText=oF; } return cap.length; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; E0=g.ents; X0=p.x; Y0=p.y;
       for(k=0;k<8;k++){ ux=Math.cos(k*0.7854); uy=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ux*80,Y0+uy*80,g.map.segs)){ dx=ux; dy=uy; break; } }
       rd=E0.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC; })[0];
       if(!rd) return 'SKIP: staging: no pillager in the fixture raid';
       CFG.raiderCrawl=0; g.ents=[rd]; keys={};
       rd.x=X0+dx*30; rd.y=Y0+dy*30; rd.hp=40; rd.maxhp=100; rd.downed=1; rd.finished=0; rd.downT=14; rd.hostile=true; rd.state='down'; rd.getUp=0;
       n=frame();
       if(!(n>0)) return 'SKIP: staging: no FINISH drawn over the downed pillager while he stands';
       p.hp=1; p.armor=0; p.iv=0; p.revived=true; killPlayer('crawler');
       if(!p.dying) return 'SKIP: staging: killPlayer did not open the death beat';
       for(i=0;i<5;i++){ g.t+=0.016; __sim(0.016); rd.x=X0+dx*30; rd.y=Y0+dy*30; n=frame(); if(n>0){ bad.push('FINISH drawn in the death beat (frame '+(i+1)+', beat '+(+(g.deathBeat||0)).toFixed(2)+')'); break; } }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oF; CFG.raiderCrawl=oCr; keys=oK; if(g&&E0) g.ents=E0; }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'36.92',what:")) { throw "check 36.92 is in the fixture already" }

SubRx @'
  {v:'36.91',what:
'@ @'
  {v:'36.92',what:'cw-mapchips: on the seed 4242 Cold Storage sector map at 1080p and 4K every label sits on a dark chip, the chips do not touch each other and the strongbox chip stays clear of its icon',
   run:function(){
     var g, bad=[], os=MAPFIRST.skip, ow=W, oh=H, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, oFR=proto.fillRect, chips, n, z, ent, sb, i, j, c, d, gx, gy;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); MAPFIRST.skip=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||g.over) return 'SKIP: no raid';
       P.contracts=[{type:'kill',tgt:'crawler',n:5,prog:3,reward:4321,desc:'Destroy 5 crawlers',tier:'std'},{type:'open',ct:'crate',n:4,prog:4,reward:777,desc:'Search 4 crates',tier:'std'},{type:'conduct',ck:'clean',n:1,prog:0,reward:1234,desc:'Extract without using a single heal',tier:'std'}];
       g.mapOpen=true; g.bagOpen=false; g.paused=false; keys={}; mouse.down=false; g.mapFirst=0; g.intel=1;
       sb=g.containers.filter(function(v){ return v.strong&&!v.opened; })[0];
       if(!sb) return 'staging: no strongbox';
       for(n=0;n<2;n++){
         W=n?3840:1920; H=n?2160:1080; z=Math.max(1,hudRes()); chips=[];
         proto.fillRect=function(x,y,w,h){ if(/^rgba\(11, ?12, ?13, ?0?\.6\)$/.test(String(this.fillStyle))) chips.push({l:x,r:x+w,tp:y,bt:y+h}); return oFR.apply(this,arguments); };
         try{ ent=txRecord(function(){ drawMapOverlay(); }); } finally { proto.fillRect=oFR; }
         var m=mapProj(), tag='z'+z;
         var bx=ent.filter(function(h){ var b=txBox(h), cx=b.x+b.w/2, cy=b.y+b.h/2; return cx>m.ox&&cx<m.ox+WORLD_W*m.sc&&cy>m.oy&&cy<m.oy+WORLD_H*m.sc; });
         if(bx.length<20) bad.push(tag+': only '+bx.length+' labels drawn');
         if(chips.length<bx.length-2) bad.push(tag+': '+chips.length+' chips for '+bx.length+' labels');
         for(i=0;i<chips.length;i++) for(j=i+1;j<chips.length;j++){ c=chips[i]; d=chips[j]; gx=Math.max(c.l-d.r,d.l-c.r); gy=Math.max(c.tp-d.bt,d.tp-c.bt); if(gx<0&&gy<0){ bad.push(tag+': two chips overlap'); i=chips.length; break; } }
         var ix=m.ox+sb.x*m.sc, iy=m.oy+sb.y*m.sc, r=15*z;
         chips.forEach(function(k){ if(k.r>ix-r&&k.l<ix+r&&k.bt>iy-r&&k.tp<iy+r) bad.push(tag+': a chip sits on the strongbox icon'); });
       }
       return bad.length?bad.filter(function(s,k,a){ return a.indexOf(s)===k; }).join('; '):null;
     }finally{
       proto.fillText=oFT; proto.fillRect=oFR; W=ow; H=oh; MAPFIRST.skip=os;
       try{ if(g){ g.mapFirst=0; g.mapOpen=false; } __endRaid('abandon'); }catch(e){} __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'36.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

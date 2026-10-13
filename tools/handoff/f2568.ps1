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

if ($s.Contains("  {v:'25.68',what:")) { throw "check 25.68 is in the fixture already" }

SubRx @'
  {v:'25.67',what:
'@ @'
  {v:'25.68',what:'his order (the scavenging noise less repetitive): 20 s of searching never plays the same clip twice in a row nor the same settings, uses at least 3 clips, keeps every gap between 0.2 and 1.7 s, digs every third to fifth hit, and plays nothing under G.sim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof foley!=='function'||typeof searchFoley!=='function') return 'SKIP: no raid or foley here';
     if(typeof searchTick!=='function'||typeof SRCHFX!=='object') return 'the search sound has no varied rhythm (no searchTick): it repeats one clip on a fixed beat';
     var bad=[], rec=[], kFoley=foley, kSim=null, g=null, T=0, i, j, k, c, ct, tys=['locker','body','crate'], roles, gaps, dg, minG, maxG, dgap, sameSet;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over) return 'SKIP: no live raid';
       kSim=g.sim; g.sim=false;
       foley=function(r,x,y,o){ rec.push({r:r,t:T,o:o||{}}); return false; };
       for(k=0;k<tys.length;k++){
         ct={type:tys[k]}; rec.length=0; SRCHFX.t=0; SRCHFX.last=''; SRCHFX.n=0; SRCHFX.dig=4; SRCHFX.hit=0; T=0;
         searchFoley(ct,'rummage');
         for(i=1;i<=400;i++){ T=i*0.05; searchTick(ct,0.05); }
         c=rec.slice();
         if(c.length<30||c.length>90){ bad.push(tys[k]+': 20 s of searching made '+c.length+' hits'); continue; }
         roles={}; minG=9; maxG=0; dg=[]; dgap=0;
         for(j=0;j<c.length;j++){
           roles[c[j].r]=1;
           if(j>0){
             if(c[j].r===c[j-1].r) bad.push(tys[k]+': hit '+j+' plays '+c[j].r+' twice in a row');
             sameSet=(c[j].o.rate===c[j-1].o.rate&&c[j].o.g===c[j-1].o.g&&c[j].o.off===c[j-1].o.off);
             if(sameSet) bad.push(tys[k]+': hit '+j+' repeats the settings of the one before');
             minG=Math.min(minG,c[j].t-c[j-1].t); maxG=Math.max(maxG,c[j].t-c[j-1].t);
           }
           if(c[j].o.dig){ if(dg.length) { dgap=j-dg[dg.length-1]; if(dgap<3||dgap>5) bad.push(tys[k]+': digs are '+dgap+' hits apart, not 3 to 5'); } dg.push(j); }
         }
         if(Object.keys(roles).length<3) bad.push(tys[k]+': only '+Object.keys(roles).length+' distinct clip(s) in 20 s');
         if(minG<0.2-1e-9) bad.push(tys[k]+': a gap of '+minG.toFixed(2)+' s, under 0.25');
         if(maxG>1.7) bad.push(tys[k]+': a gap of '+maxG.toFixed(2)+' s');
         if(!dg.length) bad.push(tys[k]+': no dig in 20 s');
       }
       g.sim=true; rec.length=0; SRCHFX.t=0; searchFoley({type:'locker'},'rummage'); for(i=0;i<40;i++) searchTick({type:'locker'},0.05); g.sim=false;
       if(rec.length) bad.push('a search under G.sim played '+rec.length+' sounds');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ foley=kFoley; }catch(_f){}
       try{ if(g&&kSim!==null) g.sim=kSim; SRCHFX.t=0; SRCHFX.last=''; SRCHFX.n=0; SRCHFX.hit=0; SRCHFX.dig=4; }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,6).join('; '):null; }},
  {v:'25.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

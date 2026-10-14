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

if ($s.Contains("  {v:'26.15',what:")) { throw "check 26.15 is in the fixture already" }

SubRx @'
  {v:'26.14',what:
'@ @'
  {v:'26.15',what:'his words (the search sound repeats from one crate to the next): containers searched in a row never open on the same clip, a locker lets out a metal clip and a body a cloth clip in its first four hits, every container keeps one base pitch of its own within 10 percent, and nothing plays under G.sim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof foley!=='function'||typeof searchFoley!=='function') return 'SKIP: no raid or foley here';
     if(typeof searchTick!=='function'||typeof SRCHFX!=='object') return 'the search sound has no rhythm (no searchTick)';
     var bad=[], rec=[], kFoley=foley, kSim=null, g=null, T=0, i, j, r, k, c, q, seq=[], prs=[], uniq={}, p0, p1,
       cts=[{type:'crate',x:612,y:845},{type:'locker',x:1830,y:1210},{type:'body',x:2475,y:640},{type:'cache',x:930,y:1920}],
       metalC=['plateClack','boltLatch'], clothC=['strapRip','bandageTear'];
     function inList(h,L){ return h.some(function(x){ return L.indexOf(x)>=0; }); }
     function go(c0,tag){
       var h, w;
       rec.length=0; SRCHFX.t=0; T=0;
       searchFoley(c0,'rummage');
       for(w=1;w<=600&&rec.length<4;w++){ T=w*0.05; searchTick(c0,0.05); }
       h=rec.map(function(x){ return x.r; });
       seq.push({tag:tag,ty:c0.type,h:h});
       return h;
     }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over) return 'SKIP: no live raid';
       kSim=g.sim; g.sim=false;
       foley=function(rl,x,y,o){ rec.push({r:rl,t:T,o:o||{}}); return false; };
       for(r=0;r<3;r++) for(k=0;k<cts.length;k++) go(cts[k],cts[k].type+' '+(r*4+k));
       go(cts[0],'the same crate again'); go(cts[0],'the same crate a third time');
       for(j=0;j<seq.length;j++){
         c=seq[j].h;
         if(c.length<4){ bad.push(seq[j].tag+' made '+c.length+' hits'); continue; }
         if(j>0&&seq[j-1].h[0]===c[0]) bad.push(seq[j].tag+' opens on '+c[0]+', the same as the search before it');
         if(seq[j].ty==='locker'&&!inList(c,metalC)) bad.push(seq[j].tag+' ('+c.join(',')+') has no metal clip in its first four hits');
         if(seq[j].ty==='body'&&!inList(c,clothC)) bad.push(seq[j].tag+' ('+c.join(',')+') has no cloth clip in its first four hits');
       }
       for(q=0;q<5;q++){ searchFoley({type:'crate',x:300+q*517,y:200+q*389},'rummage'); prs.push(SRCHFX.pr); }
       prs.forEach(function(v){ uniq[v]=1; });
       if(prs.some(function(v){ return !(v>=0.9-1e-9&&v<=1.1+1e-9); })) bad.push('a container base pitch is not within 10 percent either way ('+prs.join(',')+')');
       else if(Object.keys(uniq).length<3) bad.push('five crates in five places share only '+Object.keys(uniq).length+' base pitches');
       searchFoley(cts[0],'rummage'); p0=SRCHFX.pr; searchFoley(cts[0],'rummage'); p1=SRCHFX.pr;
       if(p0!==p1||!(p0>0)) bad.push('the same crate has a different base pitch from one search to the next ('+p0+', '+p1+')');
       g.sim=true; rec.length=0; SRCHFX.t=0; searchFoley(cts[1],'rummage'); for(i=0;i<40;i++) searchTick(cts[1],0.05); g.sim=false;
       if(rec.length) bad.push('a search under G.sim played '+rec.length+' sounds');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ foley=kFoley; }catch(_f){}
       try{ if(g&&kSim!==null) g.sim=kSim; SRCHFX.t=0; SRCHFX.last=''; SRCHFX.n=0; SRCHFX.hit=0; SRCHFX.dig=4; SRCHFX.open=''; }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,6).join('; '):null; }},
  {v:'26.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

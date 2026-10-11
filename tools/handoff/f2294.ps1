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

if ($s.Contains("  {v:'22.94',what:")) { throw "check 22.94 is in the fixture already" }

SubRx @'
  {v:'22.93',what:
'@ @'
  {v:'22.94',what:'co-op marks and the Crier marker grow at 4K: at 3840x2160 a teammate ping label and the CRIER countdown are drawn at least 1.9 times their 1080p font size, the ping distance ends in a small m, and no CRIER countdown is drawn over the open backpack',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace)||typeof netPingDraw!=='function'||typeof drawCrierMarkers!=='function'||typeof mkSnitch!=='function'||typeof hudRes!=='function') return 'SKIP: no pings or Crier marker here';
     var bad=[], g=null, p=null, W0=W, H0=H, keep={on:NET.on,seat:NET.seat,pings:NET.pings,roster:NET.roster,wps:NET.wps}, c, a, b, bag=0, CR='CRI'+'ER ';
     function grab(w,h){
       var out={ping:0,lbl:'',crier:0}, tr, i, t;
       W=w; H=h;
       NET.pings=[{s:1,x:p.x+300,y:p.y+40,at:Date.now()}]; NET.wps={};
       tr=__textTrace(function(){ ctx.save(); ctx.setTransform(1,0,0,1,0,0); try{ netPingDraw(); drawCrierMarkers(); } finally { ctx.restore(); } });
       for(i=0;i<tr.length;i++){ t=tr[i].t; if(t.indexOf('ZQX PINGER')===0&&!out.ping){ out.ping=tr[i].px; out.lbl=t; } if(t.indexOf(CR)===0&&!out.crier) out.crier=tr[i].px; }
       return out;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; g.bagOpen=false; g.mapOpen=false;
       NET.on=true; NET.seat=0; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'ZQX PINGER'}];
       c=mkSnitch(p.x+120,p.y); c.state='alarm'; c.wind=3; c.lost=0; c.markX=p.x; c.markY=p.y;
       g.ents.length=0; g.ents.push(c);
       a=grab(1920,1080);
       b=grab(3840,2160);
       if(!a.ping||!b.ping) return 'SKIP: staging: the ping label was not drawn';
       if(!a.crier||!b.crier) return 'SKIP: staging: the Crier countdown was not drawn';
       if(b.ping<a.ping*1.9) bad.push('at 4K the ping label is '+b.ping.toFixed(1)+' px against '+a.ping.toFixed(1)+' px at 1080p');
       if(b.crier<a.crier*1.9) bad.push('at 4K the CRIER countdown is '+b.crier.toFixed(1)+' px against '+a.crier.toFixed(1)+' px at 1080p');
       if(!(/\d+m$/).test(a.lbl)) bad.push('the ping distance reads '+a.lbl+', not a small m');
       W=W0; H=H0; g.bagOpen=true;
       var tr2=__textTrace(function(){ ctx.save(); ctx.setTransform(1,0,0,1,0,0); try{ drawCrierMarkers(); } finally { ctx.restore(); } });
       for(var j=0;j<tr2.length;j++) if(tr2[j].t.indexOf(CR)===0) bag++;
       if(bag) bad.push('the CRIER countdown was drawn over the open backpack');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       W=W0; H=H0;
       for(var k in keep) NET[k]=keep[k];
       try{ var g2=__state(); if(g2){ g2.bagOpen=false; g2.ents.length=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

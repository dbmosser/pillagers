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

if ($s.Contains("  {v:'17.29',what:")) { throw "check 17.29 is in the fixture already" }

SubRx @'
  {v:'17.28',what:
'@ @'
  {v:'17.29',what:'a smoke or a decoy player 2 throws reaches the host: his window tells the host, the host puts the cloud in the sight lines its enemies use, the decoy calls a patrolling enemy over, both are passed on to the other window and not back, a decoy passed on for drawing calls nothing, and the blast of his frag is heard on the host',
   run:function(){
     if(typeof activateThrow!=='function'||typeof updateThrowables!=='function'||typeof explodeFrag!=='function'||typeof netEntsPeer!=='function'||typeof netOnMsg!=='function'||typeof refreshVseg!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no party throwables';
     var keep={}, k, oSend=netSend, sent=[], bad=[], g=null, p, e=null, c, i, r, n0, e0, fx,
         ha={state:'in',seat:0}, pa={state:'in',seat:1}, pb={state:'in',seat:2};
     function sends(t,kk,q){ return sent.filter(function(s){ return s.m&&s.m.t===t&&s.m.k===kk&&(!q||s.q===q); }).length; }
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       NET.fxQ=[];
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=G;
       if(!g||!g.player||!g.smokes||!g.decoys||!g.ents||!g.map) return 'SKIP: staging: no live raid';
       p=g.player;
       for(i=0;i<g.ents.length;i++){ c=g.ents[i]; if((c.kind==='sentry'||c.kind==='crawler')&&!c.downed&&!c.neutral&&!c.finished){ e=c; break; } }
       if(!e) return 'SKIP: staging: no sentry or crawler on the map';
       netSend=function(q,m){ sent.push({q:q,m:m}); return true; };
       NET.specG=null; NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[ha]; NET.up=[];
       if(!netEntsPeer()) return 'SKIP: staging: the window does not read as player 2 up top';
       activateThrow({kind:'smoke',tx:p.x+90,ty:p.y});
       activateThrow({kind:'decoy',tx:p.x+90,ty:p.y});
       if(!sends('thr','smoke')) bad.push('the player 2 window told the host nothing of its smoke');
       if(!sends('thr','decoy')) bad.push('the player 2 window told the host nothing of its decoy');
       sent.length=0; e0=g.ents; g.ents=[];
       fx=(p.x+1400<WORLD_W-40)?p.x+1400:p.x-1400;
       try{ explodeFrag({x:fx,y:p.y,mine:1}); } finally { g.ents=e0; }
       if(!sends('thr','nz')) bad.push('the blast of a frag player 2 threw was not told to the host');
       sent.length=0; g.smokes.length=0; g.decoys.length=0; g.throws.length=0;
       NET.role='host'; NET.seat=0; NET.peers=[pa,pb];
       refreshVseg(); n0=g.map.segs.length;
       r=netOnMsg(pa,JSON.stringify({t:'thr',k:'smoke',x:Math.round(p.x+90),y:Math.round(p.y)}));
       refreshVseg();
       if(g.smokes.length!==1) bad.push('the host did not put the smoke player 2 threw in its world ('+r+')');
       else if((g.vseg||[]).length!==n0+8) bad.push('the smoke player 2 threw is not in the sight lines the host enemies use ('+(g.vseg||[]).length+' lines against '+n0+' map lines)');
       if(!sends('thr','smoke',pb)) bad.push('the host did not pass the smoke on to the other window');
       if(sends('thr','smoke',pa)) bad.push('the host sent player 2 his own smoke back');
       e.state='patrol'; e.alert=0;
       r=netOnMsg(pa,JSON.stringify({t:'thr',k:'decoy',x:Math.round(e.x+10),y:Math.round(e.y)}));
       updateThrowables(0.15);
       if(e.state!=='investigate') bad.push('a decoy player 2 threw beside a patrolling '+e.kind+' did not call it over on the host ('+r+', '+e.state+')');
       if(!sends('thr','decoy',pb)) bad.push('the host did not pass the decoy on to the other window');
       e.state='patrol'; e.alert=0;
       r=netOnMsg(pa,JSON.stringify({t:'thr',k:'nz',x:Math.round(e.x),y:Math.round(e.y)}));
       if(e.state!=='investigate') bad.push('the blast of a frag player 2 threw beside a patrolling '+e.kind+' was not heard on the host ('+r+')');
       g.decoys.length=0; g.smokes.length=0; e.state='patrol'; e.alert=0;
       NET.role='join'; NET.seat=1; NET.peers=[ha];
       r=netOnMsg(ha,JSON.stringify({t:'thr',k:'decoy',x:Math.round(e.x+10),y:Math.round(e.y)}));
       if(g.decoys.length!==1) bad.push('the player 2 window did not draw a decoy the host threw ('+r+')');
       updateThrowables(0.15);
       if(e.state!=='patrol') bad.push('a decoy passed on for drawing called the copy of a '+e.kind+' in the player 2 window');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       netSend=oSend;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ if(g&&g===G&&!g.over) __endRaid('abandon'); __topClear(); }catch(e2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

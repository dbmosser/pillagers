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

if ($s.Contains("  {v:'17.36',what:")) { throw "check 17.36 is in the fixture already" }

SubRx @'
  {v:'17.35',what:
'@ @'
  {v:'17.36',what:'a wall broken in a shared raid falls in every window: the player 2 window asks the host instead of breaking its own copy, the host breaks it and tells every window, a wall the host breaks itself is told too, and the player 2 window takes a wall the host names by its build number out of its map and its sight lines',
   run:function(){
     if(typeof damageWall!=='function'||typeof wallHp!=='function'||typeof netEntsPeer!=='function'||typeof netOnMsg!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no party walls';
     var keep={}, k, oSend=netSend, sent=[], bad=[], g=null, W, L=[], i, w, r, n0,
         ha={state:'in',seat:0}, pa={state:'in',seat:1}, pb={state:'in',seat:2};
     function sends(t,q){ return sent.filter(function(s){ return s.m&&s.m.t===t&&(!q||s.q===q); }); }
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=G;
       if(!g||!g.map||!g.map.walls||g.over) return 'SKIP: staging: no live raid';
       if(CFG.destruct===0) return 'SKIP: staging: destruction is off';
       W=g.map.walls;
       for(i=0;i<W.length&&L.length<3;i++) if(W[i].furn&&!W[i].win&&wallHp(W[i])!==null) L.push(W[i]);
       if(L.length<3) return 'SKIP: staging: fewer than three pieces of furniture on the map';
       if(L[0].wid===undefined||L[0].wid===L[1].wid) bad.push('walls carry no build number a party could name them by');
       netSend=function(q,m){ sent.push({q:q,m:m}); return true; };
       NET.specG=null; NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[ha]; NET.up=[];
       if(!netEntsPeer()) return 'SKIP: staging: the window does not read as player 2 up top';
       w=L[0]; damageWall(w,5000,w.x+w.w/2,w.y+w.h/2);
       if(W.indexOf(w)<0) bad.push('the player 2 window broke its own copy of a piece of furniture');
       r=sends('wdmg');
       if(!r.length||r[0].m.id!==w.wid||r[0].q!==ha) bad.push('the player 2 window did not ask the host to break the furniture it hit ('+r.length+' asks)');
       sent.length=0; NET.role='host'; NET.seat=0; NET.peers=[pa,pb];
       r=netOnMsg(pa,JSON.stringify({t:'wdmg',sd:g.seed>>>0,id:w.wid,a:5000}));
       if(W.indexOf(w)>=0) bad.push('the host did not break the furniture player 2 asked it to ('+r+')');
       if(!sends('wall',pa).length||!sends('wall',pb).length) bad.push('the host did not tell every window that the furniture player 2 hit fell');
       sent.length=0; w=L[1]; damageWall(w,5000,w.x+w.w/2,w.y+w.h/2);
       r=sends('wall');
       if(W.indexOf(w)>=0) bad.push('the host did not break its own furniture');
       else if(r.length!==2||r[0].m.id!==w.wid) bad.push('the party was not told of furniture the host broke itself ('+r.length+' words)');
       sent.length=0; NET.role='join'; NET.seat=1; NET.peers=[ha];
       w=L[2]; n0=g.map.segs.length;
       r=netOnMsg(ha,JSON.stringify({t:'wall',sd:g.seed>>>0,id:w.wid}));
       if(W.indexOf(w)>=0) bad.push('the player 2 window kept a wall the host said fell ('+r+')');
       else if(g.map.segs.length!==n0-4) bad.push('the player 2 window took the wall out but kept its sight lines ('+n0+' to '+g.map.segs.length+')');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       netSend=oSend;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ if(g&&g===G&&!g.over) __endRaid('abandon'); __topClear(); }catch(e2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

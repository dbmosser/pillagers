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

if ($s.Contains("  {v:'17.58',what:")) { throw "check 17.58 is in the fixture already" }

SubRx @'
  {v:'17.57',what:
'@ @'
  {v:'17.58',what:'drop-in: a late teammate is told the walls the host already has down and takes them down too, so it does not stand behind walls that are gone',
   run:function(){
     if(typeof netLateReply!=='function'||typeof netLateApply!=='function'||typeof netWallById!=='function') return 'SKIP: this build has no drop-in';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, sent=[], bad=[], oSend=netSend, oSay=say, peer={seat:1,state:'in'}, w, wid, n0, wl;
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player||!G.map.walls.length) return 'SKIP: staging: no raid';
       netSend=function(p,m){ sent.push(m); return true; };
       say=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer];
       netUpAnnounce(G);
       wl=G.map.walls[Math.floor(G.map.walls.length/2)]; wid=wl.wid;
       G.map.walls.splice(G.map.walls.indexOf(wl),1); rebuildGeometry();
       sent.length=0; netLateReply(peer);
       w=sent.filter(function(m){ return m&&m.t==='raid'; })[0];
       if(!w) bad.push('the host sent no raid word to a late teammate');
       else if(!w.wg||w.wg.indexOf(wid)<0) bad.push('the late word does not name the wall already down ('+JSON.stringify(w.wg)+')');
       __endRaid('abandon'); __topClear();
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       NET.role='join'; NET.seat=1; netEntsInit(G);
       n0=G.map.walls.length;
       if(!netWallById(wid)) return 'SKIP: staging: the fresh build has no wall '+wid;
       netLateApply({late:{t:50,left:300,x:Math.round(G.player.x),y:Math.round(G.player.y)},gone:[],wg:[wid]});
       if(netWallById(wid)) bad.push('the wall the host had down still stands in the late window');
       if(G.map.walls.length!==n0-1) bad.push('the late window took down '+(n0-G.map.walls.length)+' walls, not one');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; say=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

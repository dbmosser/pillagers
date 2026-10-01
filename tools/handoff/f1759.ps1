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

if ($s.Contains("  {v:'17.59',what:")) { throw "check 17.59 is in the fixture already" }

SubRx @'
  {v:'17.58',what:
'@ @'
  {v:'17.59',what:'drop-in: a late teammate is sent the map markers already placed, the host own and any other teammate, and not its own',
   run:function(){
     if(typeof netLateReply!=='function'||typeof netWpTake!=='function') return 'SKIP: this build has no drop-in or no markers';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, sent=[], bad=[], oSend=netSend, oSay=say, peer={seat:1,state:'in'}, wp;
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       netSend=function(p,m){ sent.push(m); return true; };
       say=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer];
       netUpAnnounce(G);
       G.waypoint={x:1234,y:2345}; NET.wps={1:{x:5,y:6},2:{x:777,y:888}};
       sent.length=0; netLateReply(peer);
       wp=sent.filter(function(m){ return m&&m.t==='wp'; });
       if(!wp.some(function(m){ return m.s===undefined&&m.x===1234&&m.y===2345; })) bad.push('the late teammate was not sent the host map marker');
       if(!wp.some(function(m){ return m.s===2&&m.x===777&&m.y===888; })) bad.push('the late teammate was not sent another teammate map marker');
       if(wp.some(function(m){ return m.s===1; })) bad.push('the late teammate was sent its own marker back');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; say=oSay;
       try{ if(G) G.waypoint=null; }catch(_w){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

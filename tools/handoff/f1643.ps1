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

if ($s.Contains("  {v:'16.43',what:")) { throw "check 16.43 is in the fixture already" }

SubRx @'
  {v:'16.42',what:
'@ @'
  {v:'16.43',what:'ping: a ping reaches the party through the host with who made it, and snaps to an enemy near the cursor',
   run:function(){
     if(typeof netPingTake!=='function'||typeof netPingPush!=='function'||typeof netPingMake!=='function') return 'this build has no ping';
     var keep={role:NET.role,seat:NET.seat,peers:NET.peers,pings:NET.pings,roster:NET.roster}, oS=netSend, sent=[], bad=[], r;
     try{
       netSend=function(q,m){ sent.push(m); return true; };
       var P1={state:'in',seat:1}, P2={state:'in',seat:2};
       NET.role='host'; NET.seat=0; NET.peers=[P1,P2]; NET.pings=[]; NET.roster=[{seat:0,name:'KITE'},{seat:1,name:'MOSS'},{seat:2,name:'REED'}];
       r=netPingTake(P1,{t:'png',x:100,y:200,w:'CRAWLER',id:7});
       if(r!=='png'||!NET.pings.length||NET.pings[0].s!==1||NET.pings[0].w!=='CRAWLER') bad.push('the host did not keep the ping from seat 1 ('+r+', '+JSON.stringify(NET.pings[0])+')');
       if(sent.length!==1||sent[0].s!==1||sent[0].x!==100) bad.push('the host did not pass the ping to the other teammate only ('+JSON.stringify(sent)+')');
       NET.role='join'; NET.seat=2; NET.pings=[];
       r=netPingTake(P1,{t:'png',s:1,x:5,y:6,w:''});
       if(r!=='png'||NET.pings[0].s!==1) bad.push('a teammate did not keep a passed on ping');
       if(netPingTake(P1,{t:'png',s:2,x:5,y:6})!=='ignored') bad.push('a window kept its own ping passed back');
       if(netPingTake(P1,{t:'png',x:'a',y:6})!=='bad') bad.push('a ping with no place was kept');
     } finally { netSend=oS; NET.role=keep.role; NET.seat=keep.seat; NET.peers=keep.peers; NET.pings=keep.pings; NET.roster=keep.roster; }
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("if(code==='KeyN'&&G&&!G.over&&!repeat&&NET.on) netPingMake();")<0) bad.push('N does not ping');
     if(src.indexOf("if(_lbN&&_rbN&&(!PAD.prev[4]||!PAD.prev[5])&&G&&!G.over&&NET.on) netPingMake();")<0) bad.push('a controller cannot ping');
     return bad.length?bad.join('; '):null; }},
  {v:'16.42',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

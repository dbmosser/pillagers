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

if ($s.Contains("  {v:'16.46',what:")) { throw "check 16.46 is in the fixture already" }

SubRx @'
  {v:'16.45',what:
'@ @'
  {v:'16.46',what:'map markers reach the party through the host and clear; a danger ping replaces the plain one; D-UP pings and holds for the map',
   run:function(){
     if(typeof netWpTake!=='function'||typeof netWpSend!=='function') return 'this build shares no map marker';
     var keep={role:NET.role,seat:NET.seat,peers:NET.peers,wps:NET.wps,pings:NET.pings,roster:NET.roster}, oS=netSend, sent=[], bad=[], r;
     try{
       netSend=function(q,m){ sent.push(m); return true; };
       var P1={state:'in',seat:1}, P2={state:'in',seat:2};
       NET.role='host'; NET.seat=0; NET.peers=[P1,P2]; NET.wps={}; NET.pings=[]; NET.roster=[{seat:0,name:'KITE'},{seat:1,name:'MOSS'},{seat:2,name:'REED'}];
       r=netWpTake(P1,{t:'wp',x:300,y:400});
       if(r!=='wp'||!NET.wps[1]||NET.wps[1].x!==300) bad.push('the host did not keep the marker from seat 1 ('+r+')');
       if(sent.length!==1||sent[0].s!==1||sent[0].x!==300) bad.push('the host did not pass the marker on ('+JSON.stringify(sent)+')');
       r=netWpTake(P1,{t:'wp',clr:1});
       if(r!=='wp:clr'||NET.wps[1]) bad.push('a cleared marker stayed');
       netPingPush(1,{x:10,y:10,w:''}); netPingPush(1,{x:10,y:10,w:'',dg:1});
       if(NET.pings.length!==1||!NET.pings[0].dg) bad.push('a danger ping did not replace the plain one ('+JSON.stringify(NET.pings)+')');
     } finally { netSend=oS; NET.role=keep.role; NET.seat=keep.seat; NET.peers=keep.peers; NET.wps=keep.wps; NET.pings=keep.pings; NET.roster=keep.roster; }
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("if(G.mapOpen) G.mapOpen=false; else if(NET.on&&NET.upSeed) netPingMake(); else G.mapOpen=true;")<0) bad.push('D-UP does not ping');
     if(src.indexOf("if(_lbN&&_rbN&&(!PAD.prev[4]||!PAD.prev[5])&&G&&!G.over&&NET.on) netPingMake();")>=0) bad.push('both bumpers still ping');
     return bad.length?bad.join('; '):null; }},
  {v:'16.45',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

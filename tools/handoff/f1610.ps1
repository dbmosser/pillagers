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

if ($s.Contains("  {v:'16.10',what:")) { throw "check 16.10 is in the fixture already" }

SubRx @'
  {v:'16.09',what:
'@ @'
  {v:'16.10',what:'voices carry by distance up top: with both up top on the party seed a teammate at 60 is heard full, at 500 quieter, at 1,200 not at all; muted he is silent; with no raid in hand (the Undercroft) he is full again',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof voiceVol!=='function') return 'SKIP: this build has no voice';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, keepMute=P.netMute, p, peer, keepV=null, v;
     function at(d){ NET.up[1]={seat:1,x:p.x+d,y:p.y,f:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0}; voiceVol(peer); return peer.vGain.gain.value; }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); p=G.player; P.netMute={};
       keepV=G.map.segs; G.map.segs=[];
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.up=[];
       peer={state:'in',seat:1,pid:'zqxpid01',name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}},vGain:{gain:{value:1}}};
       NET.peers=[peer]; NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxpid01',name:'ZQX MATE'}];
       v=at(60); if(v!==1) bad.push('a teammate 60 away is heard at '+v+', not full');
       v=at(500); if(!(v>0&&v<0.6)) bad.push('a teammate 500 away is heard at '+v+', not quieter');
       v=at(1200); if(v!==0) bad.push('a teammate 1,200 away is heard at '+v+', not silent');
       P.netMute={zqxpid01:1}; v=at(60); if(v!==0) bad.push('a muted teammate beside him is heard at '+v);
       P.netMute={}; G.map.segs=keepV; keepV=null; G=null; voiceVol(peer);
       if(peer.vGain.gain.value!==1) bad.push('with no raid in hand a teammate is heard at '+peer.vGain.gain.value+', not full');
     }
     finally{
       try{ if(keepV&&G&&G.map) G.map.segs=keepV; }catch(_s){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ P.netMute=keepMute; }catch(_pm){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.09',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

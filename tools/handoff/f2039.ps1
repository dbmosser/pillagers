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

if ($s.Contains("  {v:'20.39',what:")) { throw "check 20.39 is in the fixture already" }

SubRx @'
  {v:'20.38',what:
'@ @'
  {v:'20.39',what:'the hot ground is shared in co-op: the host sends where it is, a linked window moves its disc there and says so, and a box one of the party empties on it pays the two bonus items',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netSrchTick!=='function'||typeof netWorldSend!=='function'||typeof netWorldTake!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSend=netSend, oFast=netSendFast, oBc=netBroadcast, oSay=say, sent=[], fast=[], lines=[], g, i, A=null, a0, lw, H, x2, peer={seat:0,state:'in'};
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.hotZone) return 'SKIP: no live raid with hot ground';
       for(i=0;i<g.containers.length;i++){ var c=g.containers[i]; if(!c.opened&&!c.cache&&!c.dropped&&c.loot&&c.loot.length>=1){ A=c; break; } }
       if(!A) return 'SKIP: staging: no plain box';
       a0=A.loot.length;
       netSend=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSendFast=function(q,m){ fast.push(JSON.parse(JSON.stringify(m))); return true; };
       netBroadcast=function(){}; say=function(s){ lines.push(String(s)); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}]; NET.upSeed=g.seed>>>0;
       netContInit(g);
       H=g.hotZone; H.x=A.x; H.y=A.y;
       A.netBy=1; NET.holds={1:{cid:A.cid,slow:1}}; A.prog=(A.time||1)-0.0001;
       netSrchTick(0.01);
       lw=sent.filter(function(m){ return m.t==='loot'&&m.done; })[0];
       if(!lw) bad.push('the party search never finished ('+sent.length+' words)');
       else { if(!(lw.items.length>=a0+1)) bad.push('a box on the hot ground gave the party '+lw.items.length+' items for its '+a0); if(lw.hot!==1) bad.push('the word does not say hot ground'); }
       netWorldSend();
       if(!fast.length||!fast[0].hz||fast[0].hz[0]!==Math.round(H.x)) bad.push('the world word does not carry the hot ground ('+JSON.stringify(fast[0]&&fast[0].hz)+')');
       NET.role='join'; NET.seat=1; NET.peers=[peer]; lines=[];
       x2=Math.round(clamp(H.x>WORLD_W/2?H.x-1500:H.x+1500,H.r,WORLD_W-H.r));
       netWorldTake(peer,{t:'wd',sd:g.seed>>>0,hz:[x2,Math.round(H.y),(H.moves|0)+1]});
       if(Math.abs(H.x-x2)>1) bad.push('a linked window kept its own hot ground ('+Math.round(H.x)+', not '+x2+')');
       if(!lines.some(function(s){ return s.indexOf('hot ground has moved')>=0; })) bad.push('a linked window was not told the hot ground moved');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netSendFast=oFast; netBroadcast=oBc; say=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

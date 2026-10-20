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

if ($s.Contains("  {v:'32.97',what:")) { throw "check 32.97 is in the fixture already" }

SubRx @'
  {v:'32.96',what:
'@ @'
  {v:'32.97',what:'a drop pings the teammate: on a linked raid the item dropped by either window puts one pile ping on the other window (not on the dropper), taking the pile clears it, and a solo drop makes none',
   run:function(){
     if(typeof netPileShare!=='function'||typeof netPilePrune!=='function') return 'a dropped item sends the teammate no ping';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, keep={on:NET.on,role:NET.role,peers:NET.peers,seat:NET.seat,pings:NET.pings}, oH=netEntsHost, oP=netEntsPeer, oSend=netSend, sent=[], r, i, c, n0,
         p1={state:'in',seat:1,dc:{readyState:'open',send:function(){}}}, p2={state:'in',seat:2,dc:{readyState:'open',send:function(){}}};
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={};
       netSend=function(q,m){ sent.push({seat:q.seat,m:m}); return true; };
       // solo: nothing goes out and no ping appears
       NET.on=false; NET.role=null; NET.peers=[]; NET.pings=[];
       g.bag.push('frag'); dropItem(g.bag.lastIndexOf('frag'));
       if(sent.length||NET.pings.length) bad.push('a solo drop made a ping');
       // linked, the host drops: the one teammate gets one pile ping, the host none
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[p1]; NET.pings=[]; netEntsHost=function(){ return true; };
       sent=[]; g.bag.push('frag'); dropItem(g.bag.lastIndexOf('frag'));
       if(sent.length!==1||sent[0].seat!==1||sent[0].m.t!=='png'||!sent[0].m.pl||sent[0].m.s!==0) bad.push('the host drop did not send one pile ping to the teammate ('+JSON.stringify(sent)+')');
       if(NET.pings.length) bad.push('the dropper got a ping of its own drop');
       // linked, the teammate drops: the host keeps the ping and the pile
       NET.peers=[p1]; NET.pings=[]; sent=[]; n0=g.containers.length;
       r=netPileTake(p1,{t:'pile',k:'bandage',x:Math.round(g.player.x),y:Math.round(g.player.y)});
       if(r!=='pile'||g.containers.length!==n0+1) bad.push('the host refused the teammate pile ('+r+')');
       if(NET.pings.length!==1||!NET.pings[0].pl||NET.pings[0].s!==1) bad.push('the host got no pile ping from the teammate drop ('+JSON.stringify(NET.pings)+')');
       if(sent.length) bad.push('the pile ping went back to the dropper');
       // taking the pile clears the ping, leaving it standing keeps it
       if(NET.pings.length){ NET.pings[0].at-=2000; netPilePrune(); if(NET.pings.length!==1) bad.push('the ping cleared while its pile was still there'); }
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c.dropped){ c.opened=true; c.loot=[]; } }   // the earlier test piles lie at the same spot
       netPilePrune();
       if(NET.pings.length) bad.push('the ping stayed after the pile was taken');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ netSend=oSend; netEntsHost=oH; netEntsPeer=oP; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.seat=keep.seat; NET.pings=keep.pings; keys={}; try{ var g2=__state(); if(g2){ g2.over=false; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

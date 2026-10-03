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

if ($s.Contains("  {v:'18.27',what:")) { throw "check 18.27 is in the fixture already" }

SubRx @'
  {v:'18.26',what:
'@ @'
  {v:'18.27',what:'trading is dropping: on a linked window the drop sends a pile word to the host and makes no box of its own, the host makes a numbered pile at the spot with the item in it, the backpack drop function drops the selected stack, and the key lists teach Z (Y on a pad) for a teammate',
   run:function(){
     if(typeof bagDropSel!=='function'||typeof netPileTake!=='function') return 'trading is still offering';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, p, keep={on:NET.on,role:NET.role,peers:NET.peers,up:NET.up,roster:NET.roster,seat:NET.seat}, oSend=netSend, oPeer=netEntsPeer, oHost=netEntsHost, sent=[], n0, c, i, zRow=null, yRow=null, peer={state:'in',seat:0,dc:{readyState:'open',send:function(){}}}, peer1={state:'in',seat:1,dc:{readyState:'open',send:function(){}}};
     for(i=0;i<LEGEND.length;i++) if(LEGEND[i][0]==='TEAM') LEGEND[i][1].forEach(function(r){ if(r[0]==='Z') zRow=r; });
     for(i=0;i<LEGEND_PAD.length;i++) if(LEGEND_PAD[i][0]==='TEAM') LEGEND_PAD[i][1].forEach(function(r){ if(r[0]==='Y') yRow=r; });
     if(!zRow||!/drop/.test(String(zRow[1]))) bad.push('the key list TEAM section has no Z drop row');
     if(!yRow||!/drop/.test(String(yRow[1]))) bad.push('the pad list TEAM section has no Y drop row');
     try{
       netSend=function(q,m){ sent.push(m); return true; };
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['bandage','bandage'],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={};
       if(g.bag.indexOf('bandage')<0) g.bag.push('bandage','bandage');
       // 1. A LINKED WINDOW: the drop goes to the host as a word, and no box is made here.
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}]; netEntsPeer=function(){ return true; };
       n0=g.containers.length; g.bagOpen=true; g.bagSel=0;
       if(!bagDropSel()) bad.push('the linked window could not drop');
       if(g.containers.length!==n0) bad.push('the linked window made a box of its own');
       if(!sent.some(function(m){ return m&&m.t==='pile'&&m.k==='bandage'; })) bad.push('no pile word went to the host ('+JSON.stringify(sent).slice(0,80)+')');
       // 2. THE HOST: the word makes a numbered pile at the spot, holding the item.
       NET.role='host'; NET.seat=0; NET.peers=[peer1]; NET.up=[]; netEntsHost=function(){ return true; }; NET.contMap=NET.contMap||{}; if(typeof NET.contN!=='number') NET.contN=g.containers.length;
       n0=g.containers.length;
       if(netPileTake(peer1,{t:'pile',k:'bandage',x:Math.round(p.x)+40,y:Math.round(p.y)})!=='pile') bad.push('the host refused the pile word');
       c=g.containers[g.containers.length-1];
       if(g.containers.length!==n0+1||!c||!c.dropped||!c.loot||c.loot[0]!=='bandage'||Math.abs(c.x-(p.x+40))>40) bad.push('the host made no pile with the item at the spot');
       // 3. SOLO: the drop function makes the pile here.
       NET.on=false; NET.role=null; n0=g.containers.length; g.bagOpen=true; g.bagSel=0;
       if(g.bag.indexOf('bandage')<0) g.bag.push('bandage');
       if(!bagDropSel()||g.containers.length!==n0+1) bad.push('the solo drop made no pile');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ netSend=oSend; netEntsPeer=oPeer; netEntsHost=oHost; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.up=keep.up; NET.roster=keep.roster; NET.seat=keep.seat; keys={}; try{ var g2=__state(); if(g2){ g2.bagOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

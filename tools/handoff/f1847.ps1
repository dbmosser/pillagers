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

if ($s.Contains("  {v:'18.47',what:")) { throw "check 18.47 is in the fixture already" }

SubRx @'
  {v:'18.46',what:
'@ @'
  {v:'18.47',what:'a drop is never lost on its way: the host makes a pile for a teammate while it spectates (its raid over, the world kept for the party), and a linked window with no host link makes the pile itself',
   run:function(){
     if(typeof netPileTake!=='function'||typeof dropItem!=='function') return 'SKIP: no drop trading here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, keep={on:NET.on,role:NET.role,peers:NET.peers,specG:NET.specG,seat:NET.seat}, oH=netEntsHost, oP=netEntsPeer, oSend=netSend, n0, r, peer1={state:'in',seat:1,dc:{readyState:'open',send:function(){}}};
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={};
       netSend=function(){ return true; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[peer1]; NET.up=NET.up||[]; netEntsHost=function(){ return true; };
       g.over=true; NET.specG=g; n0=g.containers.length;
       r=netPileTake(peer1,{t:'pile',k:'bandage',x:Math.round(g.player.x),y:Math.round(g.player.y)});
       if(r!=='pile'||g.containers.length!==n0+1) bad.push('the spectating host refused the pile ('+r+')');
       g.over=false; NET.specG=keep.specG;
       NET.role='join'; NET.seat=1; NET.peers=[]; netEntsPeer=function(){ return true; };
       g.bag.push('frag'); n0=g.containers.length;
       dropItem(g.bag.lastIndexOf('frag'));
       if(g.containers.length!==n0+1) bad.push('a linked window with no host link dropped the item into nowhere');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ netSend=oSend; netEntsHost=oH; netEntsPeer=oP; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.specG=keep.specG; NET.seat=keep.seat; keys={}; try{ var g2=__state(); if(g2){ g2.over=false; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

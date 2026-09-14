$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'13.96',what:
'@ @'
  {v:'13.97',what:'a pack call does not reset a crier alarm: a crawler calling the pack beside a crier with half a second of alarm left leaves it in alarm with the same wind, while a patrolling crier joins the call (machine and pillager AI audit 2026-09-14, finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof packCall!=='function') return 'SKIP: no pack call in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       var C=null, K=null, i;
       for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if(!C&&e.kind==='snitch'&&e.hp>0) C=e; if(!K&&e.kind==='crawler'&&e.hp>0) K=e; }
       if(!C||!K) return 'SKIP: this raid has no crier or no crawler to stage';
       g.ents.length=0; g.ents.push(K); g.ents.push(C);
       K.x=C.x+300; K.y=C.y; K.state='patrol';
       // CONTROL: a patrolling crier joins the call.
       C.state='patrol'; C.wind=0; C.lost=0;
       packCall(K,p.x,p.y);
       if(C.state!=='chase') return 'SKIP: a patrolling crier 300 units from the caller did not join the call, so nothing here can be measured';
       // THE FINDING: a crier with half a second of alarm left.
       C.state='alarm'; C.wind=0.5; C.lost=0; C.markX=p.x; C.markY=p.y;
       packCall(K,p.x,p.y);
       if(C.state!=='alarm') bad.push('a crawler calling the pack turned a crier with half a second of alarm left into '+C.state+', throwing its countdown away');
       else if(C.wind!==0.5) bad.push('the pack call changed the crier alarm wind from 0.5 to '+C.wind);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

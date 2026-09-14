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
  {v:'13.90',what:
'@ @'
  {v:'13.91',what:'what you buy at the stall is not loot you earned: a rifle bought with banked Credits does not complete a haul card worth the rifle, while the same rifle found in the raid does (contracts, notoriety and waves audit 2026-09-14, finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof pedBuy!=='function'||typeof contractExtract!=='function'||typeof bagValue!=='function'||!ITEMS.gun_rifle) return 'SKIP: no stall or contracts in this build';
     var bad=[], P2=__P(), keep={cr:P2.credits,ct:JSON.stringify(P2.contracts||[])};
     function card(){ return {type:'haul',v:ival('gun_rifle'),n:1,prog:0,reward:1,tier:'std',desc:'probe haul'}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player) return 'SKIP: no live raid';
       g.ents.length=0; g.hotAssign={}; g.hotAuto={}; g.player.downed=false;
       // THE FINDING: a rifle bought from the stall.
       g.bag=[]; g.carriedIn=0; g.carriedKit=[]; P2.credits=999999;
       g.trade={kind:'peddler',hp:100,x:g.player.x,y:g.player.y,stock:[{k:'gun_rifle',price:10,sold:false}]};
       var c1=card(); P2.contracts=[c1];
       pedBuy(0);
       if(g.bag.indexOf('gun_rifle')<0) return 'SKIP: the stall did not put the rifle in the backpack';
       contractExtract(g.bag,bagValue());
       if((c1.prog||0)>0) bad.push('a rifle bought with banked Credits completed a haul card worth the rifle');
       // CONTROL: the same rifle found in the raid completes it.
       g.trade=null; g.bag=['gun_rifle']; g.carriedIn=0; g.carriedKit=[];
       var c2=card(); P2.contracts=[c2];
       contractExtract(g.bag,bagValue());
       if(!((c2.prog||0)>0)) bad.push('control: the same rifle found in the raid did not complete the haul card, so this check cannot see a completion');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.credits=keep.cr; P2.contracts=JSON.parse(keep.ct); saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2){ g2.trade=null; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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
  {v:'13.42',what:'out of a consumable
'@ @'
  {v:'13.43',what:'a fresh profile starts on Few machines and Few pillagers, and a COLD STORAGE raid by day holds no more crawlers than Few names and no more than 5 pillagers, while putting the old house floor back raises the crawlers (his rulings of 2026-09-13)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof GAMEOPTS==='undefined'||typeof applyGameOpts!=='function'||typeof gameOptLive!=='function') return 'SKIP: no Settings rows in this build';
     var bad=[], P2=__P(), keepGO=JSON.stringify(P2.gameOpts||{}), keepT=JSON.stringify(P2.tuned||{}), keepCond=P2.cond;
     function rowN(k){ for(var i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k===k){ var ix=gameOptLive(k); return ix<0?'CUSTOM':GAMEOPTS[i].opts[ix].n; } return null; }
     function count(){ var g=__state(), o={crawler:0,raider:0}; for(var i=0;i<g.ents.length;i++){ var k=g.ents[i].kind; if(o[k]!==undefined) o[k]++; } return o; }
     function fresh(){ __topClear(); __cleanProfile(); __resetCfg(); P2.gameOpts={}; P2.tuned={}; P2.cond='day'; applyGameOpts(); }
     try{
       fresh();
       if(rowN('robots')!=='Few') bad.push('a fresh profile shows Machines '+rowN('robots')+', not Few');
       if(rowN('raiders')!=='Few') bad.push('a fresh profile shows Pillagers '+rowN('raiders')+', not Few');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var A=count();
       try{ __endRaid('abandon'); }catch(_a){}
       if(A.crawler>20) bad.push('a fresh profile on COLD STORAGE by day built '+A.crawler+' crawlers against a Few count of 20');
       if(A.raider>5) bad.push('a fresh profile on COLD STORAGE built '+A.raider+' pillagers against a Few count of 5');
       // CONTROL: the old Few floor of 1.5 a house must build more, or the zero above is not the floor.
       fresh(); CFG.crawlerPerHouse=1.5;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var B=count();
       try{ __endRaid('abandon'); }catch(_b){}
       if(!(B.crawler>A.crawler)) bad.push('control: the old house floor built '+B.crawler+' crawlers, not more than '+A.crawler+', so this check cannot see the floor');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ P2.gameOpts=JSON.parse(keepGO); P2.tuned=JSON.parse(keepT); P2.cond=keepCond; applyGameOpts(); }catch(_r){}
       __resetCfg(); __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.42',what:'out of a consumable
'@
SubRx @'
       if(CFG.crawlerPerHouse!==1.5) bad.push('a fresh profile floors crawlers at '+CFG.crawlerPerHouse+' a house, not the 1.5 that Machines Few carries, so the row only moves half the machines');
'@ @'
       if(CFG.crawlerPerHouse!==0) bad.push('a fresh profile floors crawlers at '+CFG.crawlerPerHouse+' a house; since v13.43 Machines Few carries 0, so Few means the count it names');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

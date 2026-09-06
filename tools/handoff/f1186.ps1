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

# v11.86 CHECK, inserted before the v11.85 entry. A survivor is staged (the
# map's own if it has one, else one built by mkStray), handed his bandage
# through the real strayGive, and the pay, the gift and the card are read.
SubRx @'
  {v:'11.85',what:'the map names each extraction at 18px or more and counts down to its close at 15px or more, one row each above the ring, instead of both in the smallest face the game has (his note of 2026-09-06)',
'@ @'
  {v:'11.86',what:'meeting the survivor request pays 900 or more, puts a piece of salvage in your hands at once, and the card names the gift without saying already banked (his notes of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__P)) return 'SKIP: this fixture cannot deploy and read the card';
     if(typeof strayGive!=='function'||typeof mkStray!=='function') return 'SKIP: no survivor in this build';
     var bad=[], banked='already '+'banked', paidLine='The survivor '+'paid you';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, P=__P(), e=null, i;
       for(i=0;i<g.ents.length&&!e;i++) if(g.ents[i].kind==='stray'&&!g.ents[i].downed) e=g.ents[i];
       if(!e){ e=mkStray(p.x+40,p.y); g.ents.push(e); }
       e.want='bandage'; e.helped=0; e.hostile=false; e.downed=false;
       g.bag=['bandage']; p.reserve=0;
       var c0=P.credits||0;
       strayGive(e);
       if(!e.helped) bad.push('control: the survivor was not helped (bag '+g.bag.join(',')+')');
       var paid=(P.credits||0)-c0;
       if(paid<900) bad.push('the survivor paid '+paid+', under 900');
       if(!g.strayGave) bad.push('the survivor gave nothing on the spot');
       else if(g.bag.indexOf(g.strayGave)<0&&!g.containers.some(function(c){ return c.loot&&c.loot.indexOf(g.strayGave)>=0&&Math.hypot(c.x-e.x,c.y-e.y)<60; })) bad.push('the gift '+g.strayGave+' is neither in the bag nor at his feet');
       p.downed=false; __endRaid('extract');
       var txt=''; try{ txt=((document.getElementById('outcome')||{}).innerText||'').replace(/\s+/g,' '); }catch(_t){}
       if(txt.indexOf(paidLine)<0) bad.push('control: the card has no survivor line (card says: '+txt.slice(0,80)+')');
       if(txt.indexOf(banked)>=0) bad.push('the card still says '+banked);
       if(g.strayGave&&txt.indexOf('gave you a')<0) bad.push('the card does not name the gift');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.85',what:'the map names each extraction at 18px or more and counts down to its close at 15px or more, one row each above the ring, instead of both in the smallest face the game has (his note of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

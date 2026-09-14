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
  {v:'13.56',what:
'@ @'
  {v:'13.57',what:'the XP printed on the outcome card equals the XP banked even when the distance walked sits on a rounding edge, and at a round distance it always did (end-of-raid audit 2026-09-14, finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(typeof xpBaseFor!=='function') return 'SKIP: no XP formula in this build';
     var man=document.getElementById('oc_manifest');
     if(!man) return 'SKIP: no outcome card in this page';
     var bad=[], P2=__P(), keepXp=P2.xp;
     function rec(d){ return {outcome:'extract',haul:0,carriedIn:0,containers:0,kills:{},termPay:0,doorsOpened:0,caches:0,dist:d,night:0,wxHard:0}; }
     // FIND AN EDGE: a fractional distance whose XP differs from its rounded neighbour's.
     var EDGE=null, d;
     for(d=0.5;d<20000&&EDGE===null;d+=0.5){ var fr=d+0.4; if(xpBaseFor(rec(fr))!==xpBaseFor(rec(Math.round(fr)))) EDGE=fr; }
     if(EDGE===null) return 'SKIP: no distance under 20000 gives different XP raw and rounded, so there is no edge to stage';
     function run(dist){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.tel) return null;
       g.ents.length=0; g.player.downed=false; g.bag=[]; g.carriedIn=0;
       g.tel.distance=dist;
       var x0=P2.xp||0;
       __endRaid('extract');
       var m=/\+([\d,]+) XP/.exec(man.textContent||'');
       try{ __topClear(); }catch(_t){}
       var banked=(P2.xp||0)-x0;
       return {card:m?Number(m[1].replace(/,/g,'')):null, banked:banked};
     }
     try{
       var R=run(Math.round(EDGE)+0);
       if(R===null) return 'SKIP: no live raid to extract from';
       if(R.card===null) return 'SKIP: the outcome card printed no XP line to read';
       if(R.banked<=0) return 'SKIP: this path banked no XP to compare against';
       // CONTROL: a round distance, card and bank already agree.
       if(R.card!==R.banked) bad.push('control: at a round distance the card printed '+R.card+' XP and the profile banked '+R.banked+', so this check is not reading the same two numbers');
       var E=run(EDGE);
       if(E&&E.card!==null&&E.card!==E.banked) bad.push('at '+EDGE+' units walked the card printed +'+E.card+' XP while the profile banked '+E.banked);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.xp=keepXp; saveProfile(); }catch(_x){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

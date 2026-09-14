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
  {v:'13.52',what:
'@ @'
  {v:'13.53',what:'hazard pay is paid only on what the run brought home: extracting with a valuable item carried up from the stash pays no hazard bonus on it, while the same item found in the raid still pays the full Terms rate (end-of-raid audit 2026-09-14, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(typeof termsPay!=='function'||typeof ival!=='function') return 'SKIP: no Terms pay or item value in this build';
     var ITEM=null, k;
     for(k in ITEMS){ if(ITEMS[k]&&ITEMS[k].val>=600&&ITEMS[k].use!=='gun'&&ITEMS[k].use!=='key'){ ITEM=k; break; } }
     if(!ITEM) return 'SKIP: no item worth enough to measure hazard pay on';
     var VAL=ival(ITEM);
     if(!(VAL>0)) return 'SKIP: that item values at nothing';
     var bad=[], P2=__P(), keepTP=termsPay, keepCr=P2.credits, RATE=0.5;
     function run(carriedUp){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g) return null;
       g.ents.length=0; g.player.downed=false; g.pedCarry=0;
       g.bag=[ITEM]; g.carriedIn=carriedUp?VAL:0;
       termsPay=function(){ return RATE; };
       P2.credits=10000;
       __endRaid('extract');
       termsPay=keepTP;
       return (P2.credits||0)-10000;
     }
     try{
       var up=run(true), found=run(false);
       if(up===null||found===null) return 'SKIP: no live raid to extract from';
       var want=Math.round(VAL*RATE);
       // CONTROL: found in the raid, the full Terms rate is paid on it.
       if(found<want) bad.push('control: '+VAL+' worth found in the raid paid '+found+' on extraction, not the '+want+' the Terms rate owes, so this check is not seeing hazard pay');
       // THE FINDING: carried up from the stash, it earns nothing extra.
       if(up>=want) bad.push('extracting with '+VAL+' worth of his own stash carried up the lift paid '+up+' in credits, the hazard bonus on loot the run never found');
       else if(found-up<want-1) bad.push('the hazard bonus on the found item and the carried item differ by only '+(found-up)+', not the '+want+' the rate owes');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ termsPay=keepTP; }catch(_t){}
       try{ P2.credits=keepCr; }catch(_c0){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

# v12.65 CHECK, inserted before the v12.64 entry. It runs the real extraction
# accounting for the contract board, with the card staged by hand so the
# threshold is a number this check chose and not one a roll happened to give it.
# The two arms are the same value arriving two different ways: carried up from
# his own stash, and found in the raid. Only the second is a haul.
SubRx @'
  {v:'12.64',what:'the buy button says how short he is even when he cannot afford one unit, which is the commonest refusal at the counter and the only one it used to answer with a dead grey button and no words; the partly affordable case still says it, an affordable order does not, and a row locked for a reason that is not money keeps its own words (2026-09-08 audit, my defect from v8.18)',
'@ @'
  {v:'12.65',what:'a haul contract counts what the run brought back and not what the lift carried up: staging an expensive gun out of his own stash and walking straight out no longer finishes it, while the same value found in the raid still does (2026-09-08 audit)',
   run:function(){
     if(!(window.__P&&window.__state&&window.__deploy&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof contractExtract!=='function'||typeof ival!=='function') return 'SKIP: this build has no contract extraction to drive';
     // A single item worth enough to clear the card on its own, taken off the
     // item table rather than named here.
     var ITEM=null, k;
     for(k in ITEMS){ if(ITEMS[k]&&ITEMS[k].val>=600&&ITEMS[k].use){ ITEM=k; break; } }
     if(!ITEM){ for(k in ITEMS){ if(ITEMS[k]&&ITEMS[k].val>=600){ ITEM=k; break; } } }
     if(!ITEM) return 'SKIP: no item in this build is worth enough to stage a haul card against';
     var VAL=ival(ITEM);
     if(!(VAL>0)) return 'SKIP: that item values at nothing, so a haul cannot be built from it';
     var bad=[], P2=__P(), keepC=(P2.contracts||[]).slice();
     function card(){ return {type:'haul',v:Math.max(1,Math.round(VAL*0.5)),n:1,prog:0,reward:100,desc:'haul card staged by check 12.65'}; }
     function run(carriedIn){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g) return null;
       var c=card();
       P2.contracts=[c];
       g.carriedIn=carriedIn?VAL:0;
       contractExtract([ITEM],VAL);
       return {prog:c.prog,need:c.v};
     }
     try{
       // THE FINDING: the value came up the lift with him, so the run earned none
       // of it and the card must not be satisfied.
       var A=run(true);
       if(!A) return 'SKIP: no live raid to extract from';
       if(A.prog>0)
         bad.push('a haul card asking for '+A.need+' was finished by carrying '+VAL+' worth of his own stash up the lift and walking straight back out: the run brought nothing home and the best-paying card on the board went ready anyway');
       // CONTROL: the same value, found in the raid rather than carried up. This
       // is what the card asks for and it must still be satisfied, or the build
       // has broken the card instead of the counting.
       var B=run(false);
       if(B&&B.prog<1)
         bad.push('control: '+VAL+' worth found in the raid no longer finishes a card asking for '+B.need+', so this build has broken the haul contract rather than what it counts');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.contracts=keepC; saveProfile(); }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.64',what:'the buy button says how short he is even when he cannot afford one unit, which is the commonest refusal at the counter and the only one it used to answer with a dead grey button and no words; the partly affordable case still says it, an affordable order does not, and a row locked for a reason that is not money keeps its own words (2026-09-08 audit, my defect from v8.18)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

# v12.69 CHECK, inserted before the v12.68 entry. The XP is measured as a
# DIFFERENCE between two records that are identical but for where the value came
# from, so whatever else that function pays cannot flatter or spoil the answer.
# The career best is then driven through a real extraction. A hundred thousand is
# used because it is far larger than anything a raid produces by accident, so a
# number that moves can only have come from the staging.
SubRx @'
  {v:'12.68',what:'answering the hire bench question leaves him at the bench: pressing Hire nobody and then either answer puts the bench back on screen, and the HIRED pill is cleared where it can be seen, while a card raised by nothing still closes onto the floor (2026-09-08 audit, my defect from v8.17)',
'@ @'
  {v:'12.69',what:'the XP a run pays for its haul counts what it brought back and not what the lift carried up, and the career best does the same, while a haul actually found in the raid pays exactly what it always did (2026-09-08 audit, the other side of v12.65)',
   run:function(){
     if(!(window.__P&&window.__state&&window.__deploy&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof spForRun!=='function') return 'SKIP: this build has no run XP to read';
     var bad=[], P2=__P(), keepBest=P2.best, keepXp=P2.xp, keepLog=(P2.log||[]).slice();
     var BIG=100000, WANT=Math.round((BIG/1000)*35);
     function rec(carried){
       return {outcome:'extract',haul:BIG,carriedIn:carried,kills:{},containers:0,termPay:0,
               secs:100,downs:0,revives:0,spotted:0,notExt:0};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       // THE FINDING, as a difference: two runs identical but for where the value
       // came from. Only the found one may pay for it.
       var carriedUp=spForRun(rec(BIG)), foundThere=spForRun(rec(0));
       if(typeof carriedUp!=='number'||typeof foundThere!=='number') return 'SKIP: the run XP did not come back as a number';
       if(foundThere-carriedUp!==WANT)
         bad.push('a run that carried '+BIG+' up the lift and brought the same '+BIG+' back was paid within '+(foundThere-carriedUp)+' XP of one that actually found it, against the '+WANT+' that value is worth: the whole reward track can be walked by riding his own stash up and down');
       // AND THE CAREER BEST, through a real extraction.
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid to extract from';
       var pick=null, k;
       for(k in ITEMS){ if(ITEMS[k]&&ival(k)>=200){ pick=k; break; } }
       if(pick){
         P2.best=0;
         g.bag=[pick]; g.carriedIn=ival(pick);
         g.player.downed=false; g.player.hp=100;
         __endRaid('extract');
         if((P2.best||0)>0)
           bad.push('the career best recorded '+(P2.best||0)+' for a raid whose entire bag came up the lift with him, so the best haul figure and every measurement I read off the run log count value that was never looted');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.best=keepBest; P2.xp=keepXp; P2.log=keepLog; saveProfile(); }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.68',what:'answering the hire bench question leaves him at the bench: pressing Hire nobody and then either answer puts the bench back on screen, and the HIRED pill is cleared where it can be seen, while a card raised by nothing still closes onto the floor (2026-09-08 audit, my defect from v8.17)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

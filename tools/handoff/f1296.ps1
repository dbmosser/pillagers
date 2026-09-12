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

# v12.96 CHECK, inserted before the v12.95 entry.
#
# THREE RUNS THAT SEPARATE THE TWO ACTS: one clean run with three pillagers picked
# up, one where he actually stood up and picked nobody up, and one with both. Only
# the middle case is ambiguous under the old rule, and only the third distinguishes
# "subtract the pickups" from "ignore the counter entirely".
#
# IT ASSERTS THE CARD AND THE REPORT AGREE, because the same conflated number went
# into the file a friend sends to Daniel, and a fix to one of them would leave the
# two documents disagreeing about the same raid.
#
# THE CONTROL IS THE SECOND RUN: a build that simply printed zero would pass every
# other arm here.
SubRx @'
  {v:'12.95',what:'the Undercroft pause box owns the keyboard
'@ @'
  {v:'12.96',what:'the career card counts times he got back up and not pillagers he picked up: three pickups on a clean run read as none, a real stand-up still reads as one, a run with both counts only the stand-up, and the report he is sent carries the same number as the card (audit finding 12, 2026-09-11)',
   run:function(){
     if(typeof statSummary!=='function') return 'SKIP: this fixture cannot summarise the run log';
     if(!window.__P) return 'SKIP: this fixture cannot reach the profile';
     var bad=[], P2=__P(), keepLog=(P2.log||[]).slice();
     function run(o){
       return {n:o.n,outcome:'extract',ver:'1.00',preset:'std',weapon:'Fists',dur:30,haul:100,
               containers:1,shots:0,hits:0,heals:0,kills:{sentry:0,crawler:0,raider:0,snitch:0},
               downs:o.downs,revives:o.revives,raiderRevives:o.picked,tags:[],note:''};
     }
     try{
       // A CLEAN RUN WITH THREE PILLAGERS PICKED UP. He never went down.
       var clean=[run({n:1,downs:0,revives:3,picked:3})];
       var a=statSummary(clean);
       if(a.downs!==0)
         bad.push('control: the run planted as a clean one is summarised as '+a.downs+' downs, so this check is reading something other than the run it planted');
       if(a.revives!==0)
         bad.push('a raid he walked through without going down once says he got back up '+a.revives+' times, because reviving a downed pillager is counted as him standing up: the card prints Went down 0 with that number directly underneath it');
       // A REAL STAND-UP AND NOBODY PICKED UP. This is the control: a build that
       // simply printed zero would pass every other arm.
       var stood=[run({n:1,downs:1,revives:1,picked:0})];
       var b=statSummary(stood);
       if(b.revives!==1)
         bad.push('control: a raid where he went down and got back up once now says '+b.revives+', so the count has been zeroed rather than corrected');
       // BOTH IN ONE RAID: he stood up once and picked up one pillager.
       var both=[run({n:1,downs:1,revives:2,picked:1})];
       var c=statSummary(both);
       if(c.revives!==1)
         bad.push('a raid where he got back up once and picked up one pillager counts '+c.revives+' stand-ups rather than 1');
       // THE REPORT HE IS SENT MUST AGREE WITH THE CARD, or two documents describe
       // the same raid differently.
       if(typeof buildExport==='function'){
         P2.log=clean.slice();
         var rep=''; try{ rep=buildExport()||''; }catch(_x){}
         var m=/\brev:(\d+)/.exec(rep);
         if(!m) bad.push('control: the run report no longer carries a stand-up count at all, so the card and the report cannot be compared');
         else if(+m[1]!==0)
           bad.push('the report he sends says rev:'+m[1]+' for a raid he walked through without going down, so the file a friend copies out disagrees with the card on the same raid');
         P2.log=stood.slice();
         var rep2=''; try{ rep2=buildExport()||''; }catch(_y){}
         var m2=/\brev:(\d+)/.exec(rep2);
         if(m2&&+m2[1]!==1)
           bad.push('control: the report says rev:'+m2[1]+' for a raid where he really did get back up once');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.log=keepLog; saveProfile(); }catch(_p){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.95',what:'the Undercroft pause box owns the keyboard
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

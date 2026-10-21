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

if ($s.Contains("  {v:'33.18',what:")) { throw "check 33.18 is in the fixture already" }

SubRx @'
  {v:'33.17',what:
'@ @'
  {v:'33.18',what:'the daily raid: one date gives one seed, another date another, the row arms only the next raid, a normal raid still rolls its own seed, and the best haul is kept in new profile fields',
   run:function(){
     if(typeof dailyArm!=='function'||typeof dailySeedOf!=='function'||typeof dailyRecord!=='function') return 'no daily raid code in this build';
     var s1, s2, k, t, r, g, sv=pendSeed, svP=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       svP=P.dailyRec;
       pendSeed=null; DAILY.on=1; k=dailyArm(); s1=pendSeed;
       pendSeed=null; DAILY.on=1; dailyArm(); s2=pendSeed;
       if(!k||!s1||s1!==s2) return 'two starts of today got seeds '+s1+' and '+s2;
       if(dailySeedOf(dailyKey(Date.now()+864e5))===s1) return 'tomorrow gave the same seed as today';
       if(dailySeedOf(dailyKey(Date.now()+864e5*2))===dailySeedOf(dailyKey(Date.now()+864e5))) return 'two other dates gave the same seed';
       pendSeed=null; DAILY.on=0;
       if(dailyArm()||pendSeed!==null) return 'a normal raid was given a seed with the daily row off';
       if(DAILY.on) return 'the daily flag stayed on after a raid started';
       P.dailyRec=null; t=dailyKey();
       dailyRecord(t,300); dailyRecord(t,120); r=P.dailyRec;
       if(!r||r.b!==300||r.t!==300) return 'daily best not kept: '+JSON.stringify(r);
       dailyRecord('1999-01-01',50); r=P.dailyRec;
       if(r.t!==50||r.b!==300) return 'a new day did not restart the day line or lost the best: '+JSON.stringify(r);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.seed!==4242) return 'a normal deploy lost its seed (got '+(g&&g.seed)+')';
       __endRaid('abandon');
       pendSeed=null; DAILY.on=1; startRaid(); g=__state();
       if(!g||g.seed!==s1) return 'the daily raid seed was '+(g&&g.seed)+', wanted '+s1;
       if(g.daily!==k) return 'the raid does not know it is the daily raid';
       return null;
     } finally {
       DAILY.on=0; pendSeed=sv; try{ P.dailyRec=svP; }catch(_e0){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'33.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

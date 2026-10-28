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

if ($s.Contains("  {v:'35.47',what:")) { throw "check 35.47 is in the fixture already" }

SubRx @'
  {v:'35.46',what:
'@ @'
  {v:'35.47',what:'cloud-ach-born-scan: a new save that plays two runs and then opens its stats page keeps its true kill counts: the one-time log scan is for saves from before live counting, so it never adds the same runs twice',
   run:function(){
     if(typeof achRun!=='function'||typeof achStatsDraw!=='function') return 'SKIP: this fixture has no achievements';
     var SRC='', sc=document.getElementsByTagName('script'), i;
     for(i=0;i<sc.length;i++) SRC+=(sc[i].textContent||'');
     var NEED='var '+'P='+'{'+'cre'+'dits:';
     var a=SRC.indexOf(NEED);
     if(a<0) return 'SKIP: the born profile is not in this page';
     var lo=a+NEED.indexOf('{'), hi=SRC.indexOf('}'+';',lo), born=null;
     if(hi<0) return 'SKIP: the born profile has no end in this page';
     try{ born=(new Function('return '+SRC.slice(lo,hi+1)))(); }catch(_b){ born=null; }
     if(!born||typeof born.credits!=='number') return 'SKIP: the born profile did not read back as a profile';
     var keep=P, bad=[], r, rec;
     try{
       P=born; P.log=[]; P.ach={}; P.achN={};
       for(r=0;r<2;r++){ rec={kills:{raider:7,crawler:30},dmg:{},outcome:'died',haul:0,downs:0}; P.log.push(rec); achRun(rec,true); }
       if((P.achN.raider|0)!==14) return 'SKIP: two live runs did not count 14 pillager kills (counted '+(P.achN.raider|0)+')';
       achStatsDraw(document.createElement('div'));
       if((P.achN.raider|0)!==14) bad.push('opening the stats page turned 14 pillager kills into '+(P.achN.raider|0));
       if((P.achN.mach|0)!==60) bad.push('opening the stats page turned 60 machine kills into '+(P.achN.mach|0));
       if(P.ach.pill25) bad.push('the 25 pillager kill medal unlocked at 14 kills');
       achStatsDraw(document.createElement('div'));
       if((P.achN.raider|0)!==14) bad.push('a second look at the stats page moved the count to '+(P.achN.raider|0));
     } finally { P=keep; try{ saveProfile(); }catch(_s){} }
     return bad.length?bad.join('; '):null;
   }},
  {v:'35.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

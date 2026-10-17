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

if ($s.Contains("  {v:'28.80',what:")) { throw "check 28.80 is in the fixture already" }

SubRx @'
  {v:'28.79',what:
'@ @'
  {v:'28.80',what:'guns come up at half the old rate in locker, safe, body, jackpot and cache loot rolls, and the loot table totals are unchanged (his order: fewer guns in loot)',
   run:function(){
     var tabs=['locker','safe','body','jackpot','cache'], oldTot={locker:111,safe:117,body:101,jackpot:104,cache:142};
     var N=20000, guns=0, tot=0, i, j, k, rate, old, sv=RNGS, s;
     // the old per-table gun share (weights before this change): 6/111, 19/117, 8/101, 14/104, 33/142
     old=(6/111+19/117+8/101+14/104+33/142)/5;
     try{
       RNGS=0x1234567;
       for(i=0;i<tabs.length;i++){
         if(!LOOT[tabs[i]]) return 'no LOOT.'+tabs[i];
         s=0; for(j=0;j<LOOT[tabs[i]].length;j++) s+=LOOT[tabs[i]][j][1];
         if(Math.abs(s-oldTot[tabs[i]])>0.001) return 'LOOT.'+tabs[i]+' total weight is '+s+', was '+oldTot[tabs[i]]+' (it moves the seeded stream)';
         for(j=0;j<N;j++){ k=rollTable(LOOT[tabs[i]]); tot++; if(String(k).indexOf('gun_')===0) guns++; }
       }
     } finally { RNGS=sv; }
     rate=guns/tot;
     if(rate>old*0.58) return 'guns come up '+(rate*100).toFixed(2)+'% of rolls, old rate '+(old*100).toFixed(2)+'%: not about half';
     if(rate<old*0.42) return 'guns come up '+(rate*100).toFixed(2)+'% of rolls, too rare against the old '+(old*100).toFixed(2)+'%';
     return null;
   }},
  {v:'28.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

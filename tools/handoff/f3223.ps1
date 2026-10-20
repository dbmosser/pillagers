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

if ($s.Contains("  {v:'32.23',what:")) { throw "check 32.23 is in the fixture already" }

SubRx @'
  {v:'32.22',what:
'@ @'
  {v:'32.23',what:'career offers the easy card after three deaths in a row, once, and yes cuts damage 30 percent (his 2.90 b)',
   run:function(){
     if(typeof easyCareerAsk!=='function') return 'no easyCareerAsk';
     var on0=ARCADE.on, ea0=ARCADE.easyAsk, dr0=P.dieRun, g0=G, d0=CFG.eDmg, g={}, i, m;
     try{
       ARCADE.on=0; CFG.eDmg=1; ARCADE.easyAsk=null; P.dieRun=0;
       for(i=0;i<3;i++) easyCareerNote('dead');
       if(P.dieRun!==3) return 'deaths not counted: '+P.dieRun;
       if(!easyCareerAsk(g)||!g.carAsk||!ARCADE.easyAsk) return 'no card on the third death';
       if(P.dieRun!==0) return 'streak not reset after asking';
       if(easyCareerAsk({})) return 'asked again with no new deaths';
       P.dieRun=2; easyCareerNote('extract'); if(P.dieRun!==0) return 'extraction did not clear the streak';
       P.dieRun=3; CFG.eDmg=0.7; if(easyCareerAsk({})) return 'asked while Forgiving already on';
       CFG.eDmg=1; ARCADE.on=1; if(easyCareerAsk({})) return 'asked in the demo';
       ARCADE.on=0; P.dieRun=3; if(easyCareerAsk({sim:1})) return 'asked in a sim';
       G={carAsk:1,bag:[],over:0,sim:0,arcade:0}; ARCADE.easyAsk={at:Date.now()};
       if(!easyLive()) return 'card not live in a career raid';
       easyAnswer(true);
       if(!G.easyC) return 'yes did not set easy';
       m=easyDmgMul(); if(Math.abs(m-0.7)>1e-9) return 'damage x'+m;
       if(G.bag.indexOf('medkit')<0) return 'no free medkit';
       G.easyC=0; if(easyDmgMul()!==1) return 'no cut without a yes';
       return null;
     } finally { ARCADE.on=on0; ARCADE.easyAsk=ea0; P.dieRun=dr0; G=g0; CFG.eDmg=d0; } }},
  {v:'32.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

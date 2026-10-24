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

if ($s.Contains("  {v:'34.46',what:")) { throw "check 34.46 is in the fixture already" }

SubRx @'
  {v:'34.45',what:
'@ @'
  {v:'34.46',what:'the contract done line carries only the contract words, not the long turn in sentence (one row on screen, 109)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__P)||typeof contractKill!=='function'||typeof say!=='function') return 'SKIP: no contracts here';
     var P2=__P(), con0=P2.contracts, realSay=say, said=[], hit=null, i, c;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       c={type:'kill',tgt:'warden',n:1,prog:0,desc:'Destroy 1 Warden',reward:100,id:'zqx109'};
       P2.contracts=[c];
       say=function(m,k,o){ said.push({m:String(m),sub:(o&&o.sub)?String(o.sub):''}); return realSay.apply(this,arguments); };
       contractKill('warden');
       for(i=0;i<said.length;i++) if(said[i].m.indexOf('CONTRACT DONE')===0) hit=said[i];
       if(!hit) return 'SKIP: staging: the contract did not finish';
       if(/mainframe/i.test(hit.sub)) return 'the contract done detail still says '+JSON.stringify(hit.sub);
       return null;
     }catch(err){ return 'threw: '+(err&&err.message||err); }
     finally{ say=realSay; P2.contracts=con0; keys={}; try{ __endRaid('abandon'); }catch(e2){} } }},
  {v:'34.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

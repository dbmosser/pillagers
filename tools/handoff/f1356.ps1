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
  {v:'13.55',what:
'@ @'
  {v:'13.56',what:'a contract finished during the raid stays in the run log when he dies: the newest log row lists it, as it already does after an extraction (end-of-raid audit 2026-09-14, finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     var bad=[], P2=__P(), keepLog=(P2.log||[]).slice(), LABEL='kill-probe1356';
     function run(how){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.tel) return null;
       g.ents.length=0; g.player.downed=false;
       g.tel.contractsMid=[{desc:'contract staged by check 13.56',label:LABEL}];
       var n0=(P2.log||[]).length;
       __endRaid(how);
       try{ __topClear(); }catch(_t){}
       var L=P2.log||[];
       if(L.length<=n0) return {norow:1};
       var row=L[L.length-1];
       return {list:(row&&row.contractsBanked)||null};
     }
     try{
       var D=run('dead');
       if(D===null) return 'SKIP: no live raid to end';
       if(D.norow) return 'SKIP: ending a raid wrote no log row this check can read';
       if(!(D.list&&D.list.indexOf(LABEL)>=0)) bad.push('a contract finished during the raid is missing from the log row after a death (the row lists '+JSON.stringify(D.list)+'), while the card can still be claimed and paid at the Mainframe');
       // CONTROL: an extraction already lists it.
       var E=run('extract');
       if(E&&!E.norow&&!(E.list&&E.list.indexOf(LABEL)>=0)) bad.push('control: the extraction log row does not list the mid-raid contract either, so this check is not reading the right field');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.log=keepLog; saveProfile(); }catch(_l){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

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

if ($s.Contains("  {v:'17.64',what:")) { throw "check 17.64 is in the fixture already" }

SubRx @'
  {v:'17.63',what:
'@ @'
  {v:'17.64',what:'a teammate who joined a raid in progress is charged for the time he played: his abandon XP cost and run length count from when he joined, and a player who started the raid is charged as before',
   run:function(){
     if(typeof runElapsed!=='function') return 'a late teammate is charged for the minutes before he joined';
     if(typeof netLateApply!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: no drop-in or raid in this fixture';
     var bad=[], oSay=say, e0, e1;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       say=function(){};
       e0=runElapsed();
       if(Math.abs(e0-elapsed())>0.01) bad.push('a player who started the raid is charged '+e0.toFixed(1)+' s, not the '+elapsed().toFixed(1)+' s it ran');
       netLateApply({late:{t:600,left:Math.max(1,(G.raidLen===undefined?CFG.raidSec:G.raidLen)-600),x:Math.round(G.player.x),y:Math.round(G.player.y)},gone:[]});
       e1=runElapsed();
       if(!(e1<2)) bad.push('a teammate who just joined 600 s into the raid is charged '+e1.toFixed(1)+' s');
       if(!(abandonRepCost(e1)<=101)) bad.push('his abandon would cost '+abandonRepCost(e1)+' XP the moment he joined');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=oSay;
       try{ if(G) G.lateEl=0; __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

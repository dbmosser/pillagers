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

if ($s.Contains("  {v:'28.98',what:")) { throw "check 28.98 is in the fixture already" }

SubRx @'
  {v:'28.97',what:
'@ @'
  {v:'28.98',what:'an exploding red barrel leaves a fire that burns what stands in it over time and then burns out (his order: after the first explosion, also leave fire that deals damage over time)',
   run:function(){
     if(typeof brlFireAdd!=='function') return 'a barrel blast leaves no fire (no brlFireAdd)';
     var g=null, B, p, od=damagePlayer, calls=[], n0, n1, hp0;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       if(!g.brl||!g.brl.length) return 'SKIP: no barrel on this map';
       B=g.brl[0]; p=g.player; p.x=B.x+30; p.y=B.y;
       damagePlayer=function(a,s){ calls.push(String(s)); return od.apply(this,arguments); };
       brlBlast(B);
       if(!g.bfire||!g.bfire.length) return 'the blast left no fire';
       p.hp=Math.max(p.hp||0,100); p.downed=false; p.dying=false; p.x=B.x+20; p.y=B.y;
       n0=calls.filter(function(s){ return s==='fire'; }).length;
       brlTick(0.3); brlTick(0.3); brlTick(0.3);
       n1=calls.filter(function(s){ return s==='fire'; }).length;
       if(n1<=n0) return 'standing in the fire it never burned the player (fires '+g.bfire.length+', t '+(g.bfire[0]&&g.bfire[0].t)+', by '+(g.bfire[0]&&g.bfire[0].by)+', dying '+p.dying+', specOut '+p.specOut+', los '+losClear(B.x,B.y,p.x,p.y,g.map.segs)+', calls '+calls.join('/')+')';
       brlTick(30);
       if(g.bfire.length) return 'the fire never burns out';
       return null;
     } finally {
       damagePlayer=od;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'28.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

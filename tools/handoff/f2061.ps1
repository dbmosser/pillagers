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

if ($s.Contains("  {v:'20.61',what:")) { throw "check 20.61 is in the fixture already" }

SubRx @'
  {v:'20.60',what:
'@ @'
  {v:'20.61',what:'a frag charge that goes off in your hand hurts you even inside the two seconds of cover after a revive, as it already did inside a roll',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof cookOff!=='function'||typeof explodeFrag!=='function') return 'SKIP: no raid or frag charge in this fixture';
     var NK={}, k, bad=[], g=null, p, a, b;
     for(k in NET) NK[k]=NET[k];
     function own(){ return (g.tel&&g.tel.dmg&&g.tel.dmg.yourself)||0; }
     function blow(iv){ var d0=own(); p.hp=5000; p.downed=false; p.iv=iv; p.cooking=1; p.cookKind='frag'; p.cookT=1.23; cookOff(); return own()-d0; }
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.tel||!g.tel.dmg) return 'SKIP: no live raid';
       p=g.player;
       a=blow(0);
       if(!(a>0)) return 'SKIP: staging: a charge going off in the hand with no cover did no damage here ('+a+')';
       if((g.deathBeat!==undefined&&g.deathBeat!==null)||p.dying) return 'SKIP: staging: the first blast ended the run';
       b=blow(2);
       if(!(b>0)) bad.push('a charge that went off in your hand inside the cover after a revive did no damage to you, while the same blast without cover did '+Math.round(a));
       if(p.cooking||p.cookKind) bad.push('the charge was still in hand after it went off');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.hp=g2.player.maxhp||100; g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"

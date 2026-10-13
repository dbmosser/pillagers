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

if ($s.Contains("  {v:'24.76',what:")) { throw "check 24.76 is in the fixture already" }

SubRx @'
  {v:'24.75',what:
'@ @'
  {v:'24.76',what:'his answer 2026-10-12: a DEMO hit takes what the same hit takes in CAREER (no half damage)',
   run:function(){
     var bad=[], g, p, h0, norm=null, arc=null;
     try{
       __topClear(); __runPrep(); __resetCfg();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       p.iv=0; p.armor=0; p.downed=false; p.hp=100; h0=p.hp;
       damagePlayer(20,'sentry','T'); norm=h0-p.hp;
       p.iv=0; p.hp=100; __endRaid('abandon'); __topClear();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player;
       if(typeof arcadeShieldOff==='function') arcadeShieldOff();
       p.iv=0; p.armor=0; p.downed=false; p.hp=100; h0=p.hp;
       damagePlayer(20,'sentry','T'); arc=h0-p.hp;
       if(!(norm>0)) bad.push('a CAREER hit of 20 took '+norm);
       else if(Math.abs(arc-norm)>1e-6) bad.push('a DEMO hit of 20 took '+arc+', a CAREER hit took '+norm);
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; } }catch(_p){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
